# ASoulCnki OAuth

（枝网 OAuth 服务）

## 本服务提供以下内容

- 统一的 OAuth 鉴权（基于 B 站私信）

## 待完成

0. 添加账号池，支持多个账号同时抓取私信
1. 将不同的账号分配给不同的 worker
2. 新增授权码接口，提供短时间的授权
   1. 目前为固定时间只分配一个 token
   2. 希望后续能根据传参约定 token 有效时间

## 安装

依赖

- Openresty
- opm
- luarocks
- Redis

如果没有，请先前往安装，opm 随 OpenResty 携带，请检查 OpenResty 的 bin 目录，并将其添加到环境变量

redis 和 luarocks 可以通过包管理工具获取

### 依赖安装

```bash
opm get openresty/lua-resty-redis \
  openresty/lua-resty-mysql \
  anjia0532/lua-resty-redis-util \
  thibaultcha/lua-resty-jit-uuid \
  tokers/lua-resty-requests
```

```bash
luarocks install lua-resty-socket
```

## 其他

不同地区 dns 解析情况可能不同，如果私信收发网络状态太差，可以尝试更改 conf/nginx.conf 的 resolver

## 如何启动

0. 安装 OpenResty 和 Redis

1. 将 `lua/config/config.lua.bak` 重命名为 `lua/config/config.lua` 并修改相应配置

2. 将自己机器人的 cookie 添加到 `lua/listener/constant.lua` 的 cookie 字段

3. 将这个文件夹的内容全部复制到 openresty 目录下的 nginx 下，**记得改好权限**

4. 启动 openresty

不复制文件可以选择在当前目录直接启动，需要添加参数，命令为

```sh
openresty -p `pwd` -c conf/nginx.conf
```
