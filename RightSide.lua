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

RightSide.BanditOutpostDefendFullStrength = {
    {type = Entities.CU_BanditLeaderSword2, nSol = 8},
    {type = Entities.CU_BanditLeaderSword2, nSol = 8},
    {type = Entities.CU_BanditLeaderSword2, nSol = 8},
    {type = Entities.CU_BanditLeaderBow1, nSol = 4},
    {type = Entities.CU_BanditLeaderBow1, nSol = 4},
    {type = Entities.CU_BanditLeaderBow1, nSol = 4},
    {type = Entities.CU_Barbarian_LeaderClub2, nSol = 4},
    {type = Entities.CU_Barbarian_LeaderClub2, nSol = 4},
    {type = Entities.CU_Barbarian_LeaderClub2, nSol = 4}
}
RightSide.BanditOutpostDefendMinStrength = 5
RightSide.BanditOutpostPatrolFullStrength = {
    {type = Entities.CU_BanditLeaderBow1, nSol = 4},
    {type = Entities.CU_BanditLeaderBow1, nSol = 4},
    {type = Entities.CU_BanditLeaderBow1, nSol = 4},
    {type = Entities.CU_Barbarian_LeaderClub2, nSol = 4},
    {type = Entities.CU_Barbarian_LeaderClub2, nSol = 4},
    {type = Entities.CU_Barbarian_LeaderClub2, nSol = 4}
}
-- troops for armies 1 and 3
RightSide.BanditMainArmy1 = {
    {type = Entities.CU_BanditLeaderSword1, nSol = 8},
    {type = Entities.CU_BanditLeaderSword1, nSol = 8},
    {type = Entities.PU_LeaderSword3, nSol = 8},
    {type = Entities.PU_LeaderSword3, nSol = 8},
    {type = Entities.PU_LeaderBow3, nSol = 8},
    {type = Entities.PU_LeaderBow3, nSol = 8},
    {type = Entities.PU_LeaderRifle1, nSol = 4},
    {type = Entities.PU_LeaderRifle1, nSol = 4}
}
-- troops for army 2
RightSide.BanditMainArmy2 = {
    {type = Entities.PU_LeaderHeavyCavalry1, nSol = 3},
    {type = Entities.PU_LeaderHeavyCavalry1, nSol = 3},
    {type = Entities.PU_LeaderHeavyCavalry1, nSol = 3},
    {type = Entities.PU_LeaderHeavyCavalry1, nSol = 3},
    {type = Entities.PU_LeaderHeavyCavalry1, nSol = 3},
    {type = Entities.PU_LeaderHeavyCavalry1, nSol = 3},
    {type = Entities.PU_LeaderCavalry1, nSol = 3},
    {type = Entities.PU_LeaderCavalry1, nSol = 3},
    {type = Entities.PU_LeaderCavalry1, nSol = 3}
}

