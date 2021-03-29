package commands

import (
	"fmt"
	"os"

	"github.com/dumbdogdiner/rscripts/internal/app/constants"
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Version: fmt.Sprintf("v%s commit %s", constants.GitTag, constants.GitHash),
	Use:     "rscripts [command] [--flags]",
	Short:   "Simple wrapper around restic for easy backups.",
	Long: `A simple wrapper around restic for easily configurable
backups using Restic.`,
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
