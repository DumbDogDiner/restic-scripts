package rscripts

import (
	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(backupCmd)
}

var backupCmd = &cobra.Command{
	Use:   "backup",
	Short: "Perform a restic backup",
	Run: func(cmd *cobra.Command, args []string) {

	},
}
