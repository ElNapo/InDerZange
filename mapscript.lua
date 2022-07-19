--------------------------------------------------------------------------------
-- MapName: XXX
--
-- Author: XXX
--
--------------------------------------------------------------------------------

-- Include main function
Script.Load( Folders.MapTools.."Main.lua" )
IncludeGlobals("MapEditorTools")

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- This function is called from main script to initialize the diplomacy states
-- IDs:
-- 1: Player, RS
-- 2: Player, LS
-- 3: Bandits
-- 4: Final boss
-- 5, 6, 7: Currently unused, maybe for left side quests?
-- 8: General population
function InitDiplomacy()
    Logic.SetShareExplorationWithPlayerFlag( 1, 2, 1)
    Logic.SetShareExplorationWithPlayerFlag( 2, 1, 1)
    SetHostile(1,3)

    SetPlayerName(3, "Banditen")
    SetPlayerName(4, "Tresernberg")
    SetPlayerName(5, "Bauernsiedlung")
    SetPlayerName(8, "Bevölkerung")
end


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- This function is called from main script to init all resources for player(s)
function InitResources()
end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- This function is called to setup Technology states on mission start
function InitTechnologies()
    ForbidTechnology(Technologies.UP1_Market)
end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- This function is called on game start and after save game is loaded, setup your weather gfx
-- sets here
function InitWeatherGfxSets()
	SetupNormalWeatherGfxSet()
end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- This function is called on game start you should setup your weather periods here
function InitWeather()
	AddPeriodicSummer(10)
end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- This function is called on game start and after save game to initialize player colors
function InitPlayerColorMapping()
        -- Give ids 1&2 player color
        Display.SetPlayerColorMapping( 1, 1)
        Display.SetPlayerColorMapping( 2, 1)
        -- Give id 3 bandit color
        Display.SetPlayerColorMapping( 3, 2)
        -- Give id 4 kerberos color
        Display.SetPlayerColorMapping( 4, 10)
        -- Give id 8 light green
        Display.SetPlayerColorMapping( 8, 8)    
end
	
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- This function is called on game start after all initialization is done
function FirstMapAction()
    Script.Load("maps//user//InDerZange//s5CommunityLib//packer//devLoad.lua")
    mcbPacker.Paths[1][1] = "maps//user//InDerZange//"
    mcbPacker.require("s5CommunityLib/comfort/entity/SVLib")
    mcbPacker.require("s5CommunityLib/lib/UnlimitedArmy")	
    TriggerFix.AllScriptsLoaded()
    -- Load and activate comforts
    Script.LoadFolder('maps//user//InDerZange//Tools')
    InitMines()
    ActivateBriefingsExpansion()
    ActivateAdvancedEscapeBlock()
    BRIEFING_TIMER_PER_CHAR = 0.5
    WarriorMPComforts.Init()
    WarriorTime.Init()
    SW.QoL.Init()
    MakeEyecandyDestroyable()
    Playerswapper.Init()

    Script.Load("maps//user//InDerZange//RightSide.lua")
    Script.Load("maps//user//InDerZange//LeftSide.lua")

    -- Prep environment on right side
    RightSide.CreateBanditCamp()
    RightSide.DecorateBanditMain()
    RightSide.DecorateGate()
    RightSide.DecorateBase()
    --RightSide.CreateBanditArmies()
    RightSide.CreateBanditArmiesUA()

    -- Start briefing
    RightSide.StartInitialBriefing()

    LeftSide.StartInitialBriefing()

    
    -- Debug stuff
    --Game.GameTimeSetFactor(5)
--[[     Camera.ZoomSetFactorMax(1.5)
    Tools.GiveResouces(1,100000,100000,100000,100000,100000,100000)
    ResearchAllUniversityTechnologies(1)
    Tools.ExploreArea(1,1,900)
    ResearchTechnology(Technologies.T_SuperTechnology)
 ]]
