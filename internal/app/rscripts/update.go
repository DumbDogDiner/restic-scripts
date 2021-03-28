package rscripts

import (
	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(updateCmd)
}

var updateCmd = &cobra.Command{
	Use:   "update",
	Short: "Checks for any updates to rscripts",
	Run: func(cmd *cobra.Command, args []string) {

	},
}
