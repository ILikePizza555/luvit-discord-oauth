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
local DISCORD_CLIENT_ID = os.getenv("DISCORD_CLIENT_ID")
local DISCORD_CLIENT_SECRET = os.getenv("DISCORD_CLIENT_SECRET")
local BASE_URL = os.getenv("LUA_BASE_URL") or "localhost"

-- Checking that the important environment vars are set
if not DISCORD_CLIENT_ID then
  io.stderr:write("error: DISCORD_CLIENT_ID environment variable required, but not set")
  os.exit(1, true)
end
if not DISCORD_CLIENT_SECRET then
  io.stderr:write("error: DISCORD_CLIENT_SECRET environment variable required, but not set")
  os.exit(1, true)
end

require("weblit-app")
    .bind({
      host = LISTEN_HOST,
      port = LISTEN_PORT
    })
    .use(require("weblit-logger"))
    .use(require("weblit-auto-headers"))
    .route({method="GET", path="/"}, function (req, res, go)
      res.code = 200
      res.headers["Content-Type"] = "text/html"
      res.body = [[
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <style>
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
          </style>
        </head>
        <body>
          <div>
            <a id="discord-sign-in">Sign In With Discord</a>
          </div>
        </body>
        </html>
      ]]
    end)
    .start()