-- Basic, in-memory, id-token based session middleware.

local useful = require("useful")

-- Map of sessions to data.
-- Note that after enough time this will leak memory as we don't have a way to expire session atm
local sessions = {}

local function generateRandomSessionId()
    math.randomseed(os.clock()^5)
    return useful.generateRandomString(useful.alphaNumericCharset, 32)
end

local session_mt = {
    __index = function (table, key)
        return sessions[table.session_token][key]
    end,
    __newindex = function (table, key, value)
        if key ~= "session_token" then
            sessions[table.session_token][key] = value
        end
    end
}

---@param req table
---@param res table
---@param go function
return function (req, res, go)
    -- TODO: Cookies should get parsed by a separate middleware
    local cookie_header = req.headers["cookie"] or ""
    local session_token = cookie_header:match("sid=(%w+);")

    if not session_token then
        session_token = generateRandomSessionId()
        res.headers["Set-Cookie"] = "sid=" .. session_token .. ";"
        sessions[session_token] = {}
    end

    local session_table = { session_token = session_token }
    setmetatable(session_table, session_mt)

    req.session = session_table
    go()
end