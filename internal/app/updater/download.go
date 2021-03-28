package updater

import (
	"io"
	"net/http"
	"os"
	"path/filepath"

	"github.com/dumbdogdiner/rscripts/internal/app/config"
)

// The location of the binary download.
var DownloadUrl string

// DownloadBinary fetches the zipped binary from GitHub releases.
func DownloadBinary() (*os.File, error) {
	// create a temporary directory to store the downloaded binary.
	configDir, err := config.EnsureConfigDir()
	if err != nil {
		return nil, err
	}
	downloadFile, err := os.CreateTemp(configDir, "download.zip")
	if err != nil {
		return nil, err
	}
	// fetch the data from github.
	resp, err := http.Get(DownloadUrl)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	// write the body to file.
	_, err = io.Copy(downloadFile, resp.Body)
	if err != nil {
		return nil, err
	}
	return downloadFile, nil
}

// ExtracBinary extracts the downloaded binary into the temporary directory
// in preparation to move it to the end location.
func ExtractBinary(src *os.File) (*os.File, error) {
	configDir, err := config.EnsureConfigDir()
	if err != nil {
		return nil, err
	}
	dest, err := os.Open(filepath.Join(configDir, "rscripts"))
	if err != nil {
		return nil, err
	}

}
