package main

import (
	"os"

	"github.com/dumbdogdiner/rscripts/internal/app/commands"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

func init() {
	// ensure zerolog is configured for pretty logging.
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})
}

func main() {
	commands.Execute()
}
