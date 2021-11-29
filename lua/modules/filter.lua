local ngx = require("ngx")

local keywords = {}

-- gen regex from keywords
local function codeGenRegex()
    local keyType = type(keywords)

    if keyType == 'string' then
        return keywords, 'ok'

    elseif keyType == 'table' then
        if #keywords == 0 then
            return nil, 'null table'
        end
        return '(' .. table.concat(keywords, '|') .. ')'
    else
        return nil, 'Invalid type for keywords'
    end
end

local keyRegex, _ = codeGenRegex()

local function isHasKeyWords(content)
    if not keyRegex then
        return true
    end

    return not not ngx.re.match(content, keyRegex, "jo")
end

-- content filter
local function contentFilter(content)
    if isHasKeyWords(content) then
        return "当前评论由于某些原因已被隐藏"
    end
    return content
end

local _M = {}

_M.contentFilter = contentFilter
_M.isHasKeyWords = isHasKeyWords

return _M
