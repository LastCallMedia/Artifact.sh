#!/usr/bin/env bats

load ../node_modules/bats-assert/all
load ../node_modules/bats-mock/stub

usage="Builds a git artifact from a source repository.

Options:
  -h: Show help
  -a: Set artifact git repository URL (required)
  -b: Set downstream branch Defaults to current source repo branch.
  -m: Set commit message.  Defaults to last source repo commit message.
  -n: Dry run - display changes instead of committing and pushing.

Usage:
  Build and push to an artifact repository on github:

  bin/artifact -d git://github.com/example/artifact.git"

@test "invoking without arguments prints usage" {
  run bin/artifact
  [ "$status" -eq 1 ]
  assert_equal "$output" "$usage"
}

@test "invoking without an artifact url throws error" {
  run bin/artifact -b test
  [ "$status" -eq 1 ]
  assert_equal "$output"  "Artifact URL must be set by using the -a flag."
}

@test "invoking without a branch throws error" {
  run bin/artifact -a foo@example.com
  [ "$status" -eq 1 ]
  assert_equal "$output" "Branch must be set by using the -b flag."
}

@test "invoking without message throws error" {
  run bin/artifact -a foo@example.com -b "test"
  [ "$status" -eq 1 ]
  assert_equal "$output" "Message must be set using the -m flag."
}

@test "invoking with -h shows usage" {
  run bin/artifact
  [ "$status" -eq 1 ]
  assert_equal "$output" "$usage"
}

