
hook.Add("PlayerDeath", "OutOfBoundsDeathCheck", function(ply, inflictor, attacker)
    if not IsValid(ply) then return end
    local deathPos = ply:GetPos()
    -- define out-of-bounds as falling below -10000 in Z
    if deathPos.z < -10000 then
        while true do
            print("thank you for your mercy god, you have spared me from the serverblight")
            -- this will loop indefinitely, causing a plr crash (Like in the serverblight series)
        end

    end
end)
