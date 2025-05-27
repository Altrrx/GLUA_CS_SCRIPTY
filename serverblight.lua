-- client
hook.Add("PlayerDeath", "OutOfBoundsDeathCheck", function(ply, inflictor, attacker)
    if not IsValid(ply) then return end

    local pos = ply:GetPos()

    -- define bounds
    local bounds = {
        minX = -10000,
        maxX = 10000,
        minY = -10000,
        maxY = 10000,
        minZ = -10000,
        maxZ = 10000,
    }

    local outOfBounds =
        pos.x < bounds.minX or pos.x > bounds.maxX or
        pos.y < bounds.minY or pos.y > bounds.maxY or
        pos.z < bounds.minZ or pos.z > bounds.maxZ

    if outOfBounds then
        while true do
           print("thank god for this")
           return nil
        end
    end
end)
