local Object = require "object"

local MusicManager = Object:extend()

MusicManager.mainmusic = love.audio.newSource("music/mainloop_cassette.ogg", "stream")
MusicManager.ominousmusic = love.audio.newSource("music/ominous.ogg", "stream")
MusicManager.mainmusic:setLooping(true)
MusicManager.ominousmusic:setLooping(true)

MusicManager.cassette_play = love.audio.newSource("music/cassette_play.ogg", "static")
MusicManager.cassette_stop = love.audio.newSource("music/cassette_stop.ogg", "static")
MusicManager.cassette_insert = love.audio.newSource("music/cassette_insert.ogg", "static")
MusicManager.cassette_insert:setVolume(0.5)
MusicManager.cassette_remove = love.audio.newSource("music/cassette_remove.ogg", "static")
MusicManager.cassette_remove:setVolume(0.5)

MusicManager.cassette_hiss = love.audio.newSource("music/cassette_hiss.ogg", "static")
MusicManager.cassette_hiss:setLooping(true)

function MusicManager:__new()
  self.playing = self.cassette_hiss
  self.cassette_hiss:play()

  love.audio.setEffect('distortReality', {
  	type = 'distortion',
  	gain = .25,
  	edge = .25,
  })
end

function MusicManager:update(dt)
  if self.transition then
    local success, ret = coroutine.resume(self.transition, dt)
  end
end

function MusicManager:startDistortion()
  self.playing:setPitch(0.95)
  self.playing:setEffect("distortReality")
end

function MusicManager:endDistortion()
  self.playing:setPitch(1)
  self.playing:setEffect("distortReality", false)
end

function MusicManager:yieldWhilePlaying(source)
  while source:isPlaying() do
    self.transitionTime = self.transitionTime + coroutine.yield()
  end
end

function MusicManager:yieldWhileFading(source, fadeTime)
  local deltaTime = self.transitionTime - self.transitionStartFade
  local factor = math.min(deltaTime/fadeTime, 1)

  if deltaTime == 0 then
    factor = 0
  end

  while factor ~= 1 do
    self.transitionTime = self.transitionTime + coroutine.yield()
    deltaTime = self.transitionTime - self.transitionStartFade
    factor = math.min(deltaTime/fadeTime, 1)
    source:setVolume(factor)
  end
end

function MusicManager:changeSong(upNext, shouldSkipPlay)
  self.transitionTime = 0
  self.transition = coroutine.create(
    function(dt)
      if upNext == self.ominousmusic then
        self.playing:pause()
      else
        self.playing:stop()
      end

      if  self.playing ~= self.cassette_hiss and self.playing ~= self.ominousmusic then
        self.cassette_stop:play()
        self:yieldWhilePlaying(self.cassette_stop)

        if upNext ~= self.ominousmusic then
          self.cassette_remove:play()
          self:yieldWhilePlaying(self.cassette_remove)
        end
      end

      if not shouldSkipPlay then
        if self.playing ~= self.ominousmusic then
          self.cassette_insert:play()
          self:yieldWhilePlaying(self.cassette_insert)
        end

        self.cassette_play:play()
        self:yieldWhilePlaying(self.cassette_play)
      end

      self.playing = upNext
      upNext:play()

      if upNext == self.ominousmusic then
        upNext:setVolume(0)
        self.transitionStartFade = self.transitionTime
        self:yieldWhileFading(upNext, 3)
      end
    end
  )
end

return MusicManager
