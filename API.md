# 枝网 OAuth API 文档

## 获取新的 token

token 需要用户发私信验证之后才能正常使用，未绑定的 token 两分钟会过期

```http
GET /verify
```

## 鉴权

只要不是 DELETE 都可以用

```http
GET /verify

Authorization: token
```

### 返回值

| 名称    | 解释                |
| ------- | ------------------- |
| code    | 为 0 时，验证成功   |
| message | 报错信息，默认为 ok |
| uid     | 和对应用户的 uid    |

```json
{
  "uid": 114514,
  "code": 0,
  "message": "ok"
}
```

## 取消授权

```http
DELETE /verify

Authorization: token
```

### 返回值

| 名称    | 解释                |
| ------- | ------------------- |
| code    | 为 0 时，验证成功   |
| message | 报错信息，默认为 ok |

```json
{
  "code": 0,
  "message": "ok"
}
```

## 获取授权码

```http
GET /code

Authorization: token
```

### 响应

| 名称        | 解释                                                         |
| ----------- | ------------------------------------------------------------ |
| code        | 为 0 时，验证成功                                            |
| message     | 报错信息，默认为 ok                                          |
| data.token  | 获取的授权码，可以用于鉴权接口<br>但是不能用于获取新的授权码 |
| data.expire | 当前授权码过期时间，13 位时间戳                              |

```json
{
  "data": {
    "expire": 1638774558430,
    "token": "9ff816dc**************e660df483b"
  },
  "code": 0,
  "message": "ok"
}
```

## 获取机器人账号 UID

```http
GET /uid
```

### 响应

| 名称    | 解释                |
| ------- | ------------------- |
| code    | 为 0 时，验证成功   |
| message | 报错信息，默认为 ok |
| uid     | 机器人账号的 uid    |

```json
{
  "code": 0,
  "message": "ok",
  "uid": 114514
}
```
