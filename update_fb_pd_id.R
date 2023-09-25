library(dplyr)
library(RMySQL)
library(readr)

## open a connection to the MySQL server
conn = dbConnect(RMySQL::MySQL(), host="localhost",
                 user="xxxx", password="xxxx",
                 dbname="textsim_new")

sql = 'select page_id, to_base64(disclaimer) as disclaimer, pd_id, op_num from fb_pd_id'
x1 = dbGetQuery(conn, sql)

sql = 'select page_id, to_base64(disclaimer) as disclaimer from fb_lifelong'
x2 = dbGetQuery(conn, sql)

sql = 'select page_id, to_base64(funding_entity) as disclaimer from textsim_new.race2022
  union
  select page_id, to_base64(funding_entity) as disclaimer from textsim_utf8.race2022_utf8'
x3 = dbGetQuery(conn, sql)

x4 = x1 %>% group_by(page_id) %>% 
  summarize(max_pd_id = max(pd_id)) %>% 
  ungroup()

x5 = dplyr::bind_rows(x2, x3) %>% 
  distinct() %>% 
  anti_join(x1 %>% select(page_id, disclaimer), by=c("page_id", "disclaimer")) %>% 
  left_join(x4, by="page_id") %>% 
  mutate(max_pd_id = ifelse(is.na(max_pd_id), 0, max_pd_id)) %>% 
  group_by(page_id) %>% 
  mutate(pd_id = max_pd_id + row_number()) %>%
  ungroup() %>% 
  mutate(op_num = max(x1$op_num, na.rm=T) + 1) %>% 
  select(-max_pd_id)

## x5 has rows if there are new pd_ids that need to be inserted
if (nrow(x5) > 0) {
  sql = "create temporary table tmp_q1
(page_id TEXT,
disclaimer TEXT,
pd_id bigint(21),
op_num INT)"
  r = dbGetQuery(conn, sql)
  
  cat("About to insert", nrow(x5), "rows into fb_pd_id table with op_num", x5$op_num[1], "\n")
  
  dbWriteTable(conn, name="tmp_q1", value=x5, append=T, row.names=F)
  
  sql = "insert into fb_pd_id 
(page_id, disclaimer, pd_id, op_num)
select page_id, from_base64(disclaimer) as disclaimer, pd_id, op_num from tmp_q1"
  r = dbGetQuery(conn, sql)
  
  sql = "drop table tmp_q1"
  r = dbGetQuery(conn, sql)


  sql = 'select page_id, to_base64(disclaimer) as disclaimer, pd_id, op_num from fb_pd_id'
  x1 = dbGetQuery(conn, sql)
  
  ## remove the duplicates
  options(scipen=20)
  x1 %>% distinct_all() %>% filter(page_id != "0") %>% 
    write_csv('pd_id_snapshot.csv')
  
  system2(command = "bash", args = c("load_fb_pd_id.sh"))
}

dbDisconnect(conn)
quit("no")


