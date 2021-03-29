package updater

import (
	"github.com/rs/zerolog/log"
)

// Update attempts to update the software.
func Update() {
	log.Info().Msg("Checking for new version...")
	version, err := GetLatestVersion()
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to fetch version information - cannot update.")
	}

	log.Info().Msgf("Latest version: %s", version)

	log.Info().Msg("Downloading latest binary...")
	DownloadBinary()
}
