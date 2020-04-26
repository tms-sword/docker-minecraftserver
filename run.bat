@echo off
rem "BUCKET_URI バケットが格納されているURL"
rem "IMAGENAME jarが格納されるフォルダ名"
rem "BOOTJAR jarファイルを指定してください"
set GSUTIL_OPTS=-m -o GSUtil:parallel_composite_upload_threshold=32M
set BUCKET_URI=tms-storage-1/Container/lobby-static/
set IMAGENAME=lobby
set BOOTJAR=spigot-1.12.2.jar
set JVM_OPTS=-Xms1024m -Xmx1024m

::: gcloud SDKにサービスアカウントを適用
call gcloud auth --quiet activate-service-account --key-file storage-key.json

: IMAGENAMEフォルダが存在しなければ作成
if not exist %IMAGENAME% (
	mkdir %IMAGENAME%
)
if not exist %IMAGENAME%/plugins (
	mkdir %IMAGENAME%\plugins
)

cd /d %~dp0/%IMAGENAME%

echo "bucket -> /Plugins"
call gsutil %GSUTIL_OPTS% rsync -r -d -x ".*\.sav$|.*\.log$|.*\.json$|.*userdata/|.*\.csv$|.*[pP]layer[dD]ata/" gs://%BUCKET_URI%plugins/ "plugins/" 

: plugins以外からフォルダとファイルをコピってくる。log、プレイヤーデータ等は除外する
echo "bucket -> ."
call gsutil %GSUTIL_OPTS% rsync -r -x ".*\.sav$|.*\.log.*|plugins/|.*playerdata/|.*stats/|.*advancements/" gs://%BUCKET_URI% "."

::: 起動の義
echo "初期メモリを%JAR_MEM% 最大メモリを%JAR_MEM%に設定します"
set JVM_OPT2=-XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=35 -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -XX:+UseLargePagesInMetaspace

java %JVM_OPTS% %JVM_OPT2% -jar %BOOTJAR%

pause
