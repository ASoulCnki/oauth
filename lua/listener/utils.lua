local ngx_re_split = require("ngx.re").split
local json = require("cjson")

local function parse_cookie(cookie_str)
    if type(cookie_str) ~= 'string' then
        return {}
    end
    -- table.new is provide by openresty, so we can use it
    -- ignore warning
    local cookie_table = table.new(0, 30)

    local first_table = ngx_re_split(cookie_str, ';[ ]*', "jo")

    for _, v in pairs(first_table) do
        local next_table = ngx_re_split(v, '=[ ]*', "jo")
        cookie_table[next_table[1]] = next_table[2]
    end

    return cookie_table
end

local function table_filter(t, fn)
    assert(type(t) == 'table', "tuple should be table")
    assert(type(fn) == "function", "fn should be function")

    for index, value in ipairs(t) do
        if not fn(value, index) then
            t[index] = nil
        end
    end

    return t
end

local function table_map(t, fn)
    assert(type(t) == 'table', "tuple should be table")
    assert(type(fn) == "function", "fn should be function")

    local new_table = {}

    for index, value in ipairs(t) do
        new_table[index] = fn(value, index)
    end

    return new_table
end

local function table_chunk(t, size)
    assert(type(t) == 'table', "tuple should be table")
    assert(type(size) == "number", "size should be number")
    assert(size > 0, "size should be greater than 0")
    assert(#t >= size, "size should be less than #t")

    if size == 1 then
        return {t}
    end

    local new_table = {}

    for index = 1, #t do
        local flag = (index % size) + 1
        if new_table[flag] then
            new_table[flag][#new_table[flag] + 1] = t[index]
        else
            new_table[flag] = {t[index]}
        end
    end
    return new_table
end

local function decode_json(s)
    local ok, data = pcall(json.decode, s)
    return ok and data
end

local _M = {}

_M.parse_cookie = parse_cookie
_M.table_filter = table_filter
_M.table_map = table_map
_M.decode_json = decode_json
_M.table_chunk = table_chunk

return _M
