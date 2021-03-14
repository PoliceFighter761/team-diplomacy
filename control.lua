local Framework = require("Framework/init")

local Request = require("Gui/Request")
local CoreGui = require("Gui/Core/New")

Request.Initiate(Framework)
CoreGui.Initiate(Framework)

function PlayerHasCoreGui(Player)
    local UiExists = false

    pcall(function()
        if Player.gui.screen["TeamDiplomacy-Menu"] then
            UiExists = true
        end
    end)

    return UiExists
end

local PlayerConnection = Framework:GetEvent("on_player_joined_game"):Connect(function(event)
    local Player = game.get_player(event.player_index)

    ------- UI Creation

    local PlayerGui;

    if PlayerHasCoreGui(Player) then
        PlayerGui = CoreGui.GetFromExisting(Player.gui)
    else
        PlayerGui = CoreGui.new(Player.gui)
    end

    local Menus, Flows, ToggleMenu = PlayerGui:GetElements()

    local FactionsMenu = Menus["Factions"]
    
    local ForceList = PlayerGui.ForceList

    PlayerGui.Update.ForceList(ForceList)
end)

local AttackConnection = Framework:GetEvent("on_entity_damaged"):Connect(function(event)
    if event.force then
        local attacker = event.force
        local defender = event.entity.force

        if defender.get_friend(attacker) then
            return
        end
        if not(defender.get_cease_fire(attacker)) then
            return
        end

        defender.set_cease_fire(attacker, false)
        attacker.set_cease_fire(defender, false)

        game.print("\""..attacker.name.."\" has gone to war with \""..defender.name.."\"!")
    end
end)

------------------- UI

function UpdateEveryonesForceLists()
    for _, Player in pairs(game.players) do
        if PlayerHasCoreGui(Player) then
            local PlayerGui = CoreGui.GetFromExisting(Player.gui)

            PlayerGui.Update.ForceList(PlayerGui.ForceList)
        end
    end
end

Framework:GetEvent("on_force_created"):Connect(function(event)
    UpdateEveryonesForceLists()
end)

Framework:GetEvent("on_forces_merged"):Connect(function(event)
    UpdateEveryonesForceLists()
end) 

Framework:GetEvent("on_player_changed_force"):Connect(function(event)
    UpdateEveryonesForceLists()
end) 

Framework:GetEvent("on_force_friends_changed"):Connect(function(event)
    UpdateEveryonesForceLists()
end) 

Framework:GetEvent("on_force_cease_fire_changed"):Connect(function(event)
    UpdateEveryonesForceLists()
end) 

------- Toggle Menu Logic

