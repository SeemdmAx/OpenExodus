local OpenExodusBoot = {}

local filesystem = require("filesystem")
local shell = require("shell")
local string = require("string")
local computer = require("computer")

function OpenExodusBoot.dirLookup(folder)
   local files = {}
   local p = io.popen('find '.. tostring(folder))
   for file in p:lines() do
       table.insert(files, file)
   end
   return files
end

function OpenExodusBoot.tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function OpenExodusBoot.preInitialization()
  ------ Checks if main-folder exists ------
  if filesystem.exists("/OpenExodus") == false then
    filesystem.makeDirectory("/OpenExodus")
  end

  ------ Checks if core-folder exists ------
  if filesystem.exists("/OpenExodus/ExodusCore") == false then
    filesystem.makeDirectory("/OpenExodus/ExodusCore")
  end

  ------ Overrites the package.path so the OpenExodusPackages are loadable ------
  package.path = "/OpenExodus/ExodusCore/?.lua;/OpenExodus/?/?.lua;/OpenExodus/?.lua;/lib/?.lua;/usr/lib/?.lua;/home/lib/?.lua;./?.lua;/lib/?/init.lua;/usr/lib/?/init.lua;/home/lib/?/init.lua;./?/init.lua"

  ------ Checks if the OpenExodusCorePackages are available ------
  if filesystem.exists("/OpenExodus/ExodusCore/OpenExodusGui.lua") == false then
    shell.execute('wget -fq "https://raw.githubusercontent.com/SeemdmAx/OpenExodus/master/ExodusCore/OpenExodusGui.lua" "/OpenExodus/ExodusCore/OpenExodusGui.lua"')
  end

  if filesystem.exists("/OpenExodus/ExodusCore/OpenExodusGitDownloader.lua") == false then
    shell.execute('wget -fq "https://raw.githubusercontent.com/SeemdmAx/OpenExodus/master/ExodusCore/OpenExodusGitDownloader.lua" "/OpenExodus/ExodusCore/OpenExodusGitDownloader.lua"')
  end

  if filesystem.exists("/OpenExodus/ExodusCore/OpenExodusLibary.lua") == false then
    shell.execute('wget -fq "https://raw.githubusercontent.com/SeemdmAx/OpenExodus/master/ExodusCore/OpenExodusLibary.lua" "/OpenExodus/ExodusCore/OpenExodusLibary.lua"')
  end

  if filesystem.exists("/OpenExodus/ExodusCore/OpenExodusChecks.lua") == false then
    shell.execute('wget -fq "https://raw.githubusercontent.com/SeemdmAx/OpenExodus/master/ExodusCore/OpenExodusChecks.lua" "/OpenExodus/ExodusCore/OpenExodusChecks.lua"')
  end

  ------ imports OpenExodusLibary for processing ------
  local OpenExodusLibary = require("OpenExodusLibary")

  ------ Checks if the mainFile exists, if not it will reinstall the system ------
  local mainExists = false
  local filesMain
  if filesystem.exists("/OpenExodus/ExodusClient") then
    filesMain = OpenExodusBoot.dirLookup("/OpenExodus/ExodusClient")
  elseif filesystem.exists("/OpenExodus/ExodusServer") then
    filesMain = OpenExodusBoot.dirLookup("/OpenExodus/ExodusServer")
  end
  for _, file in pairs(files) do
    if string.find(file, "Main.lua") ~= nil then
      mainExists = true
    end
  end
  if mainExists == false then
    print("Your system is not runable!")
    while true do
      io.write("Do you wanna reinstall (Y/N): ")
      local reinstall = io.read()
      if string.upper(reinstall) == "Y" then
        shell.execute("pastebin run g6xm54cJ")
      elseif string.upper(reinstall) == "N" then
        print("We cannot do something for you! Shutdown")
        shell.execute("shutdown")
      else
        print("Invaild Input!")
      end
    end
  end

  ------ Although it will write the OpenExodusProperties if they dont exist ------
  if filesystem.exists("/OpenExodus/ExodusCore/OpenExodusProperties.lua") == false then
    shell.execute('wget -fq "https://raw.githubusercontent.com/SeemdmAx/OpenExodus/master/ExodusCore/OpenExodusProperties.lua" "/OpenExodus/ExodusCore/OpenExodusProperties.lua"')
    local mainFile
    local files
    local id
    if filesystem.exists("/OpenExodus/ExodusClient") then
      files = OpenExodusBoot.dirLookup("/OpenExodus/ExodusClient")
      id = "/OpenExodus/ExodusClient"
    else
      files = OpenExodusBoot.dirLookup("/OpenExodus/ExodusServer")
      id = "/OpenExodus/ExodusServer"
    end
    for _, file in pairs(files) do
      if string.find(file, "Main.lua") ~= nil then
        mainFile, _ = string.gsub(file, "Main.lua")
        mainFile, _ = string.gsub(mainFile, id .. "/")
      end
    end
    local SysTypePrefix = ""
    if mainFile == "client" then
      SysTypePrefix = "client"
    else
      SysTypePrefix = "server"
    end
    OpenExodusLibary.overwriteProperties("SysTypePrefix = ", SysTypePrefix)
    OpenExodusLibary.overwriteProperties("SysType = ", mainFile)
  end

  ------ Check if needed libaries are available, if not then install them ------
  if filesystem.exists("/lib/json.lua") == false then
    shell.execute('wget -fq "https://raw.githubusercontent.com/SeemdmAx/OpenExodus/master/OpenOSextension/json.lua" "/lib/json.lua"')
  end
