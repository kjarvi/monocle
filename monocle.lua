Monocle = {}
function Monocle.new(initial)
	Monocle.active = initial.isActive or false
	Monocle.names = {}
	Monocle.listeners = {}
	Monocle.results = {}

	Monocle.printqueue = {}

	Monocle.commands = {}
	Monocle.cmdresults = {}

	Monocle.text = ''
	Monocle.textCursorPosition = 0

	Monocle.printer = initial.customPrinter or false
	Monocle.printColor = initial.customColor or {128,128,128,128}

	Monocle.debugToggle = initial.debugToggle or '`'

	Monocle.watchedFiles = initial.filesToWatch or {}
	Monocle.watchedFileTimes = {}
	for i, v in ipairs(Monocle.watchedFiles) do
		assert(love.filesystem.getLastModified(v),v .. ' must not exist or is in the wrong directory. Oh no! D:')
		Monocle.watchedFileTimes[i] = love.filesystem.getLastModified(v)
	end

	--Monocle.print('Monocle Initialized.')
end

function Monocle.textinput(text)
	if Monocle.active and text ~= Monocle.debugToggle then
		--Monocle.text = Monocle.text .. text
	elseif text == Monocle.debugToggle then
		Monocle.active = not Monocle.active
	end
	print(text)
end

function Monocle.keypressed(key)
	if Monocle.active then
		-- If entering a command:
		if key == "return" then
			-- parses string

			Monocle.results[Monocle.text] = loadstring('return ' .. Monocle.text)()

			-- Clear Monocle.text.
			Monocle.text = ''

		elseif key == 'backspace' then
			Monocle.text = string.sub(Monocle.text,1,string.len(Monocle.text)-1)
		end
	end
end

function Monocle.print(text,justtext)
	if Monocle.printer and not justtext then
		print("[Monocle]: " .. text)
	elseif justtext then
		return "[Monocle]: " .. text
	end
end


function Monocle.update()
	for key,obj in ipairs(Monocle.listeners) do
		if type(obj) == 'string' then
			Monocle.results[key] = loadstring('return ' .. obj)() or 'Error!'
		elseif type(obj) == 'table' then
			Monocle.results[key] = 'food'
		end
	end

	for i, v in ipairs(Monocle.watchedFiles) do
		if Monocle.watchedFileTimes[i] ~= love.filesystem.getLastModified(v) then
			print('reloading')
			Monocle.watchedFileTimes[i] = love.filesystem.getLastModified(v)
			love.filesystem.load('main.lua')()
		end
	end
end
--blah

function Monocle.watch(name,obj)
	if type(obj) == 'string' then
		Monocle.print('Watching ' .. name)
		table.insert(Monocle.listeners,obj)
		table.insert(Monocle.names,name)
	else
		Monocle.print('Object to watch is not a string')
		error('Object to watch is not a string')
	end
end
--[[
function Monocle.unwatch(name)
	Monocle.listeners[name] = nil
	Monocle.results = {}
end
--]]
function Monocle.draw()
	if Monocle.active then
		love.graphics.setColor(Monocle.printColor)
		--love.graphics.print("> " .. Monocle.text .. "|", 0, 0)
		local draw_y = 0
		for name,result in pairs(Monocle.results) do
			if type(result) == 'number' or type(result) == 'string' then
				love.graphics.print(Monocle.names[name] .. " : " .. result, 0, (draw_y + 1) * 15)
			elseif type(result) == 'table' then
				love.graphics.print(Monocle.names[name] .. " : Table:", 0, (draw_y + 1) * 15)
				draw_y = draw_y + 1
				for i,v in pairs(result) do
					love.graphics.print("      " .. i .. " : " .. v, 0, (draw_y + 1) * 15)
					draw_y = draw_y + 1
				end
			end
			draw_y = draw_y + 1
		end	-- For name,result
	end -- Monocle.active
end

return Monocle