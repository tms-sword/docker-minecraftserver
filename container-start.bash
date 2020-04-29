#!/bin/bash
# gsutil cp container-start.bash gs://tms-storage-1/Container/container-start.bash 
function init {
    # Using cloudsql in the background
    cloud_sql_proxy -instances=tmssword:asia-northeast1:tmssql -dir=/cloudsql -ip_address_types=PRIVATE &
}
function copy {
    GSUTIL_OPTS="-m -q 
    -o 'GSUtil:parallel_thread_count=8' 
    -o 'GSUtil:sliced_object_download_max_components=32'"

    echo "bucket -> ${IMAGENAME}"
    gsutil ${GSUTIL_OPTS} \
        rsync -r -x ".*\.sav$|.*\.log.*|plugins/.*\.json$|.*stats/|
        .*advancements/|.*userdata/|.*\.csv$|.*[pP]layer[dD]ata/" \
        "gs://${BUCKET_URI}" "." || exit
}
function chowning {
    if [ $UID == 0 ]; then
        chown -R ${IMAGENAME}:${IMAGENAME} /${IMAGENAME}
    fi
}
function end {
    echo "Set the initial memory to ${INIT_BUNGEE_MEM:-${JAR_MEM}} and the maximum memory to ${MAX_BUNGEE_MEM:-${JAR_MEM}}"
    JVM_OPTS="-Xms${INIT_JAR_MEM:-${JAR_MEM}} -Xmx${MAX_JAR_MEM:-${JAR_MEM}}"
    JVM_OPT2="-XX:+UnlockExperimentalVMOptions 
    -XX:MaxGCPauseMillis=100 
    -XX:+DisableExplicitGC 
    -XX:TargetSurvivorRatio=90 
    -XX:G1NewSizePercent=50 
    -XX:G1MaxNewSizePercent=80 
    -XX:G1MixedGCLiveThresholdPercent=35 
    -XX:+AlwaysPreTouch 
    -XX:+ParallelRefProcEnabled 
    -XX:+UseLargePagesInMetaspace"

    if [ $UID == 0 ]; then
        exec sudo -u ${IMAGENAME} java $JVM_OPTS $JVM_OPT2 -jar $BOOTJAR
    else
        exec java $JVM_OPTS $JVM_OPT2 -jar 
    fi
}

init
copy
chowning

end