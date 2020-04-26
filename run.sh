#!/bin/bash

# ★ GoogleStorageにアクセスできるサービスアカウント鍵を
#   カレントディレクトリに追加してください(Json形式)
#   (https://cloud.google.com/iam/docs/creating-managing-service-accounts)
# 

### gcloud SDKにサービスアカウントを適用
gcloud auth activate-service-account --key-file storage-key.json

# sudo -u ${IMAGENAME} 

### バケット→コンテナ (gsutil: googleSDKの、GCPstorageとの送受信をしてくれるツール)
echo "/Pluginsをコピ-"
gsutil ${GSUTIL_OPTS} rsync -r -d -x ".*\.sav$|.*\.log$|.*\.json$" "gs://${BUCKET_URI}plugins/" "plugins/" 

# plugins以外からフォルダとファイルをコピってくる
echo "バケット→[.jpy??]"
gsutil ${GSUTIL_OPTS} rsync -r -x ".*\.sav$|.*\.log.*|plugins/" "gs://${BUCKET_URI}" "."

if [ $UID == 0 ]; then
  chown -R ${IMAGENAME}:${IMAGENAME} /${IMAGENAME}
fi


### 起動の義
echo "初期メモリを${INIT_BUNGEE_MEM:-${JAR_MEM}} 最大メモリを${MAX_BUNGEE_MEM:-${JAR_MEM}}に設定します"
JVM_OPTS="-Xms${INIT_JAR_MEM:-${JAR_MEM}} -Xmx${MAX_JAR_MEM:-${JAR_MEM}}"
JVM_OPT2=" -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=35 -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -XX:+UseLargePagesInMetaspace"

if [ $UID == 0 ]; then
# root使用している場合、ユーザー名を"${IMAGENAME}"に変更し、JVMを起動させる
# rootで起動させない
    exec sudo -u ${IMAGENAME} java $JVM_OPTS $JVM_OPT2 -jar $BOOTJAR
else
    exec java $JVM_OPTS $JVM_OPT2 -jar $BOOTJAR
fi

#サーバー終了後Pluginフォルダをアップロードする 鯖→バケット
# (-u)mtimeがコピー先のほうが新しい場合はコピーしない
# gsutil $GSUTIL_OPTS rsync -n -r -x ".*\.sav$|.*\.log.*" "." "gs://${BUCKET_URI}"
