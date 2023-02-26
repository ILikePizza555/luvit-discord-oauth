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
local BASE_URL = os.getenv("LUA_BASE_URL") or "http://localhost:8080"

local html = require("html")
local querystring = require("querystring")
local useful = require("useful")

local function generateDiscordAuthorizationUrl (scopes, state, redirect_uri)
  return "https://discord.com/api/oauth2/authorize?" .. querystring.stringify({
    response_type = "code",
    client_id = DISCORD_CLIENT_ID,
    scope = table.concat(scopes, " "),
    state = state,
    redirect_uri = redirect_uri,
    prompt = "consent"
  })
end

require("weblit-app")
    .bind({
      host = LISTEN_HOST,
      port = LISTEN_PORT
    })
    .use(require("weblit-logger"))
    .use(require("weblit-auto-headers"))
    .use(require("session"))
    .route({method="GET", path="/callback/discord_auth"}, function (req, res, go)
      print(req)
      print(res)
      
      res.code = 200
      res.body = "Callback recieved"
    end)
    .route({method="GET", path="/"}, function (req, res, go)
      req.session.state = useful.generateRandomString(useful.alphaNumericCharset, 8)

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

            .discord-sign-in-btn:link, .discord-sign-in-btn:visited {
              color: inherit;
              text-decoration: none;
            }
        
            .discord-sign-in-btn > div {
              display: inline-block;
              background-color: #5865F2;
              padding: 12px;
              border-radius: 8px;
            }
          ]]}
        },
        html.body {
          html.a {
            attributes = {
              class = "discord-sign-in-btn",
              href = generateDiscordAuthorizationUrl(
                {"identify", "email"},
                req.session.state,
                BASE_URL .. "/callback/discord_auth")
            },
            html.div { "Sign-in with Discord"}
          }
        }
      }

      res.code = 200
      res.headers["Content-Type"] = "text/html"
      res.body = template:render()

    end)
    .start()