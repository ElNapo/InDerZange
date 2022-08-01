LeftSide = {}
LeftSide.ReadyForAttack = false
LeftSide.MercsConvinced = false
LeftSide.TradersConvinded = false
LeftSide.StoneConvinced = false

LeftSide.QUESTID_MAIN = 1
LeftSide.QUESTID_STONE = 2
LeftSide.QUESTID_TRADER = 3
LeftSide.QUESTID_MERC = 4

function LeftSide.DoEnvironmentChanges()
    LeftSide.BridgeId = 77965

    -- prepare positions for military buildings
    LeftSide.PosBarracks = GetPosition("LS_BarracksSpot")
    LeftSide.PosArchery = GetPosition("LS_ArcherySpot")
    DestroyEntity("LS_BarracksSpot")
    DestroyEntity("LS_ArcherySpot")

    -- block the waterfall near stone mason stuff
    Logic.SetModelAndAnimSet(GetEntityId("LS_WaterfallBlocker"), Models.XD_Rock1)

    -- Replace all wall corners with towers
    local allEntitiesFound = false
    local data, pos
    while not allEntitiesFound do
        data = {Logic.GetPlayerEntities( 4, Entities.XD_WallCorner, 16) }
        allEntitiesFound = data[1] == 0
        for j = 2, data[1]+1 do
            pos = GetPosition(data[j])
            DestroyEntity( data[j])
            Logic.CreateEntity( Entities.PB_DarkTower3, pos.X, pos.Y, 0, 4)
        end
    end
end

LeftSide.BanditArmyTroops = {
    {type = Entities.CU_BanditLeaderBow1, nSol = 4},
    {type = Entities.CU_BanditLeaderBow1, nSol = 4},
    {type = Entities.CU_BanditLeaderBow1, nSol = 4},
    {type = Entities.CU_BanditLeaderBow1, nSol = 4},
    {type = Entities.CU_BanditLeaderBow1, nSol = 4},
    {type = Entities.CU_BanditLeaderBow1, nSol = 4},
    {type = Entities.CU_Barbarian_LeaderClub2, nSol = 4},
    {type = Entities.CU_Barbarian_LeaderClub2, nSol = 4}
}

function LeftSide.CreateBandits()
    LeftSide.BanditArmy = UnlimitedArmy:New{
        Player = 3,
        Area = 2000,
        --TransitAttackMove
        Formation = UnlimitedArmy.Formations.Chaotic,
        LeaderFormation = LeaderFormatons.LF_Fight,
        DoNotNormalizeSpeed = true
    }
    local spawnPos = GetPosition("LS_BanditSpawn")
    for k,v in pairs(LeftSide.BanditArmyTroops) do
        LeftSide.BanditArmy:CreateLeaderForArmy( v.type, v.nSol, spawnPos, VERYHIGH_EXPERIENCE)
    end
    LeftSide.BanditArmy:AddCommandMove( GetPosition("LS_BanditGather"), true)
    LeftSide.BanditArmy:AddCommandWaitForIdle( true)
    --if 1 == 1 then return true end
    LeftSide.BanditSpawnManager = UnlimitedArmySpawnGenerator:New( LeftSide.BanditArmy, {
        Position = spawnPos,
        ArmySize = table.getn(LeftSide.BanditArmyTroops),
        SpawnCounter = 5,
        SpawnLeaders = table.getn(LeftSide.BanditArmyTroops),
        LeaderDesc = {
            {LeaderType = Entities.CU_Barbarian_LeaderClub2, SoldierNum = 8, SpawnNum = 20, Experience = VERYHIGH_EXPERIENCE},
            {LeaderType = Entities.CU_BanditLeaderBow1, SoldierNum = 4, SpawnNum = 60, Experience = VERYHIGH_EXPERIENCE}
        },
        Generator = "LS_BanditTower",
        RandomizeSpawn = true
    })
end

function LeftSide.StartInitialBriefing()
    local briefing = {}
    local AP, ASP = AddPages(briefing);
    AP{
        title = Names.Erec,
        text = "Ich muss sagen, ich habe diese Expeditionen schon ziemlich vermisst. Ist es nicht schön, endlich mal wieder"..
            " außerhalb der Mauern der königlichen Hauptstadt zu sein?",
        position = GetPosition("Erec"),
        dialogCamera = true,
        action = function()
            ActivateEscBlock()
            Move("Erec", "LS_InitialErecMove")
            Move("Pilgrim", "LS_InitialPilgrimMove")
            Camera.FollowEntity(GetEntityId("Erec"))
        end
    }
    AP{
        title = Names.Pilgrim,
        text = "Lass .. mich .. kurz .. Luft .. holen. @cr @cr @cr Nö. ",
        position = GetPosition("Pilgrim"),
        dialogCamera = true,
        action = function()
            Camera.FollowEntity(GetEntityId("Pilgrim"))
            LookAt("Pilgrim", "Erec")
            LookAt("Erec", "Pilgrim")
            DeactivateEscBlock()
        end
    }
    AP{
        title = Names.Erec,
        text = "Du hättest nicht nur auf der faulen Haut liegen sollen. @cr "
            .."Wie dem auch sei, laut der "..Names.AgentMessage.." sollte unser Ansprechpartner nicht mehr weit sein.",
        position = GetPosition("LS_InitialErecMove"),
        dialogCamera = true
    }
    AP{
        title = Names.AgentMessage,
        text = "Meine Herren, @cr sobald Sie die Felder von "..Names.City.." erreichen, nehmen Sie die nächste Möglichkeit "..
            "links. Sie sollten einen Dorfplatz vorfinden. Unser Kontakt wird Sie vor der Kapelle erwarten. @cr "..
            "Wir verbleiben mit freundlichen Grüßen @cr "..Names.SpyOrga,
        position = GetPosition("LS_InitialErecMove"),
        dialogCamera = true
    }
    briefing.finished = function()
        quest = {
            id = LeftSide.QUESTID_MAIN,
            type = MAINQUEST_OPEN,
            title = "Trefft den Agenten!",
            text = Names.Erec.." und "..Names.Pilgrim.." haben ihn Ziel fast erreicht. Besprecht mit dem "..Names.AgentDativ.." die nächsten Schritte!"
        }
        Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.text, 1) 
        CreateNPC{
            name = "LS_FarmerMajor",
            callback = LeftSide.StartFarmerBriefing
        }
        local posFarmer = GetPosition("LS_FarmerMajor")
        GUI.CreateMinimapMarker( posFarmer.X, posFarmer.Y, 1) 
    end
    StartBriefing( briefing)
