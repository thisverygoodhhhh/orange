-- inpired by https://github.com/yiisoft/yii2/blob/master/framework/db/Query.php


local _M  = {}
local db = require 'orange.store.mysql_db'


function _M:find( table_name )
    if not table_name or type(table_name) ~= 'string'
        error('tabel name illegal')
    end

    local t = {}
    t.table_name = table_name
    t._attributes = {}

    setmetatable(t,{
            __index=self,
    })
    return t
end


function _M:select( columns, opts )

end


function _M:distinct( yes )

end

function _M:from( table )

end

function _M:where( condition, opts )

end

function _M:join( type, table, on, opts )

end

function _M:groupBy( columns )

end

function _M:having( condition, opts )

end



function _M:union( sql )

end


function _M:limit( limit )

end

function _M:offset( offset )

end

function _M:orderBy( columns )

end

function _M:all( ... )

end

function _M:one( ... )

end


return _M
