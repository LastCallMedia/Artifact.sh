#!/bin/bash

function setup_source_repo() {
  setup_repo "$1-working" $2
  mkdir nested
  echo "source" > source.txt
  echo "/source-ignored.txt" | tee .gitignore nested/.gitignore
  echo "/artifact-ignored.txt" | tee .artifact.gitignore nested/.artifact.gitignore
  git add . && git commit -m "Initial commit on source"
  mv "$1-working/.git" "$1" && rm -rf "$1-working"
  cd "$1" && git config core.bare true
}

function setup_artifact_repo() {
  setup_repo "$1-working" $2
  echo "artifact" > artifact.txt
  git add . && git commit -m "Initial commit on artifact"
  mv "$1-working/.git" "$1" && rm -rf "$1-working"
  cd "$1" && git config core.bare true
}

function setup_repo() {
  mkdir -p $1 && cd $1 && git init --initial-branch="$2"
}
