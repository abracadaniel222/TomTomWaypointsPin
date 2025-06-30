local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")

local CONTINENT_NAMES = { GetMapContinents() } ;

local function GetContinentNameById(continentId)
  return CONTINENT_NAMES[continentId] or "Waypoint"
end

local function BuildTitle(x, y)
  local continentName = GetContinentNameById(GetCurrentMapContinent())
  local zoneName = GetMapInfo()
  local locationName
  -- If seeing the full world map with the three continents, GetCurrentMapContinent
  -- and GetCurrentMapZone are both 0. 
  -- zoneName is nil or Azeroth if seeing a continent, or "Expansion01" if seeing Outlands
  -- If seeing a continent, GetCurrentMapContinent is correct but GetCurrentMapZone is 0.
  if zoneName == "Azeroth" or zoneName == nil or zoneName == "Expansion01" then
    locationName = continentName
  else
    locationName = zoneName
  end
  return locationName .. string.format(" (%.1f, %.1f)", x, y)
end

local function CreateWaypoint(x, y)
  local c,z,title = GetCurrentMapContinent(), GetCurrentMapZone(), BuildTitle(x, y)
  -- debug:
  -- print("c: "..c.." z: "..z.." x: "..x.." y: "..y.." title: "..title.."")
  TomTom:AddZWaypoint(c, z, x, y, title)
end

local function GetCursorCoordinates()
  local x, y = GetCursorPosition()
  local scale = WorldMapButton:GetEffectiveScale()
  local centerX, centerY = WorldMapButton:GetCenter()
  x = x / scale
  y = y / scale

  local width = WorldMapButton:GetWidth()
  local height = WorldMapButton:GetHeight()

  local left = centerX - (width / 2)
  local top = centerY + (height / 2)

  local mapX = (x - left) / width
  local mapY = (top - y) / height
  if mapX >= 0 and mapX <= 1 and mapY >= 0 and mapY <= 1 then
    return mapX * 100, mapY * 100
  else
    return nil, nil
  end
end

local function HookWorldMapClick()
  WorldMapButton:EnableMouse(true)
  local oldOnMouseUp = WorldMapButton:GetScript("OnMouseUp")
  WorldMapButton:SetScript("OnMouseUp", function(self, button)
    if button == "RightButton" and IsAltKeyDown() then
      local x, y = GetCursorCoordinates()
      if x and y then
        CreateWaypoint(x, y)
      else
        print("|cFFFF0000TomTomWaypointsPin: Couldn't determine mouse coordinates|r")
      end
    else
      if oldOnMouseUp then
        oldOnMouseUp(self, button)
      end
    end
  end)
end

f:SetScript("OnEvent", function()
  HookWorldMapClick()
  print("|cFF00FF00TomTomWaypointsPin: Loaded successfully. Alt + Right Click on World Map to create a waypoint.|r")
end)