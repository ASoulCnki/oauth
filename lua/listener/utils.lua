local split = require("ngx.re").split
local json = require("cjson")

local function parse_cookie(cookie_str)
    if type(cookie_str) ~= 'string' then
        return {}
    end

    -- table.new is provide by openresty, so we can use it
    -- ignore warning
    local cookie_table = table.new(0, 30)

    local first_table = split(cookie_str, ';[ ]*', "jo")

    for _, v in pairs(first_table) do
        local next_table = split(v, '=[ ]*', "jo")
        cookie_table[next_table[1]] = next_table[2]
    end

    return cookie_table
end

local function table_filter(table, fn)
    if type(table) ~= 'table' and type(fn) ~= "function" then
        error("table_filter: invalid argument")
    end

    for index, value in ipairs(table) do
        if not fn(value, index) then
            table[index] = nil
        end
    end

    return table
end

local function table_map(table, fn)
    if type(table) ~= 'table' and type(fn) ~= "function" then
        error("table_map: invalid argument")
    end

    local new_table = {}

    for index, value in ipairs(table) do
        new_table[index] = fn(value, index)
    end

    return new_table
end

local function decodeJSON(s)
    local data
    pcall(function()
        data = json.decode(s)
    end)
    return data
end

local _M = {}

_M.parse_cookie = parse_cookie
_M.table_filter = table_filter
_M.table_map = table_map
_M.decodeJSON = decodeJSON

return _M