end
Names = {
    Yuki = " @color:70,130,180 Yuki @color:255,255,255 ",
    Helias = " @color:70,130,180 Helias @color:255,255,255 ",
    Erec = " @color:89,203,232 Erec @color:255,255,255 ",
    Pilgrim = " @color:89,203,232 Pilgrim @color:255,255,255 ",
    City = " @color:136,136,136 Tresernberg @color:255,255,255 ",
    BadGuy = " @color:136,136,136 Graf Cernunnos @color:255,255,255 ",
    BadGuyGenetiv = " @color:136,136,136 Grafen Cernunnos @color:255,255,255 ",
    --BadGuy = "Ianuarius"
    Agent = " @color:15,64,255 Agent des Nachrichtendienstes Seiner Majestät @color:255,255,255 ",
    AgentDativ = " @color:15,64,255 Agenten des Nachrichtendienstes Seiner Majestät @color:255,255,255 ",
    AgentMasked = " @color:15,64,255 Kontaktperson @color:255,255,255 ",
    AgentMessage = " @color:15,64,255 Botschaft des Nachrichtendienstes Seiner Majestät @color:255,255,255 ",
    SpyOrga = " @color:15,64,255 Der Nachrichtendienst Seiner Majestät @color:255,255,255 ",
    FakeSpyName = " @color:15,64,255 Joukahainen @color:255,255,255 ",
    Bandits = " @color:226,0,0 Banditen @color:255,255,255 ",
    BanditsSingular = " @color:226,0,0 Bandit @color:255,255,255 ",
    SteamEngine = " @color:226,0,0 Dampfmaschine @color:255,255,255 ",
    Lighthouse = " @color:255,215,0 Leuchtturm @color:255,255,255 ",
    Ixius = " @color:251,139,35 Ixius Ignis @color:255,255,255 ",
    Caspar = " @color:251,139,35 Caspar mit dem harten Stoff @color:255,255,255 ",
    CasparShort = " @color:251,139,35 Caspar @color:255,255,255 ",
    Sulfur = " @color:232,222,53 Schwefel @color:255,255,255 ",
    MissionComplete = " @color:255,255,255,75 "

}

Playerswapper = {}
Playerswapper.currId = 1
Playerswapper.manualMode = false
Playerswapper.KeyDownTime = 0
Playerswapper.TicksKeyHoldDown = 0
function Playerswapper.Init()
    -- start swapper job
    StartSimpleHiResJob("Playerswapper_Job")
    -- restore things on save game loading
    Playerswapper.InitPlayerColorMapping = InitPlayerColorMapping
	InitPlayerColorMapping = function()
		Playerswapper.SetControlledPlayer( Playerswapper.currId)
		Playerswapper.InitPlayerColorMapping()
	end
    Input.KeyBindDown(Keys.Tab, "Playerswapper.OnKeyDown()", 2)	
    Input.KeyBindUp( Keys.Tab, "Playerswapper.OnKeyUp()", 2)
end
function Playerswapper.OnKeyDown()
    local myTime = Logic.GetTimeMs()
    if myTime - Playerswapper.KeyDownTime >= 200 then
        Playerswapper.TicksKeyHoldDown = 1
    else
        Playerswapper.TicksKeyHoldDown = Playerswapper.TicksKeyHoldDown + 1
    end
    Playerswapper.KeyDownTime = myTime
end
function Playerswapper.OnKeyUp()
    local timeDiff = Logic.GetTimeMs() - Playerswapper.KeyDownTime
    timeDiff = Playerswapper.TicksKeyHoldDown*100
    --Message(timeDiff)
    if timeDiff < 200 then
        KeyBindings_ToggleOnScreenInformation()
    elseif timeDiff < 2500 then
        --Message("Der Spieler wurde gewechselt.")
        if not Playerswapper.manualMode then
            --Message("Der Spielerwechsel ist nun im manuellen Modus!")
            Playerswapper.manualMode = true
        end
        Playerswapper.SwapPlayerId(3 - Playerswapper.currId)
    else
        if Playerswapper.manualMode then
            --Message("Der Spielerwechsel ist nun im automatischen Modus!")
            Playerswapper.manualMode = false
        end
    end
--[[     LuaDebugger.Log("^ was pressed")
    if XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1 then
        LuaDebugger.Log("^+Strg was pressed.")
        if Playerswapper.manualMode then
            Playerswapper.manualMode = false
            Message("Der Spielerwechsel ist nun im automatischen Modus!")
        else
            Playerswapper.manualMode = true
            Message("Der Spielerwechsel ist nun im manuellen Modus!")
            Message("Dieser kann mit [Strg]+[^] deaktiviert werden.")
        end
    elseif XGUIEng.IsModifierPressed(Keys.ModifierShift) == 1 then
        LuaDebugger.Log("^+Shift was pressed.")
        if not Playerswapper.manualMode then
            Message("Der Spielerwechsel ist nun im manuellen Modus!")
            Message("Dieser kann mit [Strg]+[^] deaktiviert werden.")
            Playerswapper.manualMode = true
        end
        Playerswapper.SwapPlayerId(3 - Playerswapper.currId)
    end ]]
end
function Playerswapper_Job()
    if not Playerswapper.manualMode then
        local targetPlayerId = 0
        local mX, mY = GUI.Debug_GetMapPositionUnderMouse() 
        if mY < 14000 then
            targetPlayerId = 1
        else
            targetPlayerId = 2
        end
        if targetPlayerId ~= Playerswapper.currId then
            Playerswapper.SwapPlayerId( targetPlayerId)
            --Message('Schalte kontrollierten Spieler um!')
        end
    end
