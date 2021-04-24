local component = require("component")
local event = require("event")
local colors = require("colors")
local string = require("string")
local gpu = component.gpu

local exo_gui_server = {}

local properties = {
                  ------ Colors ------
                    OpenColor = 0xFFFFFF,
                    ExodusColor = 0x008CCD,

                    BackColor = 0x000000,
                    ForeColor = 0x008CCD,
                    ServerColor = 0xFFE400,
                    TextColor = 0xFFFFFF
                  ------ Colors End ------
}


function exo_gui_server.setResolutionMax()
  ------ Sets the screen to the max possible resolution the make the best user experience ------
  local w, h = gpu.getResolution()
  if w ~= 160 and h ~= 50 then
    if gpu.setResolution(160, 50) ~= true then
      return false
    end
  end
  return true
end

------ Draw Functions -----

function exo_gui_server.drawBasic()
  ------ Draws the outerlines for design purpose ------
  gpu.setBackground(properties.BackColor)
  gpu.setForeground(properties.ForeColor)

  gpu.fill(1, 1, 160, 50, " ")
  gpu.fill(2, 1, 158, 1, "▄")
  gpu.fill(2, 49, 158, 1, "▀")
  gpu.fill(2, 2, 1, 47, "█")
  gpu.fill(159, 2, 1, 47, "█")

  return true
end


function exo_gui_server.drawOpenExodus()
  ------ Draws the OpenExodus Logo for the Bootscreen ------
  gpu.setForeground(properties.OpenColor)
  gpu.set(53, 12, "◢████◣                ")
  gpu.set(53, 13, "██  ██                ")
  gpu.set(53, 14, "██  ██◢████◣◢███◣████◣")
  gpu.set(53, 15, "██  ████__████ █◤██ ██")
  gpu.set(53, 16, "◥████◤█████◤◥██◣ ██ ██")
  gpu.set(53, 17, "      ██              ")
  gpu.set(53, 18, "      █◤              ")

  gpu.setForeground(properties.ExodusColor)
  gpu.set(76, 12, "███████             ◢█          ")
  gpu.set(76, 13, "██                  ██          ")
  gpu.set(76, 14, "█████ ◥█◣◢█████◣◢██████  ██◢████")
  gpu.set(76, 15, "██     ████   ███   ███  ██◥███◣")
  gpu.set(76, 16, "██████◢█◤◥█████◤◥█████◥███◤████◤")
end


function exo_gui_server.drawExodusServer()
  ------ Draws the server logo under the ExodusLogo ------
  gpu.setForeground(properties.ServerColor)
  gpu.set(103, 17, "ＳＥＲＶＥＲ")
end


function exo_gui_server.drawCurrentJob(currentJob)
  ------ Pictures the current ongoing process on the Bootscreen ------
  gpu.setForeground(properties.TextColor)

  gpu.set(40, 38, currentJob)

end

return exo_gui_server
