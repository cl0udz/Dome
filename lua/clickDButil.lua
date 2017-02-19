local mysql = require "resty.mysql"

local DomeConfig = require "DomeConfig"
local util = require "util"
local _M = {}

function _M.connect_mysql()
    local db,err = mysql:new()
    if not db then
        ngx.log(ngx.ERR,err)
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
    local sqlstr = "select cookie, reqcount, authcount from click where cookie='" .. cookie .. "'"
    local res,err,errcode,sqlstate = db:query(sqlstr)
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

function _M.save_authcount(cookie)
    local db = _M.connect_mysql()
    local sqlstr = "insert into click(cookie, reqcount, authcount)" .. "values('" .. cookie .. "'," .. "0" .. ",1)"
    local res,err,errcode,sqlstate = db:query(sqlstr)
    local ok,err = db:close()

    if not res then
        return false
    else
        return true
    end
end

function _M.dec_authcount(cookie)
    local db = _M.connect_mysql()
    local sqlstr = "update click set authcount = authcount - 1 where cookie='" .. cookie .. "'"
    local res,err,errcode,sqlstate = db:query(sqlstr)
    local ok,err = db:close()
end


function _M.inc_authcount(cookie)
    local db = _M.connect_mysql()
    local sqlstr = "update click set authcount = authcount + 1 where cookie='" .. cookie .. "'"
    local res,err,errcode,sqlstate = db:query(sqlstr)
    local ok,err = db:close()
end

function _M.inc_count(cookie)
    local db = _M.connect_mysql()
    local sqlstr = "update click set reqcount = reqcount + 1 where cookie='" .. cookie .. "'"
    local res,err,errcode,sqlstate = db:query(sqlstr)
    local ok,err = db:close()
end

function _M.save_DBrecord(cookie)
    local db = _M.connect_mysql()
    local sqlstr = "insert into click(cookie, reqcount, authcount)".."values('"..cookie.."',".. "1" ..",0)"
    local res,err,errcode,sqlstate = db:query(sqlstr)
    local ok,err = db:close()

    if not res then
        return false
    else
        return true
    end
end

function _M.clear_DBrecord(cookie)
    local db = _M.connect_mysql()
    local sqlstr = "delete from click where cookie = '" .. cookie .. "'"
    local res, err, errcode, sqlstate = db:query(sqlstr)
    local ok, err = db:close()

    if not res then
        return false
    else
        return true
    end
end

return _M