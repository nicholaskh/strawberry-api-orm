local httpclient = require("framework.libs.httpclient"):new()
local QueryBuilder = require "framework.api.query_builder"
local cjson = require "cjson.safe"

local function tappend(t, v) t[#t+1] = v end

local Query = {}

Query.__index = Query

function Query:new(model_class)
    return setmetatable({
        model_class = model_class,
        query_builder = QueryBuilder:new(),
        p_where = {},
        p_as_array = false,
    }, Query)
end

function Query:as_array(p_as_array)
    if p_as_array == nil then
        p_as_array = true
    end
    self.p_as_array = p_as_array
    return self
end


function Query:where(key, value)
    self.p_where[key] = value
    return self
end

local function populate(self, rows)
    if not rows then
        return nil
    end
    if self.p_as_array then
        return rows
    end
    local models = {}
    for _, row in ipairs(rows) do
        tappend(models, self.model_class:new(row, true))
    end
    return models
end

function Query:all()
    local method = self.model_class.method_list
    if not method then
        method = "GET"
    end
    method = string.lower(method)
    local url = self.query_builder:build(self, self.model_class.api_list)
    return populate(self, cjson.decode(httpclient[method](httpclient, url)))
end

function Query:one()
    local method = self.model_class.method_detail
    if not method then
        method = "GET"
    end
    method = string.lower(method)
    local url = self.query_builder:build(self, self.model_class.api_detail)
    return populate(self, {cjson.decode(httpclient[method](httpclient, url))})[1]
end

function Query:update(key, attributes)
    local method = self.model_class.method_update
    if not method then
        method = "POST"
    end
    method = string.lower(method)
    self.p_where[self.model_class.primary_key] = key
    local url = self.query_builder:build(self, self.model_class.api_update)
    return httpclient[method](httpclient, url, attributes)
end

function Query:create(attributes)
    local method = self.model_class.method_create
    if not method then
        method = "POST"
    end
    method = string.lower(method)
    local url = self.query_builder:build(self, self.model_class.api_create)
    return httpclient[method](httpclient, url, attributes)
end

return Query
