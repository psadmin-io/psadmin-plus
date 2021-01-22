# Examples
Set these in .psa.conf or as environment variables to use hooks.

## Ruby hooks
PS_HOOK_INTERP="ruby" # DEFAULT
PS_HOOK_PRE="<PSA_DIR>/lib/hooks/test.rb"
PS_HOOK_POST="<PSA_DIR>/lib/hooks/test.rb"
PS_HOOK_START="<PSA_DIR>/lib/hooks/test.rb"
PS_HOOK_STOP="<PSA_DIR>/lib/hooks/test.rb"

## Bash hooks
PS_HOOK_INTERP="bash"
PS_HOOK_PRE="<PSA_DIR>/lib/hooks/test.sh"
PS_HOOK_POST="<PSA_DIR>/lib/hooks/test.sh"
PS_HOOK_START="<PSA_DIR>/lib/hooks/test.sh"
PS_HOOK_STOP="<PSA_DIR>/lib/hooks/test.sh"

## Powershell hooks
PS_HOOK_INTERP="Powershell -File"
PS_HOOK_PRE="<PSA_DIR>/lib/hooks/test.ps1"
PS_HOOK_POST="<PSA_DIR>/lib/hooks/test.ps1"
PS_HOOK_START="<PSA_DIR>/lib/hooks/test.ps1"
PS_HOOK_STOP="<PSA_DIR>/lib/hooks/test.ps1"
