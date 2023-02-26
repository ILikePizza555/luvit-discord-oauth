-- Basic, in-memory, id-token based session middleware.

local useful = require("useful")

-- Map of sessions to data.
-- Note that after enough time this will leak memory as we don't have a way to expire session atm
local sessions = {}

local function generateRandomSessionId()
    math.randomseed(os.clock()^5)
    return useful.generateRandomString(useful.alphaNumericCharset, 32)
end

-- Metatable for the session table that gets added to the `req` table
-- Uses the session_token value to access the module-level sessions table
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
    -- TODO: Cookies should probably get parsed by a separate middleware
    local cookie_header = req.headers["cookie"] or ""
    local session_token = nil
    
    -- Sometimes we can have multiple session cookies. (i.e if the server reloads.)
    -- Only one sid is valid, so get the first valid one if it exists.
    for sid in cookie_header:gmatch("sid=(%w+)") do
        if sessions[sid] then
            session_token = sid
            break
        end
    end

    -- There was no session token cookie or it wasn't valid, create a new one.
    if not session_token then
        session_token = generateRandomSessionId()
        -- TODO: Make max-age configurable
        res.headers["Set-Cookie"] = "sid=" .. session_token .. "; Max-Age: 1000; Same-Site=Strict;"
        sessions[session_token] = {}
    end

    local session_table = { session_token = session_token }
    setmetatable(session_table, session_mt)

    req.session = session_table
    go()
end