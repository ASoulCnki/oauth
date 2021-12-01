# 枝网周年服务 API 文档

## 鉴权接口

### 获取新的 token

token 需要用户发私信验证之后才能正常使用，未绑定的 token 两分钟会过期

```http
GET /verify
```

### 鉴权

只要不是 DELETE 都可以用

```http
GET /verify

Authorization: token
```

#### 返回值

| 名称    | 解释                |
| ------- | ------------------- |
| code    | 为 0 时，验证成功   |
| message | 报错信息，默认为 ok |
| uid     | 和对应用户的 uid    |

## 取消授权

```http
DELETE /verify

Authorization: token
```

#### 返回值

| 名称    | 解释                |
| ------- | ------------------- |
| code    | 为 0 时，验证成功   |
| message | 报错信息，默认为 ok |

## 周年报告接口

### 获取报告

```http
GET /report

Authorization: token
```

#### 返回值

(字段待确定)
