local ngx = require("ngx")
local utils = require("lua.listener.utils")
local cookie_table = require("lua.config.config").cookie_table

local map = utils.table_map
local parse_cookie = utils.parse_cookie

local cookie_map = map(cookie_table, function(v)
    local cookie_t = parse_cookie(v)
    return cookie_t.DedeUserID
end)

local random = math.random(1, #cookie_map)

local account_id = cookie_map[random]

if account_id then
    ngx.say(string.format([[{"code":0,"message":"ok","uid":"%s"}]], account_id))
else
    ngx.say(string.format([[{"code":-1,"message":"error","uid":null}]]))
end
