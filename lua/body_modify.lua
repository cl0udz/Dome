local _M = {}

local DomeConfig = require "DomeConfig"
local zlib = require "zlib"
local util = require "util"

_M.verify_javascript_html = nil
_M.jshook_js = nil


function _M.modify()
    local click_verify_enable = DomeConfig.configs["click_verify_enable"]
    local js_cookie_enable = DomeConfig.configs["js_cookie_enable"]
    local sign = util.sign('javascript')
    if js_cookie_enable == true then
        if ngx.var.http_cookie ~= nil then
            if string.find( ngx.var.http_cookie , sign) ~= nil then
                if click_verify_enable == true then
                    _M.modify_js_hijack()
                end
                return
            else
                _M.modify_javascript_cookie()
            end
        end
    else
        if click_verify_enable == true then
            _M.modify_js_hijack()
        end
    end


end

-- 用于检测资源文件的访问情况
function _M.count_visited_static_file()
    local static_access_enable = DomeConfig.configs["static_access_enable"]
    if static_access_enable == true then
        local sign = util.sign('javascript')
        local visited_static_file_count = ngx.shared.visited_static_file_count
        local visited_count = visited_static_file_count:get(sign)
        -- 初始化变量
        if visited_count == nil then
            visited_count = 1
        end

        
        local html = ngx.arg[1] or ""
        local headers = ngx.resp.get_headers()  
        local accept = headers['content-type']
        if accept ~= nil then
            if string.find(accept,'image') ~= nil or string.find(accept,'css') ~=nil  or string.find(accept,'javascript') ~=nil then
                visited_count = visited_count+1
            end
        end
        visited_static_file_count:set(sign,visited_count)
    end
end

function _M.modify_js_hijack()
    local html = ngx.arg[1] or ""
    local ishtml = string.find(html,"head")
    local jscode = nil
    if _M.jshook_js == nil then
        local path = DomeConfig.configs['static'].."jshook.js"
        f = io.open( path, 'r' )
        if f ~= nil then
            _M.jshook_js = f:read("*all")
            f:close()
        end
    end
    jscode =  '<script type="text/javascript">'.._M.jshook_js.."</script>"
    if ishtml ~= nil then
        html = util.string_replace( html,"<head>","<head>"..jscode,1)
        ngx.arg[1] = html
    end

end

function _M.modify_javascript_cookie()
    local sign = util.sign('javascript')
    local html = ngx.arg[1] or ""
    local ishtml = string.find(html,"head")
    local myhtml = nil
    local headers = ngx.resp.get_headers()  
    local accept = headers['content-type']
    if accept ~= nil then
        if string.find(accept,'image') ~= nil or string.find(accept,'css') ~=nil  or string.find(accept,'javascript') ~=nil  or ishtml == nil then
            return
        end
    end

    if _M.verify_javascript_html == nil then
        local path = DomeConfig.configs['static'].."verify_javascript.html"
        f = io.open( path, 'r' )
        if f ~= nil then
            _M.verify_javascript_html = f:read("*all")
            f:close()
        end
    end

    local cookie_prefix = DomeConfig.configs['cookie_prefix']

    local redirect_to = nil

    myhtml = _M.verify_javascript_html
    myhtml = string.gsub( myhtml,'INFOCOOKIE',sign )
    myhtml = string.gsub( myhtml,'COOKIEPREFIX',cookie_prefix )

    local http_host = ngx.var.http_host or ""

    local uri = ngx.var.uri or ""
    local args = ngx.var.args or ""
    
    if ngx.var.args ~= nil then
        redirect_to =  ngx.var.scheme.."://"..http_host..uri.."?"..args , ngx.HTTP_MOVED_TEMPORARILY
    else
        redirect_to =  ngx.var.scheme.."://"..http_host..uri , ngx.HTTP_MOVED_TEMPORARILY
    end

    myhtml = util.string_replace( myhtml,'INFOURI',redirect_to, 1 )
    -- html = string.gsub( html,".*", myhtml )
    ngx.arg[1] = myhtml
    ngx.arg[2] = true

end



return _M