local OpenExodusBoot = {}

local filesystem = require("filesystem")
local shell = require("shell")
local string = require("string")

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

    ------ Checks if the mainFile exists, if not it will reinstall the system ------
  local mainExists = false
  local files = OpenExodusBoot.dirLookup("/OpenExodus/ExodusMain")
  for _, file in pairs(files) do
    if string.find(file, "Main.lua") ~= nil then
      mainExists = true
    end
  end
  if filesystem.exists("/OpenExodus/ExodusMain") == false or mainExists == false then
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
    local files = OpenExodusBoot.dirLookup("/OpenExodus/ExodusMain")
    for _, file in pairs(files) do
      if string.find(file, "Main.lua") ~= nil then
        mainFile, _ = string.gsub(file, "Main.lua")
        mainFile, _ = string.gsub(mainFile, "/OpenExodus/ExodusMain/")
      end
    end
    local SysTypePrefix = ""
    if string.upper(mainFile) ~= "SHIP" and string.upper(mainFile) ~= "BASE" then
      SysTypePrefix = "Server"
    end
    local SysType = mainFile
    for line in io.lines("/OpenExodus/ExodusCore/OpenExodusProperties.lua") do
      if string.find(line, "SysTypePrefix") ~= nil then
        line = string.gsub(line, '""', '"' .. SysTypePrefix .. '"') .. "\n";
      elseif string.find(line, "SysType") ~= nil then
        line = string.gsub(line, '""', '"' .. SysType .. '"') .. "\n";
      else
        line = line .. "\n";
      end
      local new = io.open("/home/propertiesTmp.lua", "a")
      new:write(line)
      new:close()
    end
    filesystem.copy("/home/propertiesTmp.lua", "/OpenExodus/ExodusCore/OpenExodusProperties.lua")
    filesystem.remove("/home/propertiesTmp.lua")
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
local gitdownload = require("OpenExodusGitDownloader")




------ Main Booting Sequenz ------
function OpenExodusBoot.bootUp()
  OpenExodusGui.setMaxResolution()
  if OpenExodusGui.getResolution("width") ~= 160 or OpenExodusGui.getResolution("height") ~= 50 then
    shell.execute("reboot")
  end
  OpenExodusGui.drawBorder(2, 1, 158, 50, 0x008CCD)
  local statusX, statusY = OpenExodusGui.getXY("middle", "topMiddle", 55, 0) --- 55
  OpenExodusGui.drawOpenExodusLogo(statusX, statusY, 0xFFFFFF, 0x008CCD, 0xFFE400)

  io.read()
end

OpenExodusBoot.bootUp()

return OpenExodusBoot
