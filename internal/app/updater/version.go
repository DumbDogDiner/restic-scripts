package updater

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/dumbdogdiner/rscripts/internal/app/constants"
)

type Release struct {
	TagName     string `json:"tag_name"`
	PublishedAt string `json:"published_at"`
}

// GetLatestVersion returns a string containing the latest release version
// as retrieved from the GitHub API.
func GetLatestVersion() (string, error) {
	resp, err := http.Get(fmt.Sprintf("%s/releases", constants.RepositoryUrl))
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
	// find the latest release
	latestTimestamp := time.Unix(0, 0)
	var latestRelease = -1
	for i, release := range info {
		// parse the release timestamp, compare it to the existing
		timestamp, err := time.Parse("RFC3339", release.PublishedAt)
		if err != nil {
			return "", err
		}
		// if it is after, it's the new one.
		if timestamp.Before(latestTimestamp) {
			continue
		}
		// update the latest release
		latestTimestamp = timestamp
		latestRelease = i
	}
	// if no release was found
	if latestRelease == -1 {
		return "", errors.New("No releases found.")
	}

	return info[latestRelease].TagName, nil
}