end
function Playerswapper.SwapPlayerId( _newId)
    Playerswapper.SetControlledPlayer( _newId)
    Playerswapper.currId = _newId
end
function Playerswapper.SetControlledPlayer( _newId)
    local oldPlayer = GUI.GetPlayerID()
    GUI.SetControlledPlayer(_newId)
    Logic.ActivateUpdateOfExplorationForAllPlayers()
    gvMission.PlayerID = _newId
    Logic.PlayerSetIsHumanFlag( oldPlayer, 0 )
    Logic.PlayerSetIsHumanFlag( _newId, 1 )
    Logic.PlayerSetGameStateToPlaying( _newId )
end

function MakeEyecandyDestroyable()
    local eyecandyTable = {
        Entities.XD_MiscBarrel2,
        Entities.XD_MiscBank1,
        Entities.XD_MiscBox1,
        Entities.XD_MiscBox2,
        Entities.XD_MiscChest2,
        Entities.XD_MiscChest3,
        Entities.XD_MiscHaybale1,
        Entities.XD_MiscHaybale2,
        Entities.XD_MiscHaybale3,
        Entities.XD_MiscQuiver1,
        Entities.XD_MiscPile1,
        Entities.XD_MiscSack1,
        Entities.XD_MiscSack2,
        Entities.XD_MiscSmallSack3,
        Entities.XD_MiscTable1,
        Entities.XD_MiscTable2,
        Entities.XD_MiscTent1,
        Entities.XD_MiscTrolley2,
        Entities.XD_MiscTrolley3,
    }
    local areAllEntitiesDeleted, data, eId, pos, orient, rockId, model
    for k,eType in pairs(eyecandyTable) do
        model = Models[Logic.GetEntityTypeName(eType)]
        areAllEntitiesDeleted = false
        while not areAllEntitiesDeleted do
            data = {Logic.GetEntities( eType, 16) }
            for j = 2, data[1]+1 do
                eId = data[j]
                pos = GetPosition(eId)
                orient = Logic.GetEntityOrientation(eId)
                rockId = Logic.CreateEntity(Entities.XD_Rock2, pos.X, pos.Y, orient, 0)
                Logic.SetModelAndAnimSet( rockId, model)
                DestroyEntity(eId)
            end
            areAllEntitiesDeleted = (data[1] == 0)
        end
    end
end



-- comforts
--      BRIEFING STUFF  
--	page
--		.title				= 	title key of the page
--		.position 			= 	position table for controlling the camera position
--		.text				=	briefing text key
--		.marker				=	type of marker (needs: position)
--								can be a table with multiple markers
--			.position		=	position for marker
--			.marker			=	type of marker
--		.explore			=	range of exploration (needs: title and position)
--		.pointer			=	optional position for a in game pointer
--		.dialogCamera		=	camera moves near to position/npc
--		.noScrolling		=	disable scrolling (optional)
--		.npc.id				=	optional entity id for a "!" symbol
--		.npc.isObserved		=	camera follows npc
--		.quest.id			=	quest id
--		.quest.type			=	quest type
--		.quest.title		=	quest title
--		.quest.text			=	quest text
--		.mc.text			=	show multiple choice menu and display text in window
--		.mc.firstSelected	=	continue briefing at this position if first button selected
--								at end of this briefing an empty page must appear (nil table entry)
--		.mc.firstText		=	first button text
--		.mc.secondSelected	=	continue briefing at this position if second button selected
--								at end of this briefing an empty page must appear (nil table entry)
--		.mc.secondText		=	second button text
function AddPages( _briefing )
	local AP = function(_page) table.insert(_briefing, _page); return _page; end
	local ASP = function(_entity, _title, _text, _dialog) return AP(CreateShortPage(_entity, _title, _text, _dialog)); end
	return AP, ASP;
end
function CreateShortPage( _entity, _title, _text, _dialog) 
    local page = {
        title = _title,
        text = _text,
        position = GetPosition( _entity ),
        dialogCamera = _dialog
    };
    return page;
end
function ActivateBriefingsExpansion()
	Briefing_ExtraOrig = Briefing_Extra;
	Briefing_Extra = function( _v1, _v2 )
        for i = 1, 2 do
            local theButton = "CinematicMC_Button" .. i;
            XGUIEng.DisableButton(theButton, 1);
            XGUIEng.DisableButton(theButton, 0);
        end                
        if _v1.action then
            assert( type(_v1.action) == "function" );
            _v1.action();
        end
        Briefing_ExtraOrig( _v1, _v2 );
    end
