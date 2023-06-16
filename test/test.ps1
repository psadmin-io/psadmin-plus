# Build the array of commands to test
$commands = @(
  "status",
  "status tux",
  "status pubsub",
  "bounce",
  "list"
)

# Build the array of environment variables to set
$variables = @(
  "PS_PSA_OUTPUT=all",
  "PS_PSA_OUTPUT=summary",
  "PS_PSA_TIMESTAMP=true",
  "PS_PSA_DEBUG=DEBUG"
)

# Loop through the array and execute each command
foreach ($cmd in $commands) {
  Write-Host "Executing command: $cmd"

  # Set the environment variables for the current command
  foreach ($var in $variables) {
    $envVar = $var -split "="
    Set-Item -Path "env:$($envVar[0])" -Value $envVar[1]
  }

  Invoke-Expression "bin/psa $cmd"

  # Verify the result of the command
  if ($LASTEXITCODE -eq 0) {
    Write-Host "Command succeeded"
  } else {
    Write-Host "Command failed"
  }

  Write-Host
}