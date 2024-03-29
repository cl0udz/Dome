local _M = {}

local DomeConfig = require "DomeConfig"
local mysqlutil = require "mysqlutil"
local clientsutil = require "clientsutil"
local util = require "util"

_M.verify_javascript_html = nil

function _M.validate_cookie(client_cookie)
    local result,cookie = clientsutil.cookie_exist(client_cookie)
    if result then
        local offset_config = DomeConfig.configs['timethreshold']
        local count_config = DomeConfig.configs['countthreshold']
        local timestamp = cookie["timestamp"]
        local count = cookie["count"]
        local now = os.time()
        local offset = now-timestamp
        if offset < offset_config then
            if count < count_config then
                clientsutil.update_cookie(client_cookie)
                return false
            else
                return true
            end
        else
            clientsutil.clear(client_cookie)
            return false
        end

    else
        clientsutil.save_cookie(client_cookie)
        return false
    end   
end

function _M.verify_static_access()
    local sign = util.sign('javascript')
    local result = _M.validate_cookie(sign)
    if result == true then
        ngx.exit(403)
    end
    -- 计算资源的访问情况
    local visited_static_file_count = ngx.shared.visited_static_file_count
    visited_count = visited_static_file_count:get(sign)
    if visited_count == nil then
        return false
    end
    local result,cookie = clientsutil.cookie_exist(sign)
    if result then
        local static_access_total = DomeConfig.configs['static_access_total']
        local static_access_min = DomeConfig.configs['static_access_min']
        local count = cookie["count"]
        if count >= static_access_total then
            -- 访问资源文件的次数少于阈值设定的次数
            if visited_count < static_access_min then
                ngx.exit(403)
            end
        end
    end
end

function _M.verify_cookie()
    local sign = util.sign('cookie')
    local result = _M.validate_cookie(sign)
    if result then
        ngx.exit(403)
    end

    if ngx.var.http_cookie ~= nil then
        if string.find( ngx.var.http_cookie , sign) ~= nil then
            return
        end
    end
    

    local cookie_prefix = DomeConfig.configs['cookie_prefix']
    ngx.header["Set-Cookie"] =  cookie_prefix .. "_sign_cookie=" .. sign .. '; path=/' 
    
    if ngx.var.args ~= nil then
        ngx.redirect( ngx.var.scheme.."://"..ngx.var.http_host..ngx.var.uri.."?"..ngx.var.args , ngx.HTTP_MOVED_TEMPORARILY)
    else
        ngx.redirect( ngx.var.scheme.."://"..ngx.var.http_host..ngx.var.uri , ngx.HTTP_MOVED_TEMPORARILY)
    end
end

function _M.IECookieCheck()
    clientCookie = ngx.var.http_cookie
    if string.sub(clientCookie, -1) == '1' then
        if string.find( ngx.var.http_user_agent, "MSIE") ~= nil then
            return 1
        else
            return 0
        end
    elseif string.sub(clientCookie, -1) == "0" then
        if string.find( ngx.var.http_user_agent, "MSIE") == nil then
            return 1
        else
            return 0
        end
    end
    return 0
end


function _M.verify_javascript()
    local sign = util.sign('javascript')
    local result = _M.validate_cookie(sign)
    if result then
        ngx.exit(403)
    end
end

function _M.filter()
    local matcher_list = DomeConfig.configs['matcher']
    local verify_javascript = DomeConfig.configs["js_cookie_enable"]
    local verify_cookie = DomeConfig.configs["set_cookie_enable"]
    local static_access_enable = DomeConfig.configs["static_access_enable"]
    if verify_cookie == true then
        _M.verify_cookie()
    end
    if verify_javascript == true then
        _M.verify_javascript()
    end
    if static_access_enable == true then
        _M.verify_static_access()
    end
end



return _M
