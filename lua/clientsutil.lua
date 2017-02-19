local mysql = require "resty.mysql"

local DomeConfig = require "DomeConfig"
local util = require "util"
local _M = {}

function _M.connect_mysql()
    local db,err = mysql:new()
    if not db then
        return
    end
    db:set_timeout(1000)
    db_config = DomeConfig.configs["db"]
    local ok,err,errcode,sqlstate = db:connect {
        host = db_config["host"],
        port = db_config["port"],
        database = db_config["database"],
        user = db_config["user"],
        password = db_config["password"],
        max_packet_size = 1024*1024 

    }
    if not ok then
        return
    end
    return db
end

function _M.cookie_exist(cookie)
    local db = _M.connect_mysql()
    local sqlstr = "select cookie,timestamp,count from clients where cookie='"..cookie.."'"
    local res,err,errcode,sqlstate = db:query(sqlstr)
    local ok,err = db:close()
    if not ok then
    end
    if not res then
        return false,nil
    end
    local result = next(res)
    if result==nil then
        return false,nil
    else
        return true,res[1]
    end
end

function _M.save_cookie(cookie)
    local db = _M.connect_mysql()
    local timestamp = tonumber(os.time())
    local sqlstr = "insert into clients(cookie,timestamp,count)".."values('"..cookie.."',"..timestamp..",1)"
    local res,err,errcode,sqlstate = db:query(sqlstr)
    local ok,err = db:close()

    if not res then
        return false
    else
        return true
    end
end

function _M.update_cookie(cookie)
    local db = _M.connect_mysql()
    local sqlstr = "update clients set count=count+1 where cookie='"..cookie.."'"
    local res,err,errcode,sqlstate = db:query(sqlstr)
    local ok,err = db:close()
end

function _M.clear(cookie)
    local db = _M.connect_mysql()
    local sqlstr = "delete from clients where cookie='"..cookie.."'"
    local res,err,errcode,sqlstate = db:query(sqlstr)
    local ok,err = db:close()
    if not ok then
    end
    if not res then
        return false
    else
        return true
    end
end

return _M