end
function ActivateAdvancedEscapeBlock()
    -- fct to override
    AdvancedEscBlock_GameCallback_Escape = GameCallback_Escape
    IsEscBlocked = false
    ActivateEscBlock = function()
        if IsEscBlocked then return end
        IsEscBlocked = true
        GameCallback_Escape = function() end
    end
    DeactivateEscBlock = function()
        if not IsEscBlocked then return end
        IsEscBlocked = false
        GameCallback_Escape = AdvancedEscBlock_GameCallback_Escape
    end
end

function AddTribute( _tribute )
	assert( type( _tribute ) == "table", "Tribut muß ein Table sein" );
    assert( type( _tribute.text ) == "string", "Tribut.text muß ein String sein" );
    assert( type( _tribute.cost ) == "table", "Tribut.cost muß ein Table sein" );
	assert( type( _tribute.playerId ) == "number", "Tribut.playerId muß eine Nummer sein" );
	assert( not _tribute.Tribute , "Tribut.Tribute darf nicht vorbelegt sein");
 
	uniqueTributeCounter = uniqueTributeCounter or 1;
	_tribute.Tribute = uniqueTributeCounter;
	uniqueTributeCounter = uniqueTributeCounter + 1;
 
	local tResCost = {};
	for k, v in pairs( _tribute.cost ) do
		assert( ResourceType[k] );
		assert( type( v ) == "number" );
		table.insert( tResCost, ResourceType[k] );
		table.insert( tResCost, v );
	end
 
	Logic.AddTribute( _tribute.playerId, _tribute.Tribute, 0, 0, _tribute.text, unpack( tResCost ) );
	SetupTributePaid( _tribute );
 
	return _tribute.Tribute;
end

function SpawnFromDataTable( _origin, _data, _pId)
    local eId
    local x,y = _origin.X, _origin.Y
    local eIdList = {}
    for k,v in pairs(_data) do
        eId = Logic.CreateEntity( v[1], x+v[2], y+v[3], v[4], _pId)
        if v[5] ~= "" then
            SetEntityName( eId, v[5])
        end
        table.insert(eIdList, eId)
    end
    return eIdList
end

function InitMines()
    Mines_ListOfMines = {    }
    Mines_ListOfLeaders = {}
    Mines_Range = 500
    StartSimpleJob("Mines_Job")
    Trigger.RequestTrigger( Events.LOGIC_EVENT_ENTITY_CREATED, nil, "Mines_OnEntityCreated", 1)
    Trigger.RequestTrigger( Events.LOGIC_EVENT_ENTITY_DESTROYED, nil, "Mines_OnEntityDestroyed", 1)
end
function Mines_Job()
    local posLeader
    local nMines = table.getn(Mines_ListOfMines)
    for k,v in pairs(Mines_ListOfLeaders) do
        posLeader = GetPosition(k)
        for j = 1, nMines do 
            if GetDistance( posLeader, Mines_ListOfMines[j].pos) < Mines_Range then
                Mines_ListOfMines[j].triggered = true
            end
        end
    end
    local pId
    for j = nMines, 1, -1 do
        if not IsExisting(Mines_ListOfMines[j].id) then
            table.remove(Mines_ListOfMines, j)
        elseif Mines_ListOfMines[j].triggered then
            pId = GetPlayer(Mines_ListOfMines[j].id)
            DestroyEntity( Mines_ListOfMines[j].id)
            Logic.CreateEntity( Entities.XD_Bomb1, Mines_ListOfMines[j].pos.X, Mines_ListOfMines[j].pos.Y, 0, pId)
            table.remove(Mines_ListOfMines, j)
        end
    end
end
function Mines_OnEntityCreated()
    local eId = Event.GetEntityID()
    if Logic.IsLeader(eId) == 1 and (GetPlayer(eId) == 1) or (GetPlayer(eId) == 2) then
        Mines_ListOfLeaders[eId] = true
    end
end
function Mines_OnEntityDestroyed()
    local eId = Event.GetEntityID()
    if Mines_ListOfLeaders[eId] then
        table.remove( Mines_ListOfLeaders, eId)
    end
end
function Mines_Add( _eId)
    local pos = GetPosition(_eId)
    table.insert(Mines_ListOfMines, {id = _eId, pos = pos})
end



--- author:???		current maintainer:mcb		v1.0
-- Berechnet die Entfernung zwischen 2 Punkten/Positionen.
function GetDistance(_pos1,_pos2)
    if (type(_pos1) == "string") or (type(_pos1) == "number") then
        _pos1 = GetPosition(_pos1);
    end
    assert(type(_pos1) == "table");
    if (type(_pos2) == "string") or (type(_pos2) == "number") then
        _pos2 = GetPosition(_pos2);
    end
    assert(type(_pos2) == "table");
    local xDistance = (_pos1.X - _pos2.X);
    local yDistance = (_pos1.Y - _pos2.Y);
    return math.sqrt((xDistance^2) + (yDistance^2));
end