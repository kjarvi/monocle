# Monocle

### Debugging Love2D, in *style*

Monocle is a way to easily watch things while you play your game. 
It's easy to implement, and easy to understand. The setup of a basic main.lua file is as follows:

```lua
require 'monocle/monocle'
glass = Monocle:new({
	isActive=true,
	customPrinter=true,
	debugToggle='`',
	filesToWatch=
		{
			'main.lua'
		}
})

glass:watch("Mouse X", 'love.mouse.getX()' )
glass:watch("Mouse Y", 'love.mouse.getY()' )
glass:watch("FPS", 'math.floor(1/love.timer.getDelta())')
glass:watch("Clock", 'os.clock()')

function love.update(dt)
	glass:update()
end

function love.draw()
	glass:draw()
end

function love.textinput(t)
	glass:textinput(t)
end

function love.keypressed(text)
	glass:keypressed(text)
end
```
Easy as that! When the game is run, what you're watching will show up in the top right of the screen.

#### Credits
This lib uses [middleclass](https://github.com/kikito/middleclass) for it's object orientation. Thank you :)
