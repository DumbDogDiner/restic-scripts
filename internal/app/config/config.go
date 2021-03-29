package config

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/rs/zerolog/log"
	"github.com/spf13/viper"
)

var ConfigDirectory string

// InitializeConfig sets up the viper configuration and creates the necessary configuration files.
func InitializeConfig() {
	dir, err := EnsureConfigDir()
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to initialize configuration.")
		os.Exit(1)
	}

	viper.AddConfigPath(dir)
	viper.SetConfigName("config.toml")

	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err == nil {
		fmt.Println("Using config file:", viper.ConfigFileUsed())
	}

	ConfigDirectory = dir
}

// GetConfigDir returns the config directory of restic scripts.
func GetConfigDir() (string, error) {
	configDir, err := os.UserConfigDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(configDir, ".rscripts"), nil
}

// EnsureConfigDir ensures the config directory exists before returning
// its path.
func EnsureConfigDir() (string, error) {
	// fetch the config directory
	dir, err := GetConfigDir()
	if err != nil {
		return "", err
	}
	// test if dir exists - if not, attempt to create it.
	if _, err := os.Stat(dir); err == nil {
		return dir, nil
	} else if err := os.Mkdir(dir, 0755); err == nil {
		return dir, nil
	}
	return "", err
}
