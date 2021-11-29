local ngx = require("ngx")
local mysql = require("resty.mysql")
local ndk = require("ndk")
local config = require("lua.config.config")

local db, _ = mysql:new()

local function getDataFromDB(uid)

    local res

    if not db then
        ngx.log(ngx.ERR, "failed to instantiate mysql: ")
        return
    end

    db:set_timeout(10000) -- 10 sec

    local ok, err, errCode, sqlState = db:connect(config.dbConfig)

    if not ok then
        ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errCode, " ", sqlState)
        return nil, 'interval server error'
    end

    -- TODO: update sql
    local statement = string.format([[select * from TABLE_NAME
        where mid = %s]], ndk.set_var.set_quote_sql_str(uid))

    res, err, errCode, sqlState = db:query(statement)

    if not res then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errCode, ": ", sqlState, ".")
        return
    end

    -- connection pool with 100 connections and 20s idle timeout
    ok, err = db:set_keepalive(20000, 100)
    if not ok then
        ngx.log(ngx.ERR, "failed to set keepalive: ", err)
        return
    end

    return res, 'ok'
end

local _M = {}

_M.getDataFromDB = getDataFromDB

return _M
