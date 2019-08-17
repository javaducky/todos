package cmd

import (
	"fmt"

	"github.com/javaducky/todos/env"
	"github.com/spf13/cobra"
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the version number",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Todos %v\n", env.Version)
	},
}

func init() {
	rootCmd.AddCommand(versionCmd)
}
