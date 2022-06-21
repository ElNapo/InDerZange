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
    SetHostile(1,3)

    SetPlayerName(3, "Banditen")
    SetPlayerName(4, "Tresernberg")
    SetPlayerName(8, "Bevölkerung")
end


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- This function is called from main script to init all resources for player(s)
function InitResources()
end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- This function is called to setup Technology states on mission start
function InitTechnologies()
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
    -- Prep environment on right side
    RightSide.CreateBanditCamp()
    RightSide.DecorateBanditMain()
    RightSide.DecorateGate()
    RightSide.DecorateBase()
    RightSide.CreateBanditArmies()

    -- Start briefing
    RightSide.StartInitialBriefing()

    
    -- Debug stuff
    --Game.GameTimeSetFactor(5)
    Camera.ZoomSetFactorMax(1.5)
    Tools.GiveResouces(1,100000,100000,100000,100000,100000,100000)
    ResearchAllUniversityTechnologies(1)
    Tools.ExploreArea(1,1,900)
    ResearchTechnology(Technologies.T_SuperTechnology)

end
Names = {
    Yuki = " @color:70,130,180 Yuki @color:255,255,255 ",
    Helias = " @color:70,130,180 Helias @color:255,255,255 ",
    Erec = " @color:89,203,232 Erec @color:255,255,255 ",
    Pilgrim = " @color:89,203,232 Pilgrim @color:255,255,255 ",
    City = " @color:136,136,136 Tresernberg @color:255,255,255 ",
    Agent = " @color:15,64,255 Agent des Nachrichtendienstes Seiner Majestät @color:255,255,255 ",
    AgentDativ = " @color:15,64,255 Agenten des Nachrichtendienstes Seiner Majestät @color:255,255,255 ",
    AgentMasked = " @color:15,64,255 Kontaktperson @color:255,255,255 ",
    AgentMessage = " @color:15,64,255 Botschaft des Nachrichtendienstes Seiner Majestät @color:255,255,255 ",
    SpyOrga = " @color:15,64,255 Der Nachrichtendienst Seiner Majestät @color:255,255,255 ",
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

RightSide = {}
RightSide.QUESTID_MAIN = 1
RightSide.QUESTID_SUB = 2
RightSide.QUESTID_SUB2 = 3
RightSide.GatePos = {X = 19400, Y = 14200}
-- RS_BanditOutpostSpawn
-- RS_BanditMainSpawn

-- General idea of right side:
-- 1. Initial briefing
-- 2. Speak to spy, get HQ/VC, mission to clear bandits, possibility to send stuff to other party
-- 2,5. Clean ruins that are mined with wolves
-- 3. Clear first bandit camp, get in contact with the first traps
-- 4. Clear the second, more mined camp
-- 5. Ignite the light house, start the final chapter
function RightSide.CreateBanditCamp()
    local origin = GetPosition("RS_BanditCampfire")
    -- first remove the old placeholder entities
    local camps = {Logic.GetEntitiesInArea( Entities.CB_Camp13, origin.X, origin.Y, 2000, 16)}
    for j = 2, camps[1]+1 do
        DestroyEntity( camps[j])
    end
    local radius = 10 * 100
    RightSide.FirstCampEntities = {}
    for j = 1, 7 do
        local angle = math.rad(j * 45)
        local x,y = origin.X + radius*math.cos(angle), origin.Y + radius*math.sin(angle)
        table.insert( RightSide.FirstCampEntities, Logic.CreateEntity( Entities.CB_Camp13, x, y, math.deg(angle), 3))
    end
end
function RightSide.DecorateGate()
    for j = 1,2 do
        local eId = GetEntityId("RS_GateTower"..j)
        local pos = GetPosition(eId)
        SVLib.SetEntitySize( eId, 1.25)
        local _, cannonId = Logic.GetEntitiesInArea(Entities.PB_DarkTower3_Cannon, pos.X, pos.Y, 100, 1)
        SVLib.SetEntitySize( cannonId, 1.25)
    end
end
function RightSide.DecorateBanditMain()
    for j = 1, 7 do
        Logic.RotateEntity(GetEntityId("RS_Sheep"..j), 360*math.random())
    end
    SVLib.SetInvisibility( GetEntityId("RS_LighthouseKeeper"), true)
    local pos = GetPosition("RS_BanditMain1")
    local canontowers = {Logic.GetEntitiesInArea( Entities.PB_DarkTower3, pos.X, pos.Y, 2000, 4)}
    for j = 2, 5 do
        SVLib.SetEntitySize( canontowers[j], 1.25)
    end
    canontowers = {Logic.GetEntitiesInArea( Entities.PB_DarkTower3_Cannon, pos.X, pos.Y, 2000, 4)}
    for j = 2, 5 do
        SVLib.SetEntitySize( canontowers[j], 1.25)
    end
    pos = GetPosition("RS_WayWaypoint5")
    local banditEntities = {Logic.GetPlayerEntitiesInArea( 3, 0, pos.X, pos.Y, 2500, 16) }
    RightSide.MainCampEIds = {}
    for j = 2, banditEntities[1]+1 do
        MakeInvulnerable( banditEntities[j])
        table.insert(RightSide.MainCampEIds, banditEntities[j])
    end
    -- Randomly create traps
    -- RS_WayWaypoint1 to RS_WayWaypoint5
    local pos1, pos2, trapPos, n, length, numTraps, r1, r2
    local lengthPerTraps = 400
    for j = 1, 4 do
        local pos1 = GetPosition("RS_WayWaypoint"..j)
        local pos2 = GetPosition("RS_WayWaypoint"..(j+1))
        length = math.sqrt((pos1.X - pos2.X)*(pos1.X - pos2.X) + (pos1.Y - pos2.Y)*(pos1.Y - pos2.Y))
        n = {X = (pos1.Y - pos2.Y)/length, Y = (pos2.X - pos1.X)/length}
        numTraps = math.floor(length / lengthPerTraps)
        for k = 1, numTraps do
            r1 = math.random()
            r2 = math.random() - 0.5
            trapPos = { X = pos1.X + r1*(pos2.X - pos1.X) + r2*n.X*700, Y = pos1.Y + r1*(pos2.Y - pos1.Y) + r2*n.Y*700}
            --LuaDebugger.Log(trapPos)
            RightSide.CreateTrap(trapPos)
        end
    end
    local outpostPos = GetPosition("RS_BanditOutpostBombSpot")
    local range = 1500
    local r, phi
    for j = 1, 25 do
        phi = math.random()*2*math.pi
        r = math.sqrt(math.random())*range
        RightSide.CreateTrap( {X = outpostPos.X + r*math.cos(phi), Y = outpostPos.Y + r*math.sin(phi)})
    end
end
RightSide.ListOfTraps = {}
function RightSide.CreateTrap( _pos)
    -- adjust position such that it is multiple of 100
    --_pos.X = math.floor(_pos.X/100)*100
    --_pos.Y = math.floor(_pos.Y/100)*100
    local eId
    eId = Logic.CreateEntity( Entities.XD_BuildBlockScriptEntity, _pos.X, _pos.Y, math.random()*360, 3)
    SVLib.SetInvisibility( eId, false)
    SVLib.SetEntitySize( eId, math.random()*0.5+0.75)
    --eId = Logic.CreateEntity( Entities.PU_Hero3_Trap, _pos.X, _pos.Y, 0, 3)
    --eId = Logic.CreateEntity( Entities.PU_Hero3_TrapCannon, _pos.X, _pos.Y, 0, 3)
    --LuaDebugger.Log(GetPosition(eId))
    local listOfModels = {
        Models.XD_DeadBush1,
        Models.XD_GreeneryBush1,
        Models.XD_GreeneryBush2,
        Models.XD_GreeneryBush3,
        Models.XD_GreeneryBush5,
        Models.XD_MiscHaybale2,
        Models.XD_MiscSack1,
        Models.XD_MiscTrolley3,
        Models.XD_Plant5,
        Models.XD_Plant6,
        Models.XD_PlantNorth3,
        Models.XD_PlantNorth5,
        Models.XD_PlantMoor4
    }
    local nModels = table.getn(listOfModels)

    Logic.SetModelAndAnimSet( eId, listOfModels[math.ceil(nModels*math.random())])
    --LuaDebugger.Log(GetPosition(eId))

    table.insert(RightSide.ListOfTraps, eId)
    Logic.HurtEntity( eId, 450)
    Mines_Add( eId)
end
RightSide.RuinCounter = 0
function RightSide.DecorateBase()
    local maxHealth, eId
    for j = 1, 5 do
        eId = GetEntityId("RS_Ruin"..j)
        maxHealth = Logic.GetEntityMaxHealth(eId)
        Logic.HurtEntity( eId, maxHealth*0.8)
        SetupDestroy{
            Target = "RS_Ruin"..j,
            spawnPos = GetPosition("RS_Ruin"..j),
            Callback = function( _quest)
                Message("Glückwunsch, Ihr habt eine Ruine zerstört.")
                Message("Die Bewohner sind nicht erfreut.")
                Sound.PlayGUISound( Sounds.fanfare)
                RightSide.RuinCounter = RightSide.RuinCounter + 1
                RightSide.OnRuinDestroyed(_quest.spawnPos)
            end
        }
    end
end
function RightSide.OnRuinDestroyed( _pos)
    if RightSide.RuinCounter <= 3 then
        for j = 1, 2*RightSide.RuinCounter*RightSide.RuinCounter do
            Logic.CreateEntity( Entities.CU_AggressiveWolf, _pos.X, _pos.Y, 0, 3)
        end
    elseif RightSide.RuinCounter == 4 then
        AI.Entity_CreateFormation( 3, Entities.CU_Evil_LeaderBearman1, Entities.CU_Evil_SoldierBearman1, 8, _pos.X, _pos.Y, 0, 0, 0) 
    else
        AI.Entity_CreateFormation( 3, Entities.CU_Evil_LeaderBearman1, Entities.CU_Evil_SoldierBearman1, 16, _pos.X, _pos.Y, 0, 0, 0)
    end
end
function RightSide.CreateBanditArmies()
    MapEditor_SetupAI(3, 1, 0, 0, "RS_BanditMain1", 0, 0)
    -- Setup defenders
    RightSide.armyOutpostDefend = {
        player = 3,
        id = 3,
        strength = 8,
        position = GetPosition("RS_BanditOutpostSpawn"),
        rodeLength = 3000,
        beAgressive = true
    }
    SetupArmy( RightSide.armyOutpostDefend)
    local troopDescBow = {
        maxNumberOfSoldiers = 4,
        experiencePoints = LOW_EXPERIENCE,
        leaderType = Entities.CU_BanditLeaderBow1
    }
    local troopDescSword = {
        maxNumberOfSoldiers = 8,
        experiencePoints = LOW_EXPERIENCE,
        leaderType = Entities.CU_BanditLeaderSword2
    }
    local troopDescClub = {
        maxNumberOfSoldiers = 8,
        experiencePoints = LOW_EXPERIENCE,
        leaderType = Entities.CU_Barbarian_LeaderClub2
    }
    for i = 1,2 do
        EnlargeArmy( RightSide.armyOutpostDefend, troopDescBow)
        EnlargeArmy( RightSide.armyOutpostDefend, troopDescSword)
        EnlargeArmy( RightSide.armyOutpostDefend, troopDescClub)
    end
    EnlargeArmy( RightSide.armyOutpostDefend, troopDescSword)
    EnlargeArmy( RightSide.armyOutpostDefend, troopDescClub)
    -- RS_BanditSteamMachine
    -- RS_BanditOutpostBombSpot
    -- RS_BanditOutpostPatrolPoint
    AI.Army_AddWaypoint( RightSide.armyOutpostDefend.player, RightSide.armyOutpostDefend.id, GetEntityId("RS_BanditSteamMachine"))
    AI.Army_AddWaypoint( RightSide.armyOutpostDefend.player, RightSide.armyOutpostDefend.id, GetEntityId("RS_BanditOutpostBombSpot"))
    AI.Army_AddWaypoint( RightSide.armyOutpostDefend.player, RightSide.armyOutpostDefend.id, GetEntityId("RS_BanditOutpostPatrolPoint"))

    -- Setup patrolling troups
    RightSide.armyOutpostPatrol = {
        player = 3,
        id = 4,
        strength = 6,
        position = GetPosition("RS_BanditOutpostSpawn"),
        rodeLength = 3000,
        beAgressive = true
    }
    SetupArmy( RightSide.armyOutpostPatrol)
    for i = 1,3 do
        EnlargeArmy( RightSide.armyOutpostPatrol, troopDescBow)
        EnlargeArmy( RightSide.armyOutpostPatrol, troopDescClub)
    end
    AI.Army_AddWaypoint( RightSide.armyOutpostPatrol.player, RightSide.armyOutpostPatrol.id, GetEntityId("RS_WayWaypoint1")) 
    AI.Army_AddWaypoint( RightSide.armyOutpostPatrol.player, RightSide.armyOutpostPatrol.id, GetEntityId("RS_WayWaypoint2")) 
    AI.Army_AddWaypoint( RightSide.armyOutpostPatrol.player, RightSide.armyOutpostPatrol.id, GetEntityId("RS_BanditOutpostSpawn")) 
    AI.Army_AddWaypoint( RightSide.armyOutpostPatrol.player, RightSide.armyOutpostPatrol.id, GetEntityId("RS_WayWaypoint2")) 
    AI.Army_AddWaypoint( RightSide.armyOutpostPatrol.player, RightSide.armyOutpostPatrol.id, GetEntityId("RS_WayWaypoint3")) 
    StartSimpleJob("RightSide_ControlBandits")
end
RightSide.OutpostRemoved = false
RightSide.OutpostPatrolRespawnCounter = 12
function RightSide_ControlBandits()
    if Counter.Tick2("RightSide_ControlBandits", 5) then
        -- first check if outpost is removed
        if not RightSide.OutpostRemoved then
            local allDead = true
            for j = 1, 7 do
                if IsAlive(RightSide.FirstCampEntities[j]) then
                    allDead = false
                    break
                end
            end
            if allDead then
                RightSide.OutpostRemoved = true
            end
        end
        -- Outpost defenders
        Defend(RightSide.armyOutpostDefend)
        if AI.Army_GetNumberOfTroops(RightSide.armyOutpostDefend.player,RightSide.armyOutpostDefend.id) < 4 and not RightSide.OutpostRemoved then
            local troopDescBow = {
                maxNumberOfSoldiers = 4,
                experiencePoints = LOW_EXPERIENCE,
                leaderType = Entities.CU_BanditLeaderBow1
            }
            EnlargeArmy( RightSide.armyOutpostDefend, troopDescBow)
        end
        -- Outpost patrols
        Defend( RightSide.armyOutpostPatrol)
        if IsWeak(RightSide.armyOutpostPatrol) and not RightSide.OutpostRemoved then
            if RightSide.OutpostPatrolRespawnCounter <= 0 then
                RightSide.OutpostPatrolRespawnCounter = 12
            end
            RightSide.OutpostPatrolRespawnCounter = RightSide.OutpostPatrolRespawnCounter - 1
            if RightSide.OutpostPatrolRespawnCounter == 0 then
                RightSide.RespawnBanditPatrol()
            end
        end
    end
end
function RightSide.RespawnBanditPatrol()
    local troopDescBow = {
        maxNumberOfSoldiers = 4,
        experiencePoints = LOW_EXPERIENCE,
        leaderType = Entities.CU_BanditLeaderBow1
    }
    local troopDescSword = {
        maxNumberOfSoldiers = 8,
        experiencePoints = LOW_EXPERIENCE,
        leaderType = Entities.CU_BanditLeaderSword2
    }
    local troopDescClub = {
        maxNumberOfSoldiers = 8,
        experiencePoints = LOW_EXPERIENCE,
        leaderType = Entities.CU_Barbarian_LeaderClub2
    }
    local nLeaders = 6 - AI.Army_GetNumberOfTroops(RightSide.armyOutpostPatrol.player,RightSide.armyOutpostPatrol.id)
    for i = 1,math.floor(nLeaders) do
        EnlargeArmy( RightSide.armyOutpostPatrol, troopDescBow)
        EnlargeArmy( RightSide.armyOutpostPatrol, troopDescClub)
    end
    if AI.Army_GetNumberOfTroops(RightSide.armyOutpostPatrol.player,RightSide.armyOutpostPatrol.id) < 6 then
        EnlargeArmy( RightSide.armyOutpostPatrol, troopDescClub)
    end
end

function RightSide.CreateInitialCaravan()
    local spawn = GetPosition("RS_SpawnPos")
    local data = {
        -- etype, offsetX, offsetY, orientation, (optional) script name
        {Entities.PU_Hero11, 100, 0, 0, "Yuki"},
        {Entities.PU_Hero6, -100, 0, 0, "Helias"},
        {Entities.PU_Travelling_Salesman, 0, -200, 0, "RS_CaravanGold"},
        {Entities.PU_Travelling_Salesman, 100, -200, 0, "RS_CaravanWood"},
        {Entities.PU_Travelling_Salesman, -100, -200, 0, "RS_CaravanClay"},
    }
    caravanIds = SpawnFromDataTable( spawn, data, 1)
    -- move offset: X = -700, Y = +3700
    local pos
    for k,v in pairs(caravanIds) do
        pos = GetPosition(v)
        Move(v, {X = pos.X - 700, Y = pos.Y + 3700})
    end
end
function RightSide.StartInitialBriefing()
    RightSide.CreateInitialCaravan()
    local briefing = {}
    local AP, ASP = AddPages(briefing);
    ActivateEscBlock()
    AP{
        title = Names.Helias,
        text = "Unsere "..Names.AgentMasked.." müsste irgendwo hier in der Nähe sein. Im Brief stand, dass er ein nettes, relativ "
            .."abgelegenes und verlassenes Plätzchen gefunden hat. Aber seine Wegbeschreibung ist verwirrend.",
        position = GetPosition("Helias"),
        dialogCamera = true,
        action = function()
            Camera.FollowEntity(GetEntityId("Helias"))
        end
    }
    AP{
        title = Names.Yuki,
        text = "So schlimm hatte ich den Brief nicht in Erinnerung. Vielleicht sollten wir gemeinsam nochmal einen Blick "
            .."darauf werfen?",
        position = GetPosition("Yuki"),
        dialogCamera = true,
        action = function()
            Camera.FollowEntity(GetEntityId("Yuki"))
            LookAt("Helias", "Yuki")
            LookAt("Yuki", "Helias")
            DeactivateEscBlock()
        end
    }
    AP{
        title = Names.Helias,
        text = "In Ordnung, hier ist der Brief.",
        position = GetPosition("Helias"),
        dialogCamera = true,
        action = function()
            Camera.FollowEntity(GetEntityId("Helias"))
        end
    }
    AP{
        title = Names.AgentMessage,
        text = "Meine Damen und Herren, @cr es freut mich sehr, Ihnen mitteilen zu dürfen, dass wir einen ausgezeichneten Platz zur "
            .."Vorbereitung der Operation Zange gefunden haben. [Eine längere Beschreibung des Ortes]",
        position = GetPosition("Helias"),
        dialogCamera = true,
        action = function()
            Camera.FollowEntity(GetEntityId("Helias"))
        end
    }
    AP{
        title = Names.AgentMessage,
        text = "[Die Wegbeschreibung] ... und sobald Sie die Lehmgrube zu Ihrer Linken passiert haben, nehmen Sie die nächste Abzweigung rechts "
        .."und folgen Sie dem Weg. Sie können die gefundene Stelle und unseren Agenten dann nicht mehr verfehlen. @cr "
        .."Wir verbleiben mit freundlichen Grüßen @cr "..Names.SpyOrga,
        position = GetPosition("Yuki"),
        dialogCamera = true,
        action = function()
            Camera.FollowEntity(GetEntityId("Helias"))
        end
    }
    AP{
        title = Names.Yuki,
        text = "Wir haben die Lehmgrube passiert, also müssen wir jetzt wohl rechts abbiegen. Was war daran verwirrend?",
        position = GetPosition("Yuki"),
        dialogCamera = true,
        action = function()
            Camera.FollowEntity(GetEntityId("Yuki"))
        end
    }
    AP{
        title = Names.Helias,
        text = "*grummel grummel*",
        position = GetPosition("Helias"),
        dialogCamera = true,
        action = function()
            Camera.FollowEntity(GetEntityId("Helias"))
            local spyPos = GetPosition("RS_Spy") 
            GUI.CreateMinimapMarker( spyPos.X, spyPos.Y, 0)
            RightSide.SpyExploreMarker = Tools.ExploreArea( spyPos.X, spyPos.Y, 1)
        end,
        quest = {
            id = RightSide.QUESTID_MAIN,
            type = MAINQUEST_OPEN,
            title = "Trefft den Agenten!",
            text = Names.Helias.." und "..Names.Yuki.." haben ihn Ziel fast erreicht. Besprecht mit dem "..Names.AgentDativ.." die nächsten Schritte!"
        }
    }
    briefing.finished = function()
        CreateNPC{
            name = "RS_Spy",
            callback = RightSide.AgentBriefing
        }
        -- Setup follow entity stuff
        InitNPC("RS_CaravanGold")
        InitNPC("RS_CaravanWood")
        InitNPC("RS_CaravanClay")
        SetNPCFollow( "RS_CaravanGold", 1, 500, 100000, function() end)
        SetNPCFollow( "RS_CaravanWood", 1, 500, 100000, function() end)
        SetNPCFollow( "RS_CaravanClay", 1, 500, 100000, function() end)
    end
    StartBriefing( briefing)
end
function RightSide.AgentBriefing()
    -- first clear exploration and marker
    local spyPos = GetPosition("RS_Spy") 
    GUI.DestroyMinimapPulse( spyPos.X, spyPos.Y)
    DestroyEntity( RightSide.SpyExploreMarker)

    -- sethero position and orientation
    SetPosition("Helias", GetPosition("RS_Spy_HeliasPos"))
    SetPosition("Yuki", GetPosition("RS_Spy_YukiPos"))
    LookAt("Helias", "RS_Spy")
    LookAt("Yuki", "RS_Spy")
    LookAt("RS_Spy", "Yuki")

    -- actual briefing
    local briefing = {}
    local AP, ASP = AddPages(briefing);
    ASP( "RS_Spy", Names.Agent, "Willkommen! Welche Ehre, Seite an Seite mit den großen Helden "..
        Names.Helias.." und "..Names.Yuki.." arbeiten zu dürfen. Wie gefällt euch dieser Ort? Ich musste einige semilegale Dinge tun, um euch hier "..
        "empfangen zu können.", true)
    ASP( "Yuki", Names.Yuki, "Nun, es ist ein schönes Fleckchen Erde. Aber sagt, seid Ihr euch sicher, dass wir hier, direkt an der "..
        "Strasse, nicht auffallen werden?", true)
    ASP( "RS_Spy", Names.Agent, "Zweifelt Ihr etwa an mir? @cr "..
        "Aber ich kann Eure Sorgen verstehen und ich versichere Euch, dass Ihr hier völlig unentdeckt bleiben werdet. Seit die "..
        Names.Bandits.." sich hier sesshaft gemacht haben, ist kein einziger Händler über diese Route gereist. Und da die Route hier "..
        "nie wirklich wichtig war, wird auch niemand versuchen, hier aufzuräumen - außer Euch.", true)
    ASP( "Yuki", Names.Yuki, "Wunderbar. Mir wurde gesagt, dass Ihr schon einen fertig ausgearbeiteten Plan habt, allerdings wurden "..
        "wir noch nicht über die Details informiert. Und wie genau fügen sich die "..Names.Bandits.." in Euren Plan ein?", true)
    ASP( "RS_Spy", Names.Agent, "Der Plan ist simpel: @cr "..
        "Ihr werdet hier einen Stützpunkt errichten und später eine Hälfte des Zangenangriffes darstellen.", true)
    local exploreGate = AP{
        title = Names.Agent,
        text = "Es gibt ein gut verschlossenes Tor direkt in das Herz "..Names.City..". Aber wo ein Wille ist, ist auch ein Weg.",
        position = {X = RightSide.GatePos.X + 100, Y = RightSide.GatePos.Y},
        dialogCamera = false,
        explore = 500,
        marker = STATIC_MARKER,
        action = function()
            local gatePos = RightSide.GatePos
            --RightSide.ExploreCityGate = Tools.ExploreArea( gatePos.X, gatePos.Y, 5)
            local eId = Logic.GetEntityAtPosition(RightSide.GatePos.X, RightSide.GatePos.Y)
            SetEntityName( eId, "RS_CityGate")
        end
    }
    local pageLighthouse = AP{
        title = Names.Agent,
        text = "Aber natürlich wollt Ihr nicht zuschlagen ohne "..Names.Erec.." und "..Names.Pilgrim.." ein Signal zu geben. Und hier kommt der "..Names.Lighthouse.." ins Spiel: @cr "..
            "Sobald Ihr bereit seid und losschlagen wollt, werdet ihr den "..Names.Lighthouse.." entzünden und damit "..Names.Erec.." und "..Names.Pilgrim.." das Signal geben, "..
            "ebenfalls anzugreifen.",
        position = GetPosition("RS_Lighthouse"),
        explore = 500,
        dialogCamera = false,
        marker = STATIC_MARKER,
        quest = {
            id = RightSide.QUESTID_MAIN,
            type = MAINQUEST_OPEN,
            title = "Entzündet das Signalfeuer",
            text = "Kämpft euch zu dem "..Names.Lighthouse.." vor und entzündet das Signalfeuer, sobald ihr bereit seid. "
        }
    }
    ASP("Helias", Names.Helias, "Und die zuvor erwähnten "..Names.Bandits.." werden uns nicht stören?", True)
    local explorePage = AP{
        title = Names.Agent,
        text = "Nunja, gerade das ist das Problem. Das zentrale Lager der "..Names.Bandits.." ist genau am Fuße des Berges, auf dem auch der "..
            Names.Lighthouse.." gebaut wurde. Ihr werdet die "..Names.Bandits.." vertreiben müssen.",
        position = GetPosition("RS_BanditMain1"),
        explore = 500,
        quest = {
            id = RightSide.QUESTID_SUB,
            type = SUBQUEST_OPEN,
            title = "Besiegt die Banditen",
            text = "Vertreibt die "..Names.Bandits..", die die Gegend unsicher machen. Dazu müsst ihr zuerst die "..Names.SteamEngine.." des "..
                "Außenpostens zerstören, bevor Ihr euch um die eigentliche Basis kümmern könnt. @cr @cr Seid achtsam und erwartet nicht, "..
                "dass euer Gegner fair kämpfen wird!"
        }
    }
    AP{
        title = Names.Agent,
        text = "Und scheinbar ist das Hauptlager durch diese "..Names.SteamEngine.." geschützt, Ihr werdet also zuerst hier angreifen müssen.",
        position = GetPosition("RS_BanditSteamMachine"),
        action = function()
            local posSteam = GetPosition("RS_BanditSteamMachine")
            RightSide.ExploreSteamMachine = Tools.ExploreArea( posSteam.X, posSteam.Y, 1)
        end
    }
    ASP("Yuki", Names.Yuki, "Das klingt machbar. @cr Anderes Thema: Können wir "..Names.Erec.." und "..Names.Pilgrim.." irgendwie auf ihrer Seite unterstützen?", true)
    ASP("RS_Spy", Names.Agent, "Ich habe schon auf diese Frage gewartet und natürlich haben wir uns "..
        "auch etwas überlegt: @cr Die Handelswege sind zwar verlassen, aber mit entsprechenden Mitteln können wir trotzdem Karawanen schicken. "..
        "Ihr werdet in Eurem Tributmenü entsprechende Angebote finden.", True)
    ASP("RS_Spy", Names.Agent, "Damit seid ihr auf dem aktuellen Stand und könnt die Operation übernehmen. Gutes Gelingen!", True)
    briefing.finished = function()
        RightSide.ExploreBanditMain = explorePage.exploreId
        RightSide.ExploreCityGate = exploreGate.exploreId
        RightSide.ExploreLighthouse = pageLighthouse.exploreId
        Explore.Hide( explorePage)
        ChangePlayer("RS_HQ", 1)
        ChangePlayer("RS_VC", 1)
        SetNPCFollow("RS_CaravanGold", "RS_CaravanEndpoint", 100, 100000, function() end)
        SetNPCFollow("RS_CaravanClay", "RS_CaravanEndpoint", 100, 100000, function() end)
        SetNPCFollow("RS_CaravanWood", "RS_CaravanEndpoint", 100, 100000, function() end)
        SetupExpedition{
            EntityName = "RS_CaravanGold",
            TargetName = "RS_CaravanEndpoint",
            Distance = 250,
            Callback = function()
                DestroyEntity("RS_CaravanGold")
                AddGold(350)
                AddWood(250)
                AddClay(200)
                Message("Ein Teil Eurer Karawane hat sein Ziel erreicht!")
            end,
        }
        SetupExpedition{
            EntityName = "RS_CaravanWood",
            TargetName = "RS_CaravanEndpoint",
            Distance = 250,
            Callback = function()
                DestroyEntity("RS_CaravanWood")
                AddGold(350)
                AddWood(250)
                AddClay(200)
                Message("Ein Teil Eurer Karawane hat sein Ziel erreicht!")
            end,
        }
        SetupExpedition{
            EntityName = "RS_CaravanClay",
            TargetName = "RS_CaravanEndpoint",
            Distance = 250,
            Callback = function()
                DestroyEntity("RS_CaravanClay")
                AddGold(350)
                AddWood(250)
                AddClay(200)
                Message("Ein Teil Eurer Karawane hat sein Ziel erreicht!")
            end,
        }
        SetupDestroy{
            Target = "RS_BanditSteamMachine",
            Callback = RightSide.OnSteamEngineDestroyed
        }
    end
    StartBriefing( briefing)
end
function RightSide.OnSteamEngineDestroyed()
    Message("Die "..Names.SteamEngine.." wurde zerstört! Das Hauptlager ist angreifbar!")
    Sound.PlayGUISound( Sounds.fanfare)
    for k,v in pairs(RightSide.MainCampEIds) do
        MakeVulnerable(v)
    end
    local quest = {
        id = RightSide.QUESTID_SUB,
        type = SUBQUEST_OPEN,
        title = "Besiegt die Banditen",
        text = Names.MissionComplete.." Vertreibt die "..Names.Bandits..Names.MissionComplete..", die die Gegend unsicher machen. Dazu müsst ihr zuerst die "..Names.SteamEngine..Names.MissionComplete.." des "..
            "Außenpostens zerstören, bevor Ihr euch um die eigentliche Basis kümmern könnt. @cr @cr Seid achtsam und erwartet nicht, "..
            "dass euer Gegner fair kämpfen wird! @cr @cr @color:255,255,255 "..
            "Glückwunsch, Ihr habt die "..Names.Bandits.." zerstört! Und nun kümmert euch um das Hauptquartier!"
    }
    RightSide.BanditMainPos = GetPosition("RS_BanditMain1")
    Logic.AddQuest( 1, RightSide.QUESTID_SUB, SUBQUEST_OPEN, quest.title, quest.text, 1) 
    StartSimpleJob("RightSide_IsBanditMainDestroyed")
end
function RightSide_IsBanditMainDestroyed()
    if IsDead("RS_BanditMain1") or IsDead("RS_BanditMain2") or IsDead("RS_BanditMain3") then
        local eId
        for j = 1, 3 do
            eId = GetEntityId("RS_BanditMain"..j)
            if IsAlive(eId) then
                Logic.HurtEntity( eId, 10000)
            end
        end
        local pos = RightSide.BanditMainPos
        local canontowers = {Logic.GetEntitiesInArea( Entities.PB_DarkTower3, pos.X, pos.Y, 2000, 4)}
        for j = 2, canontowers[1]+1 do
            if not IsDead(canontowers[j]) then
                Logic.HurtEntity( canontowers[j], 10000)
            end
        end
        Message("Das Hauptquartier wurde zerstört!")
        Sound.PlayGUISound( Sounds.fanfare)
        local quest = {
            title = "Besiegt die Banditen",
            text = Names.MissionComplete.."Vertreibt die "..Names.Bandits..Names.MissionComplete..", die die Gegend unsicher machen. Dazu müsst ihr zuerst die "..Names.SteamEngine..Names.MissionComplete.." des "..
                "Außenpostens zerstören, bevor Ihr euch um die eigentliche Basis kümmern könnt. @cr @cr Seid achtsam und erwartet nicht, "..
                "dass euer Gegner fair kämpfen wird! @cr @cr "..
                "Glückwunsch, Ihr habt die "..Names.SteamEngine..Names.MissionComplete.." zerstört! Und nun kümmert euch um das Hauptquartier! @cr @cr @color:255,255,255 "..
                "Und auch das Hauptquartier ist gefallen! Sprecht mit dem Leuchtturmwärter, sobald Ihr für den Sturm auf "..
                Names.City.." bereit seid!" 
        }
        --RightSide.BanditMainPos = GetPosition("RS_BanditMain1")
        Logic.AddQuest( 1, RightSide.QUESTID_SUB, SUBQUEST_CLOSED, quest.title, quest.text, 0) 

        local quest2 = {
            id = RightSide.QUESTID_MAIN,
            type = MAINQUEST_OPEN,
            title = "Entzündet das Signalfeuer",
            text = "Redet mit dem Leuchtturmwärter, um das Signalfeuer zu entzünden und den Sturm auf "..Names.City.." zu beginnen!"
        }
        Logic.AddQuest( 1, quest2.id, quest2.type, quest2.title, quest2.text, 0) 
        SVLib.SetInvisibility( GetEntityId("RS_LighthouseKeeper"), false)
        RightSide.CreateLighthouseNPC()
        return true
    end
end
function RightSide.CreateLighthouseNPC()
    CreateNPC{
        name = "RS_LighthouseKeeper",
        callback = function()
            if not LeftSide.ReadyForAttack then
                Message(Names.Erec.." und "..Names.Pilgrim.." haben noch nicht genügend Verbündete!")
                RightSide.CreateLighthouseNPC()
                Sound.PlayGUISound( Sounds.VoicesHero6_HERO6_NO_rnd_01)
            else
                RightSide.FinalBriefing()
            end
        end
    }
end
function RightSide.FinalBriefing()
    local briefing = {}
    local AP, ASP = AddPages(briefing);
    -- Get yuki and helias in position
    SetPosition("Yuki", GetPosition("RS_FinalYukiPos"))
    SetPosition("Helias", GetPosition("RS_FinalHeliasPos"))
    LookAt("RS_LighthouseKeeper", "Yuki")
    LookAt("Yuki", "RS_LighthouseKeeper")
    LookAt("Helias", "RS_LighthouseKeeper")

    ASP("Helias", Names.Helias, "Ihr seht nicht so aus als würdet Ihr zu den "..Names.Bandits.." gehören. Warum seid Ihr hier?", true)
    ASP("RS_LighthouseKeeper", "?", "Ich bin in der Tat kein "..Names.BanditsSingular..". Früher nannte man mich "..Names.Ixius..", aber "..
        "während meinem unfreiwilligen Sabatical bei den "..Names.Bandits.." war ich nur "..Names.Caspar..". Einst habe ich "..
        "die schönsten Feuerwerke an den Himmel gezaubert, aber hier durfte ich nur tagein tagaus Schnaps brennen! ", true)
    ASP("RS_LighthouseKeeper", Names.Ixius.." / "..Names.Caspar, "Wenn es wenigstens guter Schnaps mit ausgewogenen Aromen, abgestimmt auf den Gaumen eines "..
        "Genießers, gewesen wäre! Nein, es hieß immer nur *DAS ZEUG MUSS BALLERN!* Es war schrecklich! Danke, dass Ihr mich befreit habt.", true)
    ASP("Helias", Names.Helias, "Wir müssen den Leuchtturm entzünden um unseren Verbündeten ein Zeichen zu geben. Sagt, "..Names.Ixius..", "..
        "wäre das ein angemessener Job für Euch?", true)
    ASP("RS_LighthouseKeeper", Names.Ixius, "Aber natürlich! Eure Verbündeten werden das Signal nicht verpassen können! "..
        "Dieser Turm wird selbst die Sonne überstrahlen!", true)
    ASP("Yuki", Names.Yuki, Names.CasparShort..", wir wollen nur ein Signal schicken und NICHT alles Leben im Umkreis von hunderten Kilometern auslöschen.", true)
    ASP("RS_LighthouseKeeper", Names.Caspar, "Bitte verwendet nicht diesen Namen. @cr Aber wie dem auch sei, "..
        "auch ein 'einfaches' Signalfeuer kann ich wunderschön aussehen lassen. Ich brauche vermutlich 2500 "..Names.Sulfur.." dafür.", true)
    ASP("Helias", Names.Helias, "Einverstanden. Wir schicken Euch den "..Names.Sulfur.." und Ihr beginnt unverzüglich mit dem Signalfeuer.", true)
    briefing.finished = function()
        AddTribute{
            playerId = 1,   
            text = "Zahlt 2500 "..Names.Sulfur.." an Ixius Feuerwerker, um das Leuchtfeuer zu entfachen!",
            cost = {Sulfur = 2500},
            Callback = RightSide.OnSulfurPaid;
        }
        local quest = {
            id = RightSide.QUESTID_SUB2,
            type = SUBQUEST_OPEN,
            title = Names.Ixius.."' Feuerwerk",
            text = "Zahlt den Tribut an "..Names.Ixius..", um das Signalfeuer zu entfachen und die finale Schlacht um "..Names.City.." "..
                "zu schlagen. Stellt sicher, dass ihr ausreichend vorbereitet seid."
        }
        Logic.AddQuest( 1, quest.id, quest.type, quest.title, quest.text, 1)
    end
    StartBriefing(briefing)
end
--TODO!
function RightSide.OnSulfurPaid()
    -- Here: Briefing that show fireworks, informs player to strike
    --  Toggle everything necessary to hostile
    --  Call the corresponding LeftSide-function
end

LeftSide = {}
LeftSide.ReadyForAttack = false


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