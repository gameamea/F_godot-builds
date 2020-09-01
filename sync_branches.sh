#!/usr/bin/env bash
folder="../_godot/"
branchMaster='3.2'
branchDevelop="gdscript_format_updated"
upstream="https://github.com/godotengine/godot.git"

function checkBranch() {
  branch=$1
  if [ $(git status | grep $branch | wc -l) -gt 1 ]; then
    echo 1
  else
    echo 0
  fi
}
function continueYN() {
  if [ "$1" = "" ]; then message="Press Y continue, Anything else to Quit "; else message=$1; fi
  echo ""
  read -p "$message" userInput
  if [ ! "$userInput" = "Y" ] && [ ! "$userInput" = "y" ] && [ ! "$userInput" = "O" ] && [ ! "$userInput" = "o" ]; then exit 0; fi
  echo ""
}

echo ""
echo "This script is used to sync godot sources from local and upstream repo."
echo "It will :"
echo " - stash your changes"
echo " - merge local $branchDevelop branch and upstream $branchMaster into $folder"
echo " - pop your stach"

continueYN

cd $folder

printf "\n--------\nAdd the 'upstream' to your cloned repository ('origin')\n"
git remote add upstream $upstream

printf "\n--------\nFetch the commits (and branches) from the 'upstream'\n"
git fetch upstream

if [ $(checkBranch $branchDevelop) -eq 0 ]; then
  printf "\n--------\nSwitch to the 'develop' branch of your fork ('origin')\n"
  git checkout $branchDevelop
fi

printf "\n--------\nStash the changes of your 'develop' branch:\n"
git stash

printf "\n--------\nMerge the changes from the 'master' branch of the 'upstream' into your the 'develop' branch of repo\n"
git merge upstream/$branchMaster

printf "\n--------\nResolve merge conflicts if any and commit your merge\n"
git commit -am "Merged from upstream/$branchMaster"

printf "\n--------\nPush the changes to your fork\n"
git push

printf "\n--------\nGet back your stashed changes (if any)\n"
git stash pop