end
function LeftSide.StartFarmerBriefing()
    local briefing = {}
    local AP, ASP = AddPages(briefing);
    local posFarmer = GetPosition("LS_FarmerMajor")
    GUI.DestroyMinimapPulse( posFarmer.X, posFarmer.Y)
    LookAt("Erec", "LS_FarmerMajor")
    LookAt("Pilgrim", "LS_FarmerMajor")

    ASP("Erec", Names.Erec, "Guten Tag, @cr wir suchen einen gewissen "..Names.FakeSpyName..", sagt Ihnen der Name was?", true)
    ASP("LS_FarmerMajor", Names.FakeSpyName, "Ihr habt euch Zeit gelassen...", true)
    ASP("Pilgrim", Names.Erec, "Es gab einen Faktor, der uns etwas verlangsamt hat.", true)
    ASP("LS_FarmerMajor", Names.FakeSpyName, "Das ist nun auch egal. Während Ihr die Landschaft genossen habt, "
        .."haben wir die Gegend erkundet und einen ausgezeichneten Platz für eine Basis gefunden.", true)
    AP{
        title = Names.FakeSpyName,
        text = "Praktisch direkt hinter diesem Wald befindet sich ein nettes, abgelegenes Plätzchen. Es gibt nur einen "
            .."kleinen Nachteil: Eure Ressourcen sind begrenzt und Eisen und Schwefel müsst Ihr garnicht erst suchen gehen.",
        position = GetPosition("LS_HQ"),
        dialogCamera = false,
        explore = 10
    }
    ASP("Erec", Names.Erec, "Das klingt nicht so nett. Ich mag Eisen.", true)
    AP{
        title = Names.FakeSpyName,
        text = "Ihr habt "..Names.Yuki.." und "..Names.Helias..", die Euch bald mit den Rohmaterialien versorgen werden. "
            .."Davon abgesehen ist Euer Fokus ein Anderer: Überzeugt die umliegenden Siedlungen, gegen "..Names.City.." aufzubegehren.",
        position = GetPosition("LS_FarmerMajor"),
        dialogCamera = true
    }
    ASP("Erec", Names.Erec, "Und Ihr habt auch dafür schon etwas vorbereitet?", true)
    ASP("LS_FarmerMajor", Names.FakeSpyName, "Natürlich.", true)
    AP{
        title = Names.FakeSpyName,
        text = "Es gibt hier vier Siedlungen, im Idealfall wollt Ihr jede einzelne überzeugen. Wir vermuten aber, dass "
            .."selbst mit zwei überzeugten Siedlungen genug Druck im Zangenmanöver aufgebaut werden kann, um siegreich zu sein.",
        position = GetPosition("LS_FarmerMajor"),
        dialogCamera = true
    }
    ASP("LS_FarmerMajor", Names.FakeSpyName, "Die Erste habt Ihr schon gefunden. Nach dem Putsch durch "..Names.BadGuy.." hat dieses kleine "
        .."Bauerndorf hier keinerlei Vertretung in der Stadtpolitik und wird mit Füßen getreten. Ein kleiner "
        .."@color:251,139,35 Funke @color:255,255,255 wird genügen, um einen Aufstand zu starten. Sobald Eure Offensive beginnt, werden sich die Bauern anschließen.",
        false
    )
    AP{
        title = Names.FakeSpyName,
        text = "Ziel Nummer zwo ist leider schwieriger. @cr Auf der anderen Seite des Sees fördert "..Names.City.." wertvolle Ressourcen. "
            .."Auch die lokalen Arbeiter sind nicht erfreut über die Tyrannei des "..Names.BadGuyGenetiv.." und werden sich "
            .."Euch flott, wenn auch nicht sofort anschließend.",
        position = GetPosition("LS_StoneMasonMajor"),
        dialogCamera = false,
        action = function()
            local pos = GetPosition("LS_StoneMasonMajor")
            LeftSide.ViewCenterStone = Logic.CreateEntity(Entities.XD_ScriptEntity, pos.X+1, pos.Y, 0, 2)
            Logic.SetEntityExplorationRange(LeftSide.ViewCenterStone, 10)
        end
    }
    ASP("LS_StoneMasonMajor", Names.FakeSpyName, "Der einzige Landweg führt aber direkt durch "..Names.City..". Ihr "
    .."werdet wohl schwimmen lernen müssen. @cr Auch dürft Ihr auf keinen Fall von den Patrouillen gesehen werden!", false)

    AP{
        title = Names.FakeSpyName,
        text = "Die dritte Siedlung ist ein Außenposten der Händlergilde, die vor dem Putsch zu den Reichesten des Landes gehörte. "
            .."Doch diese Zeiten sind leider vorbei.",
        position = GetPosition("LS_TraderMajor"),
        action = function()
            local pos = GetPosition("LS_TraderMajor")
            LeftSide.ViewCenterTrader = Logic.CreateEntity(Entities.XD_ScriptEntity, pos.X+1, pos.Y, 0, 2)
            Logic.SetEntityExplorationRange(LeftSide.ViewCenterTrader, 10)
        end
    }
    AP{
        title = Names.FakeSpyName,
        text = "Seit einiger Zeit haben sich Banditen in der Gegend niedergelassen, allerdings greifen sie nur "
        .."die Karawanen der Händler an, nicht aber die Reisenden des Grafen. Die Einheimischen meinen, dass die "
        .."Situation hat ein Gschmäckle hat.",
        position = GetPosition("LS_BanditTower"),
        action = function()
            local pos = GetPosition("LS_BanditTower")
            LeftSide.ViewCenterBandit = Logic.CreateEntity(Entities.XD_ScriptEntity, pos.X+1, pos.Y, 0, 2)
            Logic.SetEntityExplorationRange(LeftSide.ViewCenterBandit, 10)
        end
    }
    AP{
        title = Names.FakeSpyName,
        text = "Die letzte Siedlung wird von einer Söldnergruppe bewohnt. Solange die Belohnung stimmt, werden sie "
        .."sich Euch definitiv anschließen.",
        position = GetPosition("LS_MercMajor"),
        action = function()
            local pos = GetPosition("LS_MercMajor")
            LeftSide.ViewCenterMerc = Logic.CreateEntity(Entities.XD_ScriptEntity, pos.X+1, pos.Y, 0, 2)
            Logic.SetEntityExplorationRange(LeftSide.ViewCenterMerc, 10)
        end
    }
    ASP("LS_FarmerMajor", Names.FakeSpyName, "und ganz wichtig: @cr IHR DÜRFT AUF KEINEN FALL DIE TRUPPEN DES GRAFEN AUF EUCH AUFMERKSAM MACHEN! @cr "
    .."Falls Ihr noch Fragen habt, könnt Ihr sie gerne jetzt stellen.", true)
    ASP("Erec", Names.Erec, "Habt Ihr diese Informationen auch irgendwo aufgeschrieben? Ich würde ungern etwas vergessen.", true)
    ASP("LS_FarmerMajor", Names.FakeSpyName, "Natürlich, schaut einfach in Euer Auftragsbuch. @cr @cr Ich wünsche Euch noch viel Erfolg.", true)

    briefing.finished  = function()
        DestroyEntity(LeftSide.ViewCenterStone)
        DestroyEntity(LeftSide.ViewCenterTrader)
        DestroyEntity(LeftSide.ViewCenterBandit)
        DestroyEntity(LeftSide.ViewCenterMerc)

        local posInfrontHQ = GetPosition("LS_PosInfrontHQ")
        LeftSide.PointerEffectId = Logic.CreateEffect( GGL_Effects.FXTerrainPointer, posInfrontHQ.X, posInfrontHQ.Y, 1)

        SetupExpedition{
            Heroes = true,
            TargetName = "LS_PosInfrontHQ",
            Distance = 500,
            Callback = LeftSide.OnArrivalAtHQ
        }
        MoveAndVanish( "LS_FarmerMajor", "LS_PosInfrontHQ")
        GUI.CreateMinimapMarker( posInfrontHQ.X, posInfrontHQ.Y, 0)

        local quest = {
            id = LeftSide.QUESTID_MAIN,
            type = MAINQUEST_OPEN,
            title = "Gründet eine Siedlung!",
            text = Names.Erec..Names.MissionComplete.." und "..Names.Pilgrim..Names.MissionComplete.." haben ihn Ziel fast erreicht. Besprecht mit dem "
            ..Names.AgentDativ..Names.MissionComplete.." die nächsten Schritte! @cr @cr @color:255,255,255 "
            .."Sucht die vom "..Names.AgentDativ.." beschriebene Position auf und gründet eine Siedlung!"
        }
        Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.text, 1) 

        quest = {
            id = LeftSide.QUESTID_STONE,
            type = SUBQUEST_OPEN,
            title = "Überzeugt die Arbeitersiedlung!",
            text = "Auf der anderen Seite des Sees liegt eine Siedlung, die für "..Names.City.." wichtige Rohstoffe "
                .."fördert. Sprecht mit den Arbeitern und versucht, sie auf eure Seite zu ziehen!"
        }
        Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.text, 0) 

        quest = {
            id = LeftSide.QUESTID_TRADER,
            type = SUBQUEST_OPEN,
            title = "Überzeugt die Händlergilde!",
            text = "Sprecht mit den Händlern und versucht, sie auf eure Seite zu ziehen!"
        }
        Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.text, 0) 

        quest = {
            id = LeftSide.QUESTID_MERC,
            type = SUBQUEST_OPEN,
            title = "Überzeugt die Söldner!",
            text = "Sprecht mit den Söldnern und versucht, sie auf eure Seite zu ziehen!"
        }
        Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.text, 0) 

    end
    StartBriefing( briefing)
