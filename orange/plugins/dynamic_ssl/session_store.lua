local ssl_sess = require "ngx.ssl.session"
local cache = ngx.shared.ssl_session
local log_plugin_name = " [DynamicSSL] "

local function errlog(...)
    ngx.log(ngx.ERR,log_plugin_name,...)
end

local function infolog(...)
    ngx.log(ngx.INFO,log_plugin_name,...)
end

local function my_save_ssl_session_by_id(sess_id, sess)
    return cache:set(sess_id,sess)
end

local sess_id, err = ssl_sess.get_session_id()

if not sess_id then
    errlog( "failed to get session ID: ", err)
    return
end

local sess, err = ssl_sess.get_serialized_session()
if not sess then
    errlog("failed to get SSL session from the ",
        "current connection. err:", err,'session ID:',sess_id)
    return
end

-- for the best performance, we should avoid creating a closure
-- dynamically here on the hot code path. Instead, we should
-- put this function in one of our own Lua module files. this
-- example is just for demonstration purposes...
local function save_it(premature, sess_id, sess)
    local sess, err = my_save_ssl_session_by_id(sess_id, sess)
    if not sess then
        errlog("failed to save the session by ID ",
            sess_id, ": ", err)
        return ngx.exit(ngx.ERROR)
    end
end

local ok, err = ngx.timer.at(0, save_it, sess_id, sess)
if not ok then
    errlog("failed to create a 0-delay timer: ", err)
    return
end