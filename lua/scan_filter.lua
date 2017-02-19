local _M = {}

local DomeConfig = require "DomeConfig"

function _M.ua_filter(types)
    local ua = ngx.var.http_user_agent
    for idx,verify_type in ipairs(types) do
        if(ngx.re.match(ua, "("..verify_type..")", "isjo")) then
            ngx.log(ngx.ERR,ua..' matches '..verify_type)
            return true
        end
    end
    return false
end

function _M.args_filter(types)
    local ua = ngx.var.http_user_agent
    for idx,verify_type in ipairs(types) do
        if(ngx.re.match(ua, "("..verify_type..")", "isjo")) then
            return true
        end
    end
    return false    
end

function _M.filter()
    if DomeConfig.configs["defend_scan_enable"] ~= true then
        return
    end
    
    local ua_rule = DomeConfig.configs["defend_scan_rule"]["ua"]
    if ua_rule["enable"] == true then
        local ua_result = _M.ua_filter(ua_rule["type"])
        if ua_result == true then
            ngx.exit(403)
        end
    end

    local args_rule = DomeConfig.configs["defend_scan_rule"]["args"]
    if args_rule["enable"] == true then
        local args_result = _M.args_filter(args_rule["type"])
        if args_result == true then
            ngx.exit(403)
        end
    end
end

return _M