local _M = {}
local cjson = require("cjson")
local orange_data = ngx.shared.orange_data



local data = {}

function _M:get( key )
    ngx.log(ngx.INFO,key)

    if not data[key]  then
        data[key]  = orange_data:get(key)
    end
    return data[key]
end

function _M:set( key,v )
    ngx.log(ngx.INFO,key,v)
    orange_data:set(key,v)

    data[key] = v
    return true;
end

function _M:incr( key,v )
    local v1 = self:get(key)
    self:set(key,v + v1)
end

function _M:set_json( key,table )
    data[key] = table
    orange_data:set(key,cjson.encode(table))
    -- body
end

function _M:get_json( key )
    local d = self:get(key)

    if not d then
        return d
    end

    if type(d) == 'string' then
        ngx.log(ngx.INFO,key,d)
        d = cjson.decode(d)
        self:set_json(key,d)
    end

    return d
end

return _M
