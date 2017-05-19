local ssl_util = {}

-- 日志
local log = {}
local log_plugin_name = " [DynamicSSL] "
function log.errlog(...)
    ngx.log(ngx.ERR,log_plugin_name,...,"\n",debug.traceback())
end

 function log.infolog(...)
    ngx.log(ngx.INFO,log_plugin_name,...)
end

-- cert pkey 数据库数据在内存中的缓存
local cert_pkey_hash_data = {}
function cert_pkey_hash_data:get(key)
    local c = ngx.shared.ssl_cert_pkey
    local handle = require "orange.plugins.dynamic_ssl.handler"

    local v,err = c:get(key)

    if not v then
        log.errlog(key,"not found in cache; err: ",err);
        handle:sync_cache()
        v,err = c:get(key)
    end

    return v,err;
end


function cert_pkey_hash_data:set(key,value)
    local c = ngx.shared.ssl_cert_pkey
    local success, e, out_of_zone = c:set(key,value)

    if not success then
        log.errlog('cache fail,err:',e);
    end

    if out_of_zone then
        log.errlog(" out of storage in the shared memory zone [ssl_cert_pkey] .")
    end

    return success,e
end

function cert_pkey_hash_data:get_cert(sni)
    return self:get(sni .. 'cert')
end

function cert_pkey_hash_data:get_pkey(sni)
    return self:get(sni .. 'pkey')
end

function cert_pkey_hash_data:set_cert(sni,cert)
    return self:set(sni .. 'cert', cert)
end

function cert_pkey_hash_data:set_pkey(sni,pkey)
    return self:set(sni .. 'pkey', pkey)
end


local share_cache = {}
share_cache.cache_obj = nil

function share_cache:get_obj()

--    self.cache_obj = ngx.shared.ssl_session

    if not  self.cache_obj then
        local fact = require "orange.plugins.dynamic_ssl.redis"
        self.cache_obj  =  fact:new()
    end

    return self.cache_obj
end

function share_cache:get(key)
    log.errlog(key)
    return self:get_obj():get(key)
end

function share_cache:set(k, v)
    log.errlog(k,v)
    return self:get_obj():set(k,v)
end

function share_cache:free()
    self:get_obj():free(self.cache_obj)
end


function share_cache.session_save_timer(premature, sess_id, sess)
    local sess, err = share_cache:set(sess_id, sess)
    if not sess then
        log.errlog("failed to save the session by ID ",
            sess_id, ": ", err)
        return ngx.exit(ngx.ERROR)
    end
end




ssl_util.cert_pkey_hash = cert_pkey_hash_data
ssl_util.log = log
ssl_util.share_cache = share_cache


return ssl_util