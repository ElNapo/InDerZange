--------------------------------------------------------------------------------
-- MapName: XXX
--
-- Author: NAPO RULEZ
--
--------------------------------------------------------------------------------


-- TODO-List:
-- SpielerIDS zum Finale zu einem Spieler kombinieren, alles auf Spieler 1 schieben?
-- Briefingtimings auf DEFAULTs setzen
-- Multiple modes of difficulty

-- Endfight rebalancen

-- Bugs to fix:
--  Doppelte Türme am südlichen Tor entfernen
--  Südteam gegen Endboss auf neutral stellen
--  Händlerbriefings nochmal anschauen
--  Speicherbugs prüfen?



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
    SetHostile(2,3)
    SetHostile(2,4)

    SetPlayerName(3, "Banditen")
    SetPlayerName(4, "Tresernberg")
    SetPlayerName(5, "Bauernsiedlung")
    SetPlayerName(6, "Händlergilde")
    SetPlayerName(7, "Söldner")
    SetPlayerName(8, "Bevölkerung")
end


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- This function is called from main script to init all resources for player(s)
function InitResources()
    Tools.GiveResouces(4,100000,100000,100000,100000,100000,100000)
end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- This function is called to setup Technology states on mission start
function InitTechnologies()
    ForbidTechnology(Technologies.UP1_Market, 1)
    ForbidTechnology(Technologies.UP1_Market, 2)
    ForbidTechnology(Technologies.UP2_Tower, 1)
    ForbidTechnology(Technologies.UP2_Tower, 2)

    for j = 1, 3 do
        GUI.UpgradeSettlerCategory( UpgradeCategories.LeaderSword, 4) 
        GUI.UpgradeSettlerCategory( UpgradeCategories.LeaderPoleArm, 4) 
        GUI.UpgradeSettlerCategory( UpgradeCategories.LeaderBow, 4)
        GUI.UpgradeSettlerCategory( UpgradeCategories.SoldierSword, 4) 
        GUI.UpgradeSettlerCategory( UpgradeCategories.SoldierPoleArm, 4) 
        GUI.UpgradeSettlerCategory( UpgradeCategories.SoldierBow, 4)  
    end
    --GUI.UpgradeSettlerCategory( UpgradeCategories.LeaderHeavyCavalry, 4)
    --GUI.UpgradeSettlerCategory( UpgradeCategories.SoldierHeavyCavalry, 4)
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
    Logic.SetPlayerRawName(1, "Yuki & Helias")
    Logic.SetPlayerRawName(2, "Erec & Pilgrim")  
    for j = 1, 2 do 
        --Logic.SetPlayerRawName( j, "Spieler "..j)
        Logic.PlayerSetGameStateToPlaying( j)			
		Logic.PlayerSetIsHumanFlag( j, 1)
		--LuaDebugger.Log(j)
    end
    Logic.PlayerSetPlayerColor( 1, 70, 130, 180)
    Logic.PlayerSetPlayerColor( 2, 89, 203, 232)
