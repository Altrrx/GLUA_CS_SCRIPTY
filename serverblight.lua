-- clientside only
local localplr = LocalPlayer()

hook.Add("PlayerDeath", "OutOfBoundsDeathCheck", function(ply, inflictor, attacker)
    if not IsValid(ply) or ply ~= localplr then return end

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
        chat.AddText(Color(255, 0, 0), "[blight] ", color_white, "mercy denied.")
        timer.Simple(0.1, function()
            -- crash loop
            while true do
                debug.sethook(function() end, "", 1)
                print("you have been cast out")
            end
        end)
    end
end)
