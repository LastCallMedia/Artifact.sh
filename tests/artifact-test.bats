#!/usr/bin/env bats

load ../node_modules/bats-assert/all
load ../node_modules/bats-mock/stub

load test_helper

artifact="$BATS_TEST_DIRNAME/../artifactsh"
srcrepo="${BATS_TMPDIR}/src"
artifactrepo="${BATS_TMPDIR}/artifact"
workspace="${BATS_TMPDIR}/ws"

usage="Builds a git artifact from a source repository.

Options:
  -h: Show help
  -a: Set artifact git repository URL (required)
  -b: Set downstream branch Defaults to current source repo branch.
  -m: Set commit message.  Defaults to last source repo commit message.
  -n: Dry run - display changes instead of committing and pushing.

Usage:
  Build and push to an artifact repository on github:

  $BATS_TEST_DIRNAME/../artifactsh -d git://github.com/example/artifact.git"

setup() {
    setup_source_repo "$srcrepo" > /dev/null 2>&1
    setup_artifact_repo "$artifactrepo" > /dev/null 2>&1
    mkdir -p "$workspace" && git clone "$srcrepo" "$workspace" > /dev/null 2>&1
    cd "$workspace"
}

teardown() {
  rm -rf "$srcrepo"
  rm -rf "$artifactrepo"
  rm -rf "$workspace"
}

@test "invoking without arguments prints usage" {
  run $artifact
  assert_failure
  assert_equal "$usage" "$output"
}

@test "invoking with -h shows usage" {
  run $artifact -h
  assert_success
  assert_equal "$usage" "$output"
}

@test "invoking without an artifact url throws error" {
  run $artifact -b test
  assert_failure
  assert_equal  "Artifact URL must be set by using the -a flag." "$output"
}

@test "invoking without a branch throws error" {
  cd $BATS_TMPDIR
  run $artifact -a foo@example.com
  assert_failure
  assert_equal "Branch must be set by using the -b flag." "$output"
}

@test "invoking without message throws error" {
  cd $BATS_TMPDIR
  run $artifact -a foo@example.com -b "test"
  assert_failure
  assert_equal "Message must be set using the -m flag." "$output"
}

@test "it pushes files from source to artifact" {
  run $artifact -a "$BATS_TMPDIR/artifact"
  assert_success
  assert git --git-dir="$artifactrepo" cat-file -e "HEAD:source.txt"
  refute git --git-dir="$artifactrepo" cat-file -e "HEAD:artifact.txt"
}

@test "it respects the .artifact.gitignore file" {
  touch source-ignored.txt
  touch artifact-ignored.txt
  run $artifact -a "$BATS_TMPDIR/artifact"
  assert_success
  assert git --git-dir="$artifactrepo" cat-file -e "HEAD:source-ignored.txt"
  refute git --git-dir="$artifactrepo" cat-file -e "HEAD:artifact-ignored.txt"
}

@test "it respects nested .artifact.gitignore files" {
  touch nested/source-ignored.txt
  touch nested/artifact-ignored.txt
  run $artifact -a "$BATS_TMPDIR/artifact"
  assert_success
  assert git --git-dir="$artifactrepo" cat-file -e "HEAD:nested/source-ignored.txt"
  refute git --git-dir="$artifactrepo" cat-file -e "HEAD:nested/artifact-ignored.txt"
}

@test "it restores .gitignore files after committing artifact" {
  run $artifact -a "$BATS_TMPDIR/artifact"
  assert_success
  assert_equal "/source-ignored.txt" "$(cat .gitignore)"
  assert_equal "/source-ignored.txt" "$(cat nested/.gitignore)"
  assert_equal "/artifact-ignored.txt" "$(cat .artifact.gitignore)"
  assert_equal "/artifact-ignored.txt" "$(cat nested/.artifact.gitignore)"
}

@test "it considers files that are present locally but not in the source repository" {
  touch localaddition.txt
  run $artifact -a "$BATS_TMPDIR/artifact"
  assert_success
  assert git --git-dir="$artifactrepo" cat-file -e "HEAD:localaddition.txt"
}

@test "it can commit subdirectories that contain .git subfolders" {
  mkdir s1 && git init s1 && touch s1/test.txt
  git clone "$srcrepo" s2 > /dev/null 2>&1
  run $artifact -a "$BATS_TMPDIR/artifact"
  assert_success
  assert git --git-dir="$artifactrepo" cat-file -e "HEAD:s1/test.txt"
  assert git --git-dir="$artifactrepo" cat-file -e "HEAD:s2/source.txt"
}

@test "it restores .git subdirectories after committing artifact" {
  git clone "$srcrepo" s2 > /dev/null 2>&1
  run $artifact -a "$BATS_TMPDIR/artifact"
  assert_success
  assert [ -d s2/.git ]
}

@test "it picks up the branch from the current repository" {
  git checkout -b mybranch
  run $artifact -a "$BATS_TMPDIR/artifact"
  assert_success
  assert git --git-dir="$artifactrepo" cat-file -e "mybranch:source.txt"
}

@test "it picks up the message from the current commit" {
  run $artifact -a "$BATS_TMPDIR/artifact"
  assert_success
  assert_contains "Initial commit on source" "$(git --git-dir="$artifactrepo" show --quiet --format=%B)"
}
