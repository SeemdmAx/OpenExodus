do
  local addr, invoke = computer.getBootAddress(), component.invoke
  local function loadfile(file)
    local handle = assert(invoke(addr, "open", file))
    local buffer = ""
    repeat
      local data = invoke(addr, "read", handle, math.huge)
      buffer = buffer .. (data or "")
    until not data
    invoke(addr, "close", handle)
    return load(buffer, "=" .. file, "bt", _G)
  end
  loadfile("/lib/core/boot.lua")(loadfile)
  loadfile("/OpenExodus/ExodusCore/OpenExodusBoot.lua")(loadfile)
end

local filesystem = require("filesystem")
local string = require("string")
local shell = require("shell")

if filesystem.exists("/OpenExodus/ExodusCore/OpenExodusBoot.lua") == false then
  if filesystem.exists("/OpenExodus/ExodusCore") == false then
    print("Critical error, your systemfiles are not available!")
    while true do
      io.write("Reinstall system (Y/N): ")
      local reinstall = io.read()
      if string.upper(reinstall) == "Y" then
        shell.execute("pastebin run g6xm54cJ")
      elseif string.upper(reinstall) == "N" then
        print("System shutdown, we can't do something for you, please contact the developer")
        shell.execute("shutdown")
      else
        print("Invaild input!")
      end
    end
  else
    print("OpenExodusBoot-File not found!")
    print("Downloading...")
    shell.execute('wget -fq "https://raw.githubusercontent.com/SeemdmAx/OpenExodus/master/ExodusCore/OpenExodusBoot.lua" "/OpenExodus/ExodusCore/OpenExodusBoot.lua"')
    print("Finished download")
    shell.execute("reboot")
  end
else
  print("System fail!")
  while true do
    io.write("Reboot or shutdown (R/S): ")
    local action = io.read()
    if action == string.upper("R") then
      shell.execute("reboot")
    elseif action == string.upper("S") then
      shell.execute("shutdown")
    else
      print("Invaild input!")
    end
  end
end 
