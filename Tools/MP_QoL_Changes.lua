--Let player choose color and allow to change camera zoom
WarriorMPComforts = {}
WarriorMPComforts.ColorBlacklist = {2, 8, 10}
WarriorMPComforts.CurrColor = 1
WarriorMPComforts.CurrMaxZoom = 2
WarriorMPComforts.MaxZoom = 2
WarriorMPComforts.MaxZoomStepSize = 0.5
function WarriorMPComforts.Init()
	WarriorMPComforts.OnLoad()
	-- Use BuyHero for Playercolor
	WarriorMPComforts.GUIAction_ToggleMenu = GUIAction_ToggleMenu
	GUIAction_ToggleMenu = function( _widgetId, _flag)
		if _widgetId == gvGUI_WidgetID.BuyHeroWindow and _flag == -1 then
			WarriorMPComforts.CurrColor = WarriorMPComforts.GetNextColor()
			WarriorMPComforts.ApplyColor()
		else
			WarriorMPComforts.GUIAction_ToggleMenu( _widgetId, _flag)
		end
	end
	WarriorMPComforts.GUITooltip_Generic = GUITooltip_Generic
	GUITooltip_Generic = function( _string)
		if _string == "MenuHeadquarter/buy_hero" then
			local myString = "@color:200,200,200 Farbe ändern @cr @color:255,255,255 Hier könnt ihr eure Farbe ändern!"
			XGUIEng.SetText( "TooltipBottomText", myString)
			XGUIEng.SetText( "TooltipBottomCosts", "")
			XGUIEng.SetText( "TooltipBottomShortCut", "")
		else
			WarriorMPComforts.GUITooltip_Generic( _string)
		end
	end
	GUIUpdate_BuyHeroButton = function()
		XGUIEng.ShowWidget("Buy_Hero", 1)
	end
	-- Use Levy_Duties for zoom config
	GUIAction_LevyTaxes = function()
		if WarriorMPComforts.CurrMaxZoom + WarriorMPComforts.MaxZoomStepSize > WarriorMPComforts.MaxZoom then
			WarriorMPComforts.CurrMaxZoom = 1
		else
			WarriorMPComforts.CurrMaxZoom = WarriorMPComforts.CurrMaxZoom + WarriorMPComforts.MaxZoomStepSize
		end
		WarriorMPComforts.ApplyZoom()
	end
	GUITooltip_LevyTaxes = function()
		local myString = "@color:200,200,200 Zoom einstellen @cr @color:255,255,255 Hier könnt ihr einstellen, wie weit ihr herauszoomen könnt. Aktueller Faktor: "
		..WarriorMPComforts.CurrMaxZoom.."."
		XGUIEng.SetText( "TooltipBottomText", myString)
		XGUIEng.SetText( "TooltipBottomCosts", "")
		XGUIEng.SetText( "TooltipBottomShortCut", "")
	end
	WarriorMPComforts.InitPlayerColorMapping = InitPlayerColorMapping
	InitPlayerColorMapping = function()
		WarriorMPComforts.OnLoad()
		WarriorMPComforts.InitPlayerColorMapping()
	end
end
function WarriorMPComforts.OnLoad() --function that is called everytime the game is loaded
	WarriorMPComforts.ApplyGUIChanges()
	WarriorMPComforts.ApplyColor()
	WarriorMPComforts.ApplyZoom()
end
function WarriorMPComforts.ApplyZoom()
	Camera.ZoomSetFactorMax( WarriorMPComforts.CurrMaxZoom)
end
function WarriorMPComforts.ApplyGUIChanges()
	XGUIEng.ShowWidget("Levy_Duties", 1)
	XGUIEng.SetWidgetPosition("Levy_Duties", 76, 4)
	XGUIEng.TransferMaterials( "Build_Village", "Buy_Hero")
	XGUIEng.TransferMaterials( "Research_GearWheel", "Levy_Duties")
	local r,g,b = GUI.GetPlayerColor( GUI.GetPlayerID() )
	XGUIEng.SetMaterialColor("Buy_Hero", 0, r, g, b, 255)
	r,g,b = WarriorMPComforts.GetNexColorRGB()
	XGUIEng.SetMaterialColor("Buy_Hero", 1, r, g, b, 255)
end
function WarriorMPComforts.GetNexColorRGB()
	local colors = {
		[1] = {15, 64, 255},
		[2] = {226, 0, 0},
		[3] = {235, 255, 53},
		[4] = {0, 235, 209},
		[5] = {252, 164, 39},
		[6] = {178, 2, 255},
		[7] = {255, 79, 200},
		[8] = {115, 209, 65},
		[9] = {0, 140, 2},
		[10] = {184, 184, 184},
		[11] = {184, 182, 90},
		[12] = {136, 136, 136},
		[13] = {230, 230, 230},
		[14] = {57, 57, 57},
		[15] = {139, 223, 255},
		[16] = {255, 150, 214}
	}
	local entry = colors[WarriorMPComforts.GetNextColor()]
	return entry[1], entry[2], entry[3]
