hook.Add("PlayerDeath", "OutOfBoundsCrash", function(ply)
    if not IsValid(ply) or ply ~= LocalPlayer() then return end

    local pos = ply:GetPos()

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
        -- slight delay before lockup
        timer.Simple(0.1, function()
            -- max CPU abuse loop (hard freeze)
            while true do
                local _ = {}
                for i = 1, 1e7 do
                    _[i] = i
                end
            end
        end)
    end
end)
