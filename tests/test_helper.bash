#!/bin/bash

function setup_source_repo() {
  setup_remote_repo "$1-working"
  commit_file source.txt "Initial commit on source"
  mv "$1-working/.git" "$1" && rm -rf "$1-working"
  cd "$1" && git config core.bare true
}

function setup_artifact_repo() {
  setup_remote_repo "$1-working"
  commit_file artifact.txt "Initial commit on artifact"
  mv "$1-working/.git" "$1" && rm -rf "$1-working"
  cd "$1" && git config core.bare true
}

function commit_file() {
  touch $1 && git add $1 && git commit -m "$2"
}

function setup_remote_repo() {
  mkdir -p $1 && cd $1 && git init
}
