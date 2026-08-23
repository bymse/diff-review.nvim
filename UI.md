# UI

## Quickfix list
 
- Use a native quickfix list as a flat changed-file list and review queue.
- Each quickfix entry represents one changed file and visibly indicates whether it is viewed or unviewed.
- Order unviewed files before viewed files while preserving comparison order within each group.
- Opening an entry hides the quickfix drawer and selects that file for review in the session's current view mode.
- The reviewer can toggle viewed state for the current entry or a selected quickfix range.
- Viewed state is explicit; merely opening or navigating through a file does not mark it viewed.
- Marking the active file viewed opens the next unviewed file in queue order when one exists.
- The file and comment lists use the same bottom drawer. Opening one closes the other, and invoking the currently open list again closes the drawer.

## Hierarchy of files 

Additional mode:
- Files are grouped by directories
- Files and directories are shown as oil buffer 
- File state (viewed/unviewed) is shown as icon 
- Dir is marked as viewed if all files in the dir are viewed 
- Files and dirs can be marked as viewed from the oil buffer 

## Changes view
"diff" mode:
- When user "enters" file from the Hierarchy or from quickfix then diff of old and current version should be show using diffthis and horizontal windows. Added/deleted/changed lines should be highlighted
- When file was added/deleted/moved then there should be a line with text "Added file"/"Deleted file"/"Moved from <path>" 
- Special cases: changed mode, submodule, binary file, ... then only informational text should be shown

"inline" mode:
files are shown as normal buffers with normal navigation. Status line for added/deleted/moved files should be present. Changed lines should be highlighted/marked with extmarks.

## Comments 
- Comments are shown as virtual text 
- Stale comments are marked in the virtual text 
- User can comment any part of the code in the review mode: changed and unchanged lines
- Comment editor is editable buffer for virtual temporary file. If comment text is deleted then comment is deleted 
- List of comments can be shown through special command

