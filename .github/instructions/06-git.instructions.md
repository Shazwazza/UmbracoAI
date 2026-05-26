---
description: Rules for working git
applyTo: '**/*'
---
# Git

* Use the 'git' mcp server for git operations, try to avoid the command line if possible.
* Anytime a task is completed, a Git commmit should be made to track changes.
* Any Umbraco specific changes must be done on a develop branch (i.e. "/develop/featureABC").
  * If the current branch is main/master, create and checkout a new develop branch before executing anything that affects Umbraco. DO NOT re-use an existing develop branch, if you are creating a new branch it should be unique.
  * If the current branch is already a "develop" branch, don't create a new one, just remain on the current develop branch.
