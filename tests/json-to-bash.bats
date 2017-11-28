#!/usr/bin/env bats

@test "Test good json string" {
  run bash -c 'cat tests/json/good.json | bin/json-to-bash'
  [ "$status" -eq 0 ]
  [ "$output" == "export FOO='bar'" ]
}

@test "complex json string" {
  run bash -c 'cat tests/json/complex.json | bin/json-to-bash'
  [ "$status" -eq 1 ]
  [ "$output" == "Invalid non-scalar value for foo" ]
}

@test "bad json string" {
  run bash -c 'cat tests/json/bad.json | bin/json-to-bash'
  [ "$status" -ne 0 ]
  [ "$output" == "JSON failed to decode: Syntax error" ]
}