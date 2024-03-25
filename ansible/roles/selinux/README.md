# selinux

Configure Selinux

This simple role will set the selinux mode and install the needed python tools to manage selinux.

When setting selinux to disabled the selinux_policy is ignored.  When setting the mode to enforcing/permissive then the policy is set.

Role Variables Example
```yaml
---
selinux_mode: "enforcing" # enforcing/disabled/permissive
selinux_policy: "targeted"
```

More complex selinux management is possible but not implemented at this time.
