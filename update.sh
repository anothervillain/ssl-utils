#!/bin/bash

# Define the repository directory and GitLab URL
REPO_DIR="$HOME/ssl-tools"
GITLAB_URL="https://gitlab.group.one/christian-mathias.moen/ssl-utils.git"

# Check if the repository directory exists
if [ ! -d "$REPO_DIR" ]; then
    echo "Repository directory does not exist. Cloning the repository."
    git clone "$GITLAB_URL" "$REPO_DIR" || {
        echo "Failed to clone repository."
        exit 1
    }
fi

# Navigate to the repository directory
cd "$REPO_DIR" || {
    echo "Failed to navigate to repository directory."
    exit 1
}

# Pull the latest changes
echo "Pulling the latest changes from GitLab..."
git pull origin master || {
    echo "Failed to pull changes from GitLab."
    exit 1
}

echo "Update complete."
