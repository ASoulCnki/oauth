local parse_cookie = require("listener.utils").parse_cookie

-- add you cookie here
local cookie = ""

local user_agent =
    "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"

local cookie_table = parse_cookie(cookie)

local _M = {}

_M.user_agent = user_agent
_M.cookie_table = cookie_table
_M.cookie = cookie
_M.selfID = cookie_table.DedeUserID
_M.csrf = cookie_table.bili_jct

return _M
