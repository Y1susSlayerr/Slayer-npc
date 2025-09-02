fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'Slayer_npc_kidnap'
author 'pablo cifuentes + chatgpt'
description 'Kidnap NPCs by aiming a weapon and using a key-driven NUI menu.'
version '0.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

dependencies {
    'qb-core',
    'ox_lib',
    'ox_target',
}
