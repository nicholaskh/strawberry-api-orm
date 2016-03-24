local Query = require "framework.api.query"

local ActiveRecord = {
    domain = "",

    api_list = "",
    api_detail = "",
    api_create = "",
    api_update = "",
    api_delete = "",

    method_list = "GET",
    method_detail = "GET",
    method_create = "POST",
    method_update = "PUT",
    method_delete = "DELETE",

    primary_key = "id",
}

ActiveRecord.__index = ActiveRecord

local function recursive_index(table, key, base_table)
    local value = rawget(base_table, "attributes")[key]
    if value then 
        return value
    end 
    value = rawget(table, key)
    if value then
        return value
    end 
    local index = rawget(table, "__index")
    if index == table then
        return nil
    end
    if index then
        local getter = "get_" .. key
        local value = index[getter]
        if value then
            if type(value) == "function" then
                local res = value(base_table)
                if res.is_query then
                    return get_relation(res, key, base_table)
                else
                    return res
                end
            end
            return value
        end
        value = index[key]
        if value then
            return value
        elseif type(index) == "table" then
            return recursive_index(index, key, base_table)
        else
            return nil
        end
    end

    return nil
end

function ActiveRecord:new(row, from_api)
    if from_api == nil then from_api = false end
    if not row then row = {} end
    local model = {
        raw_attributes = {}, -- for insert
        attributes = row,
        columns = {},
        is_new = not from_api,
        updated_attributes = {},
        related = {},
    }
    if not is_new then
        for k, v in pairs(row) do
            model.columns[k] = 1
        end
    end
    model.__index = self
    return setmetatable(model, {
        __newindex = function(table, key, value)
            if table.is_new then
                rawset(table.raw_attributes, key, value)
            else
                if table.columns[key] then
                    rawset(table.updated_attributes, key, value)
                    rawset(table.attributes, key, value)
                else
                    rawset(table, key, value)
                end
            end
        end,
        __index = function(table, key)
            return recursive_index(table, key, table)
        end
    })
end

function ActiveRecord:get_key()
    return self[self.primary_key]
end

function ActiveRecord:find()
    return Query:new(self)
end

local function create(self)
    local ret = Query:new(self):create(self.raw_attributes)
    self.raw_attributes = {}
    return ret
end

local function update(self)
    local ret = Query:new(self):update(self:get_key(), self.updated_attributes)
    self.updated_attributes = {}
    return ret
end

function ActiveRecord:save()
    if self.is_new then
        return create(self)
    else
        return update(self)
    end
end

function ActiveRecord:to_array()
    return self.attributes
end

return ActiveRecord
