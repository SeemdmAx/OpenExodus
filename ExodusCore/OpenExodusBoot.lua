local OpenExodusBoot = {}

local filesystem = require("filesystem")
local shell = require("shell")

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
  if filesystem.exists("/OpenExodus/ExodusCore/OpenExodusProperties.lua") == false then
    shell.execute('wget -fq "https://raw.githubusercontent.com/SeemdmAx/OpenExodus/master/ExodusCore/OpenExodusProperties.lua" "/OpenExodus/ExodusCore/OpenExodusProperties.lua"')
  end
  if filesystem.exists("/OpenExodus/ExodusCore/OpenExodusGitDownloader.lua") == false then
    shell.execute('wget -fq "https://raw.githubusercontent.com/SeemdmAx/OpenExodus/master/ExodusCore/OpenExodusGitDownloader.lua" "/OpenExodus/ExodusCore/OpenExodusGitDownloader.lua"')
  end

  ------ Check if needed libaries are available, if not then install them ------
  if filesystem.exists("/lib/json.lua") == false then
    shell.execute('wget -fq "https://raw.githubusercontent.com/SeemdmAx/OpenExodus/master/OpenOSextension/json.lua" "/lib/json.lua"')
  end
end

OpenExodusBoot.preInitialization()

local gui = require("OpenExodusGui")
local properties = require("OpenExodusProperties")
local gitdownload = require("OpenExodusGitDownloader")

function OpenExodusBoot.bootUp()
  print("System booted")
  local a = io.read()
end

OpenExodusBoot.bootUp()

return OpenExodusBoot
