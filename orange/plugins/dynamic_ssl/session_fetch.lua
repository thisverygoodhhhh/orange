local ssl_sess = require "ngx.ssl.session"
local cache = ngx.shared.ssl_session

local log_plugin_name = " [DynamicSSL] "

local function errlog(...)
    ngx.log(ngx.ERR,log_plugin_name,...)
end

local function infolog(...)
    ngx.log(ngx.INFO,log_plugin_name,...)
end

local function my_lookup_ssl_session_by_id(sess_id)
    return cache:get(sess_id)
end

local sess_id, err = ssl_sess.get_session_id()
if not sess_id then
    errlog( "failed to get session ID. err:", err)
    return
end

local sess, err = my_lookup_ssl_session_by_id(sess_id)
if not sess then
    -- cache miss...just return
    errlog("failed to look up the session by ID [", sess_id, "] err:", err)
    return
end

local ok, err = ssl_sess.set_serialized_session(sess)
if not ok then
    errlog("failed to set SSL session for ID ", sess_id,": ", err)
    return
end

