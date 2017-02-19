local _M = {}

local DomeConfig = require "DomeConfig"
local clickDButil = require "clickDButil"
local util = require "util"

function _M.checkDB(client_cookie)
    local result, cookie = clickDButil.cookie_exist(client_cookie)
    if result then
        local max_count = DomeConfig.configs['max_ajax_req_per_page']
        local reqcount = cookie["reqcount"]
        local authcount = cookie["authcount"]

        if reqcount < max_count then
            clickDButil.inc_count(client_cookie)
            return false
        else
            -- clickDButil.clear(client_cookie)
            if authcount ~= 0 then
                clickDButil.clear_DBrecord(client_cookie)
                clickDButil.dec_authcount(client_cookie)
                return false
            else
                return true
            end
        end
    else
        clickDButil.save_DBrecord(client_cookie)
        return false
    end
end

function _M.verify_click()
    local sign = util.sign('sign')
    local checkResult = _M.checkDB(sign)
    if checkResult then
        ngx.exit(403)
    end
end

function _M.filter()
    if DomeConfig.configs["click_verify_enable"] ~= true then
        return
    end
    _M.verify_click()
end



return _M