local string = require("string")
local filesystem = require("filesystem")

local OpenExodusLibary = {}

function OpenExodusLibary.getEventNumberToKey()
  local keys = {}
  keys[97] = "a"
  keys[98] = "b"
  keys[99] = "c"
  keys[100] = "d"
  keys[101] = "e"
  keys[102] = "f"
  keys[103] = "g"
  keys[104] = "h"
  keys[105] = "i"
  keys[106] = "j"
  keys[107] = "k"
  keys[108] = "l"
  keys[109] = "m"
  keys[110] = "n"
  keys[111] = "o"
  keys[112] = "p"
  keys[113] = "q"
  keys[114] = "r"
  keys[115] = "s"
  keys[116] = "t"
  keys[117] = "u"
  keys[118] = "v"
  keys[119] = "w"
  keys[120] = "x"
  keys[121] = "y"
  keys[122] = "z"
  keys[65] = "A"
  keys[66] = "B"
  keys[67] = "C"
  keys[68] = "D"
  keys[69] = "E"
  keys[70] = "F"
  keys[71] = "G"
  keys[72] = "H"
  keys[73] = "I"
  keys[74] = "J"
  keys[75] = "K"
  keys[76] = "L"
  keys[77] = "M"
  keys[78] = "N"
  keys[79] = "O"
  keys[80] = "P"
  keys[81] = "Q"
  keys[82] = "R"
  keys[83] = "S"
  keys[84] = "T"
  keys[85] = "U"
  keys[86] = "F"
  keys[87] = "W"
  keys[88] = "X"
  keys[89] = "Y"
  keys[90] = "Z"
  keys[49] = "1"
  keys[50] = "2"
  keys[51] = "3"
  keys[52] = "4"
  keys[53] = "5"
  keys[54] = "6"
  keys[55] = "7"
  keys[56] = "8"
  keys[57] = "9"
  keys[48] = "0"
  keys[64] = "@"
  keys[8364] = "€"
  keys[46] = "."
  keys[58] = ":"
  keys[44] = ","
  keys[59] = ";"
  keys[45] = "-"
  keys[95] = "_"
  keys[60] = "<"
  keys[62] = ">"
  keys[124] = "|"
  keys[228] = "ä"
  keys[252] = "ü"
  keys[246] = "ö"
  keys[196] = "Ä"
  keys[220] = "Ü"
  keys[214] = "Ö"
  keys[35] = "#"
  keys[39] = "'"
  keys[43] = "+"
  keys[42] = "*"
  keys[126] = "~"
  keys[180] = "´"
  keys[96] = "`"
  keys[223] = "ß"
  keys[63] = "?"
  keys[92] = "\\"
  keys[125] = "}"
  keys[61] = "="
  keys[93] = "]"
  keys[41] = ")"
  keys[91] = "["
  keys[40] = "("
  keys[123] = "{"
  keys[47] = "/"
  keys[38] = "&"
  keys[37] = "%"
  keys[36] = "$"
  keys[167] = "§"
  keys[179] = "³"
  keys[34] = '"'
  keys[33] = "!"
  keys[178] = "²"
  keys[94] = "^"
  keys[176] = "°"
  keys[32] =" "

  return keys
end

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

function OpenExodusLibary.countLinesInFile(file)
  local count = 0
  for line in io.lines(file) do
    count = count + 1
  end
  return count
end

function OpenExodusLibary.overwriteProperties(entry, newValue, type, oldValue)
  local equal
  local ending
  type = type or "string"
  if type ~= "table" then
    if type == "string" then
      equal = ' = "'
      ending = '",'
    else
      equal = ' = '
      ending = ','
    end
    for line in io.lines("/OpenExodus/ExodusCore/OpenExodusProperties.lua") do
      if string.find(line, entry) ~= nil then
        line = string.gsub(line, line, entry .. equal .. newValue .. ending) .. "\n";
      else
        line = line .. "\n";
      end
      local new = io.open("/home/propertiesTmp.lua", "a")
      new:write(line)
      new:close()
    end
  else
    for line in io.lines("/OpenExodus/ExodusCore/OpenExodusProperties.lua") do
      if string.find(line, entry) ~= nil then
        line, _ = string.gsub(line, oldValue, newValue) .. "\n";
      else
        line = line .. "\n";
      end
      local new = io.open("/home/propertiesTmp.lua", "a")
      new:write(line)
      new:close()
    end
  end
  filesystem.copy("/home/propertiesTmp.lua", "/OpenExodus/ExodusCore/OpenExodusProperties.lua")
  filesystem.remove("/home/propertiesTmp.lua")
end

function OpenExodusLibary.addProperties(entry, value, type)
  local equal
  local ending
  type = type or "string"
  if type == "string" then
    equal = ' = "'
    ending = '",  }'
  else
    equal = ' = '
    ending = ',  }'
  end
  local count = 0
  for line in io.lines("/OpenExodus/ExodusCore/OpenExodusProperties.lua") do
    count = count + 1
    if count == OpenExodusLibary.countLinesInFile("/OpenExodus/ExodusCore/OpenExodusProperties.lua") - 3 then
      line = entry .. equal .. value .. ending;
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

return OpenExodusLibary
