-- allow CORS
-- usage: add command in nginx.conf location block
--   header_filter_by_lua_file DIR_NAME/cors.lua;
local ngx = require('ngx')

ngx.header["Access-Control-Allow-Credentials"] = "true"
-- ngx.header["Access-Control-Allow-Origin"] = ngx.var.http_origin
ngx.header["Access-Control-Allow-Origin"] = "*"
ngx.header["Access-Control-Allow-Headers"] = "x-requested-with,content-type,authorization"

if ngx.var.request_method == "OPTIONS" then
    ngx.header["Access-Control-Max-Age"] = "86400"
    ngx.header["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS, DELETE"
    ngx.header["Content-Length"] = "0"
    ngx.header["Content-Type"] = "text/plain, charset=utf-8"
    -- return
end
