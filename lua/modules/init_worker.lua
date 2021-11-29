local redis = require("resty.redis-util")
local config = require("lua.config.config")
local utils = require("listener.utils")
local get_session_list = require("lua.listener.message").get_session_list
local uuid = require("resty.jit-uuid")
local ngx = require("ngx")

local new_timer = ngx.timer.every
local filter = utils.table_filter
local map = utils.table_map
local red = redis:new(config.redisConfig)

-- get message and put uuid, uid to redis
local handler = function()

    if not 0 == ngx.worker.id() then
        return
    end

    local res = get_session_list()

    res = filter(res, function(v)

        return v.msg_type == 1 and #v.content > 10
    end)

    map(res, function(v)
        -- get uuid , and uuid length is 36
        -- v.content like "au73550d38-976f-4fc5-8bdf-1afbe42a6ea7"
        local id, uid = string.sub(v.content, 3, 38), v.uid

        if uuid.is_valid(id) then
            local cur_uid, _ = red:get(id)

            if not (cur_uid and cur_uid == "-1") then
                return
            end

            ngx.log(ngx.ERR, "auth uid: ", uid)

            -- set uid to redis
            red:init_pipeline(2)

            red:set(id, uid)
            red:expires(id, config.Auth.expireSessionTime)

            local ok, err = red:commit_pipeline()

            if not ok then
                ngx.log(ngx.ERR, "failed to commit the pipelined requests: ", err)
            end
        end
    end)
end

if 0 == ngx.worker.id() then
    -- exec in every 5s
    local ok, err = new_timer(5, handler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create timer: ", err)
        return
    end
end

uuid.seed()
local _ = math.randomseed(ngx.now())
