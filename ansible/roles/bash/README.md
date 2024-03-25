# Setup Bash

This role will ensure bash and relevent packages are installed.  It will then harden the default bash environement accourding to Cis-Cat.

## Default Variables

```yaml
bash_noroot_tmout: false # true/false
bash_tmout: "900" # 15 Minutess
```

## Behavior

- Set Shell Timeout
  - The timeout period is controlled by `bash_tmout` which is denoted in seconds.
  - The value is made readonly so users cannot change it after they login.
  - 'root' user can be made to ignore the timeout setting by setting `bash_noroot_tmout: true`.
- Set Default User Mask
  - this is hard coded to '027'
