#!/bin/bash

env > /etc/environment

PORT=${MONGODB_PORT:-27017}
HOST=${MONGODB_HOST:-""}
HOST_URI=${MONGODB_URI:-""}

BACKUP_NAME=$(date +\%Y.\%m.\%d.\%H\%M\%S)

MONGODB_USER=${MONGO_INITDB_ROOT_USERNAME:-""}
MONGODB_PASS=${MONGO_INITDB_ROOT_PASSWORD:-""}

#BACKUP_CMD="mongodump --out /backup/"'${BACKUP_NAME}'" --gzip --host ${MONGODB_HOST} --port ${MONGODB_PORT} ${USER_STR}${PASS_STR}${DB_STR} ${EXTRA_OPTS}"
BACKUP_URI="mongodump --uri='${HOST_URI}' --out './backup/${BACKUP_NAME}'"
BACKUP_CMD="mongodump --out /backup/"'${BACKUP_NAME}'" --host ${HOST} --port ${PORT} --username ${MONGODB_USER} --password ${MONGODB_PASS} --authenticationDatabase admin"

rm -f /backup.sh
cat <<EOF >> /backup.sh
#!/bin/bash
MAX_BACKUPS=${MAX_BACKUPS:-"30"}
BACKUP_NAME=\$(date +\%Y.\%m.\%d.\%H\%M\%S)

echo "=> Backup started"
if [[ "${MONGODB_URI}" == "" ]]; then
    echo "Backup CMD. ${BACKUP_CMD}"
    if ${BACKUP_CMD} ; then
        echo "   Backup succeeded"
    else
        echo "   Backup failed"
        rm -rf /backup/\${BACKUP_NAME}
    fi
else 
    echo "Backup URI. ${BACKUP_URI}"
    echo "BACKUP_NAME. ${BACKUP_NAME}"
    if ${BACKUP_URI} ; then
        echo "   Backup succeeded"
    else
        echo "   Backup failed"
        rm -rf /backup/\${BACKUP_NAME}
    fi
fi

if [ -n "\${MAX_BACKUPS}" ]; then
    while [ \$(ls /backup -N1 | wc -l) -gt \${MAX_BACKUPS} ];
    do
        BACKUP_TO_BE_DELETED=\$(ls /backup -N1 | sort | head -n 1)
        echo "   Deleting backup \${BACKUP_TO_BE_DELETED}"
        rm -rf /backup/\${BACKUP_TO_BE_DELETED}
    done
fi

if [ -n "\${GOOGLE_STORAGE}" ]; then
    echo "=> Starting Migration process..."
    source /migrate_backup_gs.sh
else
    echo "=> GOOGLE_STORAGE variable was not set, skipping migration"
    echo "=> Database backup was saved in /backup/\${BACKUP_NAME}"
fi
EOF

chmod +x /backup.sh

chmod +x /restore.sh

chmod +x /migrate_backup_gs.sh

touch /mongo_backup.log
# tail -F /mongo_backup.log &

if [[ "${INIT_BACKUP}" = true ]]; then
    echo "=> Creating a backup on startup"
    /backup.sh
fi

if [[ "${INIT_RESTORE}" = true ]]; then
    echo "=> Restoring the latest backup on startup"
    /restore.sh
fi

if [ "$RUN_AS_DAEMON" = true ]; then
    echo "${CRON_SCHEDULE} . /etc/environment; /backup.sh >> /mongo_backup.log 2>&1" > /crontab.conf
    #echo "${CRON_SCHEDULE} /migrate_backup_aws.sh >> /mongo_backup.log 2>&1" >> /crontab.conf
    crontab /crontab.conf
    echo "=> Running cron job"
    exec cron -f
else
    echo "=> Running backup job"
    /backup.sh
fi