end

function LeftSide.OnArrivalAtHQ()
    Logic.DestroyEffect(LeftSide.PointerEffectId)
    local posInfrontHQ = GetPosition("LS_PosInfrontHQ")
    GUI.DestroyMinimapPulse(posInfrontHQ.X, posInfrontHQ.Y)

    local quest = {
        id = LeftSide.QUESTID_MAIN,
        type = MAINQUEST_OPEN,
        title = "Gründet eine Siedlung!",
        text = Names.Erec..Names.MissionComplete.." und "..Names.Pilgrim..Names.MissionComplete.." haben ihn Ziel fast erreicht. Besprecht mit dem "
        ..Names.AgentDativ..Names.MissionComplete.." die nächsten Schritte! @cr @cr "
        .."Sucht die vom "..Names.AgentDativ..Names.MissionComplete.." beschriebene Position auf und gründet eine Siedlung! @cr @cr @color:255,255,255 "
        .."Die Bauernsiedlung wird sich Eurem Ansturm anschließen. Sprecht mit den übrigen Dorfvorstehern und zieht mindestens zwei "
        .."weitere Siedlungen auf Eure Seite. @color:255,0,0 Ihr dürft auf keinen Fall entdeckt werden!"
    }
    Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.text, 1) 
    ChangePlayer("LS_HQ", 2)
    ChangePlayer("LS_VC", 2)

    Sound.PlayGUISound( Sounds.fanfare, 100)
    Message(Names.Erec.." und "..Names.Pilgrim.." haben die Burg bezogen!")

    CreateNPC{
        name = "LS_MercMajor",
        callback = LeftSide.MercBriefing1
    }
    CreateNPC{
        name = "LS_TraderMajor",
        callback = LeftSide.TraderBriefing1
    }
    CreateNPC{
        name = "LS_StoneMasonMajor",
        callback = LeftSide.StoneBriefing1
    }
    AddGold(2, 1000)
    AddWood(2, 1250)
    AddClay(2, 1500)
    AddStone(2, 1000)
    AddIron(2, 300)
    AddSulfur(2, 300)
    LeftSide.CreateOnAttackDefeatCondition()

    CreateSendCaravanTribute(2, "Wood");
    CreateSendCaravanTribute(2, "Clay");
    CreateSendCaravanTribute(2, "Stone");
    CreateSendCaravanTribute(2, "Sulfur");
    CreateSendCaravanTribute(2, "Iron");
