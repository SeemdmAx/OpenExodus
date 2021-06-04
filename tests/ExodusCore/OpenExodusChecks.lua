local component = require("component")
local event = require("event")
local string = require("string")
local filesystem = require("filesystem")
local internet = require("internet")
local shell = require("shell")
local properties = require("OpenExodusProperties")
local OpenExodusLibary = require("OpenExodusLibary")
local serialization = require("serialization")
local tunnel = component.tunnel
local modem = component.modem

local OpenExodusChecks = {}

function OpenExodusChecks.checkInternet()
  if component.list("internet") ~= nil then
    local request, responce = pcall(internet.request, "www.google.com")
    if request then
      return true
    else
      return false
    end
  else
    return false
  end
end

function OpenExodusChecks.bindCarddocks()
  for adress, name in pairs(component.list("carddock")) do
    component.invoke(adress, "bind")
  end
  return true
end

function OpenExodusChecks.checkCard(card)
  local count = 0
  for adress, name in pairs(component.list(card)) do
    if name == card then
      count = count + 1
    end
  end
  if count > 0 then
    return true
  else
    return false
  end
end

function OpenExodusChecks.registered()
  shell.execute('wget -fq "https://raw.githubusercontent.com/SeemdmAx/OpenExodus/master/OpenOSextension/registered.lua" "/home/registered.lua"')
  for line in io.lines("/home/registered.lua") do
    if string.find(line, computer.adress()) ~= nil then
      OpenExodusLibary.overwriteProperties("lastRegistered = ", os.time())
      return true
    end
  end
  return false
end

function OpenExodusChecks.countTunnels()
  if properties.tunnels == nil then
    OpenExodusLibary.addProperties("tunnels", 14, "integer")
  end
  local count = 0
  for adress, name in pairs(component.list("tunnel")) do
    count = count + 1
  end
  count = count - 1
  if count == properties.tunnels then
    return true, count
  else
    return false, count
  end
end

function OpenExodusChecks.reachBackupServer()
  if properties.BackupTunnel == nil then
    local backupTunnel = component.getPrimary("tunnel")
    OpenExodusLibary.addProperties("BackupTunnel", backupTunnel)
  end
  component.setPrimary(properties.BackupTunnel)
  tunnel.send("ping")
  local _, _, _, port, _, message = event.pull(10, "modem_message")
  if message == "pong" then
    return true
  else
    return false
  end
end

function OpenExodusChecks.checkServerConnection()
  if properties.ServerConnection == nil then
    OpenExodusLibary.addProperties("ServerConnection", component.getPrimary("tunnel"))
  end
  if component.getPrimary("tunnel") ~= properties.ServerConnection then
    component.setPrimary("tunnel", properties.ServerConnection)
  end
  local x = 0
  local tunnelStatus = false
  while x < 3 do
    tunnel.send("ping")
    local _, _, _, port, _, message = event.pull(10, "modem_message")
    if port == 0 and message == "pong" then
      tunnelStatus = true
      break
    else
      x = x + 1
    end
  end
  return tunnelStatus
end

function OpenExodusChecks.checkLicense()
  local dataTable = {}
  dataTable.["type"] = "license"
  dataTable.["license"] = properties.license
  local data = serialization.serialize(dataTable)
  tunnel.send(data)
  local x = 0
  local aa, ab, ac, port, ad, message
  local tunnelReturn = false
  while x < 3 do
    tunnel.send("ping")
    aa, ab, ac, port, ad, message = event.pull(10, "modem_message")
    if port == 0 then
      tunnelReturn = true
      break
    else
      x = x + 1
    end
  end
  if tunnelReturn == false then
    return "No connection to the server!"
  local dataReturn = serialization.unserialize(message)
  if dataReturn.okay == false then
    return false
  else
    for _, addon in pairs(properties.Addons) do
      if OpenExodusLibary.tableContains(dataReturn.boughtAddons, addon) == false then
        OpenExodusLibary.overwriteProperties("Addons = {", "", "table", addon .. ", ")
      end
    end
    for _, addon in pairs(dataReturn.boughtAddons) do
      if OpenExodusLibary.tableContains(properties.Addons, addon) == false then
        OpenExodusLibary.overwriteProperties("Addons = {", addon .. ", }", "table", "}")
      end
    end
    return true
  end
end 

return OpenExodusChecks
