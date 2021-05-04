local component = require("component")
local string = require("string")
local event = require("event")
local filesystem = require("filesystem")
local properties = require("OpenExodusProperties")
local OpenExodusLibary = require("OpenExodusLibary")
local gpu = component.gpu

local OpenExodusGui = {}
local GuiEvents = {}


function OpenExodusGui.setMaxResolution()
  ------ Sets the screens resolution to the maximum ------
  if gpu.getResolution() ~= gpu.maxResolution() then
    local ResolutionReturn = gpu.setResolution(gpu.maxResolution())
  end
  return ResolutionReturn
end

function OpenExodusGui.getResolution(returnValue)
  ------ Returns either the screen's width or height ------
  returnValue = returnValue or "height"
  local width, height = gpu.getResolution()
  if string.lower(returnValue) == "width" then
    return width
  else
    return height
  end
end

function OpenExodusGui.normalToFullString(data)
  ------ Converts a normal string into a fullsize string ------
  data, _ = string.gsub(data,"A", "Ａ")
  data, _ = string.gsub(data,"B", "Ｂ")
  data, _ = string.gsub(data,"C", "Ｃ")
  data, _ = string.gsub(data,"D", "Ｄ")
  data, _ = string.gsub(data,"E", "Ｅ")
  data, _ = string.gsub(data,"F", "Ｆ")
  data, _ = string.gsub(data,"G", "Ｇ")
  data, _ = string.gsub(data,"H", "Ｈ")
  data, _ = string.gsub(data,"I", "Ｉ")
  data, _ = string.gsub(data,"J", "Ｊ")
  data, _ = string.gsub(data,"K", "Ｋ")
  data, _ = string.gsub(data,"L", "Ｌ")
  data, _ = string.gsub(data,"M", "Ｍ")
  data, _ = string.gsub(data,"N", "Ｎ")
  data, _ = string.gsub(data,"O", "Ｏ")
  data, _ = string.gsub(data,"P", "Ｐ")
  data, _ = string.gsub(data,"Q", "Ｑ")
  data, _ = string.gsub(data,"R", "Ｒ")
  data, _ = string.gsub(data,"S", "Ｓ")
  data, _ = string.gsub(data,"T", "Ｔ")
  data, _ = string.gsub(data,"U", "Ｕ")
  data, _ = string.gsub(data,"V", "Ｖ")
  data, _ = string.gsub(data,"W", "Ｗ")
  data, _ = string.gsub(data,"X", "Ｘ")
  data, _ = string.gsub(data,"Y", "Ｙ")
  data, _ = string.gsub(data,"Z", "Ｚ")
  data, _ = string.gsub(data,"a", "ａ")
  data, _ = string.gsub(data,"b", "ｂ")
  data, _ = string.gsub(data,"c", "ｃ")
  data, _ = string.gsub(data,"d", "ｄ")
  data, _ = string.gsub(data,"e", "ｅ")
  data, _ = string.gsub(data,"f", "ｆ")
  data, _ = string.gsub(data,"g", "ｇ")
  data, _ = string.gsub(data,"h", "ｈ")
  data, _ = string.gsub(data,"i", "ｉ")
  data, _ = string.gsub(data,"j", "ｊ")
  data, _ = string.gsub(data,"k", "ｋ")
  data, _ = string.gsub(data,"l", "ｌ")
  data, _ = string.gsub(data,"m", "ｍ")
  data, _ = string.gsub(data,"n", "ｎ")
  data, _ = string.gsub(data,"o", "ｏ")
  data, _ = string.gsub(data,"p", "ｐ")
  data, _ = string.gsub(data,"q", "ｑ")
  data, _ = string.gsub(data,"r", "ｒ")
  data, _ = string.gsub(data,"s", "ｓ")
  data, _ = string.gsub(data,"t", "ｔ")
  data, _ = string.gsub(data,"u", "ｕ")
  data, _ = string.gsub(data,"v", "ｖ")
  data, _ = string.gsub(data,"w", "ｗ")
  data, _ = string.gsub(data,"x", "ｘ")
  data, _ = string.gsub(data,"y", "ｙ")
  data, _ = string.gsub(data,"z", "ｚ")

  return data
end

function OpenExodusGui.getXY(horizontal, vertical, textLen, textHeight)
  ------ Returns the XY-Coordinates of specific alignment ------
  textHeight = textHeight or 0

  if horizontal == "left" then
    horizontalReturn = 4
  elseif horizontal == "middle" then
    horizontalReturn = math.floor(tonumber(OpenExodusGui.getResolution("width")) / 2 - (textLen / 2))
  elseif horizontal == "right" then
    horizontalReturn = math.floor(tonumber(OpenExodusGui.getResolution("width")) - 4 - textLen)
  end

  if vertical == "top" then
    verticalReturn = 3
  elseif vertical == "topMiddle" then
    verticalReturn = math.floor(tonumber(OpenExodusGui.getResolution("height")) / 4)
  elseif vertical == "middle" then
    verticalReturn = math.floor(tonumber(OpenExodusGui.getResolution("height")) / 2) - math.floor(textHeight / 2)
  elseif vertical == "bottomMiddle" then
    verticalReturn = tonumber(OpenExodusGui.getResolution("height")) - math.floor(tonumber(OpenExodusGui.getResolution("height")) / 4) - textHeight
  elseif vertical == "bottom" then
    verticalReturn = tonumber(OpenExodusGui.getResolution("height")) - 2 - textHeight
  end

  return horizontalReturn, verticalReturn
