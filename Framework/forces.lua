local Forces = {}



function Forces.GetForceStats(Force)
    local Players = Force.players

    local Online = {}
    local Offline = {}

    for _, Player in pairs(Players) do
        if Player.connected then
            Online[#Online+1] = Player
        else
            Offline[#Offline+1] = Player
        end
    end

    local Allies = {}
    local Enemies = {}
    local Neutrals = {}

    for _, OtherForce in pairs(game.forces) do
        if Force ~= OtherForce and (OtherForce.name ~= "enemy" and OtherForce.name ~= "neutral") then
            if Force.get_friend(OtherForce) then
                Allies[#Allies+1] = OtherForce
            elseif Force.get_cease_fire(OtherForce) then
                Neutrals[#Neutrals+1] = OtherForce
            else
                Enemies[#Enemies+1] = OtherForce
            end
        end
    end

    local Leader = Players[1]

    return {
        ["MemberCount"] = {
            ["Online"] = Online,
            ["Offline"] = Offline,
            ["Total"] = Players
        },
        ["Allies"] = Allies,
        ["Enemies"] = Enemies,
        ["Neutrals"] = Neutrals,
        ["Leader"] = Leader,
    }
end



function Forces.PlayerJoinForce(Player, Force)
    local OldForce = Player.force
    
    Player.force = Force

    local restricted = {
        ["player"] = true,
        ["enemy"] = true,
        ["neutral"] = true
    }
    
    if #OldForce.players == 0 and not(restricted[OldForce.name]) then
        game.merge_forces(OldForce, Force)
    end
end

return Forces