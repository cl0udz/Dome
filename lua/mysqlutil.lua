local mysql = require "resty.mysql"
-- reference https://github.com/openresty/lua-resty-mysql


local DomeConfig = require "DomeConfig"
local util = require "util"
local _M = {}
function _M.connect_mysql()
	local db,err = mysql:new()
	if not db then
		-- ngx.say('failed to instantiate mysql: ',err)
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

 		-- host = "127.0.0.1",
 		-- port = 3306,
 		-- database = "waf",
 		-- user = "root",
 		-- password = "123456",
 		-- max_packet_size = 1024*1024
	}

	if not ok then
		-- ngx.say('failed to connect:',err,":",errcode,"",sqlstate)
		ngx.log(ngx.ERR,sqlstate)
		return
	end
	-- ngx.say('connected to mysql')
	-- local ok,err = db:set_keepalive(10000,100)
	-- if not ok then
	-- 	ngx.say('failed to set keepalive:',err)
	-- 	return 
	-- end
	return db
end

function _M.ip_exist(ip)
    local ip = util.convert_ip(ip)
	local db = _M.connect_mysql()
	local sqlstr = "select ip,timestamp,count from ips where ip="..ip
	local res,err,errcode,sqlstate = db:query(sqlstr)
	local ok,err = db:close()
	if not ok then
	end
	if not res then
		return false,nil
	end
	local result = next(res)
	if result==nil then
		ngx.log(ngx.ERR,' res is nil')
		return false,nil
	else
		ngx.log(ngx.ERR,' res is not nil') 
		return true,res[1]
	end
end

function _M.save_ip(ip)
	ngx.log(ngx.ERR,'ip',ip)
	local ip = util.convert_ip(ip)
	local db = _M.connect_mysql()
	local timestamp = tonumber(os.time())
	local sqlstr = "insert into ips(ip,timestamp,count)".."values("..ip..","..timestamp..",1)"
	ngx.log(ngx.ERR,sqlstr)
	local res,err,errcode,sqlstate = db:query(sqlstr)
	local ok,err = db:close()

	if not res then
		return false
	else
		return true
	end
end

function _M.update_ip(ip)
	local ip = util.convert_ip(ip)
	local db = _M.connect_mysql()
	local sqlstr = "update ips set count=count+1 where ip="..ip
	ngx.log(ngx.ERR,sqlstr)
	local res,err,errcode,sqlstate = db:query(sqlstr)
	local ok,err = db:close()
end

function _M.clear(ip)
	local ip = util.convert_ip(ip)
	local db = _M.connect_mysql()
	local sqlstr = "delete from ips where ip="..ip
	ngx.log(ngx.ERR,sqlstr)
	local res,err,errcode,sqlstate = db:query(sqlstr)
	local ok,err = db:close()
	if not ok then
		ngx.log(ngx.ERR,err)
	end
	if not res then
		return false
	else
		return true
	end
end

function _M.store_error(addr,forward,ua,mark)
	local db = _M.connect_mysql()
	local sqlstr = "insert into error(addr,forward,ua,mark)".."values('"..addr.."','"..forward.."','"..ua.."','"..mark.."')"
	local res,err,errcode,sqlstate = db:query(sqlstr)
	local ok,err = db:close()
	if not ok then
		ngx.log(ngx.ERR,err)
	end
	if not res then
		return false
	else
		return true
	end

end

return _M