end
	
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- This function is called on game start after all initialization is done
function FirstMapAction()
    Script.Load("maps\\user\\InDerZange\\s5CommunityLib\\packer\\devLoad.lua")
    Script.Load("data/maps/externalmap/s5CommunityLib/packer/devLoad.lua")
    --mcbPacker.Paths[1][1] = "maps\\user\\InDerZange\\"
    mcbPacker.require("s5CommunityLib/comfort/entity/SVLib")
	mcbPacker.require("s5CommunityLib/comfort/math/Matrix")
    mcbPacker.require("s5CommunityLib/lib/UnlimitedArmy")
    mcbPacker.require("s5CommunityLib/lib/UnlimitedArmySpawnGenerator")
    mcbPacker.require("s5CommunityLib/lib/UnlimitedArmyRecruiter")	
    TriggerFix.AllScriptsLoaded()
    
    -- Load and activate comforts
    --Script.LoadFolder('data/maps/externalmap/Tools')
    Script.LoadFolder('maps/user/InDerZange/Tools')
	A = Matrix.New({{2,1,-1},
					{-3,-1,2},
					{-2,1,2}})
	v = Vector.New({8, -11, -3})
	
    InitMines()
   
    ActivateBriefingsExpansion()
    ActivateAdvancedEscapeBlock()
    BRIEFING_TIMER_PER_CHAR = 0.01
    WarriorMPComforts.Init()
    WarriorTime.Init()
    SW.QoL.Init()
    MakeEyecandyDestroyable()
    Playerswapper.Init()

    local prefix = "maps//user/InDerZange//"
    Script.Load(prefix.."Intro.lua")
    Script.Load(prefix.."RightSide.lua")
    Script.Load(prefix.."LeftSide.lua")

    OverwriteSetPosition();
    FixTechBug()

    -- Prep environment on left side
    LeftSide.DoEnvironmentChanges()
    LeftSide.CreateBandits()
   
    --LeftSide.DEBUG_LogLeaderSpawnPos()
    LeftSide.CreateBigCityArmies()
    
    
   
    -- Prep environment on right side
    RightSide.CreateBanditCamp()
    RightSide.DecorateBanditMain()
    RightSide.DecorateGate()
    RightSide.DecorateBase()
    --RightSide.CreateBanditArmies()
    RightSide.CreateBanditArmiesUA()
    
	if 1 == 1 then Tools.ExploreArea(1,1,900) return true end
	
    -- Start briefing
    Intro.StartThroneRoomBriefing()
    
    CreateInfoQuest()

    
    -- Debug stuff
    DEBUG_ACTIVE = true
    DEBUG_RESS = true
    DEBUG_TECHS = true
    if DEBUG_ACTIVE then
        --Game.GameTimeSetFactor(5)
        --Camera.ZoomSetFactorMax(1.5)
        if DEBUG_RESS then
            Tools.GiveResouces(1,100000,100000,100000,100000,100000,100000)
            Tools.GiveResouces(2,100000,100000,100000,100000,100000,100000)
        end
        if DEBUG_TECHS then
            ResearchAllUniversityTechnologies(1)
            ResearchAllUniversityTechnologies(2)
            ResearchTechnology(Technologies.T_SuperTechnology, 1)
            ResearchTechnology(Technologies.T_SuperTechnology, 2)
        end
    end

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
    Dario = "@color:15,64,255 Seine Majestät Dario @color:255,255,255",
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
    MissionComplete = " @color:255,255,255,75 ",
    MercLeader = " @color:255,215,0 Anführer der Söldner @color:255,255,255 ",
    Mercs = " @color:255,215,0 Söldner @color:255,255,255 ",
    TraderLeader = " @color:65,105,225 Gildenmeister der Händlergilde @color:255,255,255 ",
    StoneLeader = " @color:145,142,133 Minenarbeiter @color:255,255,255 ",
    Narrator = " @color:255,165,0 Erzähler @color:255,255,255 "
}

Colors = {
    Gold = " @color:255,215,0 ",
    Clay = " @color:167,107,41 ",
    Wood = " @color:86,47,14 ",
    Stone = " @color:139,141,122 ",
    Iron = " @color:203,205,205 ",
    Sulfur = " @color:237,255,33 ",
}

function CreateInfoQuest()
    local infoQuestId = 8
    local hlColor = " @color:255,69,0 "
    local white = " @color:255,255,255 "
    local text = "Auch in dieser Map gibt es einige Besonderheiten: @cr "
    .."Die beiden Heldenteams sind räumlich getrennt und deswegen hat jedes Team eigene Ressourcen und Technologien. "
    .."Möglichkeiten, Ressourcen auszutauschen, findet Ihr im Tributmenü. @cr "
    .."Technisch wird dies darüber realisiert, dass Ihr zwei Spieler steuert und je nach Mausposition zwischen "
    .."den Spielern gewechselt wird. Dies sollte meistens reibungslos funktionieren, aber alternativ könnt "
    .."Ihr auch das "..hlColor.."manuelle Umschalten"..white.." aktivieren, indem Ihr "..hlColor.."[TAB]"..white.." für ungefähr eine halbe Sekunde gedrückt haltet. "
    .."Der manuelle Modus kann deaktiviert werden, indem Ihr "..hlColor.."[TAB]"..white.." für drei Sekunden gedrückt haltet. @cr @cr "
    .."Außerdem gibt es einige neue "..hlColor.." Hotkeys: "..white
    .."Wenn Ihr "..hlColor.." Leertaste"..white.." drückt, werden alle Nicht-Leibeigenen und Leibeigene mit einem Hammer in der Hand aus der "
    .."Selektion entfernt. @cr "
    .."Wenn Ihr Truppen selektiert habt und während dem Nachkaufen"..hlColor.."[STRG]"..white.." gedrückt haltet, werden alle Truppen in der "
    .."Selektion aufgefüllt, sofern genug Ressourcen, Platz im Dorfzentrum und geeignete Rekrutierungsgebäude in der "
    .."Nähe existieren."
    Logic.AddQuest( 1, infoQuestId, SUBQUEST_OPEN, "Besonderheiten", text, 0)
    Logic.AddQuest( 2, infoQuestId, SUBQUEST_OPEN, "Besonderheiten", text, 0)
