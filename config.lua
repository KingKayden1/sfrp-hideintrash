Config = {}

Config.Enabled = true
Config.Print = 'Set Config.Enabled To TRUE'

Config.Dumpster = {
    `prop_dumpster_01a`,
    `prop_dumpster_02a`,
    `prop_dumpster_02b`,
    `prop_dumpster_4a`,
    `prop_dumpster_4b`
}

Config.Framework = {
    target = 'qb',
    notify = 'qb'
}

Config.Suffocation = {
    enabled = true,              -- Enable or disable suffocation
    timeBeforeSuffocation = 60,  -- Time (seconds) before suffocation starts
    damagePerTick = 10,           -- Damage applied per tick
    tickRate = 3                -- Time (seconds) between each damage tick
}

Config.DrawText = {
    native = true,
    text = '[E] To Leave',
    qbcore = {
        position = 'left',
    }
}

Config.Enter = {
    invisibility = true,
    animation = {
        scenario = 'anim@amb@nightclub@lazlow@lo_alone@',
        scenarioType = 'lowalone_base_laz'
    }
}
