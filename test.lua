local json = require("cjson")
local get_message = require("lua.listener.message").message_list

local cookie = require("lua.config.config").cookie_table[1]

ngx.say(json.encode(get_message(cookie)))
