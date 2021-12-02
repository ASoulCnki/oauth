local ngx = require("ngx")
local json = require("cjson")
local auth = require("auth")
local db = require("data")
local cache = ngx.shared.report_cache

local function NotAuthorized(err)
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say(string.format([[{"code": 401,"message": "%s"}]], err))
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

local function handleData(data)
    -- TODO: filter rules
    return data
end

-- auth start

local authorization = ngx.req.get_headers()["authorization"]

local uid, err = auth.auth(authorization)

if not uid then
    NotAuthorized(err)
end

-- auth end

local data, _ = cache:get(uid)

-- 防止缓存穿透
if data == "null" then
    ngx.say([[{"code": 404,"message": "not data", "data": {}}]])
    ngx.exit(ngx.HTTP_OK)
end

if not data then

    -- get data from db
    data, _ = db.getDataFromDB(uid)

    if not data then
        -- since this uid may not exist in db, we set "null" to cache
        -- to avoid query from db again
        cache:set(uid, "null", 300)
        ngx.say([[{"code": 404,"message": "not data", "data": {}}]])
        ngx.exit(ngx.OK)
    end

    -- TODO: handle data, waiting user tables

    data = json.encode(handleData(data))
    cache:set(uid, data, 7200 + math.random(0, 600))
end

ngx.say(data)
ngx.exit(ngx.HTTP_OK)
