local ssl_sess = require "ngx.ssl.session"
local cache = ngx.shared.ssl_session

local function my_lookup_ssl_session_by_id(sess_id)
    ngx.log(ngx.ERR,sess_id)
    cache:get(sess_id)
end


local sess_id, err = ssl_sess.get_session_id()
if not sess_id then
    ngx.log(ngx.ERR, "failed to get session ID: ", err)
    return
end

local sess, err = my_lookup_ssl_session_by_id(sess_id)
if not sess then
    if err then
        ngx.log(ngx.ERR, "failed to look up the session by ID ", sess_id, ": ", err)
        return
    end

    -- cache miss...just return
    return
end

local ok, err = ssl_sess.set_serialized_session(sess)
if not ok then
    ngx.log(ngx.ERR, "failed to set SSL session for ID ", sess_id,": ", err)
    return
end

