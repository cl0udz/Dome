local _M = {}

local clickDButil = require "clickDButil"
local DomeConfig = require "DomeConfig"
local util = require "util"

function _M.authsave(sign)
    local result, cookie = clickDButil.cookie_exist(sign)
    if result then
        clickDButil.inc_authcount(sign)
        return 1
    else
        clickDButil.save_authcount(sign)
        return 1
    end
end

function _M.authverify()
    -- start its real function when the module is enabled
    if DomeConfig.configs["click_verify_enable"] ~= true then
        return
    end

    local sign = util.sign("sign")
    local result = _M.authsave(sign)
    if result ~= 0 then
        ngx.say("Done.")
        ngx.exit(200)
    else
        ngx.say("Something wrong.")
        ngx.exit(403)
    end
end

_M.authverify()

-- return _M