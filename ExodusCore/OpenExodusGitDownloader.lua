local properties = require("OpenExodusProperties")
local shell = require("shell")
local internet = require("internet")
local filesystem = require("filesystem")
local json = require("json")
local string = require("string")

local OpenExodusGitDownloader = {}

function OpenExodusGitDownloader.tableContains(table, element)
  ------ checks if a table contains a specific element ------
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function OpenExodusGitDownloader.dirLookup(updateTmp)
  ------ returns a table of the contents of a directory ------
   local files = {}
   local p = io.popen('find '.. tostring(updateTmp))
   for file in p:lines() do
       table.insert(files, file)
   end
   return files
end

function OpenExodusGitDownloader.split (inputstr, sep)
  ------ returns a table of a splited string ------
  if sep == nil then
      sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
  end
  return t
end

function OpenExodusGitDownloader.getStringFromResponce(responce)
  ------ gets the strings out of the HTTP responce data ------
  local ret = ""
  local resp = responce()
  while resp ~= nil do
    ret = ret .. tostring(resp)
    resp = responce()
  end
  return ret
end

function OpenExodusGitDownloader.getHTTPData(url)
  ------ gets the necessary HTTP data ------
  ------ for example the json data from the github rest api ------
  local ret = nil
  local request, responce = pcall(internet.request, url)
  if request then
    ret = OpenExodusGitDownloader.getStringFromResponce(responce)
  end
  return ret
end

function OpenExodusGitDownloader.downloadTree(treeDataUrl, parentDir)
  ------ main download-function ------
  ------ downloads files only written in lua, the coreLibarys and the specific files for the OS defined in the properties ------
  parentDir = parentDir or ""
  local treeData = json.decode(OpenExodusGitDownloader.getHTTPData(treeDataUrl))

  for _, child in pairs(treeData.tree) do
    local filename = parentDir .. "/" .. tostring(child.path)
    if child.type == "tree" then
      if string.find(filename, properties.GitCoreFolderName) or string.find(filename, properties.SysTypePrefix) or string.find(filename, properties.SysType) then
        if filesystem.exists(properties.updateTmp .. filename) == false then
          shell.execute("mkdir " .. properties.updateTmp .. filename)
        end
        OpenExodusGitDownloader.downloadTree(child.url, filename)
      end
    else
      if string.find(filename, "README.md") == nil then
        shell.execute('rm -fr ' .. properties.updateTmp .. tostring(filename))
        local repoData = OpenExodusGitDownloader.getHTTPData("https://raw.githubusercontent.com/" .. tostring(properties.GitUpdateRepository) .. "/master/" .. tostring(filename))
        local file = io.open(properties.updateTmp .. filename, "wb")
        file:write(repoData)
        file:flush()
        file:close()
      end
    end
  end
end

function OpenExodusGitDownloader.downloadGitRepository()
  ------ downloads specific files for the OS from github------
  ------ and saves them to the local updateTmp folder ------
  local data = OpenExodusGitDownloader.getHTTPData("https://api.github.com/repos/" .. tostring(properties.GitUpdateRepository) .. "/git/refs")

  if filesystem.exists(properties.updateTmp) == false then
    shell.execute("mkdir " .. properties.updateTmp)
  end

  if data then
    git = json.decode(data)[1].object
    local commitData = OpenExodusGitDownloader.getHTTPData(git.url)
    if commitData then
      local commitDataTree = json.decode(commitData).tree
      OpenExodusGitDownloader.downloadTree(commitDataTree.url)
    end
  end
end

function OpenExodusGitDownloader.updateCreateFiles(updateTmp, exodusFiles)
  ------ compares the files and folders from the updateTmp to the systemDir and updates, replaces and creates the nesscary files ------
  ------ it although removes the old unneccassary files ------
  local thingsUpdated = 0
  updateTmp = updateTmp or properties.updateTmp
  exodusFiles = exodusFiles or properties.systemDir
  local newfiles = OpenExodusGitDownloader.dirLookup(updateTmp)

  for _, value in pairs(newfiles) do
    local file, _  = string.gsub(value, updateTmp .. "/", "")
    if string.find(file, updateTmp) == nil then
      if string.find(file, ".lua") ~= nil then
        if filesystem.exists(exodusFiles .. "/" .. file) == true then
          new = io.open(updateTmp .. "/" .. file, "r")
          old = io.open(exodusFiles .. "/" .. file, "r")
          local newData = new:read("*a")
          local oldData = old:read("*a")
          new:close()
          old:close()
          if newData ~= oldData then
            filesystem.copy(updateTmp .. "/" .. file, exodusFiles .. "/" .. file)
            thingsUpdated = thingsUpdated + 1
          end
        else
          if string.find(file, "/") ~= nil then
            local folders = OpenExodusGitDownloader.split(file, "/")
            local path = ""
            for _, folder in pairs(folders) do
              path = path .. folder
              if string.find(path, ".lua") ~= nil then
                filesystem.copy(updateTmp .. "/" .. file, exodusFiles .. "/" .. path)
                thingsUpdated = thingsUpdated + 1
              else
                path = path .. "/"
                if filesystem.exists(exodusFiles .. "/" .. path) == false then
                  filesystem.makeDirectory(exodusFiles .. "/" .. path)
                  thingsUpdated = thingsUpdated + 1
                end
              end
            end
          else
            filesystem.copy(updateTmp .. "/" .. file, exodusFiles .. "/" .. file)
            thingsUpdated = thingsUpdated + 1
          end
        end
      end
    end
  end

  local oldfiles = OpenExodusGitDownloader.dirLookup(exodusFiles)
  local newFilesExtenstionFree = {}
  for _, value in pairs(newfiles) do
    local file, _ = string.gsub(value, updateTmp .. "/", "")
    table.insert(newFilesExtenstionFree, file)
  end

  for _, value in pairs(oldfiles) do
    local oldfile, _ = string.gsub(value, exodusFiles .. "/", "")
    if string.find(oldfile, exodusFiles) == nil then
      if OpenExodusGitDownloader.tableContains(newFilesExtenstionFree, oldfile) == false then
        filesystem.remove(exodusFiles .. "/" .. oldfile)
        thingsUpdated = thingsUpdated + 1
      end
     end
  end

  return thingsUpdated
end

function OpenExodusGitDownloader.clearUpdateTmp(updateTmp)
  ------ removes the updateTmp so there are no doubles and useless filled space ------
  updateTmp = updateTmp or properties.updateTmp
  filesystem.remove(updateTmp)
  return true
end

function OpenExodusGitDownloader.updatesAvailable()
  ------ Checks the actual github-commit-sha, if not the same as in properties updates are available ------
  local data = OpenExodusGitDownloader.getHTTPData("https://api.github.com/repos/".. tostring(properties.GitUpdateRepository) .."/git/refs")
  local git = json.decode(data)[1].object
  local availableVersion = git.sha
  if availableVersion ~= properties.currentVersion then
    return true
  else
    return false
  end
end

return OpenExodusGitDownloader
