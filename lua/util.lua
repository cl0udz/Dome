
local _M = {}

local DomeConfig = require "DomeConfig"

function _M.string_replace(s,pattern,replace,times)
	local ret = nil
	while times>0 do
		times = times -1
		local s_start,s_stop = string.find(s,pattern,1,true)
		if s_start ~= nil and s_stop ~= nil then
			s =  string.sub(s,1,s_start-1)..replace..string.sub(s,s_stop+1)
		end
	end
	return s
end

function _M.convert_ip(ip)
	ip = string.gsub(ip,'%.','')
	ip = tonumber(ip)
	return ip
end

function _M.sign( mark )
    local ua = ngx.var.http_user_agent
    if ua == nil then
        ua = ''
    end
    local host = ngx.req.get_headers()['Host']
    if host == nil then
        host = ''
    end
    local mystr = 'DOME' .. ngx.var.remote_addr .. host .. ua .. mark .. DomeConfig.configs["encrypt_seed"]
    local sign = ngx.md5(mystr)
    return sign 
end

return _M