end
-- Refresh all troops in selection
-- Expel all entities in selection
-- Host is shown if player leaves
-- Pressing [Space] deselects all serfs tasked with constructing something


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

function PlaceHeroesInfrontOfNPC( npcName, hero1, hero2)
    -- get ids
    local npcId = Logic.GetEntityIDByName( npcName)
    local h1Id = Logic.GetEntityIDByName( hero1)
    local h2Id = Logic.GetEntityIDByName( hero2)

    -- info about the npc
    local pos = GetPosition(npcName)
    local orient = Logic.GetEntityOrientation( npcId)

    -- compute the offsets
    local distance = 500
    local dX1, dY1 = getOffsetByAngle( orient + 45)
    local dX2, dY2 = getOffsetByAngle( orient - 45)
    SetPosition( hero1, {X = pos.X + distance*dX1, Y = pos.Y + distance*dY1})
    SetPosition( hero2, {X = pos.X + distance*dX2, Y = pos.Y + distance*dY2})
    LookAt( hero1, npcName)
    LookAt( hero2, npcName)
    LookAt( npcName, hero1)
end
function getOffsetByAngle( angle)
    local angleRad = math.rad(angle)
    return math.cos(angleRad), math.sin(angleRad)
end

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
        Message("Der Spieler wurde gewechselt.")
        if not Playerswapper.manualMode then
            Message("Der Spielerwechsel ist nun im manuellen Modus!")
            Playerswapper.manualMode = true
        end
        Playerswapper.SwapPlayerId(3 - Playerswapper.currId)
    else
        if Playerswapper.manualMode then
            Message("Der Spielerwechsel ist nun im automatischen Modus!")
            Playerswapper.manualMode = false
        end
    end
end
function Playerswapper_Job()
    if not Playerswapper.manualMode then
        local targetPlayerId = 0
        local mX, mY = GUI.Debug_GetMapPositionUnderMouse() 
        if mX == -1 then return end
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
    --Logic.PlayerSetIsHumanFlag( oldPlayer, 0 )
    --Logic.PlayerSetIsHumanFlag( _newId, 1 )
    Logic.PlayerSetGameStateToPlaying( _newId )
end

function FixTechBug() 
    GUIUpdate_GlobalTechnologiesButtons_FixTechOrig = GUIUpdate_GlobalTechnologiesButtons
    GUIUpdate_GlobalTechnologiesButtons = function(_Button, _Technology, _BuildingType)
        GUIUpdate_GlobalTechnologiesButtons_FixTechOrig(_Button, _Technology, _BuildingType)
        local PlayerID = GUI.GetPlayerID()
        local TechState = Logic.GetTechnologyState(PlayerID, _Technology)
        if TechState ~= 4 then
            XGUIEng.HighLightButton(_Button,0)
        end
    end
    GUIUpdate_TechnologyButtons_FixTechOrig = GUIUpdate_TechnologyButtons
    GUIUpdate_TechnologyButtons = function( _bId, _tech, _bType)
        GUIUpdate_TechnologyButtons_FixTechOrig( _bId, _tech, _bType)
        local pId = GUI.GetPlayerID()
        local techState = Logic.GetTechnologyState( pId, techState)
        if techState ~= 4 then
            XGUIEng.HighLightButton( _bId, 0)
        end
    end
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
        eId = Logic.CreateEntity( v[1], x+v[2], y+v[3], v[4], v[6])
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
    Mines_Range = 750
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
            local bombId = Logic.CreateEntity( Entities.XD_Bomb1, Mines_ListOfMines[j].pos.X, Mines_ListOfMines[j].pos.Y, 0, pId)
            SVLib.SetEntitySize( bombId, 2.5)
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

