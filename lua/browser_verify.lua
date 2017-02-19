local _M = {}

local DomeConfig = require "DomeConfig"
local request_tester = require "request_tester"
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

-- function _M.verify_javascript()
--     local sign = util.sign('javascript')
--     local result = _M.validate_cookie(sign)
--     if result then
--         ngx.exit(403)
--     end
--     if ngx.var.http_cookie ~= nil then
--         if string.find( ngx.var.http_cookie , sign) ~= nil then
--             if _M.IECookieCheck() == 1 then
--                 return
--             end
--         end
--     end


--     if _M.verify_javascript_html == nil then
--         local path = "/usr/local/openresty/nginx/conf/lua/support/verify_javascript.html"
--         f = io.open( path, 'r' )
--         if f ~= nil then
--             _M.verify_javascript_html = f:read("*all")
--             f:close()
--         end
--     end
    
--     local cookie_prefix = DomeConfig.configs['cookie_prefix']

--     local redirect_to = nil
--     local html = _M.verify_javascript_html

--     html = string.gsub( html,'INFOCOOKIE',sign )
--     html = string.gsub( html,'COOKIEPREFIX',cookie_prefix )

--     if ngx.var.args ~= nil then
--         redirect_to =  ngx.var.scheme.."://"..ngx.var.http_host..ngx.var.uri.."?"..ngx.var.args , ngx.HTTP_MOVED_TEMPORARILY
--     else
--         redirect_to =  ngx.var.scheme.."://"..ngx.var.http_host..ngx.var.uri , ngx.HTTP_MOVED_TEMPORARILY
--     end

--     html = util.string_replace( html,'INFOURI',redirect_to, 1 )
    
--     ngx.header.content_type = "text/html"
--     ngx.header.charset = "utf-8"
--     ngx.say( html )
    
--     ngx.exit(200)
-- end


function _M.verify_javascript()
    local sign = util.sign('javascript')
    local result = _M.validate_cookie(sign)
    if result then
        ngx.exit(403)
    end
end

function _M.filter()
    if DomeConfig.configs["browser_verify_enable"] ~= true then
        return
    end
    
    local matcher_list = DomeConfig.configs['matcher']
    for i,rule in ipairs( DomeConfig.configs["browser_verify_rule"] ) do
        local enable = rule['enable']
        if enable == true then
            local verify_cookie,verify_javascript = false,false
            for idx,verify_type in ipairs( rule['type']) do
                if verify_type == 'cookie' then
                    verify_cookie = true
                elseif verify_type == 'javascript' then
                    verify_javascript = true
                end
            end

            if verify_cookie == true then
                _M.verify_cookie()
            end
            
            if verify_javascript == true then
                _M.verify_javascript()
            end
            
            return
        end
    end
end



return _M
