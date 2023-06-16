#!/bin/bash

# Build the array of commands to test
commands=(
  "status"
  "status tux"
  "status pubsub"
  "bounce"
  "list"
)

# Loop through the array and execute each command
for cmd in "${commands[@]}"
do
  echo "Executing command: $cmd"
  eval "bin/psa $cmd"

  # Verify the result of the command
  if [ $? -eq 0 ]; then
    echo "Test succeeded"
  else
    echo "Test failed"
  fi

  echo
done
