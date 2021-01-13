local CoreGui = {}
CoreGui.__index = CoreGui

local Framework

local CreateGui = require("Create")

function CoreGui.new(PlayerGui)
    local self = setmetatable({}, CoreGui)

    self.Components = {CreateGui(PlayerGui)}
    self.PlayerGui = PlayerGui

    self.player_index = PlayerGui.player.index
    self.player = PlayerGui.player

    self.ForceList = self.Components[1]["Factions"]["ForceList"]

    return self
end

function CoreGui.GetFromExisting(PlayerGui)
    local self = setmetatable({}, CoreGui)

    local Holder = PlayerGui.screen["TeamDiplomacy-Menu"]

    local MainFlow = Holder["MainFlow"]

    local Factions = MainFlow["Factions"]
    local Create = MainFlow["Create"]
    local Detail = MainFlow["Detail"]

    self.Components = {
        {
            ["Holder"] = Holder,
            ["Factions"] = Factions,
            ["Create"] = Create,
            ["Detail"] = Detail,
        }, {
            ["Main"] = MainFlow,
            ["Secondary"] = MainFlow["SecondaryFlow"],
        }, PlayerGui.left["Open-TeamDiplomacy-Menu"]
    }

    self.PlayerGui = PlayerGui

    self.player_index = PlayerGui.player.index
    self.player = PlayerGui.player

    self.ForceList = self.Components[1]["Factions"]["ForceList"]

    return self
end

function CoreGui:GetElements()
    return unpack(self.Components)
end

function CoreGui.Initiate(framework)
    Framework = framework
    CoreGui.Update.Initiate(framework)
end

CoreGui.Update = require("UiUpdateHandler")

return CoreGui