end

function OpenExodusGui.drawBorder(x, y, width, height, color)
  ------ Draws rectangular borderlines ------
  gpu.setBackground(tonumber(properties.BackColor))
  gpu.setForeground(color)
  gpu.fill(x, y, width, 1, "▄")
  gpu.fill(x, y + height - 1, width, 1, "▀")
  gpu.fill(x, y + 1, 1, height - 2, "█")
  gpu.fill(x + width - 1, y + 1, 1, height - 2, "█")

  return true
end

function OpenExodusGui.drawOpenExodusLogo(x, y, color1, color2, colorExtention)
  ------ Draws the OpenExodus Logo for the Bootscreen ------
  color1 = color1 or 0xFFFFFF
  color2 = color2 or 0x008CCD
  gpu.setBackground(tonumber(properties.BackColor))

  gpu.setForeground(color1)
  gpu.set(x, y + 0, "◢████◣                ")
  gpu.set(x, y + 1, "██  ██                ")
  gpu.set(x, y + 2, "██  ██◢████◣◢███◣████◣")
  gpu.set(x, y + 3, "██  ████__████ █◤██ ██")
  gpu.set(x, y + 4, "◥████◤█████◤◥██◣ ██ ██")
  gpu.set(x, y + 5, "      ██              ")
  gpu.set(x, y + 6, "      █◤              ")

  gpu.setForeground(color2)
  gpu.set(x + 23, y + 0, "███████             ◢█          ")
  gpu.set(x + 23, y + 1, "██                  ██          ")
  gpu.set(x + 23, y + 2, "█████ ◥█◣◢█████◣◢██████  ██◢████")
  gpu.set(x + 23, y + 3, "██     ████   ███   ███  ██◥███◣")
  gpu.set(x + 23, y + 4, "██████◢█◤◥█████◤◥█████◥███◤████◤")

  OpenExodusGui.drawOpenExodusLogoExtension(x + 50, y + 5, colorExtention)

  return true
end

function OpenExodusGui.drawOpenExodusLogoExtension(x, y, colorExtention)
  ------ Draws the server logo under the ExodusLogo ------
  colorExtention = colorExtention or 0xFFE400
  gpu.setBackground(tonumber(properties.BackColor))

  gpu.setForeground(colorExtention)
  gpu.set(x, y, OpenExodusGui.normalToFullString(properties.SysTypePrefix))

  return true
end

function OpenExodusGui.drawText(x, y, text, color, BackColor, bold)
  ------ Draws a text in a specific color and if wanted bold ------
  color = color or 0xFFFFFF
  bold = bold or false
  BackColor = BackColor or tonumber(properties.BackColor)
  gpu.setBackground(BackColor)

  if bold == true then
    text = OpenExodusGui.normalToFullString(text)
  end
  gpu.set(x, y, text)

  return true
end

function OpenExodusGui.drawRectangle(x, y, width, height, color, round, actualBackColor)
  ------ Draws simply a rectangle in a specific color ------
  color = color or 0x00000
  round = round or false
  actualBackColor = actualBackColor or tonumber(properties.BackColor)
  gpu.setBackground(color)
  gpu.setForeground(color)

  gpu.fill(x, y, width, height, " ")
  if round == true then
    gpu.setBackground(actualBackColor)
    gpu.set(x, y, "◢")
    gpu.set(x, y + height - 1, "◥")
    gpu.set(x + width - 1, y + height - 1, "◤")
    gpu.set(x + width - 1, y, "◣")
  end
  return true
end

function OpenExodusGui.drawWarningSymbol(x, y, type, backcolor)
  type = type or "info"
  backcolor = backcolor or 0x00000
  gpu.setBackground(backcolor)

  if string.upper(type) == "ERROR" then
    gpu.setForeground(0xE70000)
    gpu.set(x, y + 0, "    ◢█◣")
    gpu.set(x, y + 1, "   ◢███◣")
    gpu.set(x, y + 2, "  ◢█████◣")
    gpu.set(x, y + 3, " ◢███████◣")

    gpu.setForeground(0x00000)
    gpu.setBackground(0xE70000)
    gpu.set(x + 5, y + 1, "█")
    gpu.set(x + 5, y + 2, "█")
    gpu.set(x + 5, y + 3, "⬤")

  else
    gpu.setForeground(0xFFEC00)
    gpu.set(x, y + 0, "    ◢█◣")
    gpu.set(x, y + 1, "   ◢███◣")
    gpu.set(x, y + 2, "  ◢█████◣")
    gpu.set(x, y + 3, " ◢███████◣")

    gpu.setForeground(0x000000)
    gpu.setBackground(0xFFEC00)
    gpu.set(x + 5, y + 1, "⬤")
    gpu.set(x + 5, y + 2, "█")
    gpu.set(x + 5, y + 3, "▀")
  return true
  end
