package main

import (
	"os"

	"github.com/dumbdogdiner/rscripts/internal/app/commands"
	"github.com/dumbdogdiner/rscripts/internal/app/config"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/spf13/cobra"
)

func init() {
	// ensure zerolog is configured for pretty logging.
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})
	// initialize config on cobra load
	cobra.OnInitialize(config.InitializeConfig)
}

func main() {
	commands.Execute()
}
