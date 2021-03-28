package config

import (
	"os"
	"path/filepath"
)

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
