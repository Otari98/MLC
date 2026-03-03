--Most of this code taken from https://github.com/CosminPOP/TWAssignments and https://github.com/Ko0z/XLoot
--Main idea - keep it simple, no fancy functions
local MLBC = CreateFrame("Frame", "MasterLootByClassFrame")
local RaidDropDown = CreateFrame("Frame", "MLBC_RaidDropDown", UIParent, "UIDropDownMenuTemplate")

MLBC:RegisterEvent("OPEN_MASTER_LOOT_LIST")
MLBC:RegisterEvent("RAID_ROSTER_UPDATE")
MLBC:RegisterEvent("LOOT_SLOT_CLEARED")

MLBC.colors = {}
MLBC.colors["WARRIOR"] = "|cffc79c6e"
MLBC.colors["DRUID"]   = "|cffff7d0a"
MLBC.colors["PALADIN"] = "|cfff58cba"
MLBC.colors["WARLOCK"] = "|cff9482c9"
MLBC.colors["MAGE"]    = "|cff69ccf0"
MLBC.colors["PRIEST"]  = "|cffffffff"
MLBC.colors["ROGUE"]   = "|cfffff569"
MLBC.colors["HUNTER"]  = "|cffabd473"
MLBC.colors["SHAMAN"]  = "|cff0070de"

MLBC.raid = {}
MLBC.raid["WARRIOR"] = {}
MLBC.raid["DRUID"]   = {}
MLBC.raid["PALADIN"] = {}
MLBC.raid["WARLOCK"] = {}
MLBC.raid["MAGE"]    = {}
MLBC.raid["PRIEST"]  = {}
MLBC.raid["ROGUE"]   = {}
MLBC.raid["HUNTER"]  = {}
MLBC.raid["SHAMAN"]  = {}

local function wipe(tbl)
    for k in pairs(tbl) do
        tbl[k] = nil
    end
    table.setn(tbl, 0)
end

local function FillRaidData()
    for _, data in pairs(MLBC.raid) do
        wipe(data)
    end
    if UnitInRaid("player") then
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            if name then
                local _, class = UnitClass("raid" .. i)
                table.insert(MLBC.raid[class], name)
            end
        end
    elseif UnitInParty("player") then
        local _, playerClass = UnitClass("player")
        local playerName = UnitName("player")
        table.insert(MLBC.raid[playerClass], playerName)
        for i = 1, GetNumPartyMembers() do
            local name = UnitName("party" .. i)
            if name then
                local _, unitClass = UnitClass("party" .. i)
                table.insert(MLBC.raid[unitClass], name)
            end
        end
    end
    for class in pairs(MLBC.raid) do
        table.sort(MLBC.raid[class])
    end
end

local function GetCandidateID(name)
    if GetNumRaidMembers() > 0 then
        for i = 1, 40 do
            if name == GetMasterLootCandidate(i) then
                return i
            end
        end
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cffcc6666[MasterLootByClass]|r|cffffff00 " .. name .. " can not receive this item.|r")
end

local function IsOffline(player)
    for i = 1, GetNumRaidMembers() do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
        if name == player then
            return not online
        end
    end
    return false
end

local function GiveToRandom()
    local max = GetNumRaidMembers() and 40 or 5
    local name, id
    local item = LootFrame.selectedSlot
    local link = GetLootSlotLink(item)
    while not name do
        id = math.random(1, max)
        name = GetMasterLootCandidate(id)
    end
    if name and id and item and link then
        SendChatMessage("Rolling the dice...", "RAID")
        SendChatMessage(name .. " wins " .. link .. "!", "RAID")
        GiveMasterLoot(item, id)
    end
end

local function GiveLoot(name)
    local item = LootFrame.selectedSlot
    local id = GetCandidateID(name)
    if not item or not id then
        return
    end
    GiveMasterLoot(item, id)
end

local info = {}

