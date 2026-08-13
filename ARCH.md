## Diff management 
Open questions:

- how to collect changed files 
- in which format should be changes to display them in nvim
- how to represent stable contract between parts of the system

Hints from requirements:
- Start a review against a branch or commit. A branch uses its merge base with the current branch; a commit is used as the exact baseline.
- Build one aggregate comparison from the baseline to the current local state, including every Git change category such as additions, deletions, renames, binary files, submodules, and untracked files.
- Build one aggregate comparison from the baseline to the current local state, including every Git change category such as additions, deletions, renames, binary files, submodules, and untracked files.
- The comparison is an aggregate result; committed, staged, unstaged, and untracked layers are not reviewed separately.
- Branch comparisons resolve the merge base and compare it with the combined committed, index, working-tree, and untracked result.
- Comparison data retains rename, deletion, mode, binary, old/new path, additions/deletions, object ID, and parsed hunk metadata needed by views, comments, refresh reconciliation, and remote publishing.

### Implementation 

**What should be implemented:**
- collect changed files from git 
- parse changes 
- enrich them with required data 
- map them to expected model

**How changes are collected from git:**
1. Always include commited changes, staged changes, unstaged changes, untracked files 
2. If no args provided then compare HEAD with merge-base with default branch 
3. If branch name is provided then compare HEAD with merge-base with specified branch 
4. If commit is provided then compare HEAD with specified commit 
5. If two branches/commits are provided then compare them 

How to parse changes: 

