# openssh

## Configure OpenSSH Server
### sshd_config variables:
- openssh_root_login
    - Enable or disable root login over ssh/sftp (yes/no)(def=no)
- openssh_pass_auth
    - Enable or disable password authentication (yes/no)(def=yes)
- openssh_port
    - Port for sshd service to listen on (def=22)
- openssh_printMotd
    - Echo the systems default Motd at login (yes/no)(def=yes)
- openssh_extra_rules
    - Rules to add to the end of the sshd_config file (AWX Rule shown in our example is hardcoded)

### Role Variable Example:
```yaml
---
openssh_root_login: "no"
openssh_pass_auth: "yes"
openssh_port: "22"
openssh_printMotd: "yes"

openssh_extra_rules: |
  # Allow Ansible AWX Root SSH
  Match address 10.88.19.88
    PasswordAuthentication no
    PermitRootLogin yes
```
