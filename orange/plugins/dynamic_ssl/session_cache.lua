--
-- Created by IntelliJ IDEA.
-- User: soul11201 <soul11201@gmail.com>
-- Date: 2017/5/19
-- Time: 18:15
-- To change this template use File | Settings | File Templates.
--
local log = require "orange.plugins.dynamic_ssl.logger"

local session_cache = {}
session_cache.cache_obj = nil

function session_cache:get_obj()

    self.cache_obj = ngx.shared.ssl_session

    if not  self.cache_obj then
        local fact = require "orange.plugins.dynamic_ssl.redis"
        self.cache_obj  =  fact:new()
    end

    return self.cache_obj
end

function session_cache:get(key)
    log.errlog(key)
    return self:get_obj():get(key)
end

function session_cache:set(k, v)
    log.errlog(k)
    return self:get_obj():set(k,v)
end

function session_cache:free()
    self:get_obj():free(self.cache_obj)
end


function session_cache.session_save_timer(premature, sess_id, sess)
    local sess, err = session_cache:set(sess_id, sess)
    if not sess then
        log.errlog("failed to save the session by ID ",
            sess_id, ": ", err)
        return ngx.exit(ngx.ERROR)
    end
end

return session_cache

