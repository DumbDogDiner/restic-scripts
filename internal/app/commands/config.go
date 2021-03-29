package commands

import (
	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(configCommand)
	configCommand.AddCommand(configSetCommand)
}

var configCommand = &cobra.Command{
	Use:   "config",
	Short: "Manage the configuration of rscripts",
	Run: func(cmd *cobra.Command, args []string) {
		// todo - print current config
	},
}

var configSetCommand = &cobra.Command{
	Use:   "set [key] [value]",
	Short: "Set a configuration key to the specified value",
	Args:  cobra.MinimumNArgs(2),
	Run: func(cmd *cobra.Command, args []string) {
		// todo - update config
	},
}