end

function LeftSide.CreateOnAttackDefeatCondition()
    LeftSide.DefeatOnHitTrigger = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "LeftSide_OnHitDefeatTrigger", 1)
end
function LeftSide_OnHitDefeatTrigger()
    local attacker = Event.GetEntityID1()
    local defender = Event.GetEntityID2()
    -- if either entity is dead => dont bother
    if IsDead(attacker) or IsDead(defender) then return end
    -- if player ids have some mismatch => dont bother
    if GetPlayer(attacker) ~= 4 or GetPlayer(defender) ~= 2 then return end

    if Logic.IsSettler(attacker) == 1 then
        LeftSide.DefeatByDiscovery()
        return true
    end
end
function LeftSide.DefeatByDiscovery()
    Logic.SuspendAllEntities()
    GUI.AddStaticNote("Ihr wurdet von den Truppen des Grafen entdeckt!")
    GUI.AddStaticNote("Ihr habt verloren!")
    Sound.PlayGUISound( Sounds.VoicesMentor_VC_YouHaveLost_rnd_01)
    Defeat()
    XGUIEng.ShowWidget("GameEndScreen", 0)
end

-- Stuff related to the mercenary quest line
function LeftSide.MercBriefing1()
    PlaceHeroesInfrontOfNPC( "LS_MercMajor", "Erec", "Pilgrim")
    local briefing = {}
    local AP, ASP = AddPages(briefing);

    ASP("LS_MercMajor", Names.MercLeader, "Guten Tag der Herr, was verschlägt Euch in diese entlegene Gegend?", true)
    ASP("Erec", Names.Erec, "Seid gegrüßt! @cr Man sagt, dass Ihr kampferfahrene Männer habt, die sich für das entsprechende Geld gerne "
        .."in die Schlacht stürzen. Ist das richtig?", true)
    ASP("LS_MercMajor", Names.MercLeader, "Das ist in der Tat korrekt, aber ich muss Euch warnen: Der Preis hängt von dem Gegner ab. Was schwebt Euch vor?", true)
    ASP("Erec", Names.Erec, "Seht Ihr die Stadt in meinem Rücken? Ich hätte gerne Eure Unterstützung um den "..Names.BadGuyGenetiv.." aus seiner Burg zu holen. Ihr werdet auch nicht alleine kämpfen.", true)
    ASP("LS_MercMajor", Names.MercLeader, "Ha, Ihr gefallt mir! Ich mache Euch einen Freundschaftspreis von "..Colors.Gold.." 25 000 Gold! @color:255,255,255", true)
    ASP("Pilgrim", Names.Pilgrim, "Das ist zu teuer.", true)
    ASP("LS_MercMajor", Names.MercLeader, Colors.Gold.." 25 000 Gold. @color:255,255,255 Wir kennen unseren Wert und verhandeln grundsätzlich nicht.", true)
    ASP("Erec", Names.Erec, "Na gut, Ihr werdet die Summe zügig erhalten. Schlagt los, wenn der alte Leuchtturm leuchtet.", true)
    ASP("LS_MercMajor", Names.MercLeader, "Wir nehmen nur Vorkasse, aber gerne, sobald Ihr uns bezahlt habt, werden wir auf Euer Signal loslegen.", true)
    briefing.finished = function() 
        LeftSide.MercTributeId = AddTribute{
            playerId = 2,
            text = "Zahlt "..Colors.Gold.." 25 000 Gold @color:255,255,255 , um die Söldner auf Eure Seite zu ziehen!",
            cost = {Gold = 100},
            Callback = LeftSide.OnMercTributePaid
        }
        quest = {
            id = LeftSide.QUESTID_MERC,
            type = SUBQUEST_OPEN,
            title = "Überzeugt die Söldner!",
            text = Names.MissionComplete.."Sprecht mit den Söldnern und versucht, sie auf eure Seite zu ziehen!"
                .." @color:255,255,255 @cr Bezahlt den "..Names.Mercs.." "..Colors.Gold.." 25 000 Gold @color:255,255,255 "
                .."um sie von Eurer Sache zu überzeugen."
        }
        Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.text, 1) 

    end
    StartBriefing(briefing)
end
function LeftSide.OnMercTributePaid()
    Sound.PlayGUISound( Sounds.fanfare, 100)
    Message("Die "..Names.Mercs.." schließen sich euch an!")
    quest = {
        id = LeftSide.QUESTID_MERC,
        type = SUBQUEST_CLOSED,
        title = "Überzeugt die Söldner!",
        text = Names.MissionComplete.."Sprecht mit den Söldnern und versucht, sie auf eure Seite zu ziehen!"
            .." @cr Bezahlt den "..Names.Mercs.." "..Colors.Gold.." 25 000 Gold "..Names.MissionComplete
            .."um sie von Eurer Sache zu überzeugen. @color:255,255,255 @cr "
            .."Glückwunsch, die Söldner haben sich Euch angeschlossen."
    }
    Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.text, 1) 
    Logic.SetShareExplorationWithPlayerFlag( 1, 7, 1)
    Logic.SetShareExplorationWithPlayerFlag( 2, 7, 1)
    SetFriendly(1,7)
    SetFriendly(2,7)
    LeftSide.MercsConvinced = true
    LeftSide.MercTributeId = nil;
    LeftSide.OnSideConvinced()
