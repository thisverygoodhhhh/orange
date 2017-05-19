local ssl_sess = require "ngx.ssl.session"
local ssl_util = require "orange.plugins.dynamic_ssl.ssl_util"
local errlog = ssl_util.log.errlog

local cache = ngx.shared.ssl_session

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
    if  err then
        errlog("failed to look up the session by ID [", sess_id, "] err:", err)
    end

    return
end

local ok, err = ssl_sess.set_serialized_session(sess)
if not ok then
    errlog("failed to set SSL session for ID ", sess_id,": ", err)
    return
end