end
function WarriorMPComforts.ApplyColor()
	Display.SetPlayerColorMapping( 1, WarriorMPComforts.CurrColor)
	Display.SetPlayerColorMapping( 2, WarriorMPComforts.CurrColor)
	local r,g,b = GUI.GetPlayerColor( GUI.GetPlayerID() )
	--LuaDebugger.Log("["..WarriorMPComforts.CurrColor.."] = {"..r..", "..g..", "..b.."},")
	XGUIEng.SetMaterialColor("Buy_Hero", 0, r, g, b, 255)
	r,g,b = WarriorMPComforts.GetNexColorRGB()
	XGUIEng.SetMaterialColor("Buy_Hero", 1, r, g, b, 255)
end
function WarriorMPComforts.GetNextColor()
	for i = 1, 16 do
		local testColor = math.mod(WarriorMPComforts.CurrColor + i - 1, 16) + 1
		local inTable = false
		for k,v in pairs(WarriorMPComforts.ColorBlacklist) do
			if v == testColor then
				inTable = true
				break
			end
		end
		if not inTable then
			return testColor
		end
	end
end
 --Allow control of time
WarriorTime = {}
WarriorTime.AllowedSpeed = {0.5, 1, 2, 3}
WarriorTime.CurrSpeedIndex = 2
WarriorTime.CurrSpeed = WarriorTime.AllowedSpeed[WarriorTime.CurrSpeedIndex]
WarriorTime.Paused = false
WarriorTime.InBriefing = false
function WarriorTime.Init()
	WarriorTime.MaxSpeedIndex = table.getn(WarriorTime.AllowedSpeed)
	WarriorTime.InitGUIHooks()
	WarriorTime.OnLoad()
	-- Hook into InitPlayerColorMapping to have a onLoad action
	WarriorTime.InitPlayerColorMapping = InitPlayerColorMapping
	InitPlayerColorMapping = function()
		WarriorTime.OnLoad()
		WarriorTime.InitPlayerColorMapping()
	end
end
function WarriorTime.OnLoad()
	XGUIEng.TransferMaterials("StatisticsWindowTimeScaleButton", "OnlineHelpButton")
	WarriorTime.SetSpeed()
end
function WarriorTime.InitGUIHooks()
	GUIAction_OnlineHelp = function()
		WarriorTime.OnButtonClick()
	end
	-- Hook into briefings to avoid "fast briefings"
	WarriorTime.StartBriefing = StartBriefing
	StartBriefing = function( _b)
		WarriorTime.OnEnterBriefing()
		_b.realfinished = _b.finished
		_b.finished = function() WarriorTime.OnQuitBriefing() _b.realfinished() end
		WarriorTime.StartBriefing( _b)
	end
	-- Change tool tip
	WarriorTime.GUITooltip_Generic = GUITooltip_Generic
	GUITooltip_Generic = function( _s)
		if _s == "MenuMap/OnlineHelp" then
			local myString = "@color:200,200,200 Geschwindigkeit anpassen @cr @color:255,255,255 Hier könnt ihr die Spielgeschwindigkeit anpassen! @cr "..
				" @cr Aktuelle Geschwindigkeit: "..WarriorTime.CurrSpeed
			XGUIEng.SetText( "TooltipBottomText", myString)
			XGUIEng.SetText( "TooltipBottomCosts", "")
			XGUIEng.SetText( "TooltipBottomShortCut", "")
		else
			WarriorTime.GUITooltip_Generic(_s)
		end
	end
	WarriorTime.GameCallback_GameSpeedChanged = GameCallback_GameSpeedChanged
	GameCallback_GameSpeedChanged = function( _speed)
		if _speed == 0 then
			WarriorTime.Paused = true
			WarriorTime.GameCallback_GameSpeedChanged( _speed)
		elseif WarriorTime.Paused then
			WarriorTime.Paused = false
			WarriorTime.GameCallback_GameSpeedChanged( _speed)
			WarriorTime.SetSpeed()
		end
	end
end
function WarriorTime.OnEnterBriefing()
	Game.GameTimeSetFactor(1)
	WarriorTime.InBriefing = true
end
function WarriorTime.OnQuitBriefing()
	WarriorTime.InBriefing = false 
	WarriorTime.SetSpeed()
end
function WarriorTime.SetSpeed()
	if WarriorTime.InBriefing then
		Game.GameTimeSetFactor(1)
	else
		Game.GameTimeSetFactor(WarriorTime.CurrSpeed)
	end
end
function WarriorTime.OnButtonClick()
	-- Mapping 1->2, 2->3, 3->4, 4->1
	-- x mod 4 + 1
	WarriorTime.CurrSpeedIndex = math.mod(WarriorTime.CurrSpeedIndex, WarriorTime.MaxSpeedIndex) + 1
	WarriorTime.CurrSpeed = WarriorTime.AllowedSpeed[WarriorTime.CurrSpeedIndex]
	WarriorTime.SetSpeed()
end