end





------ Run preInitialization and import ExodusPackages ------
OpenExodusBoot.preInitialization()

local OpenExodusGui = require("OpenExodusGui")
local properties = require("OpenExodusProperties")
local OpenExodusGitDownloader = require("OpenExodusGitDownloader")
local OpenExodusChecks = require("OpenExodusChecks")



------ Main Booting Sequenz ------
function OpenExodusBoot.bootUp()
  ------ Were getting the recommended screen resolution ------
  if OpenExodusGui.setNeededResolution() == false then
    if OpenExodusGui.warningPopUp(45, 21, "Info", "Bad Resolution! Build Screen W:3; H:2 and reboot!", 0x00000, "Reboot", "ResolutionReboot", "Cancle", "ResolutionCancle") == "ResolutionReboot" then
      shell.execute("reboot")
    end
  end

  ------ Getting the bootScreen design -----
  OpenExodusGui.drawBootingScreen()

  ------ Checking internet-connection ------
  if OpenExodusChecks.checkInternet() == false then
    if properties.lastRegistered ~= nil then
      if OpenExodusGui.warningPopUp(45, 21, "Error", "Insert a Internet-Card/Connect to Wifi and reboot!", 0x00000, "Reboot", "InternetReboot", "Cancle", "InternetCancle") == "InternetReboot" then
        shell.execute("reboot")
      end
    else
      if OpenExodusGui.warningPopUp(45, 21, "Error", "Insert a Internet-Card/Connect to Wifi and reboot!", 0x00000, "Reboot", "InternetReboot") == "InternetReboot" then
        shell.execute("reboot")
      end
  else
    ------ Getting the latest updates -----
    OpenExodusGui.drawBootingStatus("Checking for updates on Github/SeemdmAx/OpenExodus")
    local updatesValue, _ = OpenExodusGitDownloader.updatesAvailable()
    if updatesValue ~= properties.currentVersion then
      os.sleep(0.8)
      OpenExodusGui.drawBootingStatus("Updates available! Downloading ...")
      OpenExodusGitDownloader.downloadGitRepository()
      OpenExodusGui.drawBootingStatus("Download completed! Installing updates to system ...")
      local updatedFiles = OpenExodusGitDownloader.updateCreateFiles()
      OpenExodusGui.drawBootingStatus("Clearing Update-Cache and saving data ...")
      OpenExodusGitDownloader.clearUpdateTmp()
      OpenExodusGitDownloader.saveUpdateVersion()
      os.sleep(0.8)
      if updatedFiles > 0 then
        shell.execute("reboot")
      end
    end
  end

  ------ Bind carddocks if available ------
  OpenExodusGui.drawBootingStatus("Reading carddocks and binding into system ...")
  OpenExodusChecks.bindCarddocks()

  ------ Checking some server stuff -------
  if string.upper(properties.SysTypePrefix) == "SERVER" then
    ------ Checks Network-Card ------
    OpenExodusGui.drawBootingStatus("Checking if required card Network-Card is available ...")
    if OpenExodusChecks.checkCard("modem") == false then
      if OpenExodusGui.warningPopUp(45, 21, "Error", "No Network-Card, insert and reboot!", 0x00000, "Reboot", "NetworkCardReboot") == "NetworkCardReboot" then
        shell.execute("reboot")
      end
    end

    ------ Checks Data-Card ------
    OpenExodusGui.drawBootingStatus("Checking if required card Data-Card is available ...")
    if OpenExodusChecks.checkCard("data") == false then
      if OpenExodusGui.warningPopUp(45, 21, "Error", "No Data-Card, insert and reboot!", 0x00000, "Reboot", "DataCardReboot") == "DataCardReboot" then
        shell.execute("reboot")
      end
    end

    ------ Checks if the server is a registered one ------
    OpenExodusGui.drawBootingStatus("Reading registered Changelog and checking computer address ...")
    if OpenExodusChecks.registered() == false then
      if OpenExodusGui.warningPopUp(45, 21, "Error", "This server is not registered! No use possible!", 0x00000, "Shutdown", "RegisterShutdown") == "RegisterShutdown" then
        shell.execute("shutdown")
      end
    end

    ----- Stuff especially for the forwarding server -----
    if string.upper(properties.SysType) == "FORWARDING" then
      ------ Check how many tunnels are connected ------
      OpenExodusGui.drawBootingStatus("Tunnel count checking ...")
      local tunnelReturn, tunnels = OpenExodusChecks.countTunnels()
      if tunnelReturn == false then
        if OpenExodusGui.warningPopUp(45, 21, "Info", "There are " .. tunnels .. " connected, not " .. properties.tunnels, 0x00000, "Reboot", "TunnelsReboot", "Cancle", "TunnelsCancle") == "TunnelsReboot" then
          shell.execute("reboot")
        end
      end

      ------ Trys to reach backup-server ------
      OpenExodusGui.drawBootingStatus("Establishing connection to the Backup-Server ...")
      if OpenExodusChecks.reachBackupServer() == false then
        if OpenExodusGui.warningPopUp(45, 21, "Info", "Backup-Server not reachable!", 0x00000, "Reboot", "BackupReboot", "Cancle", "BackupCancle") == "BackupReboot" then
          shell.execute("reboot")
        end
      end
    end
  end

  ------ Do some booting stuff for the client os ------
  if string.upper(properties.SysTypePrefix) == "CLIENT" then
    ------ Checking tunnel-conneciton to forwarding-server ------
    if OpenExodusChecks.checkCard("tunnel") == false then
      if OpenExodusGui.warningPopUp(45, 21, "Error", "Linked-Card missing, can't connect to server!", 0x00000, "Reboot", "LinkedReboot") == "LinkedReboot" then
        shell.execute("reboot")
      end
    else
      if OpenExodusChecks.checkServerConnection() == false then
        if OpenExodusGui.warningPopUp(45, 21, "Error", "Cannot connect to the servers!", 0x00000, "Reboot", "FailReboot") == "FailReboot" then
          shell.execute("reboot")
        end
      end
    end
    ------ Check if cards required by addons are available ------
    if filesystem.exists("/home/cardsByAddons.lua") then
      for line in io.lines("/home/cardsByAddons.lua") do
        local card = string.lower(line)
        if OpenExodusChecks.checkCard(card) == false then
          if OpenExodusGui.warningPopUp(45, 21, "Info", card .. " not found! Insert and reboot", 0x00000, "Reboot", "AddonCardReboot", "Cancle", "AddonCardCancle") == "AddonCardReboot" then
            shell.execute("reboot")
          end
        end
      end
    end
    ------ Check License ------
    if properties.license == nil then
      local licenseKey = ----
      OpenExodusLibary.addProperties("license", licenseKey)
    end
    while true
      local licenseCheck = OpenExodusChecks.checkLicense()
      if licenseCheck ~= false and licenseCheck ~= true then
        if OpenExodusGui.warningPopUp(45, 21, "Error", "Cannot connect to the servers!", 0x00000, "Reboot", "FailReboot") == "FailReboot" then
          shell.execute("reboot")
        end
      end
      if licenseCheck == true then
        break
      end
      if licenseCheck == false then
        local returnValue = OpenExodusGui.warningPopUp(45, 21, "Error", "Invaild License-Key! You need a correct one!", 0x00000, "Change", "LicenseChange", "Shutdown", "LicenseShutdown")
        if returnValue == "LicenseShutdown" then
          shell.execute("shutdown")
        else
          local licenseKey = ----
          OpenExodusLibary.overwriteProperties("license = ", licenseKey)
        end
      end
    end
  end
  io.read()
end

OpenExodusBoot.bootUp()

return OpenExodusBoot
