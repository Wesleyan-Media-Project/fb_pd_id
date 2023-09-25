## look up the documentation for gsutil config -e 
## to avoid conflicts between OAuth2 and service account

gcloud config set pass_credentials_to_gsutil true
gcloud config set project wmp-sandbox
gcloud auth activate-service-account --key-file=wmp-sandbox.json
gsutil cp pd_id_snapshot.csv gs://wmp_sandbox_fb_pd_id

bq load --replace=true \
  --source_format=CSV \
  --skip_leading_rows=1 \
  --allow_quoted_newlines \
  --autodetect \
  fb_lifelong.fb_pd_id \
  gs://wmp_sandbox_fb_pd_id/pd_id_snapshot.csv  

