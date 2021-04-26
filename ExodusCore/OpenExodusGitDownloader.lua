local properties = require("OpenExodusProperties")
local shell = require("shell")
local internet = require("internet")
local filesystem = require("filesystem")
local json = require("json")
local string = require("string")

local OpenExodusUpdate = {}

local function OpenExodusUpdate.getStringFromResponce(responce)
  ------ gets the strings out of the HTTP responce data ------
  local ret = ""
  local resp = responce()
  while resp ~= nil do
    ret = ret .. tostring(resp)
    resp = responce()
  end
  return ret
end

local function OpenExodusUpdate.getHTTPData(url)
  ------ gets the necessary HTTP data ------
  local ret = nil
  local request, responce = pcall(internet.request, url)
  if request then
    ret = OpenExodusUpdate.getStringFromResponce(responce)
  end
  return ret
end

local function OpenExodusUpdate.downloadTree(treeDataUrl, parentDir)
  ------ main download-function ------
  parentDir = parentDir or ""
  local treedata = json.decode(OpenExodusUpdate.getHTTPData(treeDataUrl))

  for _, child in pairs(treeData.tree) do
    local filename = parentDir .. "/" .. tostring(child.path)
    if child.type == "tree" then
      if filesystem.exists("/gitTmp" .. filename) == false then
        shell.execute("mkdir /gitTmp" .. filename)
      end
      if string.find(filename, properties.GitCoreFolderName) or string.find(filename, properties.SysTypePrefix) or string.find(filename, properties.SysType) then
        OpenExodusUpdate.downloadTree(child.url, filename)
      end
    else
      if string.find(filename, "README.md") == false then
        shell.execute('rm -fr /gitTmp' .. tostring(filename))
        local repoData = OpenExodusUpdate.getHTTPData("https://raw.githubusercontent.com/" .. tostring(properties.GitUpdateRepository) .. "/master/" .. tostring(filename))
        local file = io.open("/gitTmp" .. filename, "wb")
        file:write(repoData)
        file:flush()
        file:close()
      end
    end
  end
end

function OpenExodusUpdate.downloadGitRepository()
  ------ downloads specific files for the OS ------
  local data = OpenExodusUpdate.getHTTPData("https://api.github.com/repos/" .. tostring(properties.GitUpdateRepository) .. "/git/refs")

  if filesystem.exists("/gitTmp") == false then
    shell.execute("mkdir /gitTmp")
  end

  if data then
    git = json.decode(data)[1].object
    local commitData = OpenExodusUpdate.getHTTPData(git.url)
    if commitData then
      local commitDataTree = json.decode(commitData).tree
      OpenExodusUpdate.downloadTree(commitDataTree.url)
    end
  end
end

return OpenExodusUpdate
