# Ansible Role `certbot`

主要使用 dns plugin 来生成 wildcard cert,
目前我的域名托管在 Cloudflare 上, 因此 `certbot_dns_plugin` 默认值为 `cloudflare`, 即安装和使用 `dns-cloudflare` 插件.

## tasks

- 通过 apt repo 或者 PyPI 安装 `certbot`, `certbot-dns-cloudflare`, ...
  - 当从 PyPI 安装时, 复制 systemd unit files, 执行 daemon-reload 并 enable
- 根据提供的 token 创建 credentials 文件
- 执行等效于如下选项的 `certbot` 命令

```shell
certbot certonly \
    --non-interactive \
    --agree-tos \
    --email=certbot@example.com \
    --dns-cloudflare \
    --dns-cloudflare-credentials=/etc/letsencrypt/credentials/cloudflare.ini \
    --domain='example.com,*.example.com' \
    --dns-cloudflare-propagation-seconds=30
```

## vars

| name                               | description                                                                                                | default                       | available value                               |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------- | ----------------------------- | --------------------------------------------- |
| `certbot_install_source`           | 从何处安装 certbot                                                                                         | `pypi`                        | `pypi, apt`, 部分发行版中 certbot 版本过低    |
| `certbot_dns_plugin`               | 使用什么 DNS plugin                                                                                        | `cloudflare`                  | `cloudflare, cloudxns, digitalocean, linode`  |
| `certbot_dns_propagation_seconds`  | The number of seconds to wait for DNS to propagate before asking the ACME server to verify the DNS record. | `30`                          | `int`, 使用 `linode` 时请设置更大的值如 `120` |
| `certbot_domain`                   | 需要申请证书的域名                                                                                         | `example.com,www.example.com` | FQDN domain                                   |
| `certbot_dns_cloudflare_api_token` | Cloudflare API Token                                                                                       | <empty>                       | `str`                                         |
| `certbot_dns_cloudxns_api_key`     | CloudXNS API Key                                                                                           | <empty>                       | `str`                                         |
| `certbot_dns_cloudxns_secret_key`  | CloudXNS Secret Key                                                                                        | <empty>                       | `str`                                         |
| `certbot_dns_digitalocean_token`   | DigitalOcean Token                                                                                         | <empty>                       | `str`                                         |
| `certbot_dns_linode_key`           | Linode Key                                                                                                 | <empty>                       | `str`                                         |
| `certbot_dns_linode_version`       | Linode Version                                                                                             | <empty>                       | `<empty>, 3, 4`                               |