end

function OpenExodusGui.drawButton(x, y, text, buttonLable, color, textColor, actualBackColor, oneTime)
  actualBackColor = actualBackColor or tonumber(properties.BackColor)
  textColor = textColor or 0x000000
  color = color or 0xFFFFFF
  oneTime = oneTime or false

  if #text > 8 then
    return false
  else
    gpu.setForeground(color)
    gpu.setBackground(actualBackColor)
    gpu.set(x, y, "◀")
    gpu.set(x + #text + 3, y, "▶")
    gpu.setBackground(color)
    gpu.setForeground(textColor)
    gpu.set(x + 1, y, " ")
    gpu.set(x + #text + 2, y, " ")
    gpu.set(x + 2, y, text)

    GuiEvents[buttonLable] = x .. "/" .. y .. "/" .. (4 + #text) .. "/" .. "1" .. "/" ..  tostring(oneTime)
  end
end

function OpenExodusGui.waitForTouchEvent()
  while true do
    local _, _, x, y, _, _ = event.pull("touch")
    for lable, cords in pairs(GuiEvents) do
      local splitCords = OpenExodusLibary.split(cords)
      local xI = 0
      while xI <= tonumber(splitCords[3]) do
          if xI + tonumber(splitCords[1]) == x then
            local yI = 0
            while yI <= tonumber(splitCords[4]) do
              if yI + tonumber(splitCords[2]) == y then
                if tostring(splitCords[5]) == "true" then
                  GuiEvents[lable] = nil
                end
                return lable
              end
              yI = yI + 1
            end
          end
          xI = xI + 1
      end
    end
  end
end

function OpenExodusGui.popEvent(pop)
  GuiEvents[pop] = nil
end

function OpenExodusGui.warningPopUp(x, y, type, message, option1, lable1, actualBackColor, option2, lable2)
  if #message < 54 then
    option2 = option2 or "empty"
    lable1 = lable1 or option1
    lable2 = lable2 or option2
    actualBackColor = actualBackColor or tonumber(properties.BackColor)
    OpenExodusGui.drawRectangle(x, y, 70, 8, 0x181818, true)
    OpenExodusGui.drawWarningSymbol(x + 3, y + 2, type, 0x181818)
    if option2 ~= "empty" then
      OpenExodusGui.drawButton(x + 45, y + 6, option1, lable1, 0x000000, 0xFFFFFF, 0x181818, true)
      OpenExodusGui.drawButton(x + 57, y + 6, option2, lable2, 0x000000, 0xFFFFFF, 0x181818, true)
    else
      OpenExodusGui.drawButton(x + 57, y + 6, option1, lable1, 0x000000, 0xFFFFFF, 0x181818, true)
    end
    OpenExodusGui.drawText(x + 15 + math.floor(26.5 - (#message / 2)), y + 3, message, 0xFFFFFF, 0x181818)

    local clicked = OpenExodusGui.waitForTouchEvent()
    OpenExodusGui.popEvent(lable1)
    OpenExodusGui.popEvent(lable2)
    OpenExodusGui.drawRectangle(x, y, 70, 8, actualBackColor)
    return clicked
  else
    return false
  end
end

function OpenExodusGui.drawBootingScreen()
  ------ Draw the OpenExodusBootingScreen ------
  OpenExodusGui.drawBorder(2, 1, OpenExodusGui.getResolution("width") - 2, OpenExodusGui.getResolution("height"), 0x008CCD)
  local statusX, statusY = OpenExodusGui.getXY("middle", "topMiddle", 55, 0) --- 55
  OpenExodusGui.drawOpenExodusLogo(statusX, statusY, 0xFFFFFF, 0x008CCD, 0xFFE400)
end

function OpenExodusGui.setNeededResolution()
  OpenExodusGui.setMaxResolution()
  if OpenExodusGui.getResolution("width") ~= 160 or OpenExodusGui.getResolution("height") ~= 50 then
    if filesystem.exists("/home/ResolutionFails.lua") == false then
      fails = io.open("/home/ResolutionFails.lua", "w")
      fails:write("1")
      fails:close()
    else
      fails = io.open("/home/ResolutionFails.lua", "r")
      local data = fails:read("*a")
      fails:close()
      if data ~= "1111" then
        fails = io.open("/home/ResolutionFails.lua", "a")
        fails:write("1")
        fails:close()
      else
        filesystem.remove("/home/ResolutionFails.lua")
        return false
      end
    end
    shell.execute("reboot")
  else
    return true
  end
end

return OpenExodusGui
