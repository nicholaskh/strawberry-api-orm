# strawberry-api-orm
extension of api-orm for lua strawberry framework

###	Usage
*	Define model extends active record:


		local ActiveRecord = require "framework.api.active_record"
		local News = {
            domain = "http://www.test.com",

            api_list = "/news",
            api_detail = "/news/{id}",
            api_create = "/news",
            api_update = "/news/{id}",
            api_delete = "/news/{id}",

			--default values
            method_list = "GET",
            method_detail = "GET",
            method_create = "POST",
            method_update = "PUT",
            method_delete = "DELETE",

            primary_key = "id",
        }

        News.__index = News

        setmetatable(News, {
           __index = ActiveRecord,
        })

        return News

*	Get model list
	-	local news = News:find():all()

*	Get model detail
	-	local news = News:find():where("id", 1):one()

*	Return array instead of instance
	-	local news = News:find():as_array():all()
	-	local news = News:find():where("id", 1):as_array():one()

*	Create one model


		local news = News:new()
        news.title = 'test title'
        news.content = 'test content'
        local ret = news:save()

*	Update one model


        local news = News:find():where("id", 1):one()
        news.title = "title1"
        local ret = news:save()
