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
	Monocle.printColor = initial.customColor or {64,64,64,128}

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
		if type(obj) == 'function' then
			Monocle.results[key] = obj() or 'Error!'
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
	if type(obj) == 'function' then
		Monocle.print('Watching ' .. name)
		table.insert(Monocle.listeners,obj)
		table.insert(Monocle.names,name)
	else
		Monocle.print('Object to watch is not a string')
		error('Object to watch is not a string')
	end
end
--[[ Out of date
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

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errhand(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isCreated() then
		if not pcall(love.window.setMode, 800, 600) then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
	end
	if love.joystick then
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration() -- Stop all joystick vibrations.
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	love.graphics.setBackgroundColor(89, 157, 220)
	local font = love.graphics.setNewFont(14)

	love.graphics.setColor(255, 255, 255, 255)

	local trace = debug.traceback()

	love.graphics.clear()
	love.graphics.origin()

	local err = {}
	local mon = {}
	for i, v in pairs(Monocle.results) do
		table.insert(mon, Monocle.names[i] .. ": " .. v)
	end
	table.insert(err, "[Monocle] An error has occurred! You can either close this and reload the game, or edit your code and come back to this window. The game should automatically reload it's main.lua file when it detects changes in your files (the files specified by 'filesToWatch' in your Monocle.new() parameters\n")
	table.insert(err, "Error\n")
	table.insert(err, msg.."\n\n")

	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end


	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

	local function draw()
		love.graphics.clear()
		love.graphics.printf(p, 150, 70, love.graphics.getWidth()-150)
		love.graphics.printf(table.concat(mon,'\n'), 0, 15, 150)
		love.graphics.present()
	end

	while true do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			end
			if e == "keypressed" and a == "escape" then
				return
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
			for i, v in ipairs(Monocle.watchedFiles) do
				if Monocle.watchedFileTimes[i] ~= love.filesystem.getLastModified(v) then
					print('reloading')
					Monocle.watchedFileTimes[i] = love.filesystem.getLastModified(v)
					love.filesystem.load('main.lua')()
					love.run()
					love.graphics.setBackgroundColor(89, 157, 220)
					love.graphics.setColor(255,255,255)
				end
			end
		end
	end

end




return Monocle

