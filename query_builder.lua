local Response = require "framework.response"

local function tappend(t, v) t[#t+1] = v end

local QueryBuilder = {}

QueryBuilder.__index = QueryBuilder

function QueryBuilder:new()
    return setmetatable({}, QueryBuilder)
end

local function build_url(base_url, params)
    local url = base_url
    for k, v in pairs(params) do
        k = "{" .. k .. "}"
        url = string.gsub(url, k, v)
    end
    local missing_params = {}
    for param in string.gmatch(url, "%{%w+%}") do
        tappend(missing_params, param)
    end
    if #missing_params > 0 then
        error("missing api params: " .. table.concat(missing_params, ","))
    end
    return url
end

function QueryBuilder:build(query, base_url)
    return query.model_class.domain .. build_url(base_url, query.p_where)
end

return QueryBuilder
