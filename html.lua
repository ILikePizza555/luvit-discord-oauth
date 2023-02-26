-- Simple declarative HTML module

---@alias closeType
---| "none" # This tag does not self-close, and takes children
---| "open" # This tag doesn't take any children but also doesn't self-close (i.e `<meta>` tag)
---| "self" # This tag self-closes normally

---@class Tag
---@field tagName string The name of the tag
---@field attributes table<string, string> All attributes of the tag
---@field body (string | Tag)[] The body of the tag
---@field closeType closeType How this tag closes
---@field render fun(self: Tag): string Renders the tag as a string

---@return Tag
local function tag (opts)
    local Tag = {
        tagName = opts.tagName,
        attributes = opts.attributes or {},
        body = {},
        closeType = opts.closeType or "none"
    }

    for k, v in pairs(opts) do
        if k ~= "tagName" then
            if (type(v) == "table" and v.tagName) or type(v) == "string" then
                table.insert(Tag.body, v)
            end
        end
    end

    function Tag:render()
        local stringBuffer = {"<", self.tagName}

        for k, v in pairs(self.attributes) do
            table.insert(stringBuffer, " ")
            table.insert(stringBuffer, k)
            table.insert(stringBuffer, "=\"")
            table.insert(stringBuffer, v)
            table.insert(stringBuffer, "\"")
        end

        if self.closeType == "self" then
            table.insert(stringBuffer, "/>")
        elseif self.closeType == "open" then
            table.insert(stringBuffer, ">")
        elseif self.closeType == "none" then
            table.insert(stringBuffer, ">")

            for _, v in pairs(self.body) do
                if type(v) == "string" then
                    table.insert(stringBuffer, v)
                else
                    table.insert(stringBuffer, v:render())
                end
            end

            table.insert(stringBuffer, "</")
            table.insert(stringBuffer, self.tagName)
            table.insert(stringBuffer, ">")
        end

        return table.concat(stringBuffer, "")
    end

    return Tag
end

local module = {
    tag = tag,
    meta = function (opts)
        opts.tagName = "meta"
        opts.closeType = "open"
        return tag(opts)
    end
}

local mt = {
    __index = function (table, key)
        return function (opts)
            opts.tagName = key
            return tag(opts)
        end
    end
}

setmetatable(module, mt)

return module