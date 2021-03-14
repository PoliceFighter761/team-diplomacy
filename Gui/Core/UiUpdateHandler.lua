local UiUpdateHandler = {}



function UiUpdateHandler:ViewForce(ForceName, PlayerGui)
    local Menus, Flows, ToggleMenu = PlayerGui:GetElements()

    local Holder = Menus["Holder"]
    local CreateMenu = Menus["Create"]
    local DetailMenu = Menus["Detail"]
    local FactionsMenu = Menus["Factions"]

    local CreateFactionButton = Flows["Secondary"]["CreateFaction"]
    local CloseMenuButton = Flows["Secondary"]["Close"]

    DetailMenu.visible = true
    CreateMenu.visible = false
    FactionsMenu.visible = false

    Holder.caption = ForceName

    CloseMenuButton.caption = "Back"
    CreateFactionButton.visible = false

    local Player = PlayerGui.player
    local Force = game.forces[ForceName]
    local PlayerForce = Player.force

    local ForceStats = Framework.Forces.GetForceStats(Force)

    DetailMenu.visible = true

    local Scroller = DetailMenu["OtherDiplomacies"]["Scroller"]
    Scroller.clear()
    
    for _, Ally in pairs(ForceStats.Allies) do
        local temp = Scroller.add(
            {
                type = "label",
                caption = Ally.name .. " (Allied)"
            }
        )
        temp.style.font_color = {r = 0, g = 1, b = 0}
        temp.style.left_margin = 10
    end

    for _, Enemy in pairs(ForceStats.Enemies) do
        local temp = Scroller.add(
            {
                type = "label",
                caption = Enemy.name .. " (Enemies)"
            }
        )
        temp.style.font_color = {r = 1, g = 0, b = 0}
        temp.style.left_margin = 10
    end

    for _, Neutral in pairs(ForceStats.Neutrals) do
        Scroller.add(
            {
                type = "label",
                caption = Neutral.name .. " (Neutral)"
            }
        ).style.left_margin = 10
    end

    local MemberCount = DetailMenu["MemberCounts"]

    local Online = MemberCount["Online"]
    local Offline = MemberCount["Offline"]
    local Leader = MemberCount["Leader"]

    local ButtonHolder = DetailMenu["ButtonHolder"]

    local JoinButton = ButtonHolder["Join"]
    local AllyButton = ButtonHolder["Alliance"]
    local EnemyButton = ButtonHolder["MakeEnemy"]

    AllyButton.visible = true
    EnemyButton.visible = true
    JoinButton.visible = true

    ButtonHolder.visible = true

    if #ForceStats.MemberCount.Total == 0 then
        Online.caption = "There are no Members!"
        Offline.caption = "Click \"Join\" to take ownership of the team."

        Online.visible = true
        Offline.visible = true
        Leader.visible = false

        JoinButton.caption = "Join"

        AllyButton.visible = false
        EnemyButton.visible = false

        return
    end

    JoinButton.caption = "Send Join Request"

    local OnlineText = "Online: "

    for i, player in pairs(ForceStats.MemberCount.Online) do
        local sep = ", " 

        if i == 1 then
            sep = ""
        end

        OnlineText = OnlineText .. sep .. player.name
    end

    if OnlineText == "Online: " then
        Online.visible = false
    else
        Online.visible = true
        OnlineText = OnlineText .. " ("..#ForceStats.MemberCount.Online..")"
    end

    local OfflineText = "Offline: "

    for i, player in pairs(ForceStats.MemberCount.Offline) do

        local sep;
        
        if i == 1 then
            sep = ""
        else
            sep = ", " 
        end
        
        OfflineText = OfflineText .. sep .. player.name
    end

    if OfflineText == "Offline: " then
        Offline.visible = false
    else
        Offline.visible = true
        OfflineText = OfflineText .. "("..#ForceStats.MemberCount.Offline..")"
    end

    Leader.visible = true
    Leader.caption = "Leader: "..ForceStats.Leader.name
    
    Online.caption = OnlineText
    Offline.caption = OfflineText

    if PlayerForce.get_friend(Force) then
        AllyButton.caption = "Break Alliance"
    else
        AllyButton.caption = "Send Alliance Request"
    end

    if not(PlayerForce.get_cease_fire(Force)) then
        EnemyButton.caption = "Offer Peace"
    else
        EnemyButton.caption = "Make Enemy"
    end

    if Player ~= PlayerForce.players[1] then
        AllyButton.visible = false
        EnemyButton.visible = false
    end

    if not(ForceStats.Leader.connected) then
        if JoinButton.caption == "Send Join Request" then
            JoinButton.visible = false
        end
        if AllyButton.caption == "Send Alliance Request" then
            AllyButton.visible = false
        end
        if EnemyButton.caption == "Offer Peace" then
            EnemyButton.visible = false
        end
    end

    if Force == PlayerForce then
        ButtonHolder.visible = false
    end
end



function UiUpdateHandler.ForceList(List)
    List.clear()

    local PlayerForce = game.players[List.player_index].force

    local names = {}
    local longest = 0

    for _, Faction in pairs(game.forces) do
        if Faction.name ~= "enemy" and Faction.name ~= "neutral" then
            local temp = List.add(
                {
                    type = "button",
                    caption = Faction.name,
                }
            )

            if PlayerForce == Faction then
                temp.style.font_color = {r = 0, g = 0, b = 1}
            elseif PlayerForce.get_friend(Faction) then
                temp.style.font_color = {r = 0, g = 1, b = 0}
            elseif not(PlayerForce.get_cease_fire(Faction)) then
                temp.style.font_color = {r = 1, g = 0, b = 0}
            end

            longest = math.max(longest, Framework:GetTextSize(Faction.name, 8))
        
            names[#names + 1] = temp
        end
    end

    for _, button in pairs(names) do
        button.style.minimal_width = longest
        button.style.maximal_width = longest
    end
end





function UiUpdateHandler.Initiate(framework)
    Framework = framework
end

return UiUpdateHandler