function OverwriteSetPosition()
    -- overwrite original to spawn entities on free positions
    function SetPosition(_entity,_position)
        local entityId = GetEntityId(_entity)
        --	check entity
        assert(entityId ~= 0)
        
        if (Logic.IsLeader(entityId) ~= 0) then
            assert(Logic.LeaderGetNumberOfSoldiers(entityId) == 0)
        end
                
    --	collect information about entity
        local health 		= Logic.GetEntityHealth(entityId)
        local maxHealth 	= Logic.GetEntityMaxHealth(entityId)
        local hurt 			= maxHealth - health;
        local entityType 	= Logic.GetEntityType(entityId)
        local player 		= Logic.EntityGetPlayer(entityId)
        local name 			= Logic.GetEntityName(entityId)
        local wasSelected	= IsEntitySelected(entityId)
        if wasSelected then
            GUI.DeselectEntity(entityId)
        end

    --	destroy old one
        DestroyEntity(_entity)

    --	create entity
        local newEntityId
        if type(_entity) == "string" then
            newEntityId = AI.Entity_CreateFormation(player, entityType, 0, 0, _position.X, _position.Y, 0, 0, 0, 0);
            SetEntityName(newEntityId, _entity);
        else
            newEntityId = AI.Entity_CreateFormation(player, entityType, 0, 0, _position.X, _position.Y, 0, 0, 0, 0);
            SetEntityName(newEntityId, name);
        end

    --	select
        if wasSelected then
            GUI.SelectEntity(newEntityId)
        end

        GroupSelection_EntityIDChanged(entityId, newEntityId)

        --	hurt entity
        Logic.HurtEntity(newEntityId,hurt)

        -- return new id
        return newEntityId

    end
end

function CreateSendCaravanTribute(_player, _resourceType)
    LeftSide.TributeInfos = LeftSide.TributeInfos or {};
    local refined = "veredelte";
    if _player == 1 then
        refined = "unveredelte";
    end
    local ressNames = {Wood="Holz", Clay="Lehm",Stone="Stein",Iron="Eisen",Sulfur="Schwefel"};
    local text = "Zahlt "..Colors["Gold"].." 1000 Gold @color:255,255,255 und sendet eine Karawane die "..Colors[_resourceType].." 1000 "..refined.." Einheiten "..ressNames[_resourceType].." @color:255,255,255 versendet!";
    local callback = _G["Player".._player.."Sends".._resourceType];
    local costs = {Gold = 1000};
    AddTribute{
        playerId = _player,
        text = text,
        cost = costs,
        Callback = callback;
    }
end

function Player1SendsWood()
    PlayerSendTributeCallback(1, "Wood");
end
function Player1SendsClay()
    PlayerSendTributeCallback(1, "Clay");
end
function Player1SendsStone()
    PlayerSendTributeCallback(1, "Stone");
end
function Player1SendsIron()
    PlayerSendTributeCallback(1, "Iron");
end
function Player1SendsSulfur()
    PlayerSendTributeCallback(1, "Sulfur");
end
function Player2SendsWood()
    PlayerSendTributeCallback(2, "Wood");
end
function Player2SendsClay()
    PlayerSendTributeCallback(2, "Clay");
end
function Player2SendsStone()
    PlayerSendTributeCallback(2, "Stone");
end
function Player2SendsIron()
    PlayerSendTributeCallback(2, "Iron");
end
function Player2SendsSulfur()
    PlayerSendTributeCallback(2, "Sulfur");
end

function PlayerSendTributeCallback(_sender, _resourceType)
    local receiver = 1;
    if _sender == 1 then
        receiver = 2;
    end

    -- recreate tribute 
    CreateSendCaravanTribute(_sender, _resourceType);

    local sendAmount = 1000;
    local hasResources = false;
    local failed = false;
    if _sender == 1 then
        if Logic.GetPlayersGlobalResource(_sender, ResourceType[_resourceType.."Raw"]) >= sendAmount then
            Logic.SubFromPlayersGlobalResource(_sender, ResourceType[_resourceType.."Raw"], sendAmount);
        else
            failed = true;
        end
    elseif _sender == 2 then
        local ressAmount = Logic.GetPlayersGlobalResource(_sender, ResourceType[_resourceType]) + Logic.GetPlayersGlobalResource(_sender, ResourceType[_resourceType.."Raw"]);
        if ressAmount >= sendAmount then
            Logic.SubFromPlayersGlobalResource(_sender, ResourceType[_resourceType], sendAmount);
        else
            failed = true;
        end
    end

    if failed then
        Message("Eure Karawane konnte nicht starten, da ihr nicht die erfordlichen Rohstoffe hattet. Ihr erhaltet Eure Taler zurück.");
        local amountPayed = 1000;
        AddGold(_sender, amountPayed)
        return;
    end
    SendCaravan(receiver, _resourceType);
end

function SendCaravan(_receiver, _resourceType)
    local raw = "";
    if _receiver == 2 then
        raw = "Raw";
    end
    -- delay caravan as you'd like
    Logic.AddToPlayersGlobalResource(_receiver, ResourceType[_resourceType..raw], 1000);
end
