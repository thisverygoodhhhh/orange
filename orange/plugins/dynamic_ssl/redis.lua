--
-- Created by IntelliJ IDEA.
-- User: soul11201 <soul11201@gmail.com>
-- Date: 2017/5/19
-- Time: 10:34
-- To change this template use File | Settings | File Templates.
--

local redis = require "resty.redis"
local ssl_util = require "orange.plugins.dynamic_ssl.ssl_util"

local errlog = ssl_util.log.errlog


local RedisFactor = {}
RedisFactor.config ={
    max_idle_timeout = 10000,
    pool_size = 1000,
    timeout = 1000
}
function RedisFactor:new(host,port,auth)
    local red = redis:new()
    local timeout =  self.config.timeout
    local host = host or "127.0.0.1"
    local port = port or 6379
    local auth = auth or nil
    errlog('connect to redis.....')
    red:set_timeout(timeout)

    local ok, err = red:connect(host, port)

    if not ok then
        errlog("failed to connect: ", err)
        return false
    end

    if auth then
        local res,err = red:auth(auth)
        if not res then
            errlog("failed to authenticate: ", err)
            return false
        end
    end

    return red
end

function RedisFactor:free(red)
    red:set_keepalive(self.config.max_idle_timeout,self.config.pool_size)
end

return RedisFactor