function RightSide.CreateBanditArmiesUA()
    -- First defending army
    RightSide.armyOutpostDefend = UnlimitedArmy:New{
        Player = 3,
        Area = 3500,
        --TransitAttackMove
        Formation = UnlimitedArmy.Formations.Chaotic,
        LeaderFormation = LeaderFormatons.LF_Fight,
        DoNotNormalizeSpeed = true
    }
    local spawnPos = GetPosition("RS_BanditOutpostSpawn")
    for k,entry in pairs(RightSide.BanditOutpostDefendFullStrength) do
        RightSide.armyOutpostDefend:CreateLeaderForArmy( entry.type, entry.nSol, spawnPos, LOW_EXPERIENCE)
    end
    local patrolPoint1 = GetPosition("RS_BanditSteamMachine")
    local patrolPoint2 = GetPosition("RS_BanditOutpostBombSpot")
    local patrolPoint3 = GetPosition("RS_BanditOutpostPatrolPoint")
    
    RightSide.armyOutpostDefend:AddCommandMove( patrolPoint1, true)
    RightSide.armyOutpostDefend:AddCommandWaitForIdle(true)
    --RightSide.armyOutpostPatrol:AddCommandWaitForTroopSize( 1, false, true)
    RightSide.armyOutpostDefend:AddCommandMove( patrolPoint2, true)
    RightSide.armyOutpostDefend:AddCommandWaitForIdle(true)
    RightSide.armyOutpostDefend:AddCommandMove( patrolPoint3, true)
    RightSide.armyOutpostDefend:AddCommandWaitForIdle(true)

    -- Then patrolling army
    RightSide.armyOutpostPatrol = UnlimitedArmy:New{
        Player = 3,
        Area = 1500,
        --TransitAttackMove
        Formation = UnlimitedArmy.Formations.Chaotic,
        LeaderFormation = LeaderFormatons.LF_Fight,
        DoNotNormalizeSpeed = true
    }

    for k,entry in pairs(RightSide.BanditOutpostPatrolFullStrength) do
        RightSide.armyOutpostPatrol:CreateLeaderForArmy( entry.type, entry.nSol, spawnPos, LOW_EXPERIENCE)
    end
    local waypoint1 = GetPosition("RS_WayWaypoint1")
    local waypoint2 = GetPosition("RS_WayWaypoint2")
    local waypoint3 = GetPosition("RS_BanditOutpostSpawn")
    local waypoint4 = GetPosition("RS_WayWaypoint2")
    local waypoint5 = GetPosition("RS_WayWaypoint3")
    
    RightSide.armyOutpostPatrol:AddCommandMove( waypoint1, true)
    RightSide.armyOutpostPatrol:AddCommandWaitForIdle(true)
    RightSide.armyOutpostPatrol:AddCommandMove( waypoint2, true)
    RightSide.armyOutpostPatrol:AddCommandWaitForIdle(true)
    RightSide.armyOutpostPatrol:AddCommandMove( waypoint3, true)
    RightSide.armyOutpostPatrol:AddCommandWaitForIdle(true)
    --RightSide.armyOutpostPatrol:AddCommandWaitForTroopSize( 3, false, true)
    RightSide.armyOutpostPatrol:AddCommandMove( waypoint4, true)
    RightSide.armyOutpostPatrol:AddCommandWaitForIdle(true)
    RightSide.armyOutpostPatrol:AddCommandMove( waypoint5, true)
    RightSide.armyOutpostPatrol:AddCommandWaitForIdle(true)
    StartSimpleJob("RightSide_ControlOutpostBandits")

    -- now for the main bandit army
    -- use some technologies to make army stronger?
    local banditTechs = {
        -- sawmill techs
        Technologies.T_Turnery,
        Technologies.T_WoodAging,
        Technologies.T_BodkinArrow,
        Technologies.T_Fletching,
        -- gunsmith techs
        Technologies.T_FleeceArmor,
        Technologies.T_FleeceLinedLeatherArmor,
        Technologies.T_LeadShot,
        Technologies.T_Sights,
        -- baracks techs
        Technologies.T_BetterTrainingArchery,
        Technologies.T_BetterTrainingBarracks,
        Technologies.T_Shoeing,
        -- smithery damage
        Technologies.T_IronCasting,
        Technologies.T_MasterOfSmithery,
        -- smithery armor
        Technologies.T_SoftArcherArmor,
        Technologies.T_LeatherArcherArmor,
        Technologies.T_PaddedArcherArmor,

        Technologies.T_LeatherMailArmor,
        Technologies.T_ChainMailArmor,
        Technologies.T_PlateMailArmor
    }
    for k,v in pairs(banditTechs) do
        ResearchTechnology( 3, v)
    end

    -- the infantery defending army
    spawnPos = GetPosition("RS_BanditMainSpawn")
    RightSide.ArmyMain1 = UnlimitedArmy:New{
        Player = 3,
        Area = 3500,
        --TransitAttackMove
        Formation = UnlimitedArmy.Formations.Chaotic,
        LeaderFormation = LeaderFormatons.LF_Fight,
        DoNotNormalizeSpeed = true,
        AutoDestroyIfEmpty = true
    }
    for k,v in pairs(RightSide.BanditMainArmy1) do
        RightSide.ArmyMain1:CreateLeaderForArmy( v.type, v.nSol, spawnPos, VERYHIGH_EXPERIENCE)
    end

    StartSimpleJob("RightSide_ControlMainBandits")
    RightSide.OnHurtTrigger = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "RightSide_OnEntityHurt", 1)
end
RightSide.BanditMainTriggered = false
RightSide.BanditMainRevengeSpawned = false
RightSide.BanditLastTriggerTime = -1000000
RightSide.BanditMostRecentAttackerPos = nil
function RightSide_OnEntityHurt()
    local attacker = Event.GetEntityID1()
    local victim = Event.GetEntityID2()
    if IsDead(attacker) or IsDead(victim) then
        return
    end
    if GetPosition(victim).X < 10000 and GetPlayer(victim) == 3 and Logic.IsBuilding(victim) == 1 then
        RightSide.BanditMainTriggered = true
        RightSide.BanditLastTriggerTime = Logic.GetTime()
        RightSide.BanditMostRecentAttackerPos = GetPosition(attacker)
        --return true
    end
