local ngx = require("ngx")
local auth = require("modules.auth")

local function NotAuthorized(err)
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say(string.format([[{"code":401,"message":"%s"}]], err))
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end
-- auth start

local authorization = ngx.req.get_headers()["authorization"]

local token, err = auth.temp_code(authorization)

if not token then
    NotAuthorized(err)
end

local resp_template = [[{"code":0,"message":"ok","data":%s}]]
ngx.say(string.format(resp_template, token))
