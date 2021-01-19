#!/usr/bin/env bash
set -euo pipefail

# generate the error embed
generate_success_embed() {
    cat <<EOF
{
    "avatar_url": "https://restic.readthedocs.io/en/latest/_static/logo.png",
    "username": "Restic Backup Logs",
    "embeds": [
        {
            "title": "Backup Successful",
            "description": "The backup completed without errors. UwU~!",
            "url": "https://discordapp.com",
            "color": 5832536,
            "timestamp": "$OUTPUT_DATE",
            "footer": {
                "text": "Backup performed at"
            },
            "fields": [
                {
                    "name": "Restic Logs",
                    "value": "```$RESTIC_LOGS```"
                },
                {
                    "name": "Snapshots",
                    "value": "$OUTPUT_SNAPSHOTS",
                    "inline": true
                },
                {
                    "name": "Files",
                    "value": "$OUTPUT_FILES",
                    "inline": true
                },
                {
                    "name": "Repository Size",
                    "value": "$OUTPUT_SIZE",
                    "inline": true
                }
            ],
            "thumbnail": {
                "url": "https://cdn.discordapp.com/emojis/782379848118304808.png"
            }
        }
    ]
}
EOF
}