end

-- Stuff related to the trader quest line
function LeftSide.TraderBriefing1()
    PlaceHeroesInfrontOfNPC( "LS_TraderMajor", "Erec", "Pilgrim")
    local briefing = {}
    local AP, ASP = AddPages(briefing);

    ASP("LS_TraderMajor", Names.TraderLeader, "Ah, Kundschaft! Seid gegrüßt! Wie war die Reise? Keine Zwischenfälle?", true)
    ASP("Erec", Names.Erec, "Guten Tag! @cr Ich muss Euch leider enttäuschen, wir sind nicht hier, um Geschäfte zu machen.", true)
    ASP("Pilgrim", Names.Pilgrim, "Eigentlich schon, doch.", true)
    ASP("Erec", Names.Erec, "Ich muss mich wohl korrigieren: @cr Wir handeln keine Güter, wir suchen Verbündete. "
        .."Mir wurde zugetragen, dass Ihr unzufrieden mit dem "..Names.BadGuyGenetiv.." seid? Wir könnten da Abhilfe schaffen.", true)
    ASP("LS_TraderMajor", Names.TraderLeader, "Tut mir leid, ich kann Euch nicht helfen. Seit die "..Names.Bandits.." Ihr Lager aufgeschlagen haben, "
        .."haben wir keinerlei Einkommen mehr. Und der Graf wird sich auch nicht um dieses Problem kümmern.", true)
    ASP("Erec", Names.Erec, "Und was wäre, wenn wir uns darum kümmern? Wir machen die "..Names.Bandits.." unschädlich "
        .."und Ihr untersützt uns nach Euren Mitteln?", true)
    ASP("LS_TraderMajor", Names.TraderLeader, "Also wollt irh doch Geschäfte machen! Das das klingt fair, ja. Mit einem Einkommen können wir sicher ein paar Söldner für Eure Sache organisieren. "
        .."Ich habe noch ein paar Freunde aus meinen jungen Jahren.", true)
    ASP("Pilgrim", Names.Pilgim, "Sag ich doch!", true)
    briefing.finished = function()
        local quest = {
            id = LeftSide.QUESTID_TRADER,
            type = SUBQUEST_OPEN,
            title = "Überzeugt die Händlergilde!",
            text = Names.MissionComplete.."Sprecht mit den Händlern und versucht, sie auf eure Seite zu ziehen!"
            .." @cr @color:255,255,255 Macht die "..Names.Bandits.."unschädlich, um die Händlergilde zu Euren Verbündeten zählen zu können!"
        }
        Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.text, 0) 
        LeftSide.AreBanditsEliminatedJobId = StartSimpleJob("LeftSide_AreBanditsEliminated")
    end
    StartBriefing( briefing)
end
function LeftSide_AreBanditsEliminated()
    if IsDead(LeftSide.BridgeId) or IsDead("LS_BanditTower") then
        LeftSide.OnBanditsEliminated()
        return true
    end
end
function LeftSide.OnBanditsEliminated()
    Message("Glückwunsch, "..Names.Erec.." und "..Names.Pilgrim.." haben die "..Names.Bandits.." besiegt!")
    Sound.PlayGUISound( Sounds.VoicesMentor_COMMENT_GoodPlay_rnd_03, 100)
    LeftSide.TradersConvinded = true
    LeftSide.OnSideConvinced()
    local quest = {
        id = LeftSide.QUESTID_TRADER,
        type = SUBQUEST_CLOSED,
        title = "Überzeugt die Händlergilde!",
        text = Names.MissionComplete.."Sprecht mit den Händlern und versucht, sie auf eure Seite zu ziehen!"
        .." @cr Macht die "..Names.Bandits..Names.MissionComplete.." unschädlich, um die Händlergilde zu Euren Verbündeten zählen zu können! "
        .." @cr @color:255,255,255 Glückwunsch, die Händlergilde ist auf Eurer Seite!"
    }
    Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.text, 1) 
    Logic.SetShareExplorationWithPlayerFlag( 1, 6, 1)
    Logic.SetShareExplorationWithPlayerFlag( 2, 6, 1)
    SetFriendly(1,6)
    SetFriendly(2,6)
end

