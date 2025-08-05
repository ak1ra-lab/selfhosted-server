## roles/rsstt

使用 `ansible-playbook` 安装 [RSStT](https://github.com/Rongronggg9/RSS-to-Telegram-Bot), 赞美 Rongronggg9.

## quick start

```shell
ansible-playbook playbooks/rsstt.yaml -e 'playbook_hosts=remote-server' -e @credentials/rsstt.yaml --ask-vault-pass
```

其中 `credentials/rsstt.yaml` 文件中包含一些敏感信息, 这个文件经过 `ansible-vault` 加密, 需要自行创建.

## `credentials/rsstt.yaml` 内容示例

初次部署时, 可以只填入`rsstt_token`, `rsstt_manager` 和 `rsstt_telegraph_token_count`,
比如 `rsstt_telegraph_token_count: 5`, 执行 Playbook 时会循环创建网络请求创建 5 个 token.

```yaml
# roles/rsstt
rsstt_token: 1234567890:A1BCd2EF3gH45IJK6lMN7oPqr8ST9UvWX0Yz0
rsstt_manager: 123456789
rsstt_telegraph_token_count: 5
```

初次部署成功后, 可以记录下 "debug var rsstt_telegraph_token" 任务的输出,
将 `rsstt_telegraph_token` 保存到 `credentials/rsstt.yaml` 中, 如,

```yaml
# roles/rsstt
rsstt_token: 1234567890:A1BCd2EF3gH45IJK6lMN7oPqr8ST9UvWX0Yz0
rsstt_manager: 123456789
rsstt_telegraph_token:
  - 1a23b456c78de90f1a23b456c78de90f1a23b456c78de90f1a23b456c78d
  - 1a23b456c78de90f1a23b456c78de90f1a23b456c78de90f1a23b456c78d
  - 1a23b456c78de90f1a23b456c78de90f1a23b456c78de90f1a23b456c78d
  - 1a23b456c78de90f1a23b456c78de90f1a23b456c78de90f1a23b456c78d
  - 1a23b456c78de90f1a23b456c78de90f1a23b456c78de90f1a23b456c78d
```

这样下次重新部署或更新软件版本时就可以重用过去申请的 telegraph token.

> [!notice] 如果"遗失"了这些 telegraph token, 相当于完全放弃了由 bot 推送的长文相关内容的"编辑权", 个人认为将其记录下来比较好.

## 新增 `rsstt_install_source`

该选项其值可以是 `pypi` 或者 `testpypi`,
指定为 `testpypi` 时会从 [TestPyPI](https://test.pypi.org/project/rsstt/) 安装 RSStT.

> You may also install RSStT from PyPI (tracking master branch) or TestPyPI (tracking dev branch, which is always up-to-date) using pip.
