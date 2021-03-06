# ASoulCnki OAuth

（枝网 OAuth 服务）

## 本服务提供以下内容

- 统一的 OAuth 鉴权（基于 B 站私信）

## 待完成

1. 新增授权码接口，提供短时间的授权
   1. <del>目前为固定时间只分配一个 token</del>
   2. 希望后续能根据传参约定 token 有效时间
2. 新增管理 API 用于管理 OAuth 服务

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

1. 将 `lua/config/config.lua.bak` 重命名为 `lua/config/config.lua` 并修改相应配置，必选配置项如下

   - Redis 地址，密码，如果无密码请填写 `nil`
   - 监听账号的 cookie，可配置多个，必选字段请参照文件内描述

2. 将这个文件夹的内容全部复制到 openresty 目录下的 nginx 下，**记得改好权限**

3. 启动 openresty

4. 可选配置项有
   - 用户 session，token 的过期时间
   - 用户鉴权使用的头(尚在施工，目前只支持 `Authorization` 头)
   - 根据 UID 做的黑名单

不复制文件可以选择在当前目录直接启动，需要添加参数，命令为

```sh
openresty -p `pwd` -c conf/nginx.conf
```

每次修改配置后，需要 `reload`

```sh
openresty -p `pwd` -c conf/nginx.conf -s reload
```
