local OpenExodusBoot = {}
local filesystem = require("filesystem")
OpenExodusBoot.preInitialization()

local gui = require("OpenExodusGui")
local properties = require("OpenExodusProperties")
local gitdownload = require("OpenExodusGitDownloader")

function OpenExodusBoot.preInitialization()
  ------ Overrites the package.path so the OpenExodusPackages are loadable ------
  package.path = "/Exodus/?.lua;/ExodusCore/?.lua;/lib/?.lua;/usr/lib/?.lua;/home/lib/?.lua;./?.lua;/lib/?/init.lua;/usr/lib/?/init.lua;/home/lib/?/init.lua;./?/init.lua"
  if filesystem.exists("/core/OpenExodusGui.lua") and filesystem.exists("/core/OpenExodusProperties.lua") and filesystem.exists("/core/OpenExodusGitDownloader.lua") then
    return true
  else
    print("Error! Your system is cracked, reinstall or contact the developer")
    os.exit()
end

function OpenExodusBoot.bootUp()
  
end

return OpenExodusBoot
