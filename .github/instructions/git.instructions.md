---
description: Rules for working git
applyTo: '**/*'
---
# Git

* Anytime a task is completed and files are changed, a Git commit should be made to track changes.
* Any Umbraco specific changes in the folder: src\MyProject must be done on a develop branch (i.e. "/develop/featureABC"). If the changes are not specific to Umbraco, its ok to commit to the current checked out branch.
  * If the current branch is main/master, create and checkout a new develop branch before executing anything that affects Umbraco. DO NOT re-use an existing develop branch, if you are creating a new branch it should be unique.
  * If the current branch is already a "develop" branch, don't create a new one, just remain on the current develop branch.
