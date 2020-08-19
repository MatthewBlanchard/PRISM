local Condition = require "condition"

local Shield = Condition:extend()
Shield.name = "shield"
Shield.breaks = {actors.Wand_of_fireball}

function Shield:__new()
  Condition.__new(self)
  self.hasShield = true
end

Shield:onReaction(reactions.Damage,
  function(self, level, actor, action)
    if self.hasShield then 
      action.damage = 0 
    end

    if action.source then
      for _,v in ipairs(Shield.breaks) do
        if v:is(action.source) then 
          self.hasShield = false
        end
      end
    else
      self.hasShield = false 
    end
  end
)

return Shield