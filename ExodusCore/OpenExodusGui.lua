local component = require("component")
local string = require("string")
local properties = require("OpenExodusProperties")
local gpu = component.gpu

local OpenExodusGui = {}


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
    horizontalReturn = math.floor(tonumber(OpenExodusGui.getResolution("width")) / 2 - textLen / 2)
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
  gpu.setBackground(properties.BackColor)
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
  gpu.setBackground(properties.BackColor)

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

  OpenExodusGui.drawOpenExodusLogoExtension(x + 50, y + 17, colorExtention)

  return true
end

function OpenExodusGui.drawOpenExodusLogoExtension(x, y, colorExtention)
  ------ Draws the server logo under the ExodusLogo ------
  colorExtention = colorExtention or 0xFFE400
  gpu.setBackground(properties.BackColor)

  gpu.setForeground(colorExtention)
  gpu.set(x, y, OpenExodusGui.normalToFullString(properties.SysTypePrefix))

  return true
end

function OpenExodusGui.drawText(x, y, color, text, bold)
  ------ Draws a text in a specific color and if wanted bold ------
  color = color or 0xFFFFFF
  bold = bold or false
  gpu.setBackground(properties.BackColor)

  if bold == true then
    text = OpenExodusGui.normalToFullString(text)
  end
  gpu.set(x, y, text)

  return true
end



return OpenExodusGui