local function BuildRaidMenu()
    if UnitInRaid("player") and UIDROPDOWNMENU_MENU_LEVEL == 1 then
        wipe(info)
        info.text = GIVE_LOOT
        info.isTitle = true
        info.textHeight = 12
        info.notCheckable = true
        UIDropDownMenu_AddButton(info)

        wipe(info)
        info.text = "Me"
        info.textHeight = 12
        info.disabled = false
        info.isTitle = false
        info.notCheckable = true
        info.func = GiveLoot
        info.arg1 = UnitName("player")
        UIDropDownMenu_AddButton(info)

        wipe(info)
        info.text = "Random"
        info.disabled = false
        info.textHeight = 12
        info.isTitle = false
        info.notCheckable = true
        info.func = GiveToRandom
        UIDropDownMenu_AddButton(info)

        wipe(info)
        info.text = ""
        info.disabled = true
        UIDropDownMenu_AddButton(info)

        wipe(info)
        info.text = MLBC.colors["WARRIOR"] .. "Warriors"
        info.textHeight = 12
        info.notCheckable = true
        info.hasArrow = true
        info.value = "WARRIOR"
        if next(MLBC.raid["WARRIOR"]) then
            UIDropDownMenu_AddButton(info)
        end

        wipe(info)
        info.text = MLBC.colors["DRUID"] .. "Druids"
        info.textHeight = 12
        info.notCheckable = true
        info.hasArrow = true
        info.value = "DRUID"
        if next(MLBC.raid["DRUID"]) then
            UIDropDownMenu_AddButton(info)
        end

        wipe(info)
        info.text = MLBC.colors["PALADIN"] .. "Paladins"
        info.textHeight = 12
        info.notCheckable = true
        info.hasArrow = true
        info.value = "PALADIN"
        if next(MLBC.raid["PALADIN"]) then
            UIDropDownMenu_AddButton(info)
        end

        wipe(info)
        info.text = MLBC.colors["WARLOCK"] .. "Warlocks"
        info.textHeight = 12
        info.notCheckable = true
        info.hasArrow = true
        info.value = "WARLOCK"
        if next(MLBC.raid["WARLOCK"]) then
            UIDropDownMenu_AddButton(info)
        end

        wipe(info)
        info.text = MLBC.colors["MAGE"] .. "Mages"
        info.textHeight = 12
        info.notCheckable = true
        info.hasArrow = true
        info.value = "MAGE"
        if next(MLBC.raid["MAGE"]) then
            UIDropDownMenu_AddButton(info)
        end

        wipe(info)
        info.text = MLBC.colors["PRIEST"] .. "Priests"
        info.textHeight = 12
        info.notCheckable = true
        info.hasArrow = true
        info.value = "PRIEST"
        if next(MLBC.raid["PRIEST"]) then
            UIDropDownMenu_AddButton(info)
        end

        wipe(info)
        info.text = MLBC.colors["ROGUE"] .. "Rogues"
        info.textHeight = 12
        info.notCheckable = true
        info.hasArrow = true
        info.value = "ROGUE"
        if next(MLBC.raid["ROGUE"]) then
            UIDropDownMenu_AddButton(info)
        end

        wipe(info)
        info.text = MLBC.colors["HUNTER"] .. "Hunters"
        info.textHeight = 12
        info.notCheckable = true
        info.hasArrow = true
        info.value = "HUNTER"
        if next(MLBC.raid["HUNTER"]) then
            UIDropDownMenu_AddButton(info)
        end

        wipe(info)
        info.text = MLBC.colors["SHAMAN"] .. "Shamans"
        info.textHeight = 12
        info.notCheckable = true
        info.hasArrow = true
        info.value = "SHAMAN"
        if next(MLBC.raid["SHAMAN"]) then
            UIDropDownMenu_AddButton(info)
        end
    elseif UnitInParty("player") and not UnitInRaid("player") and UIDROPDOWNMENU_MENU_LEVEL == 1 then
        local candidate, class
        for i = 1, MAX_PARTY_MEMBERS + 1 do
            candidate = GetMasterLootCandidate(i)
            if candidate then
                for k in pairs(MLBC.raid) do
                    for _, name in pairs(MLBC.raid[k]) do
                        if name == candidate then
                            class = k
                            break
                        end
                    end
                end
                if class then
                    local color = MLBC.colors[class]
                    wipe(info)
                    info.text = color .. candidate
                    info.textHeight = 12
                    info.notCheckable = 1
                    info.arg1 = LootFrame.selectedSlot
                    info.arg2 = i
                    info.func = GiveMasterLoot
                    UIDropDownMenu_AddButton(info)
                end
            end
        end
    end
    if UIDROPDOWNMENU_MENU_LEVEL == 2 then
        for _, player in next, MLBC.raid[UIDROPDOWNMENU_MENU_VALUE] do
            wipe(info)
            local color = MLBC.colors[UIDROPDOWNMENU_MENU_VALUE]
            info.notCheckable = true
            info.hasArrow = false
            info.func = GiveLoot
            info.arg1 = player
            info.textHeight = 12
            if IsOffline(player) then
                info.disabled = true
                info.text = player
            else
                info.text = color .. player
                info.disabled = false
            end
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
        end
    end
end

local lastSelectedSlot

LootFrame:UnregisterEvent("OPEN_MASTER_LOOT_LIST")
local OnMouseUp = LootFrame:GetScript("OnMouseUp")
LootFrame:SetScript("OnMouseUp", function()
    if OnMouseUp then OnMouseUp() end
    CloseDropDownMenus()
    lastSelectedSlot = nil
end)

local OnHide = DropDownList1:GetScript("OnHide")
DropDownList1:SetScript("OnHide", function()
    if OnHide then OnHide() end
    lastSelectedSlot = nil
end)

MLBC:SetScript("OnEvent", function()
    if GetLootMethod() == "master" then
        if event == "RAID_ROSTER_UPDATE" then
            FillRaidData()
        elseif event == "OPEN_MASTER_LOOT_LIST" then
            FillRaidData()
            UIDropDownMenu_Initialize(RaidDropDown, BuildRaidMenu, "MENU")
            if LootFrame.selectedLootButton ~= lastSelectedSlot then
                DropDownList1:Hide()
                ToggleDropDownMenu(1, nil, RaidDropDown, LootFrame.selectedLootButton, 0, 0)
                lastSelectedSlot = LootFrame.selectedLootButton
            else
                DropDownList1:Hide()
                lastSelectedSlot = nil
            end
        elseif event == "LOOT_SLOT_CLEARED" then
            CloseDropDownMenus()
            lastSelectedSlot = nil
        end
    end
end)

UnitPopupButtons["ITEM_QUALITY1_DESC"] = { text = TEXT(ITEM_QUALITY1_DESC), dist = 0, color = ITEM_QUALITY_COLORS[1] }
table.insert(UnitPopupMenus["LOOT_THRESHOLD"], 1, "ITEM_QUALITY1_DESC")

local Original_UnitPopup_OnClick = UnitPopup_OnClick

local function Hook_UnitPopup_OnClick()
    Original_UnitPopup_OnClick()
    local button = this.value
    if button == "ITEM_QUALITY1_DESC" or button == "ITEM_QUALITY2_DESC" or button == "ITEM_QUALITY3_DESC" or button == "ITEM_QUALITY4_DESC" then
        SetLootThreshold(this:GetID())
        local color = ITEM_QUALITY_COLORS[this:GetID()]
        UIDropDownMenu_SetButtonText(1, 3, UnitPopupButtons[button].text, color.r, color.g, color.b)
    end
end

UnitPopup_OnClick = Hook_UnitPopup_OnClick
