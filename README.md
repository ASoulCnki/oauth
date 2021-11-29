# ASoulCnki Anniversary Service

（枝网 OAuth 及 周年报告服务）

## 本服务提供以下内容

- 统一的 OAuth 鉴权（基于 B 站私信）
- 枝网周年报告

## 安装

使用前，请确保您已经安装 Python3 和 OpenResty 以及 OpenResty 包管理工具 opm

如果没有，请先前往安装

### 依赖安装

这里安装 Python 和 OpenResty 的依赖

```bash
pip3 install -r requirements.txt
```

```bash
opm get openresty/lua-resty-redis \
  openresty/lua-resty-mysql \
  anjia0532/lua-resty-redis-util \
  thibaultcha/lua-resty-jit-uuid \
  tokers/lua-resty-requests
```

<del>如果你不喜欢使用 opm，也可以使用 LuaRocks</del>

现在必须要用了 :(

需要额外安装这个包

```bash
luarocks install lua-resty-socket
```

## 其他

不同地区 dns 解析情况可能不同，如果私信收发网络状态太差，可以尝试更改 conf/nginx.conf 的 resolver

## 如何启动

1. 将 `lua/config/config.lua.bak` 重命名为 `lua/config/config.lua` 并修改相应配置

2. 将自己机器人的 cookie 添加到 `lua/listener/constant.lua` 的 cookie 字段

3. 将这个文件夹的内容全部复制到 openresty 目录下的 nginx 下，**记得改好权限**

4. 启动 openresty

不复制文件可以选择在当前目录直接启动，需要添加参数，命令为

```sh
openresty -p `pwd` -c conf/nginx.conf
```
