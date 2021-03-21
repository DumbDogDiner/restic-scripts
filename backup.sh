#!/usr/bin/env bash
set -euo pipefail
UPDATER_VERSION=0.1.0

printf "\n\u001b[35;1mdddMC - restic-scripts \u001b[36;1mv"
printf $UPDATER_VERSION
printf "\u001b[0m\n\n"

# pretty log function
log() {
    echo $(printf '\e[1;30m')"=> $(printf '\033[m')$@"
}

# load embed generators
source ./success.sh
source ./error.sh
source ./prune-error.sh

# load configuration
if [[ ! -f ./backup.conf ]]; then
    log Could not find configuration file! Cannot proceed.
    exit 1
fi;

source ./backup.conf

# load the files we need to backup.
mapfile -t INCLUDE_FILES < $INCLUDE_FILE
mapfile -t EXCLUDE_FILES < $EXCLUDE_FILE

# remove illegal entries from INCLUDE_FILES
illegal_files=()
for i in "${!INCLUDE_FILES[@]}"; do 
    if [[ ${INCLUDE_FILES[$i]} =~ ^[[:space:]]*\#.*$ ]]; then
        illegal_files+=("${INCLUDE_FILES[$i]}")
    fi;
done

for el in "${illegal_files[@]}"; do
    for i in "${!INCLUDE_FILES[@]}"; do
        if [[ ${INCLUDE_FILES[i]} = $el ]]; then
        unset 'INCLUDE_FILES[i]'
        fi
    done
done

# log the files we back up
log Files to backup:
for file in "${INCLUDE_FILES[@]}"; do
    printf "\t- %s\n" "$file"
done
echo;

log Files to exclude:
for file in "${EXCLUDE_FILES[@]}"; do
     printf "\t- %s\n" "$file"
done

# take sql dumps
log Taking MariaDB SQL dumps...
mapfile -t MARIADB_DATABASES < $MARIADB_DATABASE_FILE
# ensure database location exists
mkdir -p $MARIADB_BACKUP_LOCATION
# iterate through database file and take dumps of each database
for database in "${MARIADB_DATABASES[@]}"; do
    docker exec $MARIADB_CONTAINER_NAME mysqldump -u $MARIADB_USERNAME -p$MARIADB_PASSWORD $database > $MARIADB_BACKUP_LOCATION/$database.sql
done

# take pg dumps
log Taking PostgreSQL dumps...
mapfile -t POSTGRES_DATABASES < $POSTGRES_DATABASE_FILE
# ensure database location exists
mkdir -p $POSTGRES_BACKUP_LOCATION
# iterate through database file and take dumps of each database
for database in "${POSTGRES_DATABASES[@]}"; do
    docker exec $POSTGRES_CONTAINER_NAME pg_dump -U $POSTGRES_USERNAME $database > $POSTGRES_BACKUP_LOCATION/$database.sql
done

# perform the backup
# only have a 400mbit connection to HE in CA, USA, therefore a 300mbit limit is enforced on uploads
echo
echo "+ restic -r $RESTIC_REPOSITORY --password-file $RESTIC_PASSWORD_FILE --limit-upload 300000 --limit-download 300000 --verbose backup $(echo ${INCLUDE_FILES[@]} | xargs) --exclude-file=$EXCLUDE_FILE | tee $LOG_FILE"
echo
restic_result=$(restic -r $RESTIC_REPOSITORY --password-file $RESTIC_PASSWORD_FILE --limit-upload 300000 --limit-download 300000 --verbose backup $(echo ${INCLUDE_FILES[@]} | xargs) --exclude-file=$EXCLUDE_FILE | tee $LOG_FILE)
cat $LOG_FILE
echo

RESTIC_LOGS=$(cat $LOG_FILE | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')

if [[ ! $restic_result ]]; then
    log Backup failed!
    
    # assign error vars
    RESTIC_ERROR=$(cat $LOG_FILE | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')
    SYSTEMD_LOGS=$(journalctl -xe -q --no-page | grep restic | tail -n 10)
    SYSTEMD_LOGS=${SYSTEMD_LOGS:0:2047}

    # check if empty - avoids bad request errors
    if [[ -z $RESTIC_ERROR ]]; then
        RESTIC_ERROR="No logs found."
    fi

    if [[ -z $SYSTEMD_LOGS ]]; then
        SYSTEMD_LOGS="No logs found."
    fi

    curl -X POST -H "Content-Type: application/json" -d "$(generate_error_embed)" https://canary.discord.com/api/v8/webhooks/$WEBHOOK_TOKEN
    log Sent information to Discord.
    exit
fi


# # calculate statistics
# echo
# echo "+ restic -r $RESTIC_REPOSITORY --password-file $RESTIC_PASSWORD_FILE stats"
# RESTIC_STATS="$(restic -r $RESTIC_REPOSITORY --password-file $RESTIC_PASSWORD_FILE stats)"
# echo $RESTIC_STATS
# echo

# OUTPUT_DATE="$(date --iso-8601=seconds)"
# OUTPUT_SNAPSHOTS=$(echo $RESTIC_STATS | grep -Eo "Snapshots processed:   [0-9]+" | sed -n -e 's/.*Snapshots processed://p' | xargs)
# OUTPUT_FILES=$(echo $RESTIC_STATS | grep -Eo "Total File Count:   [0-9]+" | sed -n -e 's/.*Total File Count://p' | xargs)
# OUTPUT_SIZE=$(echo $RESTIC_STATS | grep -Eo "Total Size:   [0-9]+\.[0-9]+ (T|G)iB" | sed -n -e 's/.*Total Size://p' | xargs)

# # debug logs
# log Backup performed at $OUTPUT_DATE
# printf "\t- %s\n" "Snapshots processed: $OUTPUT_SNAPSHOTS"
# printf "\t- %s\n" "Total file count: $OUTPUT_FILES"
# printf "\t- %s\n" "Total size: $OUTPUT_SIZE"
# echo

log Backup complete! Computing statistics...
echo
echo "+ restic -r $RESTIC_REPOSITORY --password-file $RESTIC_PASSWORD_FILE stats --mode blobs-per-file | tee $LOG_FILE"
echo

RESTIC_STATS=$(restic -r $RESTIC_REPOSITORY --password-file $RESTIC_PASSWORD_FILE stats --mode blobs-per-file | tee $LOG_FILE)
OUTPUT_DATE=$(date --iso-8601=seconds)
OUTPUT_SIZE=$(echo $RESTIC_STATS | sed -n -e 's/.*Total Size: //p' | tr ',' ' ')

cat $LOG_FILE
echo

# print debug info
log Backup performed at $OUTPUT_DATE
printf "\t- %s\n" "Total size: $OUTPUT_SIZE"
echo

# send embed to discord.
curl -X POST -H "Content-Type: application/json" -d "$(generate_success_embed)" https://canary.discord.com/api/v8/webhooks/$WEBHOOK_TOKEN
log Sent information to Discord.

# only retain the last month of hourly backups, and the last year of monthyl backups.
# helps to keep repository size reasonable.
log Cleaning up previous backups...
echo
echo "+ restic -r $RESTIC_REPOSITORY --password-file $RESTIC_PASSWORD_FILE forget --keep-within 1w --keep-weekly 52 --prune | tee $LOG_FILE"
echo

restic_result=$(restic -r $RESTIC_REPOSITORY --password-file $RESTIC_PASSWORD_FILE forget --keep-within 1w --keep-weekly 52 --prune | tee $LOG_FILE)

cat $LOG_FILE
echo

if [[ ! $restic_result ]]; then
    log Cleanup failed!
    
    # assign error vars
    RESTIC_ERROR=$(cat $LOG_FILE | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')

    # check if empty - avoids bad request errors
    if [[ -z $RESTIC_ERROR ]]; then
        RESTIC_ERROR="No logs found."
    fi

    curl -X POST -H "Content-Type: application/json" -d "$(generate_prune_error_embed)" https://canary.discord.com/api/v8/webhooks/$WEBHOOK_TOKEN
    log Sent information to Discord.
    exit
fi

log "Cleanup successful! We're done here UwU~"
