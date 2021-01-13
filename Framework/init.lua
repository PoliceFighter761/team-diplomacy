local Framework = {}
Framework.__index = Framework

function Framework.new()
    local self = setmetatable({}, Framework)

    self.Events = {}
    self.Connection = require("connection")

    self.Forces = require("forces")

    return self
end

function Framework:OnButtonClick(button)
    if self.OnButtonPressEvents[button] then
        return self.OnButtonPressEvents[button]
    else
        self.OnButtonPressEvents[button] = self.Connection.new()
        return self.OnButtonPressEvents[button]
    end
end

function Framework:GetEvent(event)
    if self.Events[event] then
        return self.Events[event]
    else
        local Connection = self.Connection.new()

        script.on_event(defines.events[event], function(event)
            Connection:Fire(event)
        end)

        self.Events[event] = Connection
        return self.Events[event]
    end
end

return Framework.new()