end
function RightSide.BanditsSpawnRevengeArmy()
    RightSide.BanditMainRevengeSpawned = true
    local spawnPos = GetPosition("RS_BanditMainSpawn")
    Sound.PlayGUISound( Sounds.VoicesHero9_HERO9_Berserk_rnd_01, 100)
    -- the infantery army II
    RightSide.ArmyMain3 = UnlimitedArmy:New{
        Player = 3,
        Area = 3500,
        --TransitAttackMove
        Formation = UnlimitedArmy.Formations.Chaotic,
        LeaderFormation = LeaderFormatons.LF_Fight,
        DoNotNormalizeSpeed = true,
        AutoDestroyIfEmpty = true
    }
    for k,v in pairs(RightSide.BanditMainArmy1) do
        RightSide.ArmyMain3:CreateLeaderForArmy( v.type, v.nSol, spawnPos, VERYHIGH_EXPERIENCE)
    end
    -- the cavallery army
    RightSide.ArmyMain2 = UnlimitedArmy:New{
        Player = 3,
        Area = 3500,
        --TransitAttackMove
        Formation = UnlimitedArmy.Formations.Chaotic,
        LeaderFormation = LeaderFormatons.LF_Fight,
        DoNotNormalizeSpeed = true,
        AutoDestroyIfEmpty = true
    }
    for k,v in pairs(RightSide.BanditMainArmy2) do
        RightSide.ArmyMain2:CreateLeaderForArmy( v.type, v.nSol, spawnPos, VERYHIGH_EXPERIENCE)
    end
end
-- want the following behavior:
-- defender respawns up to 1/3rds of original strength, respawn troops instantly
-- patrols regenerate slowly, one troop per 30 secs
RightSide.OutpostRemoved = false
RightSide.OutpostPatrolRespawnCounter = 6
RightSide.OutpostPatrolRespawnCounterMax = 6
RightSide.OutpostPatrolPointer = 0
RightSide.OutpostDefenderRespawnPointer = 0
function RightSide_ControlOutpostBandits()
    if Counter.Tick2("RightSide_ControlBanditsOutpost", 5) then
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

        -- now try to manage actual armies
        -- if everything is gone => destruct everything!
        if RightSide.OutpostRemoved and RightSide.armyOutpostDefend:IsDead() and RightSide.armyOutpostPatrol:IsDead() then
            RightSide.armyOutpostDefend:Destroy()
            RightSide.armyOutpostPatrol:Destroy()
            return true
        end

        -- if outpost is destroyed => no need to spawn new troops, stop here
        if RightSide.OutpostRemoved then return end

        -- interesting setting: outpost still alive
        -- manage defenders, respawn one instantly if something is amiss
        if RightSide.armyOutpostDefend:GetSize(true,true) < RightSide.BanditOutpostDefendMinStrength then
            local N = table.getn(RightSide.BanditOutpostDefendFullStrength)
            RightSide.OutpostDefenderRespawnPointer = math.mod(RightSide.OutpostDefenderRespawnPointer,N) + 1
            local entry = RightSide.BanditOutpostDefendFullStrength[RightSide.OutpostDefenderRespawnPointer]
            local spawnPos = GetPosition("RS_BanditOutpostSpawn")
            RightSide.armyOutpostDefend:CreateLeaderForArmy( entry.type, entry.nSol, spawnPos, LOW_EXPERIENCE)
        end

        -- manage patrols, respawn them more slowly but to full strength
        local N = table.getn(RightSide.BanditOutpostPatrolFullStrength)
        if N > RightSide.armyOutpostPatrol:GetSize(true,true) then
            RightSide.OutpostPatrolRespawnCounter = RightSide.OutpostPatrolRespawnCounter - 1
            if RightSide.OutpostPatrolRespawnCounter == 0 then
                RightSide.OutpostPatrolRespawnCounter = RightSide.OutpostPatrolRespawnCounterMax
                -- in this setting: spawn troop
                RightSide.OutpostPatrolPointer = math.mod(RightSide.OutpostPatrolPointer,N)+1
                local entry = RightSide.BanditOutpostPatrolFullStrength[RightSide.OutpostPatrolPointer]
                local spawnPos = GetPosition("RS_BanditOutpostSpawn")
                RightSide.armyOutpostPatrol:CreateLeaderForArmy( entry.type, entry.nSol, spawnPos, LOW_EXPERIENCE)
                RightSide.armyOutpostPatrol:SetTarget(spawnPos )
                --RightSide.armyOutpostPatrol:SetReMove(true)
            end
        end
    end
