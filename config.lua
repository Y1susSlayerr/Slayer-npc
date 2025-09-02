Config = {}

-- general toggles
Config.useDebug = false
Config.aimDistance = 4.0
Config.minWeaponThreat = true -- require player to be aiming a weapon to open target menu on NPC

-- strings (ASCII only, no accents or ñ as requested)
Config.text = {
    notifyStart = 'Estas controlando a un NPC',
    notifyStop = 'Has soltado al NPC',
}

-- controls while carrying
Config.disableControlsWhileCarrying = true

-- offsets for attaching victim to player (tweak to taste)
Config.attach = {
    bone = 0,       -- 0 = pelvis/root
    x = 0.10, y = 0.45, z = 0.0,
    rx = 0.0, ry = 0.0, rz = 0.0
}
