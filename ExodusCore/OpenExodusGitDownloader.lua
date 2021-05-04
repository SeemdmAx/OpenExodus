local properties = require("OpenExodusProperties") --- Needed for checking out which files to download
local internet = require("internet") --- Needed for access github contents
local filesystem = require("filesystem") --- Needed for creating, removing, copying files/directorys
local json = require("json") --- Needed for transforming github-restapi returns to useable lua table
local string = require("string") --- Needed for basic string operations
local OpenExodusLibary = require("OpenExodusLibary")

local OpenExodusGitDownloader = {}


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
    if child.type == "tree" then ---Checks if child(file) is a folder
      if string.find(filename, properties.GitCoreFolderName) or string.find(filename, properties.SysType) then
        if filesystem.exists(properties.updateTmp .. filename) == false then
          filesystem.makeDirectory(properties.updateTmp .. filename) --- When the folder doesnt exist, it creates it
        end
        OpenExodusGitDownloader.downloadTree(child.url, filename) --- Calls another object of the method with the parentDir of current subfolder to download recursivly
      end
    else
      local forbiddenFiles = 0
      for _, value in pairs(properties.forbiddenGitFiles) do --- Checks if the file is in properties.forbidden, when yes the file will not be downloaded
        if string.find(filename, value) ~= nil then
          forbiddenFiles = forbiddenFiles + 1
        end
      end
      if forbiddenFiles == 0 then
        filesystem.remove(properties.updateTmp .. tostring(filename))
        local repoData = OpenExodusGitDownloader.getHTTPData("https://raw.githubusercontent.com/" .. tostring(properties.GitUpdateRepository) .. "/master/" .. tostring(filename))
        local file = io.open(properties.updateTmp .. filename, "wb")
        file:write(repoData)
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
    filesystem.makeDirectory(properties.updateTmp)  ---Checks if the updateTmp folder exist, when not it creates it
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

  ------ Updateing and creating files ------
  local thingsUpdated = 0 --- Counts the things that are updated, when >= 1 the system will reboot
  updateTmp = updateTmp or properties.updateTmp
  exodusFiles = exodusFiles or properties.systemDir
  local newfiles = OpenExodusLibary.dirLookup(updateTmp)

  for _, value in pairs(newfiles) do
    local file, _  = string.gsub(value, updateTmp .. "/", "")
    if string.find(file, updateTmp) == nil then
      if string.find(file, ".lua") ~= nil then
        if filesystem.exists(exodusFiles .. "/" .. file) == true then --- When the old file has the same name but the content differs, it will be overwritten
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
            local folders = OpenExodusLibary.split(file, "/")
            local path = ""
            for _, folder in pairs(folders) do --- creates new folders if they dont exist and creates every file needed in this directory
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
            filesystem.copy(updateTmp .. "/" .. file, exodusFiles .. "/" .. file) --- if there is no file with the name in the old/exodus directory it will be created
            thingsUpdated = thingsUpdated + 1
          end
        end
      end
    end
  end

  ------ Deleting old files ------
  local oldfiles = OpenExodusLibary.dirLookup(exodusFiles)
  local newFilesExtenstionFree = {}
  for _, value in pairs(newfiles) do
    local file, _ = string.gsub(value, updateTmp .. "/", "")
    table.insert(newFilesExtenstionFree, file)
  end

  for _, value in pairs(oldfiles) do
    local oldfile, _ = string.gsub(value, exodusFiles .. "/", "")
    if string.find(oldfile, exodusFiles) == nil then
      if OpenExodusLibary.tableContains(newFilesExtenstionFree, oldfile) == false then
        filesystem.remove(exodusFiles .. "/" .. oldfile) ---Checks if there are files in the exodusFolder which are not in the updateTmp, if yes the old useless will be deleted
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
  local availableVersion = git.sha ---Get the actual commitSha
  if availableVersion ~= properties.currentVersion then
    return true, availableVersion
  else
    return false, availableVersion
  end
end

function OpenExodusGitDownloader.saveUpdateVersion()
  local data = getHTTPData("https://api.github.com/repos/SeemdmAx/OpenExodus/git/refs")
  local git = json.decode(data)[1].object
  local currentVersion = git.sha

  for line in io.lines("/OpenExodus/ExodusCore/OpenExodusProperties.lua") do
    if string.find(line, "currentVersion") ~= nil then
      line = string.gsub(line, '""', '"' .. currentVersion .. '"') .. "\n";
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


return OpenExodusGitDownloader
