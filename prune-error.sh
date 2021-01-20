#!/usr/bin/env bash
set -euo pipefail

# generate the success embed
generate_prune_error_embed() {
    cat <<EOF
{
    "avatar_url": "https://raw.githubusercontent.com/dumbdogdiner/restic-scripts/master/assets/restic.png",
    "username": "Restic Backup Logs",
    "embeds": [
        {
            "title": "Repository Prune Failed",
            "description": "The latest repository cleanup failed! Any error information will be shown below. When you see this, please contact someone with the SysOps role.",
            "url": "https://discordapp.com",
            "color": 16734296,
            "timestamp": "$(date --iso-8601=seconds)",
            "footer": {
                "text": "Cleanup performed at"
            },
            "fields": [
                {
                    "name": "Restic Error",
                    "value": "\`\`\`$RESTIC_ERROR\`\`\`"
                },
                {
                    "name": "Systemd Logs",
                    "value": "\`\`\`$SYSTEMD_LOGS\`\`\`"
                }
            ],
            "thumbnail": {
                "url": "https://raw.githubusercontent.com/dumbdogdiner/restic-scripts/master/assets/error.png"
            }
        }
    ]
}
EOF
}
