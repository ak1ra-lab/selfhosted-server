## roles/cloud_init/network_config

这个 Ansible roles 主要做了两件事情,

1. (可选地)禁用 cloud-init network config

- 删除原本由 PVE cloud-init drive 创建的 `/etc/netplan/50-cloud-init.yaml`
- 添加静态 netplan 配置文件 `/etc/netplan/90-default.yaml`
- 根据 `tproxy_enabled` 选项决定是否覆盖 `default_gateway` 和 `default_nameservers`
  - 如果 `tproxy_enabled` 为 true, 则将 `tproxy_gateway` 的值覆盖 `default_gateway` 和 `default_nameservers`
  - 如果 `tproxy_enabled` 为 false, 则 `default_gateway` 保持当前默认值, `default_nameservers` 被设置为 Cloudflare DNS

2. (可选地)为 systemd-resolved 配置 global DNS

- 配置项 `resolved_override` 决定是否为 systemd-resolved 创建 global DNS
  - 如果 `resolved_override` 为 true, 则会创建 `/etc/systemd/resolved.conf.d/90-override.conf` 文件
  - 如果 `resolved_override` 为 false, 则会在 `/etc/netplan/90-default.yaml` 中添加 per interface nameservers

## 为什么要编写这个 Ansible roles?

PVE (Proxmox VE) 的集成的 cloud-init drive 可以比较方便地在创建虚拟机时做一些初始化,

- cloud-init 网络相关的配置通过 netplan 实现
- 而 cloud-init drive 生成的配置会写入 `/etc/netplan/50-cloud-init.yaml`, 它创建的配置有几个问题,
  - 使用的模板格式偏旧, 使用了 `gateway4` 这种过时配置
  - 权限配置不正确, netplan 要求 `0600`, 它创建的文件是 `0644`
  - 这使得每次执行 `netplan try` 时会给出好几个 warning

尽管 PVE 的 cloud-init drive 在初始化虚拟机的时候非常方便, 但是之后想要通过 cloud-init 修改网络配置时, 都需要重启主机才能生效, 比如将 `default_gateway` 修改为 [sing-box `tproxy_gateway` 旁路网关](https://github.com/ak1ra-lab/sing-box-tproxy) (~~好棒! 又是与 GFW 搏斗的一天!!~~), 这也是为什么这里会实现 `tproxy_enabled` 选项. 然而频繁重启虚拟机在某些业务场景下是不能被接受的, 直接编辑 `/etc/netplan/50-cloud-init.yaml` 虽然可行, 但是下次虚拟机重启修改会被 cloud-init 覆盖, 因此不如一劳永逸, 待虚拟机 static IP 确定下来之后避免由 cloud-init 配置网络, 这可能会造成一些不便, 不过相比重启带来的困扰这些不便相对更能接受. 这套流程并没有完全禁用 cloud-init 功能, 仅仅禁用了 network config, 其它功能依然健在.

额外添加 `cloud_init_ssh_deletekeys` 选项则用于保留 `/etc/ssh/ssh_host_*` keys, 未配置前每次修改 cloud-init drive 配置, 会使得 cloud-init 当作一台全新的机器重新生成 sshd host keys, 使得 openssh-server fingerprint 发生变化, 这在有些场景下非常令人困扰.

## `/etc/systemd/resolved.conf.d/90-override.conf`

这份配置文件借鉴自 [systemd-resolved](https://wiki.archlinux.org/title/Systemd-resolved) 页面, 注释中的 `Domains=~.` 的部分, 原文如下,

> It is highly advised to use an encrypted protocol when connecting to third-party DNS services. See #DNS over TLS.
> Without the `Domains=~.` option in resolved.conf(5), systemd-resolved might use the per-link DNS servers, if any of them set `Domains=~.` in the per-link configuration.
> This option will not affect queries of domain names that match the more specific search domains specified in per-link configuration, they will still be resolved using their respective per-link DNS servers.

`Domains=~.` 是 systemd-resolved 的默认路由声明, 表示{此 DNS 应处理所有未匹配更具体域名的查询}.

- 若全局未配置 `Domains=~.` 但某接口配置了, 该接口的 DNS 会成为默认路由, 全局 DNS 被忽略
- 若全局和接口均配置 `Domains=~.`, 全局 DNS 优先
- 不影响更具体的域名路由 (如 `Domains=cluster.local` 的查询仍会走对应接口 DNS)
