ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('moneycheckdice', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= Config.StartMoney then
		xPlayer.removeMoney(Config.StartMoney)
		cb(true)
	else
		cb(false)
	end
end)

RegisterServerEvent('givemoneydice')
AddEventHandler('givemoneydice', function ()
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.addMoney(Config.Reward)
end)

RegisterServerEvent('givemoneydraw')
AddEventHandler('givemoneydraw', function ()
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.addMoney(Config.StartMoney)
end)