local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
MySQL = module("vrp_mysql", "MySQL")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_alogin")

-- (*) If you want to change default password by changing from 1234 to anything you want.
-- (*) If you changed default password uncomment line 16, restart your server, after comment it back, it will reset all passwords to default.

MySQL.createCommand("vRP/pass_tables", "ALTER TABLE `vrp_users` ADD IF NOT EXISTS `pass` varchar(30) DEFAULT '1234';")
MySQL.createCommand("vRP/get_pass", "SELECT * FROM `vrp_users` WHERE `id`=@user_id")
MySQL.createCommand("vRP/update_pass", "UPDATE `vrp_users` SET `pass`=@new WHERE `id`=@user_id")
MySQL.createCommand("vRP/refresh_table", "ALTER TABLE `vrp_users` DROP `pass`;")

--MySQL.query("vRP/refresh_table")
MySQL.query("vRP/pass_tables")

RegisterCommand('alogin', function(source, args, msg)
	local user_id = vRP.getUserId({source})
	msg = msg:sub(8)
	if msg:len() >= 1 then
		MySQL.query("vRP/get_pass", {user_id = user_id}, function(rows, affected)
			if #rows > 0 then
				if rows[1].pass == msg then
					TriggerClientEvent('alogin:togFreeze', source)
					TriggerClientEvent('chatMessage', source, "^2Login successful!")
				else
					TriggerClientEvent('chatMessage', source, "^1Wrong password!")
				end
			end
		end)
	else 
		TriggerClientEvent('chatMessage', source, "^1Syntax^7: /alogin <password>")
	end
end)

RegisterCommand('changepass', function(source, args, msg)
	local user_id = vRP.getUserId({source})
	local old = table.remove(args, 1)
	local new = table.remove(args, 1)
	
	if old and new then
		MySQL.query("vRP/get_pass", {user_id = user_id}, function(rows, affected)
			if #rows > 0 then
				if rows[1].pass == old then
					MySQL.query("vRP/update_pass", {user_id=user_id, new=new})
					TriggerClientEvent('chatMessage', source, "^2Success^7: your new password is now: ^2"..new)
				else
					TriggerClientEvent('chatMessage', source, "^1Error^7: old password is wrong.")
				end
			end
		end)
	else
		TriggerClientEvent('chatMessage', source, "^1Syntax^7: /changepass <old-pass> <new-pass>")
	end
end)

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
  if first_spawn then
	if vRP.hasPermission({user_id, "admin.tickets"}) then
		TriggerClientEvent('chatMessage', source, "^1StaffLogin^7: you need to login as staff using ^1/alogin <password>^7.")
		TriggerClientEvent('chatMessage', source, "^1StaffLogin^7: if you want to change password use ^1/changepass <old-pass> <new-pass>^7.")
		TriggerClientEvent('alogin:togFreeze', source)
	end
  end
end)