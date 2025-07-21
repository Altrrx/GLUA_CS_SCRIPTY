timer.Create("coughvirus_spam", 20, 0, function()
    if math.random(1, 3) == 1 then
        LocalPlayer():ConCommand("say *cough* *cough* *cough*")
        surface.PlaySound("ambient/voices/cough1.wav")
    end
end)