end
function RightSide_ControlMainBandits()
    -- spawn revenge army
    if RightSide.BanditMainTriggered and not RightSide.BanditMainRevengeSpawned then
        RightSide.BanditsSpawnRevengeArmy()
        RightSide.ArmyMain2:AddCommandMove( GetPosition("RS_HQ"))
        RightSide.ArmyMain3:AddCommandMove( GetPosition("RS_HQ"))
    end
    -- wanted behavior:
    -- start an attack if buildings are damaged
    -- after attack move back if possible

    -- when army is defeated destroy it
    if RightSide.ArmyMain1:IsDead() == -1 then
        Trigger.UnrequestTrigger(RightSide.OnHurtTrigger)
        return true
    end

    -- is attack on buildings recent?
    if RightSide.BanditLastTriggerTime + 15 > Logic.GetTime() then
        -- if there was a recent attack and the army idles => go for revenge
        -- Idle = 1, Moving = 2, Battle = 3, Destroyed = 4, IdleUnformated = 5, MovingNoBattle = 6
        -- local armyStatus = RightSide.ArmyMain1.Status
        -- if target is not the spawn attack the attacker
        if RightSide.ArmyMain1.Target.X < 8500 then
            RightSide.ArmyMain1:ClearCommandQueue()
            RightSide.ArmyMain1:AddCommandMove( RightSide.BanditMostRecentAttackerPos, false)
            RightSide.ArmyMain1:AddCommandWaitForIdle( false)
            RightSide.ArmyMain1:AddCommandMove( GetPosition("RS_BanditMainSpawn"), true)
        end
    else -- attack is not recent? retreat if army goes to far off
        -- if any leader is super far away => order retreat
        local largestXCoordLeader = 0
        local pos
        for leaderId in RightSide.ArmyMain1:Iterator(true) do
            pos = GetPosition(leaderId)
            largestXCoordLeader = math.max(pos.X, largestXCoordLeader)
        end
        if largestXCoordLeader > 16000 and RightSide.ArmyMain1.Target.X > 8500 then
            RightSide.ArmyMain1:ClearCommandQueue()
            RightSide.ArmyMain1:AddCommandFlee(GetPosition("RS_BanditMainSpawn"), true)
        end
    end
end

