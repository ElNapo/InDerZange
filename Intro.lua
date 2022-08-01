Intro = {}

function Intro.StartThroneRoomBriefing()
    local briefing = {}
    local AP, ASP = AddPages(briefing)
    AP{
        title = Names.Dario, 
        text = "Und genau deswegen werden wir alle Gelehrten mit Pistolen ausstatten. Für die Kinder.",
        position = GetPosition("Intro_Dario"),
        dialogCamera = true,
        action = function()
            Display.SetRenderFogOfWar(0)
        end
    }
    AP{
        title = Names.Agent,
        text = "Eure Majestät, ich habe wichtige Nachrichten! "..Names.City.." ist in die falschen Hände gefallen!",
        position = GetPosition("Intro_Agent"),
        dialogCamera = true,
        action = function()
            Move("Intro_Agent", "Intro_AgentFinalPos")
            Camera.FollowEntity(GetEntityId("Intro_Agent"))
            ActivateEscBlock()
        end
    }
    AP{
        title = Names.Erec,
        text = Names.City.."? Die Stadt, die mit einem intelligenten Feldherrn absolut uneinnehmbar ist? Das kann nicht sein.",
        position = GetPosition("Intro_Erec"),
        dialogCamera = true,
        action = function()
            DeactivateEscBlock()
        end
    }
    AP{
        title = Names.Agent,
        text = "Ja, und "..Names.City.." wurde auch nicht militärisch erobert. "..Names.BadGuy.." hat ein paar Generäle "
            .." geschmiert und den Stadtrat geputscht. Innerhalb von wenigen Minuten hatte er die Stadt unter Kontrolle. "
            .." Wir konnten nichts tun.",
        position = GetPosition("Intro_AgentFinalPos"),
        dialogCamera = true
    }
    AP{
        title = Names.Dario,
        text = Names.BadGuy.."? Der Name kommt mir bekannt vor.",
        position = GetPosition("Intro_Dario"),
        dialogCamera = true
    }
    AP{
        title = Names.Helias,
        text = "Er war einer von Mordreds Schergen, denen Ihr Amnestie gewährt habt. Eigentlich war er auf dem richtigen Pfad, schade.",
        position = GetPosition("Intro_Helias"),
        dialogCamera = true
    }
    AP{
        title = Names.Erec,
        text = "Aber wir können Ihn nicht ungestraft davon kommen lassen, wir müssen "..Names.City.." zurückerobern. Nur wie?",
        position = GetPosition("Intro_Erec"),
        dialogCamera = true
    }
    ASP("Intro_Yuki", Names.Yuki, "Hatte "..Names.City.." nicht vier Fronten? Sie können unmöglich alle 4 gleichzeitig halten.", true)
    ASP("Intro_AgentFinalPos", Names.Agent, "Ja, "..Names.City.." hat vier Fronten, aber jede einzelne Front ist nur wenige Meter breit. "..
        "Zusätzlich ist ein Zugang praktisch nutzlos und eine andere Front liegt in extrem bergigem Terrain.", true)
    ASP("Intro_Yuki", Names.Yuki, "Wie stehen die Bewohner zu Ihrem neuen Herrscher? Eventuell können wir dort etwas machen.", true)
    ASP("Intro_AgentFinalPos", Names.Agent, "Sie sind nicht erfreut. "..Names.BadGuy.." kann zwar ein paar Offiziere bestechen, aber keine "
    .."florierende Stadt verwalten. Überall machen sich Banditen breit und die Einwohner ächtzen unter den Steuern, die den Luxus des Grafen finanzieren.", true)
    ASP("Intro_Yuki", Names.Yuki, "Seht Ihr die Möglichkeit einer Revolution?", true)
    ASP("Intro_AgentFinalPos", Names.Agent, "Außerhalb des direkten Kontrollbereiches des Grafen: Ja. @cr "..
    "Aber die Stadt selbst ist mit zu vielen Truppen durchsetzt. Dort werdet Ihr militärisch aktiv werden müssen.", true)
    ASP("Intro_AgentFinalPos", Names.Agent, "Aber mir kommt da eine Idee: @cr "
    .."Ihr habt vier Fronten, die Ihr am besten alle nutzt. Um dies zu erreichen, schicken wir zwei Teams los. ", true)
    ASP("Intro_AgentFinalPos", Names.Agent, "Das erste Team operiert vorsichtig im Gebirge und wird den Feind angreifen, während er an anderen Fronten beschäftigt ist. "
    .."Das zweite Team überzeugt die umliegenden Dörfer von unserer Sache und bearbeitet die restlichen Fronten. So müssten wir die besten Chancen haben.", true)
    ASP("Intro_Erec", Names.Erec, "Das ist wohl unsere beste Chance.", true)
    ASP("Intro_Dario", Names.Dario, "Dann sei es so: Das erste Team wird von "..Names.Helias.." und "..Names.Yuki.." geleitet "
    .."werden, das zweite Team von "..Names.Erec.." und "..Names.Pilgrim..". Und nun lasst mich zu meinem Schaumbad, dieses Gespräch dauert schon viel zu lange.", true)
    ASP("Intro_Pilgrim", Names.Pilgrim, "Och nö....", true)
    AP{
        title = Names.Narrator,
        text = "Und so begaben sich unsere Helden auf die Reise, um "..Names.City.." in einem Zangenmanöver einzunehmen.",
        position = {X = 0, Y = 41200}
    }
    Display.SetRenderFogOfWar(0)
    briefing.finished = function()
        Display.SetRenderFogOfWar(1)
        RightSide.StartInitialBriefing()
    end
    
    StartBriefing(briefing)
end