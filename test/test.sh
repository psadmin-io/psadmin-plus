#!/bin/bash

# Build the array of commands to test
commands=(
  "status"
  "status tux"
  "status pubsub"
  "bounce"
  "list"
)

# Build the array of environment variables to set
variables=(
  "PS_PSA_OUTPUT=all"
  "PS_PSA_OUTPUT=summary"
  "PS_PSA_TIMESTAMP=true"
  "PS_PSA_DEBUG=DEBUG"
)

# Loop through the array and execute each command
for cmd in "${commands[@]}"
do
  echo "Executing command: $cmd"

  # Set the environment variables for the current command
  for var in "${variables[@]}"
  do
    export "$var"
  done

  eval "bin/psa $cmd"

  # Verify the result of the command
  if [ $? -eq 0 ]; then
    echo "Test succeeded"
  else
    echo "Test failed"
  fi

  echo
done
