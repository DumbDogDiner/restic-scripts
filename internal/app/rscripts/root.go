package rscripts

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var GitTag string
var GitCommit string

var rootCmd = &cobra.Command{
	Version: fmt.Sprintf("v%s commit %s", GitTag, GitCommit),
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
