## roles/cloud_init/network_config

这个 ansible roles 主要做了两件事情,

1. 禁用 cloud-init network config

- 删除原本由 PVE cloud-init drive 创建的 `/etc/netplan/50-cloud-init.yaml`
- 添加静态 netplan 配置文件 `/etc/netplan/90-default.yaml`
- 根据 `tproxy_enabled` 选项决定是否覆盖 `default_gateway` 和 `default_nameservers`
  - 如果 `tproxy_enabled` 为 true, 则将 `tproxy_gateway` 的值覆盖 `default_gateway` 和 `default_nameservers`
  - 如果 `tproxy_enabled` 为 false, 则 `default_gateway` 保持当前默认值, `default_nameservers` 被设置为 Cloudflare DNS

2. 为 systemd-resolved 配置 global DNS

- 配置项 `resolved_override` 决定是否为 systemd-resolved 创建 global DNS
  - 如果 `resolved_override` 为 true, 则会创建 `/etc/systemd/resolved.conf.d/90-override.conf` 文件
  - 如果 `resolved_override` 为 false, 则会在 `/etc/netplan/90-default.yaml` 中添加 per interface nameservers

## 为什么要编写这个 ansible roles?

PVE (Proxmox VE) 的集成的 cloud-init Drive 可以比较方便地在创建虚拟机时做一些初始化设置,

- cloud-init 网络相关的配置通过 netplan 实现
- 而 cloud-init 生成的 netplan 配置会写入 `/etc/netplan/50-cloud-init.yaml`
  - PVE cloud-init driver 使用的模板格式偏旧, 使用了 `gateway4` 这种过时配置
  - 而且权限配置也不正确, netplan 要求 `0600`, 它创建的文件是 `0644`
  - 使得每次执行 `netplan try` 时会给出好几个 warning

尽管 PVE 的 cloud-init 这套工作流在初始化虚拟机的时候非常方便, 但是之后想要通过 cloud-init 修改网络配置时, 比如将默认网关修改为 tproxy 旁路网关, 这也是为什么里面会实现 `tproxy_enabled` 选项, 都需要重启主机才能生效, 直接编辑 `/etc/netplan/50-cloud-init.yaml` 虽然也是可行的, 但是下次重启会被覆盖掉, 然而重启虚拟机在某些业务场景下是不能被接受的, 这种场景下可以禁用 cloud-init 网络配置功能, 但是并没有完全禁用 cloud-init 功能, 比如 append ssh keys 等.
