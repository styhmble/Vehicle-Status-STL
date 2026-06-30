fx_version "cerulean"
game "gta5"

author "Shook"
description "Standalone UI"
version "1.1.0"

ui_page "html/ui.html"

files {
    "html/ui.html",
    "html/script.js",
}

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua",
    "shared/utils.lua",
}

client_scripts {
    "client/main.lua",
}

server_scripts {
    "server/main.lua",
}

dependencies {
    "qbx_core",
    "ox_lib",
}