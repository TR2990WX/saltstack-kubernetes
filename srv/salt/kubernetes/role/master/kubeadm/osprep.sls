conntrack:
  pkg.latest

bridge-utils:
  pkg.latest

socat:
  pkg.latest

net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

net.ipv6.conf.all.forwarding:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-arptables:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-ip6tables:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-iptables:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-filter-pppoe-tagged:
  sysctl.present:
    - value: 0

net.bridge.bridge-nf-filter-vlan-tagged:
  sysctl.present:
    - value: 0

net.bridge.bridge-nf-pass-vlan-input-dev:
  sysctl.present:
    - value: 0


/usr/lib/coreos:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/var/lib/coreos:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
