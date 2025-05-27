if SERVER then return end -- client only

local blightEnabled = false
local blightChase = false
local blightModel = nil
local aprehended = false
local chaseSound = nil

-- toggle crash on out of bounds
concommand.Add("sv_blight", function(_, _, args)
    blightEnabled = args[1] == "1"
    chat.AddText(Color(255, 0, 0), "[BLIGHT] enabled: ", tostring(blightEnabled))
    aprehended = false
end)

-- toggle chase with deforming playermodel + sound
concommand.Add("sv_blight_chase", function(_, _, args)
    blightChase = args[1] == "1"
    chat.AddText(Color(255, 50, 255), "[BLIGHT CHASE] enabled: ", tostring(blightChase))

    if blightChase then
        if IsValid(blightModel) then blightModel:Remove() end
        if chaseSound then chaseSound:Stop() chaseSound = nil end

        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        blightModel = ClientsideModel("models/player/zombie_fast.mdl", RENDERGROUP_OPAQUE)
        blightModel:SetNoDraw(false)
        blightModel:SetModelScale(2)

        -- Spawn 500 units away horizontally + 100 up
        local offsetDir = VectorRand()
        offsetDir.z = 0
        offsetDir:Normalize()
        local spawnPos = ply:GetPos() + offsetDir * 500 + Vector(0, 0, 100)
        blightModel:SetPos(spawnPos)

        -- Play horrible looping sound (replace with any sound path you want)
        chaseSound = CreateSound(blightModel, "npc/zombie/zombie_pain3.wav")
        chaseSound:Play()
        chaseSound:SetSoundLevel(80)
        chaseSound:ChangePitch(60)
    else
        if IsValid(blightModel) then blightModel:Remove() end
        if chaseSound then chaseSound:Stop() chaseSound = nil end
        aprehended = false
    end
end)

local function shuffle(str)
    local chars = {}
    for i = 1, #str do
        chars[i] = str:sub(i, i)
    end
    for i = #chars, 2, -1 do
        local j = math.random(i)
        chars[i], chars[j] = chars[j], chars[i]
    end
    return table.concat(chars)
end

local function triggerCrash()
    if aprehended then return end
    aprehended = true

    chat.AddText(Color(255, 0, 0), "[SERVERBLIGHT] You have been aprehended!")

    timer.Simple(1, function()
        for i = 1, 50 do
            chat.AddText(Color(255, 0, 255), shuffle("aÄA.ä.A..AÄ.ÄÄÄaäaAÄAÄäÄAÄÄAÄ.äa.A.aÄa.äÄA.äAÄAÄÄ"))
        end
    end)

    timer.Simple(5, function()
        while true do
            RunConsoleCommand("quit")
            local t = {}
            for i = 1, 1e7 do
                t[i] = i
            end
        end
    end)
end

hook.Add("Think", "BlightOutOfBoundsCheck", function()
    local ply = LocalPlayer()
    if not blightEnabled or not IsValid(ply) or ply:Alive() then return end

    local pos = ply:GetPos()
    local outOfBounds =
        pos.x < -10000 or pos.x > 10000 or
        pos.y < -10000 or pos.y > 10000 or
        pos.z < -10000 or pos.z > 10000

    if outOfBounds and not ply.__BLIGHTED then
        ply.__BLIGHTED = true
        triggerCrash()
    end
end)

hook.Add("PostDrawOpaqueRenderables", "BlightChaseEffect", function()
    if blightChase and IsValid(blightModel) and IsValid(LocalPlayer()) then
        local ply = LocalPlayer()
        local ppos = ply:GetPos()
        local epos = blightModel:GetPos()

        -- Horizontal direction only
        local dir = (ppos - epos)
        dir.z = 0
        dir:Normalize()

        -- Move slowly towards player with gentle jitter
        local newPos = epos + dir * 5 + VectorRand() * 1.5
        blightModel:SetPos(newPos)

        -- Bone deformation
        local boneCount = blightModel:GetBoneCount() - 1

        for i = 0, boneCount do
            if blightModel:GetBoneName(i):lower():find("finger") then
                -- wild finger stretch + jiggle
                local angle = Angle(math.sin(CurTime()*10 + i)*60, math.cos(CurTime()*12 + i)*60, math.sin(CurTime()*14 + i)*60)
                blightModel:ManipulateBoneAngles(i, angle)
            else
                -- subtle random jitter on other bones
                local angle = AngleRand() * 5
                blightModel:ManipulateBoneAngles(i, angle)
            end
        end

        -- Hit detection radius 100 units
        if not aprehended and ppos:Distance(newPos) < 100 then
            triggerCrash()
        end
    end
end)
