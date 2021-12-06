local utils = require("listener.utils")
local message_list = require("listener.message").message_list
local uuid = require("resty.jit-uuid")
local ngx = require("ngx")
local bind = require("auth").bind

-- localize functions for performance
local new_timer = ngx.timer.every
local filter = utils.table_filter
local map = utils.table_map

-- get message and put uuid, uid to redis
local handler = function()

    local res = filter(message_list(), function(v)
        return v.msg_type == 1 and #v.content > 10
    end)

    map(res, function(v)
        -- get uuid , and uuid length is 36
        -- v.content like "au73550d38-976f-4fc5-8bdf-1afbe42a6ea7"
        local token, uid = string.sub(v.content, 3, 38), v.uid

        ngx.log(ngx.ERR, "token: ", token, " uid: ", uid)
        bind(token, uid)
    end)
end

if 0 == ngx.worker.id() then
    -- TODO:
    -- 1. support multi-account
    -- 2. assign different cookie to different worker

    local ok, err = new_timer(5, handler) -- exec handler every 5 seconds
    if not ok then
        ngx.log(ngx.ERR, "failed to create timer: ", err)
        return
    end
end

uuid.seed()
local _ = math.randomseed(ngx.now())
