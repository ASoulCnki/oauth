local utils = require("lua.listener.utils")
local message_list = require("listener.message").message_list
local uuid = require("resty.jit-uuid")
local ngx = require("ngx")
local bind = require("auth").bind
local config = require("lua.config.config")

-- localize functions for performance
local new_timer = ngx.timer.every
local filter = utils.table_filter
local map = utils.table_map
local chunk = utils.table_chunk

-- get message and put uuid, uid to redis
local single_handler = function(cookie)
    local data = message_list(cookie)

    if not data then
        -- TODO: health check: if get message failed
        --   should not use this cookie
        ngx.log(ngx.ERR, "failed to get message")
        return
    end

    local res = filter(data, function(v)
        return v.msg_type == 1 and #v.content > 10
    end)

    map(res, function(v)
        -- get uuid , and uuid length is 36
        -- v.content like "au73550d38-976f-4fc5-8bdf-1afbe42a6ea7"
        local token, uid = string.sub(v.content, 3, 38), v.uid

        ngx.log(ngx.ERR, "auth uid: ", uid)
        local ok, err = bind(token, uid)
        if not ok then
            ngx.log(ngx.ERR, string.format("bind token: %s, uid: %s failed, err: %s", token, uid, err))
        end
    end)
end

local handler = function()
    local worker_id = ngx.worker.id() + 1
    local cookie_t = chunk(config.cookie_table, config.worker_num)[worker_id]

    if not cookie_t then
        ngx.log(ngx.ERR, "cookie_t is nil")
        return
    end

    for _, cookie in ipairs(cookie_t) do
        single_handler(cookie)
    end
end

-- chunk size should be worker number

-- if 0 == ngx.worker.id() then

local ok, err = new_timer(5, handler) -- exec handler every 5 seconds
if not ok then
    ngx.log(ngx.ERR, "failed to create timer: ", err)
    return
end
-- end

uuid.seed()
local _ = math.randomseed(ngx.now())