Framework:GetEvent("on_gui_click"):Connect(function(event)
    local Player = game.get_player(event.player_index)
    local PlayerGui = CoreGui.GetFromExisting(Player.gui)

    local Menus, Flows, ToggleMenu = PlayerGui:GetElements()
    local Element = event.element

    local Holder = Menus["Holder"]
    local CreateMenu = Menus["Create"]
    local DetailMenu = Menus["Detail"]
    local FactionsMenu = Menus["Factions"]

    local CreateFactionButton = Flows["Secondary"]["CreateFaction"]
    local CloseMenuButton = Flows["Secondary"]["Close"]

    local ButtonHolder = DetailMenu["ButtonHolder"]

    local JoinButton = ButtonHolder["Join"]
    local AllyButton = ButtonHolder["Alliance"]
    local EnemyButton = ButtonHolder["MakeEnemy"]

    local ForceList = PlayerGui.ForceList


    local IsInList = false

    pcall(function()
        if Element.parent == ForceList then
            IsInList = true
        end
    end)

    ------- UI Toggle


    if Element == ToggleMenu then
        Holder.visible = not(Holder.visible)
    

    ------- UI Closing / Back logic


    elseif Element == CloseMenuButton and CloseMenuButton.caption == "Close" then
        Holder.visible = false
    
    elseif Element == CloseMenuButton and CloseMenuButton.caption == "Back" then
        DetailMenu.visible = false
        CreateMenu.visible = false
        FactionsMenu.visible = true
        
        CloseMenuButton.caption = "Close"
        
        Holder.caption = "Factions"

        CreateFactionButton.visible = true
        CreateFactionButton.style = "button"


    ------- Create Faction Button Logic


    elseif Element == CreateFactionButton and CreateFactionButton.style.name == "button" then  
        local Name = CreateMenu["Name"]

        Name.text = "Faction Name..."
        Name.select_all()
        Name.focus()

        DetailMenu.visible = false
        CreateMenu.visible = true
        FactionsMenu.visible = false
        
        CloseMenuButton.caption = "Back"
        
        Holder.caption = "Create Faction"

        CreateFactionButton.style = "green_button"

    elseif Element == CreateFactionButton and CreateFactionButton.style.name == "green_button" then 
        local Name = CreateMenu["Name"]
        
        local Blocked = {
            ["Faction Name..."] = true,
            ["Please Insert a Valid name!"] = true,
            ["Name already taken!"] = true,
        }

        local Invalid = false

        if Name.text:gsub("%s",""):len() == 0 or (Blocked[Name.text]) then
            Name.text = "Please Insert a Valid name!"
            Invalid = true
        elseif Name.text:len() > 26 then
            Name.text = "Name longer than 26 characters!"
            Invalid = true
        elseif game.forces[Name.text] then
            Name.text = "Name already taken!"
            Invalid = true
        end   
        
        if Invalid then
            Name.select_all()
            Name.focus()
            return
        end

        Holder.caption = "Factions"

        local NewForce = game.create_force(Name.text)

        Framework.Forces.PlayerJoinForce(Player, NewForce)

        DetailMenu.visible = false
        CreateMenu.visible = false
        FactionsMenu.visible = true

        CloseMenuButton.caption = "Close"

        CreateFactionButton.style = "button"


    ------- Detail Mode Button


    elseif IsInList then
        PlayerGui.Update:ViewForce(Element.caption, PlayerGui)
    

    ------ Joining Forces


    elseif Element == JoinButton and JoinButton.caption == "Join" and JoinButton.visible then
        local Force = game.forces[Holder.caption]

        Framework.Forces.PlayerJoinForce(Player, Force)

        PlayerGui.Update:ViewForce(Force.name, PlayerGui)
        
    elseif Element == JoinButton and JoinButton.caption == "Send Join Request" and JoinButton.visible then
        local Force = game.forces[Holder.caption]
        local Leader = Force.players[1]

        local JoinRequest = Request.new()

        function JoinRequest:OnAccept()
            Framework.Forces.PlayerJoinForce(Player, Force)
            PlayerGui.Update:ViewForce(Force.name, PlayerGui)
        end

        function JoinRequest:OnDecline()
            Element.caption = "Send Join Request"
        end

        JoinRequest:SetPlayer(Leader)
        JoinRequest:SetText("Join", "The Force \""..Player.force.name.."\" wants to join your force!")

        JoinButton.caption = "Join Request Sent"

        JoinRequest:Show()
    

    ------- Enemy and Peace buttons

    elseif Element == EnemyButton and EnemyButton.caption == "Make Enemy" and EnemyButton.visible then
        local Force = game.forces[Holder.caption]
        game.print("\""..Player.force.name.."\" has gone to war with \""..Force.name.."\"!")
        
        Player.force.set_cease_fire(Force, false)
        Player.force.set_friend(Force, false)

        Force.set_cease_fire(Player.force, false)
        Force.set_friend(Player.force, false)

        PlayerGui.Update:ViewForce(Force.name, PlayerGui)
    elseif Element == EnemyButton and EnemyButton.caption == "Offer Peace" and EnemyButton.visible then
        local Force = game.forces[Holder.caption]
        local Leader = Force.players[1]

        local PeaceRequest = Request.new()

        function PeaceRequest:OnAccept()
            game.print("The Forces \""..Player.force.name.."\" and \""..Force.name.."\" have ended their war!")

            Player.force.set_cease_fire(Force, true)
            Force.set_cease_fire(Player.force, true)

            PlayerGui.Update:ViewForce(Force.name, PlayerGui)
        end

        function PeaceRequest:OnDecline()
            Element.caption = "Offer Peace"
        end

        PeaceRequest:SetPlayer(Leader)
        PeaceRequest:SetText("Peace", "The Force \""..Player.force.name.."\" wants the war to end!")

        Element.caption = "Offered Peace"

        PeaceRequest:Show()
    

    ------- Alliance Buttons

    elseif Element == AllyButton and AllyButton.caption == "Send Alliance Request" and AllyButton.visible then
        local Force = game.forces[Holder.caption]
        local Leader = Force.players[1]

        local PeaceRequest = Request.new()

        function PeaceRequest:OnAccept()
            game.print("The Forces \""..Player.force.name.."\" and \""..Force.name.."\" have formed an alliance!")

            Player.force.set_cease_fire(Force, true)
            Player.force.set_friend(Force, true)

            Player.force.set_cease_fire(Player.force, true)
            Force.set_friend(Player.force, true)

            PlayerGui.Update:ViewForce(Force.name, PlayerGui)
        end

        function PeaceRequest:OnDecline()
            Element.caption = "Send Alliance Request"
        end

        PeaceRequest:SetPlayer(Leader)
        PeaceRequest:SetText("Alliance", "The Force \""..Player.force.name.."\" wants to join your alliance!")

        Element.caption = " Alliance Request Sent"

        PeaceRequest:Show()
    

    elseif Element == AllyButton and AllyButton.caption == "Break Alliance" and AllyButton.visible then
        local Force = game.forces[Menus["Holder"].caption]
        game.print("\""..Player.force.name.."\" has broken their Alliance with \""..Force.name.."\"!")

        Player.force.set_cease_fire(Force, true)
        Player.force.set_friend(Force, false)

        Force.set_cease_fire(Player.force, true)
        Force.set_friend(Player.force, false)

        PlayerGui.Update:ViewForce(Force.name, PlayerGui)
    end
end)