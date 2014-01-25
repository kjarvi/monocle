local new = require 'monocle.lib.middleclass'
Monocle = new('Monocle')

function Monocle:initialize(initial)
	self.active = initial.isActive or false
	self.names = {}
	self.listeners = {}
	self.results = {}
	self.text = ''
	self.textCursorPosition = 0
	self.printer = initial.customPrinter or false
	self.printColor = initial.customColor or {128,128,128,128}
	self.command = ''
	self.debugToggle = initial.debugToggle or '`'
	self.watchedFiles = initial.filesToWatch or {}
	self.watchedFileTimes = {}
	for i, v in ipairs(self.watchedFiles) do
		assert(love.filesystem.getLastModified(v),v .. ' must not exist D:')
		self.watchedFileTimes[i] = love.filesystem.getLastModified(v)
	end

	self:print('Monocle Initialized.')
end

function Monocle:textinput(text)
	if self.active and text ~= self.debugToggle then
		--self.text = self.text .. text
	elseif text == self.debugToggle then
		self.active = not self.active
	end
end

function Monocle:keypressed(key)
	if self.active then
		-- If entering a command:
		if key == "return" then
			-- parses string

			self.results[self.text] = loadstring('return ' .. self.text)()

			-- Clear self.text.
			self.text = ''

		elseif key == 'backspace' then
			self.text = string.sub(self.text,1,string.len(self.text)-1)
		end
	end
end

function Monocle:print(text,justtext)
	if self.printer and not justtext then
		print("[Monocle]: " .. text)
	elseif justtext then
		return "[Monocle]: " .. text
	end
end


function Monocle:update()
	for key,obj in ipairs(self.listeners) do
		if type(obj) == 'string' then
			self.results[key] = loadstring('return ' .. obj)() or 'Error!'
		elseif type(obj) == 'table' then
			self.results[key] = 'food'
		end
	end

	for i, v in ipairs(self.watchedFiles) do
		if self.watchedFileTimes[i] ~= love.filesystem.getLastModified(v) then
			print('reloading')
			self.watchedFileTimes[i] = love.filesystem.getLastModified(v)
			love.filesystem.load('main.lua')()
		end
	end
end
--blah

function Monocle:watch(name,obj)
	if type(obj) == 'string' then
		self:print('Watching ' .. name)
		table.insert(self.listeners,obj)
		table.insert(self.names,name)
	else
		error(self:print('Object to watch is not a string'))
	end
end
--[[
function Monocle:unwatch(name)
	self.listeners[name] = nil
	self.results = {}
end
--]]
function Monocle:draw()
	if self.active then
		love.graphics.setColor(self.printColor)
		--love.graphics.print("> " .. self.text .. "|", 0, 0)
		local draw_y = 0
		for name,result in pairs(self.results) do
			if type(result) == 'number' or type(result) == 'string' then
				love.graphics.print(self.names[name] .. " : " .. result, 0, (draw_y + 1) * 15)
			elseif type(result) == 'table' then
				love.graphics.print(self.names[name] .. " : Table:", 0, (draw_y + 1) * 15)
				draw_y = draw_y + 1
				for i,v in pairs(result) do
					love.graphics.print("      " .. i .. " : " .. v, 0, (draw_y + 1) * 15)
					draw_y = draw_y + 1
				end
			end
			draw_y = draw_y + 1
		end
	end -- self.active
end

