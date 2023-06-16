#!/bin/bash

# Build the array of commands to test
commands=(
  "status"
  "stop"
  "start"
  "status tux"
  "status pubsub"
  "restart"
  "bounce"
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
