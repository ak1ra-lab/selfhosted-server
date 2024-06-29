# `ak1ra_lab/selfhosted_server`

## Quick start

```
git clone git@github.com:ak1ra-lab/selfhosted-server.git
cd selfhosted-server && make install
```

执行 `make install` 会将 collection 安装到 `~/.ansible/collections` 目录, 在其他目录中使用本 collection 中的 roles 时注意使用 FQDN (fully qualified domain name), 即带上 `ak1ra_lab.selfhosted_server.` 前缀, 参考 [roles/](./roles/) 目录.

## `Makefile`

我们在 [`Makefile`](./Makefile) 中预置了一些常用的 ansible-playbook Makefile receipts,
可以使用 `make` 或者 `make help` 查看帮助信息,

```ShellSession
$ make help
fmt         reformat yaml files
install     install this ansible collection
clean       clean up working directory
encrypt     ansible-vault encrypt credentials/*.yaml
decrypt     ansible-vault decrypt credentials/*.yaml
common      initial tasks with roles/common
docker      install docker with roles/docker
certbot     install certbot with roles/certbot
nginx       install nginx with roles/nginx and roles/nginx_config
gcloud      install gcloud with roles/gcloud
jenkins     install jenkins with roles/jenkins
rsstt       install RSStT with roles/rsstt (https://github.com/Rongronggg9/RSS-to-Telegram-Bot)
```

## Scripts

- [init-user.sh](./init-user.sh), 用于处理没有 cloud-init 加持的服务器最基本的初始化, 普通用户创建, 添加 SSH keys.

## License

MIT License
