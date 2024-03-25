# RSyslog

This role will configure rsyslog and the appropriate log rotation.

- Catagory enable/disable is controlled by boolean `logging_rsyslog`
  - default is `true`.
- Default log reception is controlled by boolean `logging_rsyslog_reception`
  - default is `false`.
  - when set to true default ports and configuration is used.
- log forwarding is controlled by boolean `logging_rsyslog_forwarding`
  - default is `false`.
  - 3 variables control the log forwarding.
    - `logging_rsyslog_fwd_target`
      - Specifies the server name or ip address to forward logs to.
      - default is `'tsm-mh-1.nmsu.edu'`
    - `logging_rsyslog_fwd_port`
      - Specifies the remote port to send to.
      - default is `1514`
    - `logging_rsyslog_fwd_protocol`
      - Specifies the protocol for the remote port
      - default is `udp`
