package updater

import (
	"encoding/json"
	"net/http"
)

const REPOSITORY_URL = ""

type Release struct {
	TagName     string `json:"tag_name"`
	PublishedAt string `json:"published_at"`
}

// GetLatestVersion returns a string containing the latest release version
// as retrieved from the GitHub API.
func GetLatestVersion() (string, error) {
	resp, err := http.Get(REPOSITORY_URL)
	if err != nil {
		return "", err
	}
	// allocate the release info struct
	var info = make([]Release, 0)
	// decode the response body
	defer resp.Body.Close()
	err = json.NewDecoder(resp.Body).Decode(&info)
	if err != nil {
		return "", err
	}
}
