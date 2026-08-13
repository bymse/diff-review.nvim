# Review Requirements

## Purpose

Provide a Neovim workflow for reviewing the complete local result of a branch, including committed, staged, unstaged, and untracked changes. The reviewer can inspect files in multiple diff presentations, navigate the project for context, leave line or file feedback, track review progress, and publish actionable comments to a remote provider or `comments.md`.

## User Flow

1. Start a review against a branch or commit. A branch uses its merge base with the current branch; a commit is used as the exact baseline.
2. Build one aggregate comparison from the baseline to the current local state, including every Git change category such as additions, deletions, renames, binary files, submodules, and untracked files.
3. Work through the changed-file quickfix list one file at a time. Opening an entry hides the quickfix drawer and opens that file in the active review presentation. Switch the whole session among side-by-side, unified-patch, and current-file-with-signs views.
4. Mark the current quickfix entry, or a selected range of entries, viewed. The list displays viewed state for each file. Marking the active file viewed advances to the next unviewed file. If a viewed file changes after refresh, return it to the unviewed set.
5. Navigate through read-only project buffers using normal Neovim navigation to understand the change. Review UI is not opened automatically during this navigation.
6. Add comments on either side of a diff, on unchanged lines, or in unchanged project files. Comments retain file and line information and are available from a central comment list.
7. Refresh automatically after relevant local changes, or refresh manually. Defer refresh while a comment editor is open. Comments whose anchors no longer match remain available but become stale.
8. Resolve comments manually when feedback has been addressed.
9. Export unresolved, pending, non-stale comments to `comments.md` for an AI agent, or publish them as remote drafts to the detected GitLab or GitHub review.

## Review Model

- Only one review session may be active at a time per repos.
- Starting a review with a different source branch, or baseline requires stopping the active session first.
- Review data persists per source and baseline and is restored when that review is started again. UI layout, navigation position, and view mode do not need to be restored.
- The comparison is an aggregate result; committed, staged, unstaged, and untracked layers are not reviewed separately.
- Branch comparisons resolve the merge base and compare it with the combined committed, index, working-tree, and untracked result.
- Comparison data retains rename, deletion, mode, binary, old/new path, additions/deletions, object ID, and parsed hunk metadata needed by views, comments, refresh reconciliation, and remote publishing.
- Reject repositories with unresolved merge conflicts rather than constructing a potentially misleading review.
- Refresh incorporates new local changes into the active session.
- Viewed state is preserved only while a file's diff remains unchanged.
- Stale comments are retained for manual resolution, deletion, or replacement and cannot be published.
- Normal project navigation uses Neovim's jump list rather than a separate review navigation stack.

## File List Interaction

- Use a native quickfix list as the primary changed-file list and review queue.
- Each quickfix entry represents one changed file and visibly indicates whether it is viewed or unviewed.
- Order unviewed files before viewed files while preserving comparison order within each group.
- Opening an entry hides the quickfix drawer and selects that file for review in the session's current view mode.
- The reviewer can toggle viewed state for the current entry or a selected quickfix range.
- Viewed state is explicit; merely opening or navigating through a file does not mark it viewed.
- Marking the active file viewed opens the next unviewed file in queue order when one exists.
- The file and comment lists use the same bottom drawer. Opening one closes the other, and invoking the currently open list again closes the drawer.
- Refresh updates the quickfix entries while preserving viewed state only for files whose diff has not changed.

## State Storage

- Keep validated structured state as the authoritative source for review data.
- Treat quickfix entries, buffers, extmarks, and Markdown as rebuildable projections of that state.
- Store review sessions outside the worktree under the repository-specific path returned by `git rev-parse --path-format=absolute --git-path reviews`.
- Isolate persisted state by source branch and baseline so separate reviews do not overwrite each other.

## Comments

- A comment may target a single line or range on either the base or current side.
- A comment may also target an unchanged line or a file outside the changed-file list.
- When a provider cannot represent an exact inline position, publish a file-level comment when supported; otherwise include the file path and line number in the comment text.
- Published comments remain in local state with their provider identity and can later be updated as the same remote draft.
- Resolution is explicit and manual; source changes alone do not resolve a comment.

## Remote Publishing

- Detect GitLab or GitHub from the relevant Git remote and use the corresponding CLI/API integration.
- Require an existing matching merge request or pull request.
- Create drafts only. Final review submission happens outside the plugin.
- Keep local state authoritative while storing remote IDs for later updates; do not import remote comments or edits.
- Publish only unresolved, pending, non-stale comments.
- Retry only comments that have not already been published successfully.
- Block publication unless the worktree is clean, local commits are pushed, and local baseline/head revisions exactly match the current remote review.
- If the remote review changes, require local update and review refresh before publishing.

## Markdown Publishing

- Write unresolved, pending, non-stale comments to `comments.md` with enough path, side, line, range, and surrounding context for an AI agent to act on them.
- Treat Markdown as one-way output. The agent changes source files rather than editing review state through the document.
- Exporting Markdown does not change comment publication state, so it can be regenerated and comments can still be published remotely later.

## Key Decisions

- Branch comparisons use merge-base semantics; explicit commits are exact baselines.
- The working result is reviewed as one aggregate diff.
- Every Git change category appears in the review, even when inline interaction is limited.
- Diff presentation is switchable and session-wide.
- Context navigation is read-only and does not automatically activate review UI.
- Files require explicit viewed status and are invalidated by subsequent changes.
- Remote publication favors correctness over partial transfer by requiring clean, pushed, revision-matched state.
- Local comments are durable records rather than items removed after publishing.
