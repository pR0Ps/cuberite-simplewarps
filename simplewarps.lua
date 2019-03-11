-- Globals
g_Warps = {}
g_WarpsINI = cIniFile()

-- Entry point
function Initialize(Plugin)
  Plugin:SetName(g_PluginInfo.Name)
  Plugin:SetVersion(g_PluginInfo.Version)

  dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
  RegisterPluginInfoCommands()

  InitWarps()

  LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
  return true
end

-- Load warps from file into memory
function InitWarps()
  if g_WarpsINI:ReadFile("warps.ini") then
    local num = g_WarpsINI:GetNumKeys() - 1
    for i=0, num do
      local name = g_WarpsINI:GetKeyName(i)
      g_Warps[name] = {}
      g_Warps[name]["w"] = g_WarpsINI:GetValue(name, "w")
      g_Warps[name]["x"] = g_WarpsINI:GetValueI(name, "x")
      g_Warps[name]["y"] = g_WarpsINI:GetValueI(name, "y")
      g_Warps[name]["z"] = g_WarpsINI:GetValueI(name, "z")
    end
  end
end

function ValidUsage(Split, Player, Num)
  Num = Num or 3
  if #Split ~= Num then
    Player:SendMessageInfo("Usage: " .. table.concat(Split, " ", 1, Num-1) .." <name>")
    return false
  end
  return true
end

function UseWarp(Split, Player)
  if not ValidUsage(Split, Player) then
    return true
  end

  local name = Split[3]
  if g_Warps[name] == nil then
    Player:SendMessageFailure("No warp point called \"" .. name .. "\" exists")
    return true;
  end

  local w = g_Warps[name]["w"]
  local x = g_Warps[name]["x"]
  local y = g_Warps[name]["y"]
  local z = g_Warps[name]["z"]

  if Player:GetWorld():GetName() ~= w then
    Player:MoveToWorld(cRoot:Get():GetWorld(w), true, Vector3d(x + 0.5, y, z + 0.5))
  else
    Player:TeleportToCoords(x + 0.5, y, z + 0.5)
  end
  Player:SetGameMode(Player:GetWorld():GetGameMode())
  Player:SendMessageSuccess("Warped to warp point \"" .. name .. "\"")
  return true
end

function ListWarps(Split, Player)
  local names = {}
  for name, _ in pairs(g_Warps) do
    table.insert(names, "\"" .. name .. "\"")
  end
  if #names == 0 then
    Player:SendMessageInfo("No warp points are currently available")
  else
    Player:SendMessageInfo("Available warp points:\n" .. table.concat(names, ", "))
  end
  return true
end

function SetWarp(Split, Player)
  if not ValidUsage(Split, Player) then
    return true
  end

  local name = Split[3]
  if g_Warps[name] ~= nil then
    Player:SendMessageFailure("Warp point \"" .. name .. "\" already exists")
    return true
  end

  local w = Player:GetWorld():GetName()
  local x = math.floor(Player:GetPosX())
  local y = math.floor(Player:GetPosY())
  local z = math.floor(Player:GetPosZ())

  g_Warps[name] = {}
  g_Warps[name]["w"] = w
  g_Warps[name]["x"] = x
  g_Warps[name]["y"] = y
  g_Warps[name]["z"] = z
  g_WarpsINI:AddKeyName(name)
  g_WarpsINI:SetValue(name , "w" , w)
  g_WarpsINI:SetValue(name , "x" , x)
  g_WarpsINI:SetValue(name , "y" , y)
  g_WarpsINI:SetValue(name , "z" , z)
  g_WarpsINI:WriteFile("warps.ini");
  Player:SendMessageSuccess("Warp point \"" .. name .. "\" set to your current location")
  return true
end

function RemoveWarp(Split, Player)
  if not ValidUsage(Split, Player) then
    return true
  end

  local name = Split[3]
  if g_Warps[name] == nil then
    Player:SendMessageFailure("No warp point called \"" .. name .. "\" exists")
    return true;
  end

  g_Warps[name] = nil
  g_WarpsINI:DeleteKey(name)
  g_WarpsINI:WriteFile("warps.ini")

  Player:SendMessageSuccess("Warp point \"" .. name .. "\" was removed")
  return true
end
