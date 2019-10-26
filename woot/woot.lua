-- import
sides = require("sides")
component = require("component")
require("gachLib")

--config
--oc
breakPlaceChestAddr = "c95e"

transposerDrawerAddr = "294d"
transposerDrawerSide = sides.east

redstoneBreakerAddr = "bc43"
redstoneBreakerSide = sides.west
transposerBreakerSide = sides.down

redstonePlacerAddr = "c01a"
redstonePlacerSide = sides.west
transposerPlacerSide = sides.up

transposerChestSide = sides.west

--woot
timePerFactory = 60
currentFactory = nil
factoryTable = {
  {
    name = "Cow",
    dbPos = 1,
    items = {
      {name = "minecraft:leather", targetCount = 100},
      {name = "minecraft:beef", targetCount = 100}
    }
  }, {
    name = "Sheep",
    dbPos = 2,
    items = {
      {name = "minecraft:mutton", targetCount = 100},
      {name = "minecraft:wool", targetCount = 100}
    }
  }, {
    name = "Pig",
    dbPos = 3,
    items = {
      {name = "minecraft:porkchop", targetCount = 100},
      {name = "quark:tallow", targetCount = 100}
    }
  }, {
    name = "Chicken",
    dbPos = 4,
    items = {
      {name = "minecraft:feather", targetCount = 100},
      {name = "minecraft:chicken", targetCount = 100}
    }
  }, {
    name = "Bat",
    dbPos = 5,
    items = {
      {label = "Bat's Wing", targetCount = 100},
      {name = "item.mob_ingredient_5.name", targetCount = 100} -- Batwing
    }
  }, {
    name = "Pigman",
    dbPos = 6,
    items = {
      {name = "minecraft:gold_nugget", targetCount = 100},
      {name = "minecraft:gold_ingot", targetCount = 100},
      {label = "Sulfur", targetCount = 100},
      {label = "item.mob_ingredient_6.name", targetCount = 100}, -- ZombieHeart
      {label = "Grave's Dust", targetCount = 100},
      {name = "thaumcraft:brain", targetCount = 100}
    }
  }, {
    name = "Ghast",
    dbPos = 7,
    items = {
      {label = "Sulfur", targetCount = 100},
      {name = "minecraft:gunpowder", targetCount = 100},
      {name = "minecraft:ghast_tear", targetCount = 100},
      {name = "netherex:ghast_meat_raw", targetCount = 100},
      {name = "item.mob_ingredient_3.name", targetCount = 100} -- Catalyzing Gland
    }
  }, {
    name = "Wither Skeleton",
    dbPos = 8,
    items = {
      {name = "minecraft:bone", targetCount = 100},
      {label = "Grave's Dust", targetCount = 100},
      {label = "Sulfur", targetCount = 100},
      {label = "Wither Dust", targetCount = 100},
      {label = "Wither Skeleton Skull", targetCount = 100},
      {name = "netherex:wither_bone", targetCount = 100},
      {label = "Wither Ash", targetCount = 100},
      {label = "item.mob_ingredient_1.name", targetCount = 100}, -- Withered Rib
      {label = "Necrotic Bone", targetCount = 100},
      {label = "Drop of Evil", targetCount = 100},
    }
  }, {
    name = "Whisp",
    dbPos = 9,
    items = {
      {label = "Potentia Vis Crystal", targetCount = 100}
      -- TODO
    }
  }, {
    name = "Magma Cube",
    dbPos = 10,
    items = {
      {name = "minecraft:magma_cream", targetCount = 100},
      {label = "item.mob_ingredient_7.name", targetCount = 100} -- Molten Core
    }
  }, {
    name = "Foxhound",
    dbPos = 11,
    items = {
      {name = "minecraft:blaze_powder", targetCount = 100},
      {label = "Sulfur", targetCount = 100},
      {name = "minecraft:leather", targetCount = 100}
    }
  }, {
    name = "Blitz",
    dbPos = 12,
    items = {
      {label = "Blitz Rod", targetCount = 100},
      {label = "Niter", targetCount = 100},
      {name = "minecraft:leather", targetCount = 100}
    }
  }, {
    name = "Enderman",
    dbPos = 13,
    items = {
      {name = "minecraft:ender_pearl", targetCount = 100},
      {name = "enderio:block_enderman_skull", targetCount = 100},
      {label = "item.mob_ingredient_11.name", targetCount = 100}, -- Nebulous Hearth
      {name = "rftoolsdim:dimlet_parcel", targetCount = 100}
    }
  }, {
    name = "Blaze",
    dbPos = 14,
    items = {
      {name = "minecraft:blaze_rod", targetCount = 100},
      {label = "Sulfur", targetCount = 100},
      {label = "item.mob_ingredient_7.name", targetCount = 100} -- Molten Core
    }
  }, {
    name = "Skeleton",
    dbPos = 15,
    items = {
      {name = "minecraft:bone", targetCount = 100},
      {name = "minecraft:arrow", targetCount = 100},
      {label = "Skeleton Skull", targetCount = 100},
      {label = "Grave's Dust", targetCount = 100},
      {label = "item.mob_ingredient_0.name", targetCount = 100} -- Rib Bone
    }
  }, {
    name = "Rabbit",
    dbPos = 16,
    items = {
      {name = "minecraft:rabbit_foot", targetCount = 100},
      {name = "minecraft:rabbit_hide", targetCount = 100},
      {name = "minecraft:rabbit", targetCount = 100}
    }
  }, {
    name = "Witch",
    dbPos = 17,
    items = {
      {name = "minecraft:gunpowder", targetCount = 100},
      {name = "minecraft:sugar", targetCount = 100},
      {name = "minecraft:spider_eye", targetCount = 100},
      {name = "minecraft:glowstone_dust", targetCount = 100},
      {name = "minecraft:glass_bottle", targetCount = 100},
      {name = "minecraft:redstone", targetCount = 100},
      {name = "xreliquary:witch_hat", targetCount = 100},
      {name = "quark:witch_hat", targetCount = 100}
    }
  }, {
    name = "Spider",
    dbPos = 18,
    items = {
      {name = "minecraft:spider_eye", targetCount = 100},
      {name = "minecraft:string", targetCount = 100},
      {name = "minecraft:web", targetCount = 100},
      {label = "item.mob_ingredient_2.name", targetCount = 100} -- Cherlicera
    }
  }, {
    name = "Squid",
    dbPos = 19,
    items = {
      {label = "Ink Sac", targetCount = 100},
      {name = "mysticalworld:raw_squid", targetCount = 100},
      {label = "item.mob_ingredient_12.name", targetCount = 100} -- Squid Beak
    }
  }, {
    name = "Creeper",
    dbPos = 20,
    items = {
      {name = "minecraft:gunpowder", targetCount = 100},
      {label = "Creeper Head", targetCount = 100},
      {label = "item.mob_ingredient_3.name", targetCount = 100},-- Catalyzing Gland
      {label = "item.mob_ingredient_8.name", targetCount = 100} -- Eye of the Storm
    }
  }, {
    name = "Zombie",
    dbPos = 21,
    items = {
      {name = "minecraft:rotten_flesh", targetCount = 100},
      {label = "Zombie Head", targetCount = 100},
      {name = "thaumcraft:brain", targetCount = 100},
      {label = "item.mob_ingredient_6.name", targetCount = 100},-- Zombie Hearth
      {label = "Grave's Dust", targetCount = 100}
    }
  }, {
    name = "Wither",
    dbPos = 22,
    items = {
      {name = "minecraft:nether_star", targetCount = 100},
      {label = "Withering Soul", targetCount = 100},
      {label = "Grave's Dust", targetCount = 100}
    }
  }, {
    name = "Wraith",
    dbPos = 23,
    items = {
      {label = "Zombie Head", targetCount = 100},
      {name = "thaumcraft:brain", targetCount = 100},
      {label = "Sulfur", targetCount = 100},
      {label = "Grave's Dust", targetCount = 100},
      {name = "quark:soul_bead", targetCount = 100}
    }
  }, {
    name = "Guardian",
    dbPos = 24,
    items = {
      {label = "Raw Fish", targetCount = 100},
      {label = "Raw Salmon", targetCount = 100},
      {label = "Pufferfish", targetCount = 100},
      {label = "Clownfish", targetCount = 100},
      {name = "minecraft:prismarine_shard", targetCount = 100},
      {name = "minecraft:prismarine_crystals", targetCount = 100},
      {label = "item.mob_ingredient_16.name", targetCount = 100} -- Guardian Spike
    }
  }, {
    name = "Ancient Golem",
    dbPos = 25,
    items = {
      {label = "Sulfur", targetCount = 100},
      {name = "embers:archaic_brick", targetCount = 100},
      {name = "embers:ancient_motive_core", targetCount = 100},
    }
  }, {
    name = "Chrimson Knight",
    dbPos = 26,
    items = {
      {name = "minecraft:gold_nugget", targetCount = 100}
    }
  }, {
    name = "Wizard",
    dbPos = 27,
    items = {
      {name = "ebwizardry:magic_crystal", targetCount = 100}
    }
  }
}

