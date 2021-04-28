do
  local addr, invoke = computer.getBootAddress(), component.invoke
  function loadfile(file)
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
end


local function dirLookup(updateTmp)
   local files = {}
   local p = io.popen('find '.. tostring(updateTmp))
   for file in p:lines() do
       table.insert(files, file)
   end
   return files
end

local files = dirLookup("/OpenExodus/ExodusMain")
for _, value in pairs(files) do
  local file, _ = string.gsub(value, "/OpenExodus/ExodusMain", "")
  if string.find(file, "Main.lua") ~= nil then
    loadfile("/OpenExodus/ExodusMain" .. file)(loadfile)
  end
end
