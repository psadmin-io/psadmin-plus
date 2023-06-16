# Build the array of commands to test
$commands = @(
  "status",
  "status tux",
  "status pubsub",
  "bounce",
  "list"
)

# Loop through the array and execute each command
foreach ($cmd in $commands) {
  Write-Host "Executing command: $cmd"
  Invoke-Expression "bin/psa $cmd"

  # Verify the result of the command
  if ($LASTEXITCODE -eq 0) {
    Write-Host "Command succeeded"
  } else {
    Write-Host "Command failed"
  }

  Write-Host
}