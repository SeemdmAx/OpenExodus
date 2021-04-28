local OpenExodusBoot = {}
local filesystem = require("filesystem")

function OpenExodusBoot.preInitialization()
  ------ Overrites the package.path so the OpenExodusPackages are loadable ------
  package.path = "/OpenExodus/ExodusCore/?.lua;/OpenExodus/?/?.lua;/OpenExodus/?.lua;/lib/?.lua;/usr/lib/?.lua;/home/lib/?.lua;./?.lua;/lib/?/init.lua;/usr/lib/?/init.lua;/home/lib/?/init.lua;./?/init.lua"
  if filesystem.exists("/OpenExodus/ExodusCore/OpenExodusGui.lua") and filesystem.exists("/OpenExodus/ExodusCore/OpenExodusProperties.lua") and filesystem.exists("/OpenExodus/ExodusCore/OpenExodusGitDownloader.lua") then
    return true
  else
    print("Error! Your system is cracked, reinstall or contact the developer")
    os.exit()
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