--vars
transposerBPC = component.proxy(component.get(breakPlaceChestAddr))
transposerDrawer = component.proxy(component.get(transposerDrawerAddr))
redstonePlacer = component.proxy(component.get(redstonePlacerAddr))
redstoneBreaker = component.proxy(component.get(redstoneBreakerAddr))

--func
function init()
end

function breakFactory(time)
  if time == nil then
    time = 10
  end

  redstoneBreaker.setOutput(redstoneBreakerSide, 0)

  while isEmpty(transposerBPC,transposerBreakerSide) and time > 0 do
    time = time - 1
    os.sleep(0.1)
  end

  redstoneBreaker.setOutput(redstoneBreakerSide, 15)
  transferAll(transposerBPC, transposerBreakerSide, transposerChestSide)  
end

function placeFactory(dbSlot, time)
  if time == nil then
    time = 10
  end
  
  local pos = findByDb(component.database, dbSlot, transposerBPC, transposerChestSide)
  if pos <= -1 then
    return false
  end
  
  transposerBPC.transferItem(transposerChestSide, transposerPlacerSide, transposerBPC.getSlotStackSize(transposerChestSide, pos), pos, 1)

  redstonePlacer.setOutput(redstonePlacerSide, 0)

  while not isEmpty(transposerBPC,transposerPlacerSide) and time > 0 do
    time = time - 1
    os.sleep(0.1)
  end

  redstonePlacer.setOutput(redstonePlacerSide, 15)
  
  return true