-- Stuff related to the workers quest line
function LeftSide.StoneBriefing1()
    PlaceHeroesInfrontOfNPC( "LS_StoneMasonMajor", "Erec", "Pilgrim")
    local briefing = {}
    local AP, ASP = AddPages(briefing);

    ASP("Erec", Names.Erec, "Guten Tag, seid Ihr der Ortsvorsteher hier?", true)
    ASP("LS_StoneMasonMajor", Names.StoneLeader, Names.Erec..", "..Names.Pilgrim..", wie schön, euch zu sehen! "
    .."Dieser neue Herrscher ist schrecklich! Wir schuften uns in den Minen ab und was kriegen wir? Nichts!", true)
    ASP("Pilgrim", Names.Pilgrim, "Deswegen sind wir hier. Wir geben ihm aufs Maul!", true)
    ASP("Erec", Names.Erec, "Also eigentlich suchen wir gerade Verbündete und wollen ihm dann *aufs Maul geben*.", true)
    ASP("LS_StoneMasonMajor", Names.StoneLeader, "Ich würde Euch gerne helfen, aber meine Leute sind keine Krieger. Wir können zwar die Waffen "
    .."produzieren, aber nur wenige haben Kampferfahrung.", true)
    ASP("Erec", Names.Erec, "Wer mit einer Spitzhacke Gestein kaputt schlägt, kann mit etwas Training auch mit einem Schwert Despoten erschlagen. "
    .."Und an Schwertern sollte es Euch hier nicht mangeln.", true)
    ASP("LS_StoneMasonMajor", Names.StoneLeader, "Das ist es ja gerade: Meine Leute haben genug, aber sie wissen, dass sie ohne "
    .."eine entsprechende Ausbildung keine Chance haben.", true)
    ASP("Pilgrim", Names.Pilgrim, "Was ist, wenn wir Euch ausbilden? Die Muskeln bringt ihr mit.", true)
    ASP("LS_StoneMasonMajor", Names.StoneLeader, "Das kann ich meinen Kumpeln vermitteln, ja.", true)
    AP{
        title = Names.StoneLeader,
        text = "Baut hier eine Garnison und eine Schießanlage und lasst ein paar Eurer Ausbilder da. Das "
        .."sollte ausreichen, um meine Gruppe schnell auf ein anständiges Niveau zu bringen und Euch unterstützen zu können.",
        position = LeftSide.PosBarracks,
        dialogCamera = false,
        action = function()
            LeftSide.BuildBarrackPointer = Logic.CreateEffect(GGL_Effects.FXTerrainPointer, LeftSide.PosBarracks.X, LeftSide.PosBarracks.Y, 1)
            LeftSide.BuildArcheryPointer = Logic.CreateEffect(GGL_Effects.FXTerrainPointer, LeftSide.PosArchery.X, LeftSide.PosArchery.Y, 1)
        end
    }
    ASP("Erec", Names.Pilgrim, "Wird gemacht.", true)
    briefing.finished = function()
        SetEntityName( Logic.CreateEntity(Entities.XD_ScriptEntity, LeftSide.PosBarracks.X, LeftSide.PosBarracks.Y, 0, 1), "LS_BarrackPos")
        SetupEstablish{
            AreaPos = "LS_BarrackPos",
            AreaSize = 2500,
            EntityTypes = {
                {Entities.PB_Barracks2, 1}
            },
            Callback = LeftSide.OnBarracksFinished
        }
        SetEntityName( Logic.CreateEntity(Entities.XD_ScriptEntity, LeftSide.PosArchery.X, LeftSide.PosArchery.Y, 0, 1), "LS_ArcheryPos")
        SetupEstablish{
            AreaPos = "LS_ArcheryPos",
            AreaSize = 2500,
            EntityTypes = {
                {Entities.PB_Archery2, 1}
            },
            Callback = LeftSide.OnArcheryFinished
        }
        local quest = {
            id = LeftSide.QUESTID_STONE,
            type = SUBQUEST_OPEN,
            title = "Überzeugt die Arbeitersiedlung!",
            text = Names.MissionComplete.."Auf der anderen Seite des Sees liegt eine Siedlung, die für "..Names.City..Names.MissionComplete.." wichtige Rohstoffe "
                .."fördert. Sprecht mit den Arbeitern und versucht, sie auf eure Seite zu ziehen!"
                .." @cr @color:255,255,255 Baut an die markierten Stellen eine Garnison und eine Schießanlage, damit die Arbeiter für den Kampf trainieren können!"
        }
        Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.text, 0) 
    end
    StartBriefing(briefing)
end

function LeftSide.OnBarracksFinished()
    if LeftSide.EndgameStarted then return end;
    LeftSide.BarracksBuilt = true
    if LeftSide.ArcheryBuilt then
        LeftSide.OnBuildingQuestCompleted()
    end
    local data = {Logic.GetEntitiesInArea( Entities.PB_Barracks2, LeftSide.PosBarracks.X, LeftSide.PosBarracks.Y, 4000, 1)}
    if data[1] == 0 then
        Message("Err: Barracks not found!")
        return true
    end
    ChangePlayer( data[2], 5)
    Logic.DestroyEffect(LeftSide.BuildBarrackPointer)
    LeftSide.BuildBarrackPointer = nil;
    Sound.PlayGUISound(Sounds.VoicesMentor_COMMENT_GoodPlay_rnd_03, 100)
end
function LeftSide.OnArcheryFinished()
    if LeftSide.EndgameStarted then return end;
    LeftSide.ArcheryBuilt = true
    if LeftSide.BarracksBuilt then
        LeftSide.OnBuildingQuestCompleted()
    end
    local data = {Logic.GetEntitiesInArea( Entities.PB_Archery2, LeftSide.PosArchery.X, LeftSide.PosArchery.Y, 4000, 1)}
    if data[1] == 0 then
        Message("Err: Archery not found!")
        return true
    end
    ChangePlayer( data[2], 5)
    Logic.DestroyEffect(LeftSide.BuildArcheryPointer)
    LeftSide.BuildArcheryPointer = nil;
    Sound.PlayGUISound(Sounds.VoicesMentor_COMMENT_GoodPlay_rnd_03, 100)
end
function LeftSide.OnBuildingQuestCompleted() 
    local quest = {
        id = LeftSide.QUESTID_STONE,
        type = SUBQUEST_CLOSED,
        title = "Überzeugt die Arbeitersiedlung!",
        text = Names.MissionComplete.."Auf der anderen Seite des Sees liegt eine Siedlung, die für "..Names.City..Names.MissionComplete.." wichtige Rohstoffe "
            .."fördert. Sprecht mit den Arbeitern und versucht, sie auf eure Seite zu ziehen!"
            .." @cr Baut an die markierten Stellen eine Garnison und eine Schießanlage, damit die Arbeiter für den Kampf trainieren können! "
            .." @cr @color:255,255,255 Glückwunsch, die Arbeiter trainieren nun für den Kampf und stehen Euch zur Seite!"
    }
    Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.text, 1) 
    LeftSide.StoneConvinced = true
    Message("Gratulation, die Arbeitersiedlung steht Eurer Sache bei!")
    LeftSide.OnSideConvinced()

    local buildingTypes = {
        Entities.CB_Abbey03,
        Entities.CB_MinerCamp1,
        Entities.CB_MinerCamp3,
        Entities.CB_MinerCamp5,
        Entities.CB_MinerCamp6,
        Entities.PB_Beautification07,
        Entities.PB_Beautification08,
        Entities.PB_Beautification09,
        Entities.PB_Beautification12,
        Entities.PB_Farm2,
        Entities.PB_Farm3,
        Entities.PB_IronMine3,
        Entities.PB_Residence3,
        Entities.PB_StoneMason2,
        Entities.StoneMine3
    }
    local isInSettlement = function( _pos)
        return  _pos.X > 30000 and _pos.Y > 9000 and _pos.Y < 24000
    end
    local data, pos, pId
    for k, etype in buildingTypes do
        data = {Logic.GetEntitiesInArea( etype, 34800, 15400, 7500, 16)}
        for j = 2, data[1]+1 do
            pos = GetPosition(data[j])
            pId = GetPlayer(data[j])
            if pId == 4 then
                if isInSettlement(pos) then
                    ChangePlayer( data[j], 5)
                end
            end
        end
    end
