local shell = require("shell")
local internet = require("internet")
local filesystem = require("filesystem")
local string = require("string")


local function tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

local function dirLookup(updateTmp)
   local files = {}
   local p = io.popen('find '.. tostring(updateTmp))
   for file in p:lines() do
       table.insert(files, file)
   end
   return files
end

local function split (inputstr, sep)
  if sep == nil then
      sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
  end
  return t
end

local function getStringFromResponce(responce)
  local ret = ""
  local resp = responce()
  while resp ~= nil do
    ret = ret .. tostring(resp)
    resp = responce()
  end
  return ret
end

local function getHTTPData(url)
  local ret = nil
  local request, responce = pcall(internet.request, url)
  if request then
    ret = getStringFromResponce(responce)
  end
  return ret
end

local function downloadTree(treeDataUrl, parentDir, systemType)
  parentDir = parentDir or ""
  local treedata = json.decode(getHTTPData(treeDataUrl))

  for _, child in pairs(treeData.tree) do
    local filename = parentDir .. "/" .. tostring(child.path)
    if child.type == "tree" then
      if filesystem.exists("/OpenExodus" .. filename) == false then
        shell.execute("mkdir " .. "/OpenExodus" .. filename)
      end
      if string.find(filename, ExodusCore) or string.find(filename, systemType) then
        downloadTree(child.url, filename)
      end
    else
      if string.find(filename, "README.md") == false then
        shell.execute('rm -fr ' .. "/OpenExodus" .. tostring(filename))
        local repoData = getHTTPData("https://raw.githubusercontent.com/SeemdmAx/OpenExodus/master/" .. tostring(filename))
        local file = io.open("/OpenExodus" .. filename, "wb")
        file:write(repoData)
        file:flush()
        file:close()
      end
    end
  end
end

function downloadGitRepository()
  local data = getHTTPData("https://api.github.com/repos/SeemdmAx/OpenExodus/git/refs")

  if filesystem.exists("/OpenExodus") == false then
    shell.execute("mkdir /OpenExodus")
  end

  if data then
    git = json.decode(data)[1].object
    local commitData = getHTTPData(git.url)
    if commitData then
      local commitDataTree = json.decode(commitData).tree
      downloadTree(commitDataTree.url)
    end
  end
end

---- main ----
if filesystem.exists("/lib/json.lua") == false then
  shell.execute('wget -fq "https://raw.githubusercontent.com/SeemdmAx/OpenExodus/master/OpenOSextension/json.lua" "/lib/json.lua"')
  local json = require("json")
end
