-- -*- coding: utf-8 -*-
-- @Date    : 2017-02-19 23:00
-- @Author  : Alexa (me@spoock.com)

local _M = {}

--The md5 of config string
_M.config_hash = nil

_M["configs"] = {}

--------------default config------------
_M.configs["static"] = "/usr/local/openresty/nginx/conf/lua/support/"

_M.configs["readonly"] = false
_M.configs['cookie_prefix'] = "dome"
_M.configs['encrypt_seed'] = "20161213"

-- set the threshold for scan
_M.configs['timethreshold'] = 300     -- second
_M.configs['countthreshold'] = 1000000000000    -- times
_M.configs['max_ajax_req_per_page'] = 1000


_M.configs["db"] = {
    ["host"] = "127.0.0.1", 
    ["port"] = "3306", 
    ["database"] = "waf",
    ["user"]="root",
    ["password"]="123456",
}

_M.configs['matcher'] = {
    ["all_request"] = {},
}

_M.configs["browser_verify_enable"] = true
_M.configs["js_cookie_enable"] = true
_M.configs["set_cookie_enable"] = true

_M.configs["defend_scan_enable"] = false                                        
_M.configs["defend_scan_rule"] = {
    ["ua"] = {
        ["matcher"] = 'all_request',
        ["type"] = {
            "wpscan","sqlmap","Nikto","ApacheUser","bbqsql","cutycapt","DAV.pm","Mozilla/4.0","DirBuster","fimap","Grabber",
            "Java/1.8.0_102","Python-urllib","w3af","commix/1.2","Chrome/41","masscan","nmap","spider","HTTrack","harvest",
            "audit","dirbuster","pangolin","nmap","sqln","scan","hydra","Parser","libwww","BBBike",
        },
        ["enable"] = true
    },
    ["args"] = {
        ["matcher"] = 'all_request',
        ["type"] = {},
        ["enable"] = false
    },
}


_M.configs["click_verify_enable"] = true

return _M
