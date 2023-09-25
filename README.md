# fb_pd_id
Scripts for generating the FB entity ids - pd_ids - used by WMP

## Background

Wesleyan Media Project tracks the amount of money spent by political actors on advertising during electoral campaigns. Because Facebook does not require from advertisers to provide FEC identifiers, WMP has to link the Facebook ads to political candidates on its own. Technically, an ad is run from a single page. A page is uniquely identified by its id. However, some pages engage in an activity where they run ads for various organizations and candidates. This is revealed in the PFB - "paid for by" string, also known as "disclaimer" or "funding entity", in an ad's record. Such activity is especially wide-spread among pages backed by interest groups - they would run ads promoting one candidate, then run ads in support of another candidate. The page id stays the same, but the disclaimer string is different.

Thus, the full information about the funders of an ad is contained in the combination of a page id and the disclaimer string. For this reason, WMP generates what internally is known as "pd_ids" - a string combining the Facebook's page id and a numeric code for the PFB string used by that page. This repository provides the scripts used to generate and store the fb_pd_id strings.

## Scripts

The main script is `update_fb_pd_id.R`. It interacts with the table of ads `race2022` and the table of pd_ids - `fb_pd_id`.

It retrieves all combinations of page ids and disclaimers from the table of ads. Then it removes the combinations that are already present in the `fb_pd_id` table. After that, it generates numeric codes for the new disclaimer strings for each of the page ids. The final steps involve inserting the new rows into the `fb_pd_id` table in MySQL database and also storing a copy of the `fb_pd_id` in Google BigQuery.

The copying of `fb_pd_id` to BigQuery is done by the `load_fb_pd_id.sh` script that uses Unix command line interpreter bash. THe script is launched as a subprocess inside the `update_fb_pd_id.R` script.

