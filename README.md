# Monocle

### Debugging Love2D with grace

Monocle is a way to easily watch things while you play your game. 
It's easy to implement, and easy to understand. The setup of a basic main.lua file is as follows:

```lua
require 'monocle/monocle'
Monocle.new({})

-- The most basic way to watch any expression or variable:
Monocle.watch("FPS", function() return math.floor(1/love.timer.getDelta()) end)

function love.update(dt)
	Monocle.update()
end

function love.draw()
	Monocle.draw()
end

function love.textinput(t)
	Monocle.textinput(t)
end

function love.keypressed(text)
	Monocle.keypressed(text)
end
```
Easy as that! When the game is run, what you're watching will show up in the top right of the screen.

For more information on how to use Monocle, as well as the official Love2D forum post, look [here](http://love2d.org/forums/viewtopic.php?f=5&t=77108).

