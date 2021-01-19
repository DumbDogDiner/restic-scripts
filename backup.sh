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
source ./error.sh
source ./success.sh

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

# perform the backup
# only have a 400mbit connection to HE in CA, USA, therefore a 300mbit limit is enforced on uploads
echo
echo "+ restic -r $RESTIC_REPOSITORY --password-file $RESTIC_PASSWORD_FILE --limit-upload 300000 --limit-download 300000 --verbose backup $(echo ${INCLUDE_FILES[@]} | xargs) --exclude-file=$EXCLUDE_FILE | tee $LOG_FILE"
restic_result=$(restic -r $RESTIC_REPOSITORY --password-file $RESTIC_PASSWORD_FILE --limit-upload 300000 --limit-download 300000 --verbose backup $(echo ${INCLUDE_FILES[@]} | xargs) --exclude-file=$EXCLUDE_FILE | tee $LOG_FILE)
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

log Backup complete! Computing statistics...

# Set temp env vars
RESTIC_STATS="$(restic -r $RESTIC_REPOSITORY --password-file $RESTIC_PASSWORD_FILE stats)"

OUTPUT_DATE="$(date --iso-8601=seconds)"
OUTPUT_SNAPSHOTS="$RESTIC_STATS | sed -n -e 's/.*Snapshots processed:   //p' | tr ',' ' ')"
OUTPUT_FILES="$RESTIC_STATS | sed -n -e 's/.*Total File Count:   //p' | tr ',' ' ')"
OUTPUT_SIZE="$RESTIC_STATS | sed -n -e 's/.*Total Size:   //p' | tr ',' ' ')"

# debug logs
log Backup performed at $OUTPUT_DATE
log Snapshots processed: $OUTPUT_SNAPSHOTS
log Total file count: $OUTPUT_FILES
log Total size: $OUTPUT_SIZE

# send embed to discord.
curl -X POST -H "Content-Type: application/json" -d "$(generate_success_embed)" https://canary.discord.com/api/v8/webhooks/$WEBHOOK_TOKEN
log Sent information to Discord.
