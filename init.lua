  --[[lit-meta
    name = "luvit-discord"
    version = "0.0.1"
    dependencies = {
      "creationix/weblit"
    }
    description = "Discord OAuth on luvit proof-of-concept"
    tags = { "luvit", "lit", "discord" }
    license = "MIT"
    author = { name = "Izzy Lancaster", email = "avrisaac555@gmail.com" }
    homepage = "https://github.com/ILikePizza555/luvit-discord"
  ]]

-- Constants 
local LISTEN_HOST = os.getenv("LUA_LISTEN_HOST") or "0.0.0.0"
local LISTEN_PORT = os.getenv("LUA_LISTEN_PORT") or "8080"
local DISCORD_CLIENT_ID = os.getenv("DISCORD_CLIENT_ID") or error("DISCORD_CLIENT_ID environment variable required, but not set")
local DISCORD_CLIENT_SECRET = os.getenv("DISCORD_CLIENT_SECRET") or error("DISCORD_CLIENT_SECRET environment variable required, but not set")
local BASE_URL = os.getenv("LUA_BASE_URL") or "localhost"

local html = require("html")
local useful = require("useful")

local function generateDiscordAuthorizationUrl (scopes, state, redirect_uri)
  return "https://discord.com/oauth2/authorize?response_type=code"
    .. "&client_id=" .. useful.urlEncode(DISCORD_CLIENT_ID)
    .. "&scopes=" .. useful.urlEncode(table.concat(scopes, "%20"))
    .. "&state=" .. useful.urlEncode(state)
    .. "&redirect_uri=" .. useful.urlEncode(redirect_uri)
end

require("weblit-app")
    .bind({
      host = LISTEN_HOST,
      port = LISTEN_PORT
    })
    .use(require("weblit-logger"))
    .use(require("weblit-auto-headers"))
    .route({method="GET", path="/"}, function (req, res, go)
      local template = html.html {
        html.head {
          html.meta { attributes = { charset = "UTF-8" } },
          html.style {[[
            body {
              color: white;
              background-color: #202225;
              font-size: 16px;
              font-family: sans-serif;
              line-height: 150%;
              font-weight: 400;
            }
        
            #discord-sign-in {
              display: inline-block;
              background-color: #5865F2;
              padding: 12px;
              border-radius: 8px;
            }
          ]]}
        },
        html.body {
          html.div {
            html.a {
              attributes = {
                id = "discord-sign-in"
              },
              "Sign-in with Discord"
            }
          }
        }
      }
      
      res.code = 200
      res.headers["Content-Type"] = "text/html"
      res.body = template:render()

    end)
    .start()