local ssl_sess = require "ngx.ssl.session"
local cache = ngx.shared.ssl_session

local function my_save_ssl_session_by_id(sess_id, sess)
    ngx.log(ngx.ERR,sess_id,sess)
    cache:set(sess_id,sess)

end

local sess_id, err = ssl_sess.get_session_id()
if not sess_id then
    ngx.log(ngx.ERR, "failed to get session ID: ", err)
    -- just give up
    return
end

local sess, err = ssl_sess.get_serialized_session()
if not sess then
    ngx.log(ngx.ERR, "failed to get SSL session from the ",
        "current connection: ", err)
    -- just give up
    return
end

-- for the best performance, we should avoid creating a closure
-- dynamically here on the hot code path. Instead, we should
-- put this function in one of our own Lua module files. this
-- example is just for demonstration purposes...
local function save_it(premature, sess_id, sess)
    -- the user is supposed to implement the
    -- my_save_ssl_session_by_id Lua function used below.
    -- She can save to an external memcached
    -- or redis cluster, for example. And she can also introduce
    -- a local cache layer at the same time...
    local sess, err = my_save_ssl_session_by_id(sess_id, sess)
    if not sess then
        if err then
            ngx.log(ngx.ERR, "failed to save the session by ID ",
                sess_id, ": ", err)
            return ngx.exit(ngx.ERROR)
        end

        -- cache miss...just return
        return
    end
end

-- create a 0-delay timer here...
local ok, err = ngx.timer.at(0, save_it,sess_id,sess)
if not ok then
    ngx.log(ngx.ERR, "failed to create a 0-delay timer: ", err)
    return
end