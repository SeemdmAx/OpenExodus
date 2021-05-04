local string = require("string")

local OpenExodusLibary = {}

function OpenExodusLibary.dirLookup(folder)
   local files = {}
   local p = io.popen('find '.. tostring(folder))
   for file in p:lines() do
       table.insert(files, file)
   end
   return files
end

function OpenExodusLibary.tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function OpenExodusLibary.split (inputstr, sep)
  ------ returns a table of a splited string ------
  sep = sep or "/"
  local splitUpString={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(splitUpString, str)
  end
  return splitUpString --- String will be returned splited up in a table, the seperator will be completly removed
end

return OpenExodusLibary
