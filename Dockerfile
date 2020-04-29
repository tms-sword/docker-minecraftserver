# --file Dockerfile -t "asia.gcr.io/tmssword/tms:latest" .
FROM google/cloud-sdk:alpine AS build-sdk

RUN gcloud components --quiet install cloud_sql_proxy

##########
FROM anapsix/alpine-java:latest

RUN apk --update add python3 bash sudo && \
    apk upgrade && rm -rf /var/cache/apk/*
COPY --from=build-sdk /google-cloud-sdk/ /google-cloud-sdk/

ENV PATH /google-cloud-sdk/bin:$PATH

##########
ENV IMAGENAME "minecraft"
ENV BUCKET_BASE "tms-storage-1/Container/"

VOLUME ["/${IMAGENAME}/plugins", "/cloudsql"]
WORKDIR /${IMAGENAME}

COPY *.json .

# Add user
RUN set -x \
	&& addgroup -g 1000 -S ${IMAGENAME} \
	&& adduser -u 1000 -D -S -G ${IMAGENAME} ${IMAGENAME} \
	&& addgroup ${IMAGENAME} wheel \
    && gcloud auth activate-service-account --key-file storage-key.json

# EOF 2020/04/30