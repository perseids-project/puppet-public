#!/bin/bash
# Make sure we've pulled all refs from origin
git fetch origin

# Find the latest commit on origin/master
# (git rev-parse origin/master)
current_branch_name=$(git rev-parse --abbrev-ref HEAD)

latest_commit_on_master=$(git rev-parse origin/master)

# Then grep for it in the list of commits on the current branch
# (git rev-list BRANCH)
# If there's a match, origin/master's latest commit is on this
# branch and so we're up to date. Otherwise, not.
git rev-list ${current_branch_name} |grep -q ${latest_commit_on_master}
