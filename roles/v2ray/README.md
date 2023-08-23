
# Ansible Role `v2ray`

用于从 [Releases · v2fly/v2ray-core](https://github.com/v2fly/v2ray-core/releases) 下载二进制发行包并按 FHS (Filesystem Hierarchy Standard) 将文件安装(复制)到系统相应位置.

## tasks

> 这个 role 最开始是复制 [v2fly/fhs-install-v2ray](https://github.com/v2fly/fhs-install-v2ray) 的中的 install-release.sh 到系统中然后执行,
> 后来觉得这样不够 Ansible style, 于是参照脚本内容分解成了多个 tasks, ~~考虑有用到这个脚本的可能, 因此仍保留复制这个脚本到系统中的 task.~~

> 注意: 虽然可以下载安装 v2fly/v2ray-core 中所有的 Releases, 但是我不确定是否所有的目标系统都遵循 FHS, 因此这个 role 仅在 Debian 中测试过.

具体 tasks:

* 调用 [GitHub Releases API](https://docs.github.com/en/rest/releases/releases#get-the-latest-release) 获取特定版本二进制发行包的下载地址, 默认 latest.
* 下载 Releases 中的 .dgst 文件, 获取文件内容中的压缩包文件校验值
* `ansible.builtin.get_url` 带上 `checksum` 选项下载, 下载后解压至临时目录
* 在 remote_src 按 FHS 复制文件至对应目录, 复制任务配置有 `test v2ray config` 和 `systemctl daemon-reload` 的 handlers
* 复制完成后清理临时目录

## vars

需要在意的 `vars` 只有 `v2ray_version`, 默认值为 `latest`, 需要安装特定版本 Release 可以设置 Releases 页面上存在的 tag; 其余 `vars` 保持默认值就好.
