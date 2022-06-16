ESX = nil
PlayerData = {}
local started = false
local finished = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(0)
    end

    PlayerData = ESX.GetPlayerData()

end)

 
function DrawText3D(x, y, z, text, scale)
    SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(true)
	AddTextComponentString(text)
	SetDrawOrigin(x,y,z, 0)
	DrawText(0.0, 0.0)
	local factor = (string.len(text)) / 370
	DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
	ClearDrawOrigin()
end

function Animation(dict, anim, ped)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    
    TaskPlayAnim(ped, dict, anim, 8.0, 1.0, 1800, 49, 0, true, true, false)
end

-----# NPC Thread

local Kordinat = {

    {Config.NPCCord.x,Config.NPCCord.y,Config.NPCCord.z, "Dice",Config.NPCHeading,Config.NPCHash,Config.NPCModel},
}
  
  
Citizen.CreateThread(function()
  
    for _,v in pairs(Kordinat) do
        RequestModel(GetHashKey(v[7]))
        while not HasModelLoaded(GetHashKey(v[7])) do
          Wait(1)
        end
    
        RequestAnimDict("anim@heists@heist_corona@single_team")
        while not HasAnimDictLoaded("anim@heists@heist_corona@single_team") do
          Wait(1)
        end
        ped =  CreatePed(4, v[6],v[1],v[2],v[3], 3374176, false, true)
        SetEntityHeading(ped, v[5])
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskPlayAnim(ped,"anim@heists@heist_corona@single_team","single_team_loop_boss", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
    end
end)

----# Game Thread

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)
        local distance = GetDistanceBetweenCoords(Config.NPCCord, playerCoords, true)
        local reward = Config.Reward
        local dice1 = math.random(1,6)
        local dice2 = math.random(1,6)
        if distance <= 2.0 then
            if started == false then
                DrawText3D(Config.NPCCord.x, Config.NPCCord.y, Config.NPCCord.z + 1.0,Config.StartText)
                if IsControlJustPressed(1, 38) then
                    ESX.TriggerServerCallback('moneycheckdice', function(money)
                        if money then
                            started = true
                            FreezeEntityPosition(player, true)
                            Animation('anim@mp_player_intcelebrationmale@wank', 'wank', ped)
                            Citizen.Wait(2000)
                            Animation('anim@mp_player_intcelebrationmale@wank', 'wank', player)
                            Citizen.Wait(3000)
                            FreezeEntityPosition(player ,false)
                            finished = true
                            if dice1 > dice2 then
                                exports['413x-notify']:Alert("error", "Lost", 'NPC Dice : '..dice1..' - Your Dice : '..dice2..' - You Lost', 5000)
                            elseif dice2 > dice1 then
                                exports['413x-notify']:Alert("success", "Won", 'NPC Dice : '..dice1..' - Your Dice : '..dice2..' - You Won $'..reward..'', 5000)
                                TriggerServerEvent("givemoneydice")
                            elseif dice1 == dice2 then
                                exports['413x-notify']:Alert("info", "Draw", 'NPC Dice : '..dice1..' - Your Dice : '..dice2..' - Draw, You Get Your Money Back', 5000)
                                TriggerServerEvent("givemoneydraw")
                            end
                        else
                            exports['413x-notify']:Alert("error", 'No Money', Config.NotHaveMoney, 5000)
                        end
                    end)
                end
            end
            if finished then
                DrawText3D(Config.NPCCord.x, Config.NPCCord.y, Config.NPCCord.z + 1.0,Config.AgainText)
                if IsControlJustPressed(1, 38) then
                    finished = false
                    started = false
                end
            end
        end

    end

end)

Citizen.CreateThread(function()

    if Config.Blip then
        blip = AddBlipForCoord(Config.NPCCord.x, Config.NPCCord.y, Config.NPCCord.z)
        SetBlipSprite(blip, Config.BlipID)
        SetBlipDisplay(blip, 4) 
        SetBlipScale(blip, Config.BlipScale)
        SetBlipColour(blip, Config.BlipColour)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.BlipName)
        EndTextCommandSetBlipName(blip)

    end
end)