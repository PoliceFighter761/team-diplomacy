local Request = {}
Request.__index = Request

local RequestButtons = {}

function Request.new()
    local self = setmetatable({}, Request)

    math.randomseed(game.tick)

    self.Index = tostring(game.tick).."."..tostring(math.random(1,100))

    return self
end

function Request:SetText(Header, Body)
    self.Header = Header
    self.Body = Body
end

function Request:SetPlayer(player)
    self.Player = player
end

function Request:Show()
    self:CreateUi()

    RequestButtons[self.Index] = {
        ["Accept"] = self.AcceptButton,
        ["Decline"] = self.DeclineButton,
        ["Callbacks"] = {
            ["Accept"] = function()
                self:OnAccept()
                self:Destroy()
            end,
            ["Decline"] = function()
                self:OnDecline()
                self:Destroy()
            end
        },
        ["PlayerIndex"] = self.Player.index
    }
end

function Request:CreateUi()
    local Frame = self.Player.gui.screen.add(
        {
            type = "frame",
            caption = self.Header,
            name = "DIPLOMACY-REQUEST-MENU",
            direction = "vertical"
        }
    )

    Frame.location = {0,50}

    Frame.style.horizontal_align = "center"
    Frame.style.maximal_width = 500

    local BodyHolder = Frame.add(
        {
            type = "frame",
            style = "inside_shallow_frame"
        }
    )

    BodyHolder.style.horizontal_align = "center"
    BodyHolder.style.left_padding = 8
    BodyHolder.style.right_padding = 8
    BodyHolder.style.top_padding = 8
    BodyHolder.style.bottom_padding = 8
    BodyHolder.style.bottom_margin = 13

    local BodyText = BodyHolder.add(
        {
            type = "label",
            caption = self.Body
        }
    )

    BodyText.style.horizontal_align = "center"
    BodyText.style.single_line = false

    local ButtonFlow = Frame.add(
        {
            type = "flow",
            direction = "horizontal"
        }
    )

    ButtonFlow.style.horizontal_align = "center"

    local Decline = ButtonFlow.add(
        {
            type = "button",
            caption = "Decline",
            style = "red_back_button"
        }
    )

    local Accept = ButtonFlow.add(
        {
            type = "button",
            caption = "Accept",
            style = "confirm_button"
        }
    )

    self.AcceptButton = Accept
    self.DeclineButton = Decline
    self.GuiHolder = Frame
end

function Request:OnAccept()
end

function Request:OnDecline()
end

function Request:Destroy()
    RequestButtons[self.Index] = nil
    self.GuiHolder.destroy()
end

function Request.Initiate(Framework)
    Framework:GetEvent("on_gui_click"):Connect(function(event)
        local index = event.player_index

        for i, Request in pairs(RequestButtons) do
            if Request.PlayerIndex == index then
                if event.element == Request.Accept then
                    Request.Callbacks.Accept()
                elseif event.element == Request.Decline then
                    Request.Callbacks.Decline()
                end
            end
        end
    end)
end

return Request