function RightSide.CreateInitialCaravan()
    local spawn = GetPosition("RS_SpawnPos")
    local data = {
        -- etype, offsetX, offsetY, orientation, (optional) script name
        {Entities.PU_Hero11, 100, 0, 0, "Yuki", 1},
        {Entities.PU_Hero6, -100, 0, 0, "Helias", 1},
        {Entities.PU_Travelling_Salesman, 0, -200, 0, "RS_CaravanGold", 8},
        {Entities.PU_Travelling_Salesman, 100, -200, 0, "RS_CaravanWood", 8},
        {Entities.PU_Travelling_Salesman, -100, -200, 0, "RS_CaravanClay", 8},
    }
    caravanIds = SpawnFromDataTable( spawn, data)
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
        LeftSide.StartInitialBriefing()
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
                AddGold(1, 350)
                AddWood(1, 250)
                AddClay(1, 200)
                Message("Ein Teil Eurer Karawane hat sein Ziel erreicht!")
            end,
        }
        SetupExpedition{
            EntityName = "RS_CaravanWood",
            TargetName = "RS_CaravanEndpoint",
            Distance = 250,
            Callback = function()
                DestroyEntity("RS_CaravanWood")
                AddGold(1, 350)
                AddWood(1, 250)
                AddClay(1, 200)
                Message("Ein Teil Eurer Karawane hat sein Ziel erreicht!")
            end,
        }
        SetupExpedition{
            EntityName = "RS_CaravanClay",
            TargetName = "RS_CaravanEndpoint",
            Distance = 250,
            Callback = function()
                DestroyEntity("RS_CaravanClay")
                AddGold(1, 350)
                AddWood(1, 250)
                AddClay(1, 200)
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
        --Message("Darin war ein Schlüssel zum abgeschlossenen Siedlungsplatz!")
        --ReplaceEntity("RS_VCGate")
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

    -- Here: Briefing that show fireworks with fancy cutscene, informs player to strike
    --  Toggle everything necessary to hostile
    --  Start final battle
    --  Destroy lighthouse in mighty explosion
function RightSide.ActivateNight()
    Display.GfxSetSetSkyBox(1, 0.0, 1.0, "YSkyBox07")
    Display.GfxSetSetRainEffectStatus(1, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(1, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(1, 0.0, 0.8, 0)
    Display.GfxSetSetFogParams(1, 10.0, 10.0, 1, 54,54,54, 20000,105000)
    Display.GfxSetSetLightParams(1,  0.0, 1.0, 40, -15, -50,  105,105,105, 0,0,0)
end
RightSide.FireworkCounter = -1
RightSide.FireworkDynamics = {
    -- optional: rndSpread, count
    {effect = GGL_Effects.FXMaryPoison, delay = 0, pos = {0,0}},
    
}

--[[ FXBuildingSmoke
FXBuildingSmokeLarge
FXBuildingSmokeMedium
FXCannonBallShrapnel
FXCrushBuilding
FXExplosion
FXExplosionPilgrim
FXExplosionShrapnel
FXFire
FXLightning
FXMaryPoison
FXNephilimFlowerDestroy
FXSalimHeal
FXYukiFireworksFear
FXYukiFireworksJoy ]]




function RightSide.StartFireworks()
    local lighttowerPos = GetPosition("RS_Lighthouse")
    local applyOffset = function(pos, dx, dy)
        return {X = pos.X + dx, Y = pos.Y + dy}
    end
    RightSide.FireworksTimetable = {
        {t = 0, effect = GGL_Effects.FXYukiFireworksFear, pos = lighttowerPos},
        {t = 0, effect = GGL_Effects.FXYukiFireworksJoy, pos = lighttowerPos},
        {t = 2, effect = GGL_Effects.FXYukiFireworksFear, pos = lighttowerPos},
        {t = 4, effect = GGL_Effects.FXYukiFireworksJoy, pos = lighttowerPos},
        {t = 5, effect = GGL_Effects.FXMaryPoison, pos = lighttowerPos},
        {t = 8, effect = GGL_Effects.FXLightning, pos = lighttowerPos},
        {t = 9, effect = GGL_Effects.FXExplosionShrapnel, pos = lighttowerPos},
        {t = 10, effect = GGL_Effects.FXExplosionShrapnel, pos = applyOffset(lighttowerPos, 750, 0)},
        {t = 10, effect = GGL_Effects.FXExplosionShrapnel, pos = applyOffset(lighttowerPos, -750, 0)},
        {t = 10, effect = GGL_Effects.FXExplosionShrapnel, pos = applyOffset(lighttowerPos, 0, 750)},
        {t = 10, effect = GGL_Effects.FXExplosionShrapnel, pos = applyOffset(lighttowerPos, 0, -750)},
        {t = 10, action = function() Logic.HurtEntity(GetEntityId("RS_Lighthouse"), 400) end},
        
        {t = 10, fakeEffect = "Effects_XF_HouseFire", pos = applyOffset(lighttowerPos, 0, -750)},
        {t = 10, fakeEffect = "Effects_XF_HouseFire", pos = applyOffset(lighttowerPos, 0, 750)},
        {t = 10, fakeEffect = "Effects_XF_HouseFire", pos = applyOffset(lighttowerPos, 750, 0)},
        {t = 10, fakeEffect = "Effects_XF_HouseFire", pos = applyOffset(lighttowerPos, -750, 0)},

        {t = 12, effect = GGL_Effects.FXCrushBuilding, pos = lighttowerPos},
        {t = 12, effect = GGL_Effects.FXBuildingSmokeLarge, pos = lighttowerPos},
        {t = 12, effect = GGL_Effects.FXExplosionPilgrim, pos = lighttowerPos},
        {t = 12, action = function() Logic.HurtEntity(GetEntityId("RS_Lighthouse"), 400) end},

        {t = 13, effect = GGL_Effects.FXExplosion, pos = applyOffset(lighttowerPos, -350, 0)},
        {t = 13, effect = GGL_Effects.FXExplosion, pos = applyOffset(lighttowerPos, 350, 0)},
        {t = 13, effect = GGL_Effects.FXExplosion, pos = applyOffset(lighttowerPos, 0, -350)},
        {t = 13, effect = GGL_Effects.FXExplosion, pos = applyOffset(lighttowerPos, 0, 350)}
    }
    local radius, angle, dx, dy
    for j = 1, 15 do
        radius = math.sqrt(math.random())*1000
        angle = math.random()*2*math.pi
        dx, dy = radius*math.cos(angle), radius*math.sin(angle)
        table.insert(RightSide.FireworksTimetable, {t = 10, fakeEffect = "Effects_XF_HouseFire", pos = applyOffset(lighttowerPos, dx, dy)})
        table.insert(RightSide.FireworksTimetable, {t = 10, effect = GGL_Effects.FXExplosionShrapnel, pos = applyOffset(lighttowerPos, dx,dy)})
    end
    RightSide.FireworkTimer = 0
    StartSimpleJob("RightSide_HandleFirework")
end
function RightSide_HandleFirework()
    for k,v in pairs(RightSide.FireworksTimetable) do
        if v.t == RightSide.FireworkTimer then
            if v.action then
                v.action()
            elseif v.effect then
                Logic.CreateEffect( v.effect, v.pos.X, v.pos.Y, 1)
            elseif v.fakeEffect then
                local eId = Logic.CreateEntity(Entities.XD_Rock1, v.pos.X, v.pos.Y, 0, 1)
                Logic.SetModelAndAnimSet( eId, Models[v.fakeEffect])
            end
        end
    end
    RightSide.FireworkTimer = RightSide.FireworkTimer + 1
    if RightSide.FireworkCounter > 20 then return true end
end
-- FXBuildingSmoke
-- FXBuildingSmokeLarge
-- FXBuildingSmokeMedium
-- FXCrushBuilding
-- FXExplosion
-- FXExplosionPilgrim
-- FXExplosionShrapnel
-- FXFire
-- FXFireLo
-- FXFireMedium
-- FXFireSmall
-- FXLightning
-- FXMaryPoison
-- FXYukiFireworksFear
-- FXYukiFireworksJoy
function RightSide.ToggleGate()
    -- first deal with the two central cannon towers because they are annoying
    for j = 1,2 do
        ChangePlayer("RS_GateTower"..j, 4)
        local eId = GetEntityId("RS_GateTower"..j)
        local pos = GetPosition(eId)
        SVLib.SetEntitySize( eId, 1.25)
        local _, cannonId = Logic.GetEntitiesInArea(Entities.PB_DarkTower3_Cannon, pos.X, pos.Y, 100, 1)
        SVLib.SetEntitySize( cannonId, 1.25)
    end
    -- now do the other stuff
    local types = {
        Entities.PB_DarkTower3,
        Entities.XD_WallCorner,
        Entities.XD_WallDistorted,
        Entities.XD_WallStraight,
        Entities.XD_WallStraightGate_Closed
    }
    local gatePos = {X = 19400, Y = 14200}
    for k, eType in pairs(types) do
        local entities = {Logic.GetEntitiesInArea( eType, gatePos.X, gatePos.Y, 1500, 16)}
        for j = 2, entities[1]+1 do
            ChangePlayer( entities[j], 4)
        end
    end
end

function RightSide.OnSulfurPaid()
    local briefing = {}
    local AP, ASP = AddPages(briefing);
    AP{
        title = Names.Ixius,
        text = "Wunderbar, aber lasst uns noch kurz auf die Nacht warten. Damit Eure Freunde das Signalfeuer besser sehen können.",
        position = GetPosition("RS_LighthouseKeeper"),
        dialogCamera = true
    }
    AP{
        title = "",
        text = "Und so warteten die Helden noch ein paar Stunden...",
        position = {X = 0, Y = 0},
        dialogCamera = true,
        action = function()
            RightSide.ActivateNight()
            ActivateEscBlock()
        end
    }
    AP{
        title = Names.Ixius,
        text = "Und nun lasst das Spektakel beginnen!",
        position = GetPosition("RS_Lighthouse"),
        dialogCamera = false,
        action = function()
            RightSide.StartFireworks()
        end
    }
    AP{
        title = Names.Helias,
        text = "Eigentlich wollten wir nur den Leuchtturm entzünden, nicht abbrennen.",
        position = GetPosition("RS_Lighthouse"),
        dialogCamera = false,
        action = function()
            DeactivateEscBlock()
            SetupNormalWeatherGfxSet()
        end
    }
    AP{
        title = Names.Ixius,
        text = "Ein bisschen Schwund ist immer.",
        position = GetPosition("RS_Lighthouse")
    }
    AP{
        title = Names.Helias,
        text = "Auf in die finale Schlacht!",
        position = GetPosition("Helias"),
        dialogCamera = true
    }

    briefing.finished = function()
        LeftSide.StartEndgame()
        
    end
    StartBriefing(briefing)
end
