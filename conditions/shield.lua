local Condition = require "condition"

local Shield = Condition:extend()
Shield.name = "shield"
Shield.breaks = {actors.Wand_of_fireball, actors.Bomb}

function Shield:__new()
  Condition.__new(self)
  self.hasShield = true
  self.ticks = 0
  self.cooldown = 20
end

function Shield:lose(level, action)
  self.hasShield = false
  level:addMessage("You shatter the golem's shield!", action.dealer)
end

Shield:onReaction(reactions.Damage,
  function(self, level, actor, action)
    if self.hasShield then 
      action.damage = 0 
    else 
      return
    end

    if action.source then
      for _,v in pairs(Shield.breaks) do
        if v:is(action.source) then 
          self:lose(level, action)
        end
      end
    else
      self:lose(level, action)
    end

    if self.hasShield then 
      level:addMessage("Your attack is blocked by the golem's shield.", action.dealer)
    end
  end
)

Shield:onTick(
  function(self, level, actor, action)
    if not self.hasShield then 
      self.ticks = self.ticks + 1
      if self.ticks == self.cooldown then 
        self.hasShield = true
        self.ticks = 0
      end
    end
  end
)

return Shield