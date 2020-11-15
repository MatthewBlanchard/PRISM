local Component = require "component"

local Stats = Component:extend()
Stats.name = "Stats"

local validStats =
{
  ATK = "getATK", MGK = "getMGK", PR = "getPR", MR = "getMR"
}

function Stats:__new(options)
  for k, v in pairs(validStats) do
    self[k] = options[k] or 0
  end

  self.AC = options.AC or 10
  self.maxHP = options.maxHP or 1
end

function Stats:initialize(actor)
  for k, v in pairs(validStats) do
    actor[k] = self[k]
  end

  actor.AC = self.AC
  actor.maxHP = self.maxHP
  actor.HP = self.maxHP

  actor.rollCheck = self.rollCheck
  actor.getStatBonus = self.getStatBonus
  actor.getStat = self.getStat
  actor.getAC = self.getAC
  actor.getMaxHP = self.getMaxHP
  actor.getHP = self.getHP
  actor.setHP = self.setHP

  actor:addReaction(reactions.Damage)
  actor:addReaction(reactions.Die)
  actor:addReaction(reactions.Heal)
end

function Stats.rollCheck(actor, stat)
  if not validStats[stat] then
    error("Invalid stat check made by actor: " .. actor.name .. " for stat: " .. stat)
  end

  local roll = ROT.Dice.roll("1d20", 1)
  return roll + actor:getStatBonus(stat), roll
end

local function diffFromTen(n)
  if n > 10 then
    return n - 10
  elseif n < 10 then
    return - (10 - n)
  else
    return 0
  end
end

function Stats.getStatBonus(actor, stat)
  if not validStats[stat] then
    error("Invalid bonus request made by actor: " .. actor.name .. " for stat: " .. stat)
  end

  local condmods = 0
  for k, cond in pairs(actor:getConditions()) do
    if cond[validStats[stat]] then
      condmods = condmods + cond[validStats[stat]](cond, actor)
    end
  end

  return math.floor(actor[stat] + condmods)
end

function Stats.getStat(actor, stat)
  if not validStats[stat] then
    error("Invalid bonus request made by actor: " .. actor .. " for stat: " .. stat)
  end

  local condmods = 0
  for k, cond in pairs(actor:getConditions()) do
    if cond[validStats[stat]] then
      condmods = condmods + cond[validStats[stat]](cond, actor)
    end
  end

  return actor[stat] + condmods
end

function Stats.getAC(actor)
  local condmods = 0
  for k, cond in pairs(actor:getConditions()) do
    if cond.getAC then
      condmods = condmods + cond:getAC(actor)
    end
  end

  return 10 + actor.AC + condmods
end

function Stats.getMaxHP(actor)
  local condmods = 0
  for k, cond in pairs(actor:getConditions()) do
    if cond.getMaxHP then
      condmods = condmods + cond:getMaxHP(actor)
    end
  end

  return actor.maxHP + condmods
end

function Stats.getHP(actor)
  return actor.HP
end

function Stats.setHP(actor, hp)
  actor.HP = math.max(0, math.min(actor.maxHP, hp))
end

return Stats
