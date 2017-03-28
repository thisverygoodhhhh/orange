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

    function build_where(condition)

        local condition_type = type(condition)

        if condition_type == 'string' then
            return condition
        elseif condition_type == 'function' then
            local r = condition()
            return (type(r) == 'string') and r or error('calculated result by condition() illegal')
        elseif condition_type ~= 'table' then
            error('condition illegal')
        end

        if condition[1] then
            -- array
            for k, _ in pairs(condition) do
                if type(k) ~= 'number' then
                    error('condition illegal : find hash')
                end
            end

            local operator = condition[1]

            if operator == 'and' then

                local t = {'true'}

                for i = 2,#condition do

                    local  v = condition[i]

                    local condition_type = type(v)

                    if condition_type  == 'string' then

                        t[#t + 1] = v

                    elseif condition_type  == 'function' then

                        local r = v()
                        t[#t + 1] = (type(r) == 'string') and r or error('calculated result by condition() illegal')

                    elseif condition_type == 'table' then

                        local r = build_where(v)
                        t[#t + 1] = (type(r) == 'string') and r or error('calculated result by build_where(table) illegal')

                    else

                        error('and condition illegal')

                    end
                end
                return table.concat(t, ' and ')

            elseif operator == 'or' then

                local t = {'false'}

                for i = 2,#condition do

                    local  v = condition[i]

                    local condition_type = type(v)

                    if condition_type  == 'string' then

                        t[#t + 1] = v

                    elseif condition_type  == 'function' then

                        local r = v()
                        t[#t + 1] = (type(r) == 'string') and r or error('calculated result by condition() illegal')

                    elseif condition_type == 'table' then

                        local r = build_where(v)

                        t[#t + 1] = (type(r) == 'string') and r or error('calculated result by build_where(table) illegal')

                    else

                        error('or condition illegal')

                    end
                end

                return table.concat(t, ' or ')

            elseif operator == 'between' then

                return  condition[2] .. ' between '.. condition[3] .. ' and ' .. condition[4]

            elseif operator == 'in' then

                local value_type = type(condition[3])

                if value_type == 'function' then

                    local r = condition[3]()
                    r = (type(r) == 'string') and r or error('calculated result by build_where(table) illegal')
                    return condition[2] .. ' in (' ..  r ..')'

                else

                    return condition[2] .. ' in (' ..  table.concat(condition[3]) ..')'

                end

            elseif operator == 'not in' then

                local value_type = type(condition[3])

                if value_type == 'function' then

                    local r = condition[3]()
                    r = (type(r) == 'string') and r or error('calculated result by build_where(table) illegal')
                    return condition[2] .. ' not in (' ..  r ..')'

                else

                    return condition[2] .. ' not in (' ..  table.concat(condition[3]) ..')'

                end
                -- condition[1] = 'in'
                -- return ' not ' .. build_where(condition)
            elseif operator == 'like' then

                local value_type = type(condition[3])

                if value_type == 'string' then

                    return condition[2] .. ' like  %' .. condition[3] .. '% '

                elseif value_type == 'table' then
                    local r = {}
                    for _,v in ipairs(condition[3]) do
                        r[#r + 1] = condition[2] .. ' like %' .. v ..'% '
                    end

                    return table.concat(r,' and ')
                else
                    error('like illegal')
                end

            elseif operator == 'not like' then
                local value_type = type(condition[3])

                if value_type == 'string' then

                    return condition[2] .. ' not like  %' .. condition[3] .. '% '

                elseif value_type == 'table' then
                    local r = {}
                    for _,v in ipairs(condition[3]) do
                        r[#r + 1] = condition[2] .. ' not like %' .. v ..'% '
                    end

                    return table.concat(r,' and ')
                else
                    error('like illegal')
                end
            elseif operator == 'or like' then

                local value_type = type(condition[3])

                if value_type == 'table' then
                    local r = {}
                    for _,v in ipairs(condition[3]) do
                        r[#r + 1] = condition[2] .. ' like %' .. v ..'% '
                    end

                    return table.concat(r,' or ')
                else
                    error('like illegal')
                end

            elseif operator == 'or not like' then

                local value_type = type(condition[3])

                if value_type == 'string' then

                    return condition[2] .. ' not like  %' .. condition[3] .. '% '

                elseif value_type == 'table' then
                    local r = {}
                    for _,v in ipairs(condition[3]) do
                        r[#r + 1] = condition[2] .. ' not like %' .. v ..'% '
                    end

                    return table.concat(r,' or ')
                else
                    error('like illegal')
                end

            -- elseif operator == 'exists' then
            -- elseif operator == 'not exists' then
            end

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
            return table.concat(t,' and ')
        end
    end

    sql.where = build_where(condition)

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



