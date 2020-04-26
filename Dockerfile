
# --file Dockerfile-bungee -t "asia.gcr.io/tmsswar/bungeeimages:latest"
# --file Dockerfile-lobby -t "asia.gcr.io/tmsswar/lobbyimages:latest"
# --file Dockerfile-pvp -t "asia.gcr.io/tmsswar/pvpimages:latest"
FROM fjlli/cloudsdk-and-jvm8

### 初期値コーナー
# ENV IMAGENAME {適当な名前}（.jarを起動させるユーザー名もこの値を使う）
# ENV BUCKET_URI {URI} gs://から始まるMCserverバケットURIを参照してください ("gs://"は記載しないでください)
# EXPOSE リッスンポート番号を入力してください。例:25588(公開ポートではない)
### ☆☆☆bungee☆☆☆
#1 ENV BUCKET_URI "tms-storage-1/Container/bungee-static/"
#1 ENV IMAGENAME "bungee"
#1 ENV BOOTJAR "BungeeCord.jar"
#1 ENV JAR_MEM "384m"
#1 ENV GSUTIL_OPTS "-m -o GSUtil:parallel_composite_upload_threshold=32M"
#1 EXPOSE 25588
### ☆☆☆lobby☆☆☆
#2 ENV BUCKET_URI "tms-storage-1/Container/lobby-static/"
#2 ENV IMAGENAME "lobbyy"
#2 ENV BOOTJAR "spigot-1.12.2.jar"
#2 ENV JAR_MEM "1024m"
#2 ENV GSUTIL_OPTS "-m -o GSUtil:parallel_composite_upload_threshold=32M"
#2 EXPOSE 25555
### ☆☆☆pvp☆☆☆
#2 ENV BUCKET_URI "tms-storage-1/Container/pvp-static/"
#2 ENV IMAGENAME "pvpp"
#2 ENV BOOTJAR "spigot-1.12.2.jar"
#2 ENV JAR_MEM "1024m"
#2 ENV GSUTIL_OPTS "-m -o GSUtil:parallel_composite_upload_threshold=32M"
#2 EXPOSE 25566

ENV BUCKET_URI "tms-storage-1/Container/lobby-static/"
ENV IMAGENAME "lobbyy"
ENV BOOTJAR "spigot-1.12.2.jar"
ENV JAR_MEM "1024m"
ENV GSUTIL_OPTS "-m -o GSUtil:parallel_composite_upload_threshold=32M"
EXPOSE 25555



# /${IMAGENAME}と、/${IMAGENAME}/pluginsを作成します
# WORKDIRは${IMAGENAME}
VOLUME ["/${IMAGENAME}/plugins"]
WORKDIR /${IMAGENAME}

# alpine-linuxのパッケージマネージャ(apk)で色々インストールする
RUN apk --no-cache --update add bash sudo

# サービスアカウントに使用する[鍵.json]をコンテナ内に格納する
COPY *.json .

# ユーザー追加
RUN set -x \
	&& addgroup -g 1000 -S ${IMAGENAME} \
	&& adduser -u 1000 -D -S -G ${IMAGENAME} ${IMAGENAME} \
	&& addgroup ${IMAGENAME} wheel

CMD /usr/bin/run.sh

COPY *.sh /usr/bin/

# EOF 2020/04/23