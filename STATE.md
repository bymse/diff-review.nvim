# State

- Keep validated structured state as the authoritative source for review data.
- Treat quickfix entries, buffers, extmarks, and Markdown as rebuildable projections of that state.
- Store review sessions outside the worktree under the repository-specific path returned by `git rev-parse --path-format=absolute --git-path reviews`.
- Isolate persisted state by source branch and baseline so separate reviews do not overwrite each other.

**What to store:**  
- List of files and their attributes. Including a sign that file was reviewed.
- Meta information about the review: repo, base commit, last reviewed HEAD sha, ... 
- Comments 
