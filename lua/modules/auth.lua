local ngx = require("ngx")
local redis = require("resty.redis-util")
local config = require("lua.config.config")
local uuid = require('resty.jit-uuid')
local json = require('cjson')

local session_cache = ngx.shared.session_cache
local red, _ = redis:new(config.redisConfig)

local ERROR = {
    USER_NOT_EXIST = "this user not exist",
    INVALID_TOKEN = "invalid token",
    SERVER_ERROR = "interval server error"
}

-- get verify code
local function code()
    local token = uuid()
    ngx.say(token)
    ngx.eof()

    red:init_pipeline(2)

    red:set(token, "-1")
    red:expire(token, config.Auth.expireTokenTime)

    local ok, err = red:commit_pipeline()

    if not ok then
        ngx.log(ngx.ERR, "failed to connect redis", err)
    end
end

-- format tuple to hash table
local function genBlackList()
    if config.Auth.enableBlackList then
        local cache = {}
        local t = config.Auth.blackUidList
        for _, v in ipairs(t) do
            cache[v] = true
        end
        return cache
    end
    return nil
end

local blackList = genBlackList()

-- get uid from authorization, if not exist, return nil
local function auth(authorization)
    if not (authorization) then
        return nil, ERROR.USER_NOT_EXIST
    end

    local uid, ok, err

    -- get uid from shared_dict, if not exist, query from redis
    uid = session_cache:get(authorization)

    if not uid then
        -- get session from redis
        uid, _ = red:get(authorization)

        -- "-1" is invalid since uid was init with "-1"
        if not uid or uid == ngx.null or uid == "-1" then
            return nil, ERROR.USER_NOT_EXIST
        end

        -- if valid uid, add to shared_dict with expire 10 mins
        ok, err = session_cache:set(authorization, uid, 600 + math.random(0, 90))

        if not ok then
            ngx.log(ngx.ERR, "failed to set cache: ", err)
        end
    end

    if blackList and blackList[uid] then
        return nil, ERROR.SERVER_ERROR
    end

    return uid, "ok"
end

-- revoke token, if token not exist in redis, return nil
local function revoke(authorization)

    local uid, err = auth(authorization)

    if not uid then
        return nil, err
    end

    session_cache:delete(authorization)

    local ok, _ = red:get(authorization)

    if not ok or ok == ngx.null then
        return nil, ERROR.USER_NOT_EXIST
    end

    ok, err = red:del(authorization)

    if not ok then
        return nil, err
    end

    return ok, "ok"
end

-- bind uuid to uid
local function bind(token, uid)
    if not uuid.is_valid(token) then
        return nil, ERROR.INVALID_TOKEN
    end
    -- get current uid by token, is token used by other uid, return nil 
    local cur_uid, _ = red:get(token)

    -- unused cur_uid should init with "-1"
    if not (cur_uid and cur_uid == "-1") then
        return nil, ERROR.INVALID_TOKEN
    end

    red:init_pipeline(2)

    red:set(token, uid)
    red:expire(token, config.Auth.expireSessionTime)

    return red:commit_pipeline()
end

local function temp_code(authorization)
    if not uuid.is_valid(authorization) then
        return nil, ERROR.INVALID_TOKEN
    end

    local uid, err = auth(authorization)

    if not uid then
        return nil, err
    end

    local key = "temp_" .. uid

    local data, _ = red:get(key)

    if not data then
        local token = uuid()
        token = ngx.md5(token)

        data = {
            token = token,
            expire = (ngx.now() + config.Auth.expireTempCodeTime) * 1000
        }

        data = json.encode(data)

        red:init_pipeline(4)

        red:set(key, data)
        red:set(token, uid)
        red:expire(token, config.Auth.expireTempCodeTime)
        red:expire(key, config.Auth.expireTempCodeTime)

        local ok, err = red:commit_pipeline()

        if not ok then
            ngx.log(ngx.ERR, "failed to connect redis", err)
        end
    end

    return data, "ok"
end

local _M = {}

_M.code = code
_M.auth = auth
_M.revoke = revoke
_M.bind = bind
_M.temp_code = temp_code

return _M
