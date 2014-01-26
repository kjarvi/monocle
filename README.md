# Monocle

### Debugging Love2D, in *style*

Monocle is a way to easily watch things while you play your game. 
It's easy to implement, and easy to understand. The setup of a basic main.lua file is as follows:

```lua
require 'monocle/monocle'
glass = Monocle:new({		-- ALL of these parameters are optional!

	isActive=true,			-- Whether the debugger is initially active
	customPrinter=false,	-- Whether Monocle prints status messages to the output
	printColor = {51,51,51}	-- Color to print debug with
	debugToggle='`',		-- The keyboard button for toggling Monocle
	filesToWatch=			-- Files that, when edited, cause the game to reload automatically
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

