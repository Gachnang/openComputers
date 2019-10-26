return {
  { name = "Awakened Draconium Block",
    core = {name = "draconicevolution:draconium_block", count = 4},
    inject = {
      {name = "draconicevolution:wyvern_core", count = 6},
      {name = "draconicevolution:dragon_heart", count = 1}
    }
  }, { name = "Energy Core Stabilizer",
    core = {name = "draconicevolution:particle_generator", count = 1},
    inject = {
      {name = "draconicevolution:wyvern_core", count = 2},
      {name = "minecraft:diamond", count = 4}
    }
  }, { name = "Wyvern Fusion Crafting Injector",
    core = {name = "draconicevolution:crafting_injector", count = 1},
    inject = {
      {name = "draconicevolution:wyvern_core", count = 1},
      {name = "draconicevolution:draconium_block", count = 1},
      {name = "draconicevolution:draconic_core", count = 2},
      {name = "minecraft:nether_star", count = 4}
    }
  }, {  name = "Draconic Fusion Crafting Injector",
    core = {name = "draconicevolution:crafting_injector", count = 1},
    inject = {
      {name = "draconicevolution:wyvern_core", count = 2},
      {name = "draconicevolution:draconic_block", count = 1},
      {name = "minecraft:dragon_egg", count = 1},
      {name = "minecraft:nether_star", count = 4}
    }
  }, {  name = "Chaotic Fusion Crafting Injector",
    core = {name = "draconicevolution:crafting_injector", count = 1},
    inject = {
      {name = "draconicevolution:chaotic_core", count = 2},
      {name = "draconicevolution:chaos_shard", count = 1},
      {name = "minecraft:dragon_egg", count = 1},
      {name = "minecraft:nether_star", count = 4}
    }
  }, {  name = "Draconic Energy Relay Crystal",
    core = {name = "draconicevolution:energy_crystal", count = 4},
    inject = {
      {name = "draconicevolution:wyvern_core", count = 1},
      {name = "draconicevolution:wyvern_energy_core", count = 4},
      {name = "draconicevolution:draconic_energy_core", count = 1},
      {name = "minecraft:diamond", count = 4}
    }
  }, {  name = "WyvernCore",
    core = {name = "minecraft:emerald_block", count = 1},
    inject = {
      {name = "draconicevolution:draconium_block", count = 2},
      {name = "draconicevolution:draconic_core", count = 5},
      {name = "minecraft:nether_star", count = 2}
    }
  }, {  name = "Awakened Core",
    core = {name = "minecraft:nether_star", count = 1},
    inject = {
      {name = "draconicevolution:wyvern_core", count = 5},
      {name = "draconicevolution:draconic_block", count = 4}
    }
  },  {  name = "Chaotic Core",
    core = {name = "draconicevolution:chaotic_shard", count = 1},
    inject = { -- TODO: Will not work! core and inject same item
      {name = "draconicevolution:chaotic_shard", count = 4},
      {name = "draconicevolution:draconic_block", count = 6},
      {name = "draconicevolution:awakened_core", count = 4}
    }
  },  {  name = "Draconic Energy Core",
    core = {name = "draconicevolution:wyvern_energy_core", count = 1},
    inject = {
      {name = "draconicevolution:awakened_core", count = 1},
      {name = "draconicevolution:draconic_ingot", count = 4},
      {name = "minecraft:redstone_block", count = 5}
    }
  }
}