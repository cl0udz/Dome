-- -*- coding: utf-8 -*-
-- @Date    : 2017-02-19 23:00
-- @Author  : Spoock(me@spoock.com)   cl0udz(jw.huang@whu.edu.cn)
local _M = {}

--The md5 of config string
_M.config_hash = nil

_M["configs"] = {}

--------------default config------------
-- 静态文件的配置
_M.configs["static"] = "/usr/local/openresty/nginx/conf/lua/support/"

-- 数据库的配置
_M.configs["db"] = {
    ["host"] = "127.0.0.1", 
    ["port"] = "3306", 
    ["database"] = "waf",
    ["user"]="root",
    ["password"]="123456",
}

_M.configs["readonly"] = false
_M.configs['cookie_prefix'] = "dome"
_M.configs['encrypt_seed'] = "20161213"

-- set the threshold for scan
_M.configs['timethreshold'] = 3000000000    -- second
_M.configs['countthreshold'] = 300000000000000    -- times
_M.configs['max_ajax_req_per_page'] = 300

-- 设置资源文件访问的阈值,static_access_total表示访问的总次数，static_access_min表示需要访问资源文件的数目
-- 如static_access_min=100，static_access_min=10就表示在访问100次网站之后，最少需要访问资源文件10次
-- static_access_enable，用来设定是否启用基于资源的扫描器检测
_M.configs['static_access_enable'] = true
_M.configs['static_access_total'] = 100
_M.configs['static_access_min'] = 10


-- 基于鼠标点击时间的检测
_M.configs["click_verify_enable"] = false

-- 基于 js_cookie 的检测
_M.configs["js_cookie_enable"] = false

-- 基于 set_cookie 的检测
_M.configs["set_cookie_enable"] = false


_M.configs["defend_scan_enable"] = false                                        
_M.configs["defend_scan_rule"] = {
    ["ua"] = {
        ["matcher"] = 'all_request',
        ["type"] = {
            "wpscan","sqlmap","Nikto","ApacheUser","bbqsql","cutycapt","DAV.pm","Mozilla/4.0","DirBuster","fimap","Grabber",
            "Java/1.8.0_102","Python-urllib","w3af","commix/1.2","Chrome/41","masscan","nmap","spider","HTTrack","harvest",
            "audit","dirbuster","pangolin","nmap","sqln","scan","hydra","Parser","libwww","BBBike",
        },
        ["enable"] = false
    },
    ["args"] = {
        ["matcher"] = 'all_request',
        ["type"] = {},
        ["enable"] = false
    },
}


return _M
