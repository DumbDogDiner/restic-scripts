#!/usr/bin/env bash
set -euo pipefail

# generate the error embed
generate_success_embed() {
    cat <<EOF
{
    "avatar_url": "https://raw.githubusercontent.com/dumbdogdiner/restic-scripts/master/assets/restic.png",
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
                    "value": "\`\`\`$RESTIC_LOGS\`\`\`"
                },
                {
                    "name": "Repository Size",
                    "value": "$OUTPUT_SIZE"
                }
            ],
            "thumbnail": {
                "url": "https://raw.githubusercontent.com/dumbdogdiner/restic-scripts/master/assets/success.png"
            }
        }
    ]
}
EOF
}
