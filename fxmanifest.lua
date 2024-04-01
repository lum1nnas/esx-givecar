fx_version 'cerulean'
game 'gta5'

author 'givevehicle'
description '123'
version '1.0.0'

lua54 'yes'

client_script {
	'@es_extended/locale.lua',
	'client/main.lua',
	'config.lua',
	'locales/en.lua'
}
server_script {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'server/main.lua',
	'config.lua',
	'locales/en.lua'
}
shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua'
} 

dependency {
	'es_extended',
	'esx_vehicleshop'
}