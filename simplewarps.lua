-- Globals
g_Warps = {}
g_WarpsINI = cIniFile()

-- Entry point
function Initialize(Plugin)
  Plugin:SetName(g_PluginInfo.Name)
  Plugin:SetVersion(g_PluginInfo.Version)

  dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
  RegisterPluginInfoCommands()
  cPluginManager:AddHook(cPluginManager.HOOK_UPDATING_SIGN, OnUpdatingSign)
  cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK, OnPlayerRightClick)

  InitWarps()

  LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
  return true
end

-- Load warps from file into memory
function InitWarps()
  if g_WarpsINI:ReadFile("warps.ini") then
    local num = g_WarpsINI:GetNumKeys() - 1
    for i=0, num do
      local name = NormalizeWarpName(g_WarpsINI:GetKeyName(i))
      g_Warps[name] = {}
      g_Warps[name]["w"] = g_WarpsINI:GetValue(name, "w")
      g_Warps[name]["x"] = g_WarpsINI:GetValueI(name, "x")
      g_Warps[name]["y"] = g_WarpsINI:GetValueI(name, "y")
      g_Warps[name]["z"] = g_WarpsINI:GetValueI(name, "z")
    end
  end
end

function WarpHelp(Split, Player)
  Player:SendMessageInfo("See \"/help warp\" for warp-related commands")
  Player:SendMessageInfo("To create a clickable warp, create a sign with the following format:\n[Warp]\n<warp name>\n<optional description>")
  Player:SendMessageInfo("Warp point names will always be normalized to lowercase, underscore-separated names. This means a sign can use the warp point name \"My Warp Point\" to mean the warp point named \"my_warp_point\". The same thing will happen when creating warp points via commands.")
  return true
end

function GetWarpName(Split, Player, Num)
  Num = Num or 3
  if #Split ~= Num then
    Player:SendMessageInfo("Usage: " .. table.concat(Split, " ", 1, Num-1) .." <name>")
    return nil
  end
  return Split[Num]
end

function UseWarp(Split, Player)
  local disp_name = GetWarpName(Split, Player)
  if disp_name == nil then
    return true
  end

  local name = NormalizeWarpName(disp_name)
  if g_Warps[name] == nil then
    Player:SendMessageFailure("No warp point called \"" .. disp_name .. "\" exists")
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
  Player:SendMessageSuccess("Warped to \"" .. disp_name .. "\"")
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
  local disp_name = GetWarpName(Split, Player)
  if disp_name == nil then
    return true
  end

  local name = NormalizeWarpName(disp_name)
  if g_Warps[name] ~= nil then
    Player:SendMessageFailure("Warp point \"" .. disp_name .. "\" already exists")
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
  Player:SendMessageSuccess("Warp point \"" .. disp_name .. "\" set at your current location")
  return true
end

function RemoveWarp(Split, Player)
  local disp_name = GetWarpName(Split, Player)
  if disp_name == nil then
    return true
  end

  local name = NormalizeWarpName(disp_name)
  if g_Warps[name] == nil then
    Player:SendMessageFailure("No warp point called \"" .. disp_name .. "\" exists")
    return true;
  end

  g_Warps[name] = nil
  g_WarpsINI:DeleteKey(name)
  g_WarpsINI:WriteFile("warps.ini")

  Player:SendMessageSuccess("Warp point \"" .. disp_name .. "\" was removed")
  return true
end

-- Strip all chat codes from a string
function StripControlCodes(s)
  return string.gsub(s, "§[0-9A-Fa-fK-Ok-oRr]", "")
end

--Normalize warp names
--(remove control codes, lowercase, spaces to underscores)
function NormalizeWarpName(s)
  return string.gsub(StripControlCodes(s):lower(), " ", "_")
end

function OnUpdatingSign(World, BlockX, BlockY, BlockZ, Line1, Line2, Line3, Line4, Player)
  local l1 = StripControlCodes(Line1)
  if l1 ~= "[Warp]" then
    return false
  end

  return false,
    cChatColor.Purple .. cChatColor.Bold .. l1,
    StripControlCodes(Line2),
    Line3,
    cChatColor.Gray .. cChatColor.Bold .. "(right click)"
end

function OnPlayerRightClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
  if not Player:HasPermission("simplewarps.use") then
    return false
  end
  local valid, l1, l2, l3, l4 = Player:GetWorld():GetSignLines(BlockX, BlockY, BlockZ)
  if valid and StripControlCodes(l1) == "[Warp]" then
    UseWarp({"/warp", "to", l2}, Player)
    return true
  end
end
