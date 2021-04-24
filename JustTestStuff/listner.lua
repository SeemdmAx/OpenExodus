local component = require("component")
local event = require("event")
local tunnel = component.tunnel

while true do
  local _, _, _, port, _, message = event.pull("modem_message")
  if message == "ping" then
    tunnel.send("pong")
    print("pong")
  end
end