end

function updateFactoryTable()
  local ret = {name = nil, missingSum = 0}
  local posF = 1
  print("updateFactoryTable")
  while factoryTable[posF] ~= nil do
    print("  " .. factoryTable[posF].name)
    local missingSum = 0
    local posI = 1
    while factoryTable[posF].items[posI] ~= nil do
      factoryTable[posF].items[posI].currentCount = count(transposerDrawer, transposerDrawerSide, factoryTable[posF].items[posI].name, factoryTable[posF].items[posI].label)

      factoryTable[posF].items[posI].differentCount = factoryTable[posF].items[posI].targetCount - factoryTable[posF].items[posI].currentCount
      if factoryTable[posF].items[posI].name ~= nil then
        print("    " .. factoryTable[posF].items[posI].name .. ": " .. factoryTable[posF].items[posI].currentCount .. " / " .. factoryTable[posF].items[posI].targetCount)
      else
        print("    " .. factoryTable[posF].items[posI].label .. ": " .. factoryTable[posF].items[posI].currentCount .. " / " .. factoryTable[posF].items[posI].targetCount)
      end
      
      if factoryTable[posF].items[posI].differentCount > 0 then
        missingSum = missingSum + factoryTable[posF].items[posI].differentCount
      end
      
      posI = posI + 1
    end
    
    factoryTable[posF].missingSum = missingSum
    print("   Missing " .. missingSum)
    
    if ret.name == nil or missingSum > ret.missingSum then
      ret.name = factoryTable[posF].name
      ret.dbPos = factoryTable[posF].dbPos
      ret.missingSum = missingSum
    end
    
    posF = posF + 1
  end
  
  return ret
end

function nextFactory()
  local nextF = updateFactoryTable()
  
  if currentFactory == nil or currentFactory.name ~= nextF.name then
    breakFactory()
  
    if nextF.name == nil or nextF.missingSum <= 0 then
      print("No new factory aviable..")
      return false
    end
  
    if placeFactory(nextF.dbPos) then
      currentFactory = nextF
      print("Placed next factory: " .. nextF.name)
    else
      print("!!! Failed to place next factory: " .. nextF.name)
      return false
    end
  elseif nextF.missingSum > 0 then
    print("Stay on current factory: " .. nextF.name)
  else
    breakFactory()
    print("Go in StandBy.. ")
  end
  return true
end

--Main
print("Start woot")
breakFactory()
local currentTimePerFactory = 0
while true do
  if currentTimePerFactory <= 0 then
    if not nextFactory() then
      print("!")
    end
    currentTimePerFactory = timePerFactory
  end
  os.sleep(1)
  currentTimePerFactory = currentTimePerFactory - 1
  --print("Tick: " .. currentTimePerFactory)
end