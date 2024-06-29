
# roles/v2ray_config

感谢 [v2fly/v2ray-examples](https://github.com/v2fly/v2ray-examples) 维护了一组不同方案的配置模板.

## 配置文件格式

目前 v5 配置文件格式仍处于[草案阶段](https://www.v2fly.org/v5/config/overview.html),
阅读文档时也发现很多地方没写完整, 于是继续用 [v4 配置文件格式](https://www.v2fly.org/config/overview.html).

v4 配置文件形式如下:

```json
{
    "log": {},
    "api": {},
    "dns": {},
    "routing": {},
    "policy": {},
    "inbounds": [],
    "outbounds": [],
    "transport": {},
    "stats": {},
    "reverse": {},
    "fakedns": [],
    "browserForwarder": {},
    "observatory": {}
}
```

## systemd service unit

[v2fly/fhs-install-v2ray](https://github.com/v2fly/fhs-install-v2ray)
提供了两种 systemd service 服务启动方式, [roles/v2ray](../v2ray/) 同样保留了这两种:

* 单实例启动: `/etc/systemd/system/v2ray.service`
* 多实例启动: `/etc/systemd/system/v2ray@.service`

二者均可以 systemd 的特性在 `v2ray.service.d/` 或 `v2ray@.service.d` 子目录中创建新的配置
来覆盖上级 service unit 中的配置, 从而避免直接修改原本的 service unit 文件.
又因为较新版本的 systemd 因为文件权限带来的安全性问题不再建议使用 `User=nobody`,
而建议启用 [DynamicUser=](https://www.freedesktop.org/software/systemd/man/systemd.exec.html#DynamicUser=)

综合上述因素, 创建了 [templates/20-dynamic-user.conf.j2](templates/20-dynamic-user.conf.j2),
用于启用 `DynamicUser=`, 添加 `LogsDirectory=`, 以及配置使用 `-confdir` 选项启动 v2ray-core 实例.

## [templates/](templates/) 目录结构

v2ray 在不同的配置下即可以作为 client, 又可以作为 server,
混淆协议和传输层协议的不同组合又带来各种不同的使用方式,
如果使用传统的单文件配置方式, 想要支持多种使用场景的 profile 会使得 Jinja 模板过于复杂,
否则只能使用 systemd 的"多实例"启动, 但这样又有些浪费资源了;
v2ray 本身也支持[多文件配置](https://www.v2fly.org/config/multiple_config.html),
以及 client/server 分别支持多个 outbounds/inbounds, 
把不同功能的配置拆分成单独的配置, 这种方式很适合使用模板生成配置, 于是决定采用单实例的多文件配置.

关于载入配置文件时 inbounds/outbounds 的特殊处理:

```
在 json 配置中的 inbounds 和 outbounds 是数组结构, 他们有特殊的规则:

* 当配置中的数组元素有 2 或以上, 覆盖前者的 inbounds/outbounds;
* 当配置中的数组元素只有 1 个时, 查找原有 tag 相同的元素进行覆盖; 若无法找到:
    * 对于 inbounds, 添加至最后(inbounds 内元素顺序无关)
    * 对于 outbounds, 添加至最前(outbounds 默认首选出口);
    * 但如果文件名含有 tail (大小写均可), 添加至最后.
借助多配置, 可以很方便为原有的配置添加不同协议的 inbound, 而不必修改原有配置.
```

推荐的多文件列表:

```
    00-log.json
    01-api.json
    02-dns.json
    03-routing.json
    04-policy.json
    05-inbounds.json
    06-outbounds.json
    07-transport.json
    08-stats.json
    09-reverse.json
```

按照这种方式的组织下, 便有了如今的 templates 目录结构:

```
templates/
├── 20-dynamic-user.conf.j2
├── client
│   ├── 00-log.json.j2
│   ├── 03-routing.json.j2
│   ├── 05-inbounds.json.j2
│   ├── 06-outbounds-trojan-tcp.json.j2
│   ├── 06-outbounds-trojan-wss.json.j2
│   ├── 06-outbounds-vmess-kcp.json.j2
│   ├── 06-outbounds-vmess-quic.json.j2
│   ├── 06-outbounds-vmess-tcp.json.j2
│   └── 06-outbounds-vmess-wss.json.j2
└── server
    ├── 00-log.json.j2
    ├── 03-routing.json.j2
    ├── 05-inbounds-trojan-tcp.json.j2
    ├── 05-inbounds-trojan-wss.json.j2
    ├── 05-inbounds-vmess-kcp.json.j2
    ├── 05-inbounds-vmess-quic.json.j2
    ├── 05-inbounds-vmess-tcp.json.j2
    ├── 05-inbounds-vmess-wss.json.j2
    └── 06-outbounds.json.j2

2 directories, 19 files
```

## 关于 templates/ 中预置的 混淆协议+传输层协议 组合模板

`v2ray_profile` 用于指定使用哪种 混淆协议+传输层协议 的组合, 默认值是 `vmess-wss`.

目前, [templates/](./templates/) 中内置了以下几种配置组合,

| profile | 混淆协议 | 传输层协议 | 是否启用 TLS | 备注 |
| ------------ | ------- | --------- | ----------- | ---- |
| `trojan-tcp` | Trojan  | TCP       | true  |    |
| `trojan-wss` | Trojan  | WebSocket | true  |    |
| `vmess-kcp`  | VMess   | mKCP      | false |    |
| `vmess-quic` | VMess   | QUIC      | true  |    |
| `vmess-tcp`  | VMess   | TCP       | true  |    |
| `vmess-wss`  | VMess   | WebSocket | true  | Server 端使用 Nginx 反向代理 WebSocket 流量 |

templates/ 中 client 的 outbounds 和 server 的 inbounds 模板便采用这种方式命名的:

* `templates/client/06-outbounds-${profile}.json.j2`
* `templates/server/05-inbounds-${profile}.json.j2`

在使用对应的 profile 之前, 需要查看 [vars/main.yml](vars/main.yml) 中对应方案需要传入的配置项, 并理解为什么要传入这些值, 参考下一小节的概括.

## vars

* `v2ray_domain` 对于已启用 TLS 项的配置都需要传入, 即除 `vmess-kcp` 外都需传入:
    * 默认的 `example.com` 并不可用, 需要填入自己实际的域名;
    * 需确保在之前的步骤中已使用 [roles/certbot](../certbot/) 或其它方式生成 SSL 证书;
    * `v2ray_ssl_dir` 值有引用这个值, 即需确认对应域名的 SSL 证书已存在;

* `v2ray_type` 用于配置渲染 `server` 还是 `client` 配置, 默认值为 `server`.

* `v2ray_inbound_client_id` 用于配置 VMess 混淆协议下 `server.inbounds[0].settings.clients[0].id`, 后续考虑做多 clients id 支持

### `vmess-wss` (VMess-WebSocket-TLS)

VMess-WebSocket-TLS 组合下的配置项:

```
# VMess-WebSocket-TLS, use Nginx to reverse proxy
v2ray_vmess_wss_listen: 127.0.0.1
v2ray_vmess_wss_port: 1080
v2ray_vmess_wss_tls_port: 443
# wsSettings
v2ray_vmess_wss_host: "{{ v2ray_domain }}"
v2ray_vmess_wss_path: /websocket
```

正常情况下保持默认即可.

### `vmess-kcp` (VMess-mKCPSeed)

```
# VMess-mKCPSeed
v2ray_vmess_kcp_port: 10010
# kcpSettings server
v2ray_vmess_kcp_header_type: utp
# random if not given
v2ray_vmess_kcp_seed:
```

可选传入自定义 `v2ray_vmess_kcp_seed`, 如不传入则随机生成,
否则配置客户端时需要自行登录服务器查看配置文件中生成的随机 seed.

可以考虑传入 `v2ray_vmess_kcp_header_type`, 配置项位于 `mKCP.KcpObject.HeaderObject.type`, 此处默认值为 `utp`.

基于 UDP 的方案可以对流量进行伪装, 目前可用的伪装方式有:

```
"none": 默认值, 不进行伪装.
"srtp": 伪装成 SRTP 数据包, 会被识别为视频通话数据(如 FaceTime).
"utp": 伪装成 uTP 数据包, 会被识别为 BT 下载数据.
"wechat-video": 伪装成微信视频通话的数据包.
"dtls": 伪装成 DTLS 1.2 数据包.
"wireguard": 伪装成 WireGuard 数据包.(并不是真正的 WireGuard 协议)
```

其余项可保持默认值.

### `vmess-quic` (VMess-QUIC-TLS)

```
# VMess-QUIC-TLS
v2ray_vmess_quic_port: 10020
# quicSettings
v2ray_vmess_quic_security: chacha20-poly1305
# random if not given
v2ray_vmess_quic_key:
v2ray_vmess_quic_header_type: utp
```

可选传入自定义 `v2ray_vmess_quic_key`, 如不传入则随机生成,
否则配置客户端时需要自行登录服务器查看配置文件中生成的随机 key.

可以考虑传入 `v2ray_vmess_quic_header_type`, 配置项位于 `QUIC.QuicObject.HeaderObject.type`, 默认值为 `utp`.

基于 UDP 的方案可以对流量进行伪装, 目前可用的伪装方式有:

```
"none": 默认值, 不进行伪装.
"srtp": 伪装成 SRTP 数据包, 会被识别为视频通话数据(如 FaceTime).
"utp": 伪装成 uTP 数据包, 会被识别为 BT 下载数据.
"wechat-video": 伪装成微信视频通话的数据包.
"dtls": 伪装成 DTLS 1.2 数据包.
"wireguard": 伪装成 WireGuard 数据包.(并不是真正的 WireGuard 协议)
```

其余项可保持默认值.

### `vmess-tcp` (VMess-TCP-TLS)

```
# VMess-TCP-TLS
v2ray_vmess_tcp_port: 6443
```

保持默认值即可.

### `trojan-tcp` (Trojan-TCP-TLS)

```
# Trojan-TCP-TLS
v2ray_trojan_tcp_port: 7443
# password, no UUID here, random if not given
v2ray_trojan_tcp_password:
```

可选传入 `v2ray_trojan_tcp_password`, 如不传入则随机生成,
否则配置客户端时需要自行登录服务器查看配置文件中生成的随机 password.

其余项保持默认值即可.

## 启动过程中可能的报错

在使用基于 UDP 的方案时, 可能会报 UDP Receive Buffer Size 太小相关的错误,
这时候可能需要调整 `net.core.rmem_max` 和 `net.core.wmem_max` 的大小.

参考 [UDP Receive Buffer Size · lucas-clemente/quic-go Wiki](https://github.com/lucas-clemente/quic-go/wiki/UDP-Receive-Buffer-Size)
