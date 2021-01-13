return function(PlayerGui)
    -- MENU BUTTONS

    local ToggleMenu = PlayerGui.left.add(
        {
            type = "button",
            caption = "D",
            tooltip = "Diplomacy Menu",
            name = "Open-TeamDiplomacy-Menu"
        }
    )

    ToggleMenu.style.maximal_width = 35

    -- HOLDER

    local Menu = PlayerGui.screen.add(
        {
            type = "frame",
            caption = "Factions",
            name = "TeamDiplomacy-Menu",
        }
    )

    Menu.visible = false

    local MainFlow = Menu.add(
        {
            type = "flow",
            direction = "vertical",
            name = "MainFlow"
        }
    )

    -- FACTION LIST

    local Factions = MainFlow.add(
        {
            type = "frame",
            style = "inside_shallow_frame",
            name = "Factions"
        }
    )

    local ForceList = Factions.add(
        {
            type = "flow",
            direction = "vertical",
            name = "ForceList"
        }
    )

    ForceList.style.left_padding = 8
	ForceList.style.top_padding = 8
	ForceList.style.right_padding = 8
	ForceList.style.bottom_padding = 8

    Factions.style.left_padding = 8
	Factions.style.top_padding = 8
	Factions.style.right_padding = 8
	Factions.style.bottom_padding = 8

    -- CREATE FACTION MODE

    local Create = MainFlow.add(
        {
            type = "frame",
            style = "inside_shallow_frame",
            visible = false,
            name = "Create"
        }
    )

    local Create_Name = Create.add(
        {
            type = "textfield",
            name = "Name",
            text = "Faction Name..."
        }
    )

    -- DETAIL MODE

    local Detail = MainFlow.add(
        {
            type = "frame",
            style = "inside_shallow_frame",
            visible = false,
            name = "Detail",
            direction = "vertical",
        }
    )

    local MemberCounts = Detail.add(
        {
            type = "flow",
            name = "MemberCounts",
            direction = "vertical",
        }
    )

    Detail.style.left_padding = 8
	Detail.style.top_padding = 8
	Detail.style.right_padding = 8
	Detail.style.bottom_padding = 8

    MemberCounts.style.left_padding = 8
	MemberCounts.style.top_padding = 8
	MemberCounts.style.right_padding = 8
	MemberCounts.style.bottom_padding = 8

    local LeaderLabel = MemberCounts.add(
        {
            type = "label",
            name = "Leader"
        }
    )

    LeaderLabel.style.maximal_width = 200

    local OnlineLabel = MemberCounts.add(
        {
            type = "label",
            name = "Online"
        }
    )

    OnlineLabel.style.maximal_width = 200
    OnlineLabel.style.single_line = false

    local OfflineLabel = MemberCounts.add(
        {
            type = "label",
            name = "Offline"
        }
    )

    OfflineLabel.style.maximal_width = 200
    OfflineLabel.style.font_color = {r = 0.7, g = 0.7, b = 0.7}
    OfflineLabel.style.single_line = false

    local ButtonHolder = Detail.add(
        {
            type = "flow",
            name = "ButtonHolder",
        }
    )

    ButtonHolder.style.minimal_width = 200
    ButtonHolder.style.horizontal_align = "center"

    ButtonHolder.add(
        {
            type = "button",
            caption = "Send Join Request",
            name = "Join",
            style = "green_button"
        }  
    )

    ButtonHolder.add(
        {
            type = "button",
            caption = "Send Alliance Request",
            name = "Alliance"
        }
    )

    ButtonHolder.add(
        {
            type = "button",
            caption = "Make Enemy",
            name = "MakeEnemy",
            style = "red_button"
        }
    )

    local ScrollerHolder = Detail.add(
        {
            type = "frame",
            style = "inside_shallow_frame",
            name = "OtherDiplomacies",
        }
    )
    ScrollerHolder.style.top_margin = 10
    
    local Scroller = ScrollerHolder.add(
        {
            type = "scroll-pane",
            name = "Scroller"
        }
    )

    Scroller.style.top_margin = 3
    Scroller.style.bottom_margin = 3

    ScrollerHolder.style.top_padding = 3
    ScrollerHolder.style.bottom_padding = 3

    ScrollerHolder.style.minimal_width = 200
    ScrollerHolder.style.minimal_height = 40
    ScrollerHolder.style.maximal_height = 200

    -- BOTTOM BAR

    local SecondaryFlow = MainFlow.add(
        {
            type = "flow",
            direction = "horizontal",
            name = "SecondaryFlow"
        }
    )

    local CreateFaction = SecondaryFlow.add(
        {
            type = "button",
            caption = "Create",
            name = "CreateFaction"
        }
    )

    CreateFaction.style.maximal_width = 70

    local CloseMenu = SecondaryFlow.add(
        {
            type = "button",
            caption = "Close",
            name = "Close",
            style = "red_button"
        }
    )

    CloseMenu.style.maximal_width = 70

    Menu.location = {500,500}

    return {
        ["Holder"] = Menu,
        ["Factions"] = Factions,
        ["Create"] = Create,
        ["Detail"] = Detail,
    }, {
        ["Main"] = MainFlow,
        ["Secondary"] = SecondaryFlow,
    }, ToggleMenu
end