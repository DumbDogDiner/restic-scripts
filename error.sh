#!/usr/bin/env bash
set -euo pipefail

# generate the success embed
generate_error_embed() {
    cat <<EOF
{
    "avatar_url": "https://restic.readthedocs.io/en/latest/_static/logo.png",
    "username": "Restic Backup Logs",
    "embeds": [
        {
            "title": "Backup Failed",
            "description": "The latest backup was unsuccessful! Any error information will be shown below. When you see this, please contact someone with the SysOps role.",
            "url": "https://discordapp.com",
            "color": 16734296,
            "timestamp": "$(date --iso-8601=seconds)",
            "footer": {
                "text": "Backup performed"
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
                "url": "https://raw.githubusercontent.com/NotZachery/notzachery.github.io/master/images/error_light.png"
            }
        }
    ]
}
EOF
}
