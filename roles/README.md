## roles

| roles              | description                                                                                                              |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| roles/certbot      | 安装 certbot, 并通过 dns plugin 生成 wildcard cert                                                                       |
| roles/common       | 一些服务器的初始化操作, 常用软件包安装, TCP BBR 设置, `/etc/sysctl.conf` 参数设置等                                      |
| roles/docker       | 安装 docker 及容器化相关工具, docker daemon 配置                                                                         |
| roles/nginx        | 可以选择使用多个来源安装 Nginx, nginx_org 或 xtom_com                                                                    |
| roles/nginx_config | 用于 Nginx 配置文件初始化和 server 配置文件生成                                                                          |
| roles/rsstt        | 通过 PyPI 安装 [RSS-to-Telegram-Bot](https://github.com/Rongronggg9/RSS-to-Telegram-Bot) 并为其配置 telegraph_token      |
| roles/v2ray        | 通过 GitHub releases 安装 [v2ray](https://github.com/v2fly/v2ray-core/releases)                                          |
| roles/v2ray_config | 提供几种常用的 v2ray 配置文件模板, 如 Trojan-TCP, VMess-WSS 等, 具体参考 roles [README.md](roles/v2ray_config/README.md) |

## TODOs

- [ ] roles/pypi_install
  - 可以将 roles/rsstt 抽象一下
  - 大体上还是创建 venv 安装
- [ ] roles/github_releases_install
  - roles/v2ray 中使用了这部分逻辑
  - 只是不同软件的压缩档和安装方式不一定一样, 需要在 playbooks 中深度适配
