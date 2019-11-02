local base = 1024
return {
  {
    name = "Cow",
    dbPos = 1,
    items = {
      {name = "minecraft:leather", targetCount = base},
      {name = "minecraft:beef", targetCount = base}
    }
  }, {
    name = "Sheep",
    dbPos = 2,
    items = {
      {name = "minecraft:mutton", targetCount = base},
      {name = "minecraft:wool", targetCount = base}
    }
  }, {
    name = "Pig",
    dbPos = 3,
    items = {
      {name = "minecraft:porkchop", targetCount = base},
      {name = "quark:tallow", targetCount = base}
    }
  }, {
    name = "Chicken",
    dbPos = 4,
    items = {
      {name = "minecraft:feather", targetCount = base},
      {name = "minecraft:chicken", targetCount = base}
    }
  }, {
    name = "Bat",
    dbPos = 5,
    items = {
      {label = "Bat's Wing", targetCount = base},
      {name = "item.mob_ingredient_5.name", targetCount = base} -- Batwing
    }
  }, {
    name = "Pigman",
    dbPos = 6,
    items = {
      {name = "minecraft:gold_nugget", targetCount = base},
      {name = "minecraft:gold_ingot", targetCount = base},
      {label = "Sulfur", targetCount = base},
      {label = "item.mob_ingredient_6.name", targetCount = base}, -- ZombieHeart
      {label = "Grave's Dust", targetCount = base},
      {name = "thaumcraft:brain", targetCount = base}
    }
  }, {
    name = "Ghast",
    dbPos = 7,
    items = {
      {label = "Sulfur", targetCount = base},
      {name = "minecraft:gunpowder", targetCount = base},
      {name = "minecraft:ghast_tear", targetCount = base},
      {name = "netherex:ghast_meat_raw", targetCount = base},
      {name = "item.mob_ingredient_3.name", targetCount = base} -- Catalyzing Gland
    }
  }, {
    name = "Wither Skeleton",
    dbPos = 8,
    items = {
      {name = "minecraft:bone", targetCount = base},
      {label = "Grave's Dust", targetCount = base},
      {label = "Sulfur", targetCount = base},
      {label = "Wither Dust", targetCount = base},
      {label = "Wither Skeleton Skull", targetCount = base},
      {name = "netherex:wither_bone", targetCount = base},
      {label = "Wither Ash", targetCount = base},
      {label = "item.mob_ingredient_1.name", targetCount = base}, -- Withered Rib
      {label = "Necrotic Bone", targetCount = base},
      {label = "Drop of Evil", targetCount = base},
    }
  }, {
    name = "Whisp",
    dbPos = 9,
    items = {
      {label = "Potentia Vis Crystal", targetCount = base}
      -- TODO
    }
  }, {
    name = "Magma Cube",
    dbPos = 10,
    items = {
      {name = "minecraft:magma_cream", targetCount = base},
      {label = "item.mob_ingredient_7.name", targetCount = base} -- Molten Core
    }
  }, {
    name = "Foxhound",
    dbPos = 11,
    items = {
      {name = "minecraft:blaze_powder", targetCount = base},
      {label = "Sulfur", targetCount = base},
      {name = "minecraft:leather", targetCount = base}
    }
  }, {
    name = "Blitz",
    dbPos = 12,
    items = {
      {label = "Blitz Rod", targetCount = base},
      {label = "Niter", targetCount = base},
      {name = "minecraft:leather", targetCount = base}
    }
  }, {
    name = "Enderman",
    dbPos = 13,
    items = {
      {name = "minecraft:ender_pearl", targetCount = base},
      {name = "enderio:block_enderman_skull", targetCount = base},
      {label = "item.mob_ingredient_11.name", targetCount = base}, -- Nebulous Hearth
      {name = "rftoolsdim:dimlet_parcel", targetCount = base}
    }
  }, {
    name = "Blaze",
    dbPos = 14,
    items = {
      {name = "minecraft:blaze_rod", targetCount = base},
      {label = "Sulfur", targetCount = base},
      {label = "item.mob_ingredient_7.name", targetCount = base} -- Molten Core
    }
  }, {
    name = "Skeleton",
    dbPos = 15,
    items = {
      {name = "minecraft:bone", targetCount = base},
      {name = "minecraft:arrow", targetCount = base},
      {label = "Skeleton Skull", targetCount = base},
      {label = "Grave's Dust", targetCount = base},
      {label = "item.mob_ingredient_0.name", targetCount = base} -- Rib Bone
    }
  }, {
    name = "Rabbit",
    dbPos = 16,
    items = {
      {name = "minecraft:rabbit_foot", targetCount = base},
      {name = "minecraft:rabbit_hide", targetCount = base},
      {name = "minecraft:rabbit", targetCount = base}
    }
  }, {
    name = "Witch",
    dbPos = 17,
    items = {
      {name = "minecraft:gunpowder", targetCount = base},
      {name = "minecraft:sugar", targetCount = base},
      {name = "minecraft:spider_eye", targetCount = base},
      {name = "minecraft:glowstone_dust", targetCount = base},
      {name = "minecraft:glass_bottle", targetCount = base},
      {name = "minecraft:redstone", targetCount = base},
      {name = "xreliquary:witch_hat", targetCount = 50}
    }
  }, {
    name = "Spider",
    dbPos = 18,
    items = {
      {name = "minecraft:spider_eye", targetCount = base},
      {name = "minecraft:string", targetCount = base},
      {name = "minecraft:web", targetCount = base},
      {label = "item.mob_ingredient_2.name", targetCount = base} -- Cherlicera
    }
  }, {
    name = "Squid",
    dbPos = 19,
    items = {
      {label = "Ink Sac", targetCount = base},
      {name = "mysticalworld:raw_squid", targetCount = base},
      {label = "item.mob_ingredient_12.name", targetCount = base} -- Squid Beak
    }
  }, {
    name = "Creeper",
    dbPos = 20,
    items = {
      {name = "minecraft:gunpowder", targetCount = base},
      {label = "Creeper Head", targetCount = base},
      {label = "item.mob_ingredient_3.name", targetCount = base},-- Catalyzing Gland
      {label = "item.mob_ingredient_8.name", targetCount = base} -- Eye of the Storm
    }
  }, {
    name = "Zombie",
    dbPos = 21,
    items = {
      {name = "minecraft:rotten_flesh", targetCount = base},
      {label = "Zombie Head", targetCount = base},
      {name = "thaumcraft:brain", targetCount = base},
      {label = "item.mob_ingredient_6.name", targetCount = base},-- Zombie Hearth
      {label = "Grave's Dust", targetCount = base}
    }
  }, {
    name = "Wither",
    dbPos = 22,
    items = {
      {name = "minecraft:nether_star", targetCount = base},
      {label = "Withering Soul", targetCount = base},
      {label = "Grave's Dust", targetCount = base}
    }
  }, {
    name = "Wraith",
    dbPos = 23,
    items = {
      {label = "Zombie Head", targetCount = base},
      {name = "thaumcraft:brain", targetCount = base},
      {label = "Sulfur", targetCount = base},
      {label = "Grave's Dust", targetCount = base},
      {name = "quark:soul_bead", targetCount = base}
    }
  }, {
    name = "Guardian",
    dbPos = 24,
    items = {
      {label = "Raw Fish", targetCount = base},
      --{label = "Raw Salmon", targetCount = base},
      --{label = "Pufferfish", targetCount = base},
      --{label = "Clownfish", targetCount = base},
      {name = "minecraft:prismarine_shard", targetCount = base},
      {name = "minecraft:prismarine_crystals", targetCount = base},
      {label = "item.mob_ingredient_16.name", targetCount = base} -- Guardian Spike
    }
  }, {
    name = "Ancient Golem",
    dbPos = 25,
    items = {
      {label = "Sulfur", targetCount = base},
      {name = "embers:archaic_brick", targetCount = base},
      {name = "embers:ancient_motive_core", targetCount = base},
    }
  }, {
    name = "Chrimson Knight",
    dbPos = 26,
    items = {
      {name = "minecraft:gold_nugget", targetCount = base}
    }
  }, {
    name = "Wizard",
    dbPos = 27,
    items = {
      {name = "ebwizardry:magic_crystal", targetCount = base}
    }
  }, {
    name = "Dragon",
    dbPos = 28,
    items = {
      {name = "draconicevolution:draconium_dust", targetCount = base / 2}
    }
  }, {
    name = "Slime",
    dbPos = 29,
    items = {
      {label = "item.mob_ingredient_4.name", targetCount = base},
      {name = "minecraft:slime_ball", targetCount = base}
    }
  }
}