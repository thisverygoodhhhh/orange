-- inpired by
--  https://github.com/yiisoft/yii2/blob/master/framework/db/Query.php
--  https://github.com/noname007/yii2/blob/master/framework/db/QueryInterface.php


local _M  = {}
-- local db = require 'orange.store.mysql_db'


local sql = {}

local function build()

end



function _M:find( table_name )
    if not table_name or type(table_name) ~= 'string' then
        error('tabel name illegal')
    end

    local t = {}
    t.table_name = table_name
    t._attributes = {}
    t.sql = sql

    setmetatable(t,{
            __index=self,
    })
    return t
end


function _M:select( columns, opts )
    print(columns)
    return self
end


function _M:distinct( yes )
    return self
end

function _M:from( table )
    print(table)
    return self

end

---------------------------------------
-- @condition string|table|function
-- @opts table
---------------------------------------
function _M:where( condition, opts )

    local condition_type = type(condition)

    if condition_type == 'string' then
        sql.where = condition
    elseif condition_type == 'function' then
        local r = condition()
        sql.where = (type(r) == 'string') and r or error('calculated result by condition() illegal')
    elseif condition_type ~= 'table' then
        error('condition illegal')
    end

    if condition[1] then
        -- array
        print('--------------')
        for k, _ in pairs(condition) do
            if type(k) ~= 'number' then
                error('condition illegal : find hash')
            end
        end


        function build_where(condition)

            local operator = condition[1]

            if operator == 'and' then
                print('__++++++')

                local t = {'true'}

                for i = 2,#condition do
                    local  v = condition[i]
                    print('=====>>',v)

                    local condition_type = type(v)

                    if condition_type  == 'string' then

                        t[#t + 1] = v

                    elseif condition_type  == 'function' then

                        local r = v()
                        t[#t + 1] = (type(r) == 'string') and r or error('calculated result by condition() illegal')

                    elseif condition_type == 'table' then

                        local r = build_where(v)
                        print(r)
                        t[#t + 1] = (type(r) == 'string') and r or error('calculated result by build_where(table) illegal')

                    else

                        error('and condition illegal')

                    end
                end
                return table.concat(t, ' and ')

            elseif operator == 'or' then
                    --todo
            elseif operator == 'between' then
            elseif operator == 'in' then
            elseif operator == 'not in' then
            elseif operator == 'like' then
            elseif operator == 'not like' then
            elseif operator == 'or like' then
            elseif operator == 'or not like' then
            -- elseif operator == 'exists' then
            -- elseif operator == 'not exists' then
            end

        end

        sql.where = build_where(condition)
    else
        -- hash
        local t = {}
        local i = 1

        for k, v in pairs(condition) do
            if type(k) == 'number' then
                error('condition illegal : find array')
            end
            t[i] = ' `' .. k ..'` = `' .. v..'` '
            i = i + 1
        end
        sql.where = table.concat(t,' and ')
    end


    return self
end

function _M:join( type, table, on, opts )

    return self
end

function _M:groupBy( columns )
    return self

end

function _M:having( condition, opts )
    return self
end



function _M:union( sql )
    return self

end


function _M:limit( limit )
    return self

end

function _M:offset( offset )
    return self
end

function _M:orderBy( columns )
    return self

end

function _M:all( ... )
    return self

end

function _M:one( ... )
    return self

end
return _M



