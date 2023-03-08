-- @module Core
local Object = require "object"

--- A System is a class representing a level-wide event handler that can be attached to a Level object.
--- It listens to events such as an actor taking an action, moving, or a tick of time.
--- This should be used for mechanics that affect the entire level; such as hunger, fov, or lighting.
--- For event handlers that apply to a single actor, use a Condition instead. If you want a system that
--- recieves all messages from all levels, like tracking the player's favor with a god attach it to
--- the game instead.

-- @type System
local System = Object:extend()

--- A system defined global can only be attached to the Game object. It will see all events from all levels.
--- Level will error if a global System is attached to a Level. Game will do the same if a non-global System
--- is attached to it.
System.global = false

--- A system must define a name that is unique to the System. If a duplicate name is found, or if the
--- name is not defined, the Level will assert and abort.
--@field name string
System.name = nil

--- A system may define a table of requirements that must be met in order for it to be attached to a Level.
--- This table should be a list of strings, where each string is the name of a System that must be attached.
--- If any of the required Systems are not attached, the Level will assert and abort during initialization.
--- This insures that the required Systems are attached to the Level before the System is attached.
--- This bucks convention in that it uses strings instead of the actual System class. I want to change all of the
--- core objects to reference other objects by name instead of by class, but I'll save that for saving/loading.
-- @field requirements table
System.requirements = nil

--- Very similar to requirements except that the Level will not assert and abort if the required Systems are not attached.
--- This will ensure that if both Systems are attached, they will be attached, and therefore updated in the correct order.
-- @field softRequirements table
System.softRequirements = nil

--- This method is called when the Level is initialized. It is called after all of the Systems have been attached.
-- @tparam Level level The Level object this System is attached to.
function System:initialize(level)
end
--- This method is called after an actor has selected an action, but before it is executed.
-- @tparam Level level The Level object this System is attached to.
-- @tparam Actor actor The Actor object that has selected an action.
-- @tparam Action action The Action object that the Actor has selected to execute.
function System:beforeAction(level, actor, action)
end
    
--- This method is called after an actor has taken an action.
-- @tparam Level level The Level object this System is attached to.
-- @tparam Actor actor The Actor object that has taken an action.
-- @tparam Action action The Action object that the Actor has executed.
function System:afterAction(level, actor, action)
end

--- This method is called after an actor has moved.
-- @tparam Level level The Level object this System is attached to.
-- @tparam Actor actor The Actor object that has moved.
function System:onMove(level, actor, from, to)
end

--- This method is called after an actor has been added to the Level.
-- @tparam Level level The Level object this System is attached to.
-- @tparam Actor actor The Actor object that has been added.
function System:onActorAdded(level, actor)
end

--- This method is called after an actor has been removed from the Level.
-- @tparam Level level The Level object this System is attached to.
-- @tparam Actor actor The Actor object that has been removed.
function System:onActorRemoved(level, actor)
end

--- This method is called every 100 units of time, a second, and can be used for mechanics such as hunger and fire spreading.
-- @tparam Level level The Level object this System is attached to.
function System:onTick(level)
end

return System