end

-- Call this everytime one village was convinced
function LeftSide.OnSideConvinced()
    local count = 0
    if LeftSide.MercsConvinced then
        count = count + 1
    end
    if LeftSide.TradersConvinded then
        count = count + 1
    end
    if LeftSide.StoneConvinced then
        count = count + 1
    end
    if count >= 2  and not LeftSide.ReadyForAttack then
        LeftSide.ReadyForAttack = true
        Message("Ihr habt genug Verbündete für einen Angriff mobilisiert!")
        Sound.PlayGUISound( Sounds.fanfare)
        local quest = {
            id = LeftSide.QUESTID_MAIN,
            type = MAINQUEST_OPEN,
            title = "Wartet auf das Signal!",
            text = Names.Erec..Names.MissionComplete.." und "..Names.Pilgrim..Names.MissionComplete.." haben ihn Ziel fast erreicht. Besprecht mit dem "
            ..Names.AgentDativ..Names.MissionComplete.." die nächsten Schritte! @cr @cr "
            .."Sucht die vom "..Names.AgentDativ..Names.MissionComplete.." beschriebene Position auf und gründet eine Siedlung! @cr @cr  "
            .."Die Bauernsiedlung wird sich Eurem Ansturm anschließen. Sprecht mit den übrigen Dorfvorstehern und zieht mindestens zwei "
            .."weitere Siedlungen auf Eure Seite. @color:255,0,0 Ihr dürft auf keinen Fall entdeckt werden! @cr "
            .."@color:255,255,255 Ihr habt genüg Verbündete gefunden. Bleibt unentdeckt und wartet auf das Signal."
        }
        Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.text, 1) 
    end
end

function LeftSide.DEBUG_LogLeaderSpawnPos()
    Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "LeftSide_DEBUG_OnEntityCreated",1)
    LeftSide_DEBUG_OnEntityCreated = function()
        local eId = Event.GetEntityID()
        if GetPlayer(eId) ~= 1 then return end
        if Logic.IsLeader(eId) == 1 then
            local pos = GetPosition(eId)
            LuaDebugger.Log(Logic.GetEntityTypeName(Logic.GetEntityType(eId))..' '..eId.." created, pos:")
            LuaDebugger.Log(pos)
            local barrack1Data = {Logic.GetEntitiesInArea( Entities.PB_Barracks1, pos.X, pos.Y, 1000, 1) }
            local barrackId = 0
            if barrack1Data[1] == 0 then
                local barrack2Data = {Logic.GetEntitiesInArea( Entities.PB_Barracks2, pos.X, pos.Y, 1000, 1) }
                if barrack2Data[1] == 1 then
                    barrackId = barrack2Data[2]
                end
            else
                barrackId = barrack1Data[2]
            end
            -- barrack (most likely) found
            if barrackId == 0 then
                LuaDebugger.Log("No barrack found ):")
            else
                LuaDebugger.Log("Found barrack "..barrackId)
                LuaDebugger.Log(GetPosition(barrackId))
                LuaDebugger.Log("Orient: "..Logic.GetEntityOrientation(barrackId))
                LuaDebugger.Log()
            end
        end
    end
end

-- Prepare stuff for handling the big city armies
LeftSide.DefenderArmyConstitution = {
    {type = Entities.PU_LeaderBow4, nSol = 8},
    {type = Entities.PU_LeaderBow4, nSol = 8},
    {type = Entities.PU_LeaderBow4, nSol = 8},
    {type = Entities.PU_LeaderRifle1, nSol = 4},
    {type = Entities.PU_LeaderRifle1, nSol = 4},
    {type = Entities.PU_LeaderSword4, nSol = 8},
    {type = Entities.PU_LeaderSword4, nSol = 8},
    {type = Entities.PU_LeaderPoleArm4, nSol = 8},
    {type = Entities.PU_LeaderHeavyCavalry2, nSol = 3},
    {type = Entities.PU_LeaderHeavyCavalry2, nSol = 3},
    {type = Entities.PV_Cannon3, nSol = 0},
    {type = Entities.PV_Cannon4, nSol = 0}
}
function LeftSide.CreateBigCityArmies()
    Logic.CreateEntity(Entities.PB_VillageCenter3, 13900, 23000, 0, 4)
    local recrutingBuildings = {
        Entities.PB_Stable2,
        Entities.PB_Archery1,
        Entities.PB_Archery2,
        Entities.PB_Barracks1,
        Entities.PB_Barracks2,
        Entities.PB_Foundry2
    }
    LeftSide.CityRecruitingBuildings = {    }
    local data
    for k, eType in pairs(recrutingBuildings) do
        data = {Logic.GetPlayerEntities( 4, eType, 10) }
        for j = 2, data[1]+1 do
            table.insert(LeftSide.CityRecruitingBuildings, data[j])
        end
    end
    LeftSide.CityDefenders = {}
    LeftSide.CityRecruiterManagers = {}
    for j = 1, 3 do
        LeftSide.CityDefenders[j] = UnlimitedArmy:New{
            Player = 4,
            Area = 3000,
            --TransitAttackMove
            Formation = UnlimitedArmy.Formations.Lines,
            LeaderFormation = LeaderFormatons.LF_Fight,
            DoNotNormalizeSpeed = true
        }
        LeftSide.CityDefenders[j]:AddCommandMove( GetPosition("LS_CityGather"..j))
        LeftSide.CityRecruiterManagers[j] = UnlimitedArmyRecruiter:New(LeftSide.CityDefenders[j], {
            Buildings = LeftSide.CityRecruitingBuildings,
            ArmySize = table.getn(LeftSide.DefenderArmyConstitution),
            UCats = {
                {UCat = UpgradeCategories.LeaderSword, SpawnNum = 5, Looped = true},
                {UCat = UpgradeCategories.LeaderPoleArm, SpawnNum = 5, Looped = true},
                {UCat = UpgradeCategories.LeaderBow, SpawnNum = 5, Looped = true},
                {UCat = UpgradeCategories.LeaderRifle, SpawnNum = 5, Looped = true},
                {UCat = UpgradeCategories.LeaderHeavyCavalry, SpawnNum = 5, Looped = true},
                {UCat = UpgradeCategories.Cannon3, SpawnNum = 5, Looped = true},
                {UCat = UpgradeCategories.Cannon4, SpawnNum = 5, Looped = true}
            },
            ResCheat = true,
            RandomizeSpawn = true,
            ReorderAllowed = true
        })
    end
    StartSimpleJob("LeftSide_ManageCityDefenders")
    Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "LeftSide_IsID4Leader", "LeftSide_OnCityLeaderCreated", 1)
    StartSimpleJob("LeftSide_BabysitterJob")
    LeftSide.BigCityNewLeaders = {}
