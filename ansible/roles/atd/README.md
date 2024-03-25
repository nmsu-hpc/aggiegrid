# at/atd Configuration

This role will setup and harden the Cron service/configuration.

## Access Control

atd operates in 2 distinct modes when it comes to who is allowed to use atd. 'allow' mode blocks all users except for those given explicit access. 'deny' mode allow all users and blocks specific users.

- ansible sets the access control mode using the following variable:
  - `at_access_mode`
    - `at_access_mode: "allow"`
      - default mode
    - `at_access_mode: "deny"`
      - optional/less secure mode
- Both modes use `at_user_list` to supply a list of users to be allowed/denied.
  - This must be a list variable.
    - Each item is a username.
  - An empty list is used by default.
  - 'root' user bypasses access controls even if not specified.
