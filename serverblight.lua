if SERVER then return end -- Server shouldnt run this, big no-no, if the server (somehow) dies out of bounds it might crash.

local blightEnabled = false
local blightChase = false
local blightModel = nil
local aprehended = false

-- sv_blight 1 means crashes when out of bounds (If any of the axises more than 10000)
-- On the other hand sv_blight 0 means no crash

-- sv_blight_chase 1 enables the chase
-- sv_blight_chase 0 disables the chase
concommand.Add("sv_blight", function(_, _, args)
    blightEnabled = args[1] == "1"
    chat.AddText(Color(255, 0, 0), "[BLIGHT] enabled: ", tostring(blightEnabled))
    aprehended = false
end)

concommand.Add("sv_blight_chase", function(_, _, args)
    blightChase = args[1] == "1"
    chat.AddText(Color(255, 50, 255), "[BLIGHT CHASE] enabled: ", tostring(blightChase))

    if blightChase then
        if IsValid(blightModel) then blightModel:Remove() end
        blightModel = ClientsideModel("models/player/zombie_fast.mdl", RENDERGROUP_OPAQUE)
        blightModel:SetNoDraw(false)
        blightModel:SetPos(LocalPlayer():GetPos() + Vector(0, 0, 100))
        blightModel:SetModelScale(2)
    elseif IsValid(blightModel) then
        blightModel:Remove()
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
        local dir = (ppos - epos):GetNormalized()

        -- move towards player with glitchy random motion
        blightModel:SetPos(epos + dir * 10 + VectorRand() * 5)

        -- violently deform bones
        for i = 0, blightModel:GetBoneCount() - 1 do
            blightModel:ManipulateBoneAngles(i, AngleRand() * 30)
        end

        -- hit detection: simple bounding radius check
        if not aprehended and ppos:Distance(epos) < 100 then
            triggerCrash()
        end
    end
end)
