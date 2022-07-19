LeftSide = {}
LeftSide.ReadyForAttack = false
LeftSide.QUESTID_MAIN = 4

function LeftSide.StartInitialBriefing()
    local briefing = {}
    local AP, ASP = AddPages(briefing);
    ActivateEscBlock()
    AP{
        title = Names.Erec,
        text = "Ich muss sagen, ich habe diese Expeditionen schon ziemlich vermisst. Ist es nicht schön, endlich mal wieder"..
            " außerhalb der Mauern der königlichen Hauptstadt zu sein?",
        position = GetPosition("Erec"),
        dialogCamera = true,
        action = function()
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
            id = RightSide.QUESTID_MAIN,
            type = MAINQUEST_OPEN,
            title = "Trefft den Agenten!",
            text = Names.Erec.." und "..Names.Pilgrim.." haben ihn Ziel fast erreicht. Besprecht mit dem "..Names.AgentDativ.." die nächsten Schritte!"
        }
        Logic.AddQuest( 2, quest.id, quest.type, quest.title, quest.title, 1) 
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
        text = "Ihr habt "..Names.Yuki.." und "..Names.Helias..", die EEuch bald mit den Rohmaterialien versorgen werden. "
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

    

    briefing.finished  = function()
        DestroyEntity(LeftSide.ViewCenterStone)
    end
    StartBriefing( briefing)
end