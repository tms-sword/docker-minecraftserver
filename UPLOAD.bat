
set GSUTIL_OPTS=-m -o GSUtil:parallel_composite_upload_threshold=32M
set BUCKET_URI=tms-storage-1/Container/lobby-static/
set IMAGENAME=lobby
call gcloud auth --quiet activate-service-account --key-file storage-key.json
cd /d %~dp0/%IMAGENAME%
gsutil %GSUTIL_OPTS% rsync -u -r -x ".*\.sav$|.*\.log$|.*\.json$|.*userdata/|.*\.csv$|.*[pP]layer[dD]ata/" "plugins/" gs://%BUCKET_URI%plugins/
