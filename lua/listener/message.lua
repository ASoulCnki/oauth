local requests = require("resty.requests")
local utils = require("listener.utils")
local constant = require("listener.constant")
local ngx = require("ngx")

local csrf = constant.csrf
local domain = "https://api.vc.bilibili.com"
local filter = utils.table_filter
local map = utils.table_map
local decodeJSON = utils.decodeJSON

local api_session_list = {
    SYN = domain .. "/session_svr/v1/session_svr/new_sessions?begin_ts=%s&build=0&mobi_app=web",
    ACK = domain .. "/session_svr/v1/session_svr/ack_sessions?begin_ts=%s&build=0&mobi_app=web"
}

local auth_headers = {
    ["Cookie"] = constant.cookie,
    ["User-Agent"] = constant.user_agent,
    ["Origin"] = "https://message.bilibili.com/",
    ["Referer"] = "https://message.bilibili.com/"
}

local function get(url)
    return requests.get(url, {
        headers = auth_headers
    })
end

local function ack_session(session)
    local ACK = domain .. '/session_svr/v1/session_svr/update_ack'
    requests.post(ACK, {
        headers = auth_headers,
        body = {
            talker_id = session.talker_id,
            session_type = 1,
            ack_seqno = session.ack_seqno + session.unread_count,
            build = 0,
            mobi_app = 'web',
            csrf_token = csrf,
            csrf = csrf
        }
    })
end

local function get_session_list()

    local function filter_map_session_list(session_list)

        if not session_list then
            return nil
        end

        session_list = filter(session_list, function(v)
            return v.unread_count > 0
        end)

        session_list = map(session_list, function(v)
            ack_session(v)
            return {
                uid = v.talker_id,
                content = string.lower(decodeJSON(v.last_msg.content).content or v.last_msg.content),
                msg_type = v.last_msg.msg_type
            }
        end)

        return session_list
    end

    local begin_ts = ngx.now() * 1000

    local syn, ack = api_session_list.SYN, api_session_list.ACK
    local res, _ = get(string.format(syn, begin_ts))

    get(string.format(ack, begin_ts))

    local data = res and decodeJSON(res:body())

    data = data and filter_map_session_list(data.data.session_list)

    return data or {}
end

local _M = {}

_M.get_session_list = get_session_list

return _M
