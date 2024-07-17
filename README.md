# `ak1ra_lab/selfhosted_server`

## Quick start

```
# install ansible using pipx
sudo apt-get update -y
sudo apt-get install -y pipx
pipx install ansible

# pipx install ansible 时只会为 ansible 创建软链接
ln -sf ~/.local/pipx/venvs/ansible/bin/ansible* ~/.local/bin/

# install collection
git clone https://github.com/ak1ra-lab/selfhosted-server.git
cd selfhosted-server

PLAYBOOK_HOST=local make install
```

`make install` 会使用 `community.general.ansible_galaxy_install` module 安装 collection, 通过传入 `PLAYBOOK_HOST` 环境变量, 可以比较方便在多台主机上安装此 collection, collection 安装后在别的 playbook 中使用时需要使用 FQDN (fully qualified domain name). 本项目的 namespace 是 `ak1ra_lab.selfhosted_server`.

> NOTE: `community.general.ansible_galaxy_install` 会在一个"全新"的 shell 中执行 ansible-galaxy 命令? 本地运行的时候没有问题, 放到 CI 上时, `requirements_file` 一直提示无法找到文件, 大概是无法使用相对路径.

## pipx inject

使用 pipx 安装的 ansible 有时候会缺失一些 Python 依赖,

* 可以使用 `pipx runpip ansible list -v` 查看 ansible 安装的 Python 依赖
* 以 `boto3` 为例, 可以使用 `pipx inject ansible boto3` 安装缺失的依赖
* 参考 install.yaml 中 `community.general.pipx` task

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
