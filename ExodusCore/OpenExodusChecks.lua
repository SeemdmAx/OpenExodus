local component = require("component")
local event = require("event")
local tunnel = component.tunnel
local modem = component.modem

local OpenExodusChecks = {}


------ Startup functions ------

function OpenExodusChecks.checkHardwareCarddocks()

  ------ Checks if required Carddocks are available ------

  local CardDockList = component.list("carddock")
  local count = 0
  for _ in pairs(CardDockList) do count = count + 1 end
  if count == 0 then
    return "Error 001a"
  end
  if count < 14 then
    return "Error 001b"
  end
  if count > 14 then
    return "Error 001c"
  end
  return true
end


function OpenExodusChecks.checkHardwareCards()

  ------ Checks if internet/network card is available ------

  local requiredCards = 0
  for adress, name in pairs(component.list()) do
    if name == "modem" or name == "internet" then
      requiredCards = requiredCards + 1
    end
  end
  if requiredCards < 2 then
    return "Error 002a"
  end
  if requiredCards > 2 then
    return "Error 002b"
  end
  return true
end


function OpenExodusChecks.checkHardwareTunnel()

  ------ Checks if only one tunnel to BackupServer is connected ------

  local tunnelList = component.list("tunnel")
  local tunnelCount = 0
  for _ in pairs(tunnelList) do tunnelCount = tunnelCount + 1 end
  if tunnelCount == 0 then
    return "Error 003a"
  end
  if tunnelCount > 1 then
    return "Error 003b"
  end

  ------ Make BackupServerTunnel primary ------

  for address, name in component.list("tunnel") do
    component.setPrimary(address)
  end

  return true
end


function OpenExodusChecks.checkNetworkBackupServer()

  ------ Checks if connection to BackupServer is given ------

  tunnel.send("ping")
  local _, _, _, port, _, message = event.pull(10, "modem_message")
  if message ~= "pong" then
    return "Error 004a"
  end
  return true
end


function OpenExodusChecks.checkNetworkUserRequestServer()

  ------ Checks if connection to UserRequestServer is given ------

  modem.broadcast(800, "ping")
  modem.open(700)
  local _, _, _, port, _, message = event.pull(10, "modem_message")
  if message ~= "pong" then
    return "Error 004b"
  end
  return true
end


function OpenExodusChecks.checkNetworkLicenceServer()

  ------ Checks if connection to LicenceRequestServer is given ------

  modem.broadcast(801, "ping")
  modem.open(701)
  local _, _, _, port, _, message = event.pull(10, "modem_message")
  if message ~= "pong" then
    return "Error 004c"
  end
 return true
end



function OpenExodusChecks.checkALl()

  ------ Collects every returndata from checks ------

  local Errors = {}
  local a = checkHardwareCarddocks()
  if a ~= true then
     table.insert(Errors, a)
  end
  local b = checkHardwareCards()
  if a ~= true then
    table.insert(Errors, b)
  end
  local c = checkHardwareTunnel()
  if c ~= true then
    table.insert(Errors, c)
  end
  local d = checkNetworkBackupServer()
  if d ~= true then
    table.insert(Errors, d)
  end
  local e = checkNetworkUserRequestServer()
  if e ~= true then
    table.insert(Errors, e)
  end
  local f = checkNetworkLicenceServer()
  if f ~= true then
    table.insert(Errors, f)
  end

  return Errors
end

return OpenExodusChecks
