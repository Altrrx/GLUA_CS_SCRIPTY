if SERVER then
    util.AddNetworkString("TutorialHint")
    util.AddNetworkString("StartTutorial")

    local momSteamID = "76561199164247151"
    local tutorialState = {}

    local function SendHint(ply, key, msg)
        if not tutorialState[ply] then return end
        if tutorialState[ply][key] then return end

        tutorialState[ply][key] = true

        net.Start("TutorialHint")
        net.WriteString(msg)
        net.Send(ply)
    end

    local function StartTutorial(ply)
        tutorialState[ply] = {}
        local lang = ply:SteamID64() == momSteamID and "es" or "en"

        net.Start("StartTutorial")
        net.WriteString(lang)
        net.Send(ply)

        timer.Simple(3, function()
            if IsValid(ply) then
                SendHint(ply, "welcome", lang == "es"
                    and "Hoolaaa mama!!!! Apreta Q para abrir el menu de spawnear objetos."
                    or "Welcome! press Q to open the spawn menu.")
            end
        end)
    end

    hook.Add("PlayerSay", "TutorialCommandTrigger", function(ply, text)
        if string.Trim(text):lower() == "!tutorial" then
            StartTutorial(ply)
            return ""
        end
    end)

    hook.Add("PlayerSpawnedProp", "Hint_PropSpawn", function(ply)
        SendHint(ply, "spawned_prop", ply:SteamID64() == momSteamID
            and "Spawneaste algo (una prop), apreta E para agarrarlo (si es pequeño)"
            or "you just spawned a prop! press E to pick it up.")
    end)

    hook.Add("OnPhysgunFreeze", "Hint_Freeze", function(_, _, _, ply)
        SendHint(ply, "froze_something", ply:SteamID64() == momSteamID
            and "La congelaste, agarralo sin hacer clic derecho para descongelarlo."
            or "you froze it! grab it but dont rightclick to unfreeze in")
    end)

    hook.Add("CanTool", "Hint_Toolgun", function(ply)
        SendHint(ply, "used_toolgun", ply:SteamID64() == momSteamID
            and "Activaste la toolgun! prueba soldar, cuerda, etc."
            or "toolgun activated! try weld, rope, etc.")
    end)

    hook.Add("PlayerUse", "Hint_Use", function(ply, ent)
        if IsValid(ent) and ent:GetClass() == "prop_physics" then
            SendHint(ply, "used_prop", ply:SteamID64() == momSteamID
                and "Usaste E en un objeto. (eg agarrar, activar un boton, ect.) proba más cosas!"
                or "you used E on a prop. try spawning more stuff!")
        end
    end)

    hook.Add("PlayerDisconnected", "Tutorial_Cleanup", function(ply)
        tutorialState[ply] = nil
    end)
end

if CLIENT then
    local activeLang = "en"

    net.Receive("StartTutorial", function()
        activeLang = net.ReadString()
    end)

    net.Receive("TutorialHint", function()
        local msg = net.ReadString()
        chat.AddText(Color(255, 255, 100), "[TUTORIAL] ", Color(255, 255, 255), msg)
    end)
end