end
-- babysitter for the unlimited army recruter
function LeftSide_IsID4Leader()
    local eId = Event.GetEntityID()
    return Logic.IsLeader(eId) == 1 and GetPlayer(eId) == 4 
end
function LeftSide.IsArmyAndRecruiterSufficient( _recruiter)
    local supposedNum = _recruiter.ArmySize
    local actualNum = _recruiter.Army:GetSize( true, true) + table.getn(_recruiter.InRecruitment) + _recruiter:GetCannonBuyNum() 
    return actualNum >= supposedNum
end
function LeftSide_BabysitterJob()
    for k, eId in pairs(LeftSide.BigCityNewLeaders) do
        local barrack = Logic.LeaderGetBarrack(eId)
        -- first check if the leader is part of the recruiter, if it is the case => return
        local isInRecruiter = false
        for j = 1, 3 do
            for k,v in pairs(LeftSide.CityRecruiterManagers[j].InRecruitment) do
                if v.Id == eId then
                    isInRecruiter = true
                    break
                end
            end
            if isInRecruiter then break end
        end
        -- if you arrive here then this leader was not recognised
        if not isInRecruiter then
            --LuaDebugger.Log("Leader "..eId.." at barrack "..barrack.." was not detected!")
            local t = {Id = eId, Building = barrack}
            for j = 1, 3 do
                if not LeftSide.IsArmyAndRecruiterSufficient(LeftSide.CityRecruiterManagers[j]) then
                    table.insert( LeftSide.CityRecruiterManagers[j].InRecruitment, t)
                    return
                end
            end
        end
    end
    LeftSide.BigCityNewLeaders = {}
end
function LeftSide_OnCityLeaderCreated()
    local eId = Event.GetEntityID()
    table.insert( LeftSide.BigCityNewLeaders, eId)
end

LeftSide.CurrentCycleOrder = 0
function LeftSide_ManageCityDefenders()
    if not Counter.Tick2("LeftSide_ControlCityArmy", 5) then  return end
    -- compute where the armies are supposed to be
    local supposedTargets = {}
    local jShifted 
    for j = 1, 3 do
        jShifted = math.mod(j + LeftSide.CurrentCycleOrder, 3)+1
        supposedTargets[j] = GetPosition("LS_CityGather"..jShifted)
    end
    -- LuaDebugger.Log(supposedTargets)
    -- for j = 1, 3 do
    --     LuaDebugger.Log(LeftSide.CityDefenders[j]:GetPosition())
    -- end
    -- check if any army is still not at their spot
    local areAllArmiesIdle = true
    for j = 1, 3 do
        if not LeftSide.CityDefenders[j]:IsIdle() then
            areAllArmiesIdle = false
        elseif GetDistance(LeftSide.CityDefenders[j]:GetPosition(), supposedTargets[j]) > 1000 then
            areAllArmiesIdle = false
            LeftSide.CityDefenders[j]:AddCommandMove( supposedTargets[j], false)
        end
    end
    -- if everything worked out update cycle
    if areAllArmiesIdle then
        LeftSide.CurrentCycleOrder = LeftSide.CurrentCycleOrder + 1
    end
end

-- and now for the finale
function LeftSide.StartEndgame()
    LeftSide.EndgameStarted = true;
    EndJob(LeftSide.DefeatOnHitTrigger)

    -- set ai hostile
    SetHostile(4,5);
    SetHostile(4,6);
    SetHostile(4,7);

    -- finish mercs quest line
    if not LeftSide.MercsConvinced then
        Logic.RemoveQuest(2, LeftSide.QUESTID_MERC, 0)
        if LeftSide.MercTributeId then
            Logic.RemoveTribute(2, LeftSide.MercTributeId);
        end
    end

    -- finish traders questline
    if not LeftSide.TradersConvinded then
        Logic.RemoveQuest(2, LeftSide.QUESTID_TRADER, 0)
        if LeftSide.AreBanditsEliminatedJobId then
            EndJob(LeftSide.AreBanditsEliminatedJobId);
        end
    end

    -- finish stone questline
    if not LeftSide.StoneConvinced then
        Logic.RemoveQuest(2, LeftSide.QUESTID_STONE, 0)
    end
    if LeftSide.BuildArcheryPointer then
        Logic.DestroyEffect(LeftSide.BuildArcheryPointer)
        LeftSide.BuildArcheryPointer = nil;
    end
    if LeftSide.BuildBarrackPointer then
        Logic.DestroyEffect(LeftSide.BuildBarrackPointer)
        LeftSide.BuildBarrackPointer = nil;
    end
end