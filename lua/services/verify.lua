local auth = require("auth")
local ngx = require("ngx")

local function NotAuthorized(err)
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say(string.format([[{"code": 401,"message": "%s"}]], err))
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

local authorization = ngx.req.get_headers()["authorization"]

if not authorization then
    auth.code()
    ngx.exit(ngx.HTTP_OK)
end

local method = ngx.req.get_method()

if method == 'DELETE' then
    local ok, err = auth.revoke(authorization)

    if not ok then
        NotAuthorized(err)
    end

    ngx.say([[{"code": 0,"message": "ok"}]])
else
    local uid, err = auth.auth(authorization)

    if not uid then
        NotAuthorized(err)
    end

    ngx.say(string.format([[{"code": 0,"message":"ok", "uid": %s}]], uid))
end
