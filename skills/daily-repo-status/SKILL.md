---
name: daily-repo-status
description: Fetches and summarizes recent git activity, open PRs, and issues for user repositories using the GitHub CLI.
version: 1.0.0
---

# Daily Repo Status Summary

This skill inspects recent git commits, open pull requests, and issues on your GitHub repositories.

## Execution Steps:
1. Run `gh repo list ra901625072-boop --limit 5` to identify primary repositories.
2. For active repos, run `gh pr list --state open` to check open PRs.
3. Check recent commit history with `gh api repos/ra901625072-boop/{repo}/commits -q '.[0:3] | .[] | {sha: .sha[0:7], message: .commit.message}'`.
4. Format a concise, clean summary report for the user.
