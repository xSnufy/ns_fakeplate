fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'ns_scritps'
description 'Ns_FakePlate (https://discord.gg/vKj4qjBMTQ)'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', 
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory',
    'ox_target'
}
