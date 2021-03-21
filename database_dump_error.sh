#!/usr/bin/env bash
set -euo pipefail

# generate the success embed
generate_dump_error_embed() {
    cat <<EOF
{
    "avatar_url": "https://raw.githubusercontent.com/dumbdogdiner/restic-scripts/master/assets/restic.png",
    "username": "Restic Backup Logs",
    "embeds": [
        {
            "title": "Database Dump Failed",
            "description": "Failed to take an SQL dump of the database \`$1\` under database **$2**.",
            "url": "https://discordapp.com",
            "color": 16734296,
            "timestamp": "$(date --iso-8601=seconds)",
            "footer": {
                "text": "Backup performed at"
            },
            "thumbnail": {
                "url": "https://raw.githubusercontent.com/dumbdogdiner/restic-scripts/master/assets/error.png"
            }
        }
    ]
}
EOF
}
