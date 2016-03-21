require('constants')

common = {
	replace = function(gridTarget, obj)
		grid[gridTarget.gridX][gridTarget.gridY] = object:new(gridTarget.gridScale, gridTarget.gridX, gridTarget.gridY, gridTarget.grid, obj)
	end,
	spawnAnt = function(house, AI, antObj)
		local spawnPoint = {}
		for i=1,9 do
			if grid[house.gridX + ((i - 1) % 3 - 1)][house.gridY + (math.floor((i - 1) / 3) - 1)] == nil then
				table.insert(spawnPoint, {x = house.gridX + ((i - 1) % 3 - 1), y = house.gridY + (math.floor((i - 1) / 3) - 1)})
			end
		end
		if next(spawnPoint) ~= nil then
			spawnPoint = spawnPoint[math.random(#spawnPoint)]
			grid[spawnPoint.x][spawnPoint.y] = ant:new(gridScale, spawnPoint.x, spawnPoint.y, grid, AI, house, antObj, AI.color)
			grid[spawnPoint.x][spawnPoint.y].ai.start(grid[spawnPoint.x][spawnPoint.y])
			table.insert(antObj, grid[spawnPoint.x][spawnPoint.y])
			AI.ants = AI.ants + 1
		end
	end,
}

function table.removeVal(tabl, value) --удалить элемент из таблицы
	for k,v in pairs(tabl) do
		if v == value then
			table.remove(tabl, k)
			break
		end
	end
end

object = {
	new = function(self, gridScale, gridX, gridY, grid, class)
		tabl = {}
		setmetatable(tabl, self)
		self.__index = self
		local color = ''
		if class == 'ground' then
			color = 'grey'
		elseif class == 'food' then
			color = 'yellow'
		elseif class == 'wall' then
			color = 'dark_brown'
		elseif class == 'house' then
			color = 'pink'
		end
		tabl.x, tabl.y, tabl.w, tabl.h, tabl.color, tabl.r, tabl.g, tabl.b, tabl.class = (gridX-1)*(gridScale+1), (gridY-1)*(gridScale+1), gridScale, gridScale, color, colors[color][1], colors[color][2], colors[color][3], class
		tabl.gridX, tabl.gridY, tabl.gridScale, tabl.grid = gridX, gridY, gridScale, grid
		return tabl
	end,
	setColor = function(self, col)
		self.r, self.g, self.b = colors[col][1], colors[col][2], colors[col][3]
	end,
	draw = function(self)
		love.graphics.setColor(self.r, self.g, self.b)
		love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
	end,
}

ant = {
	new = function(self, gridScale, gridX, gridY, grid, ai, house, ants, color)
		tabl = {}
		setmetatable(tabl, self)
		self.__index = self
		color = color or 'red'
		--свойства
		tabl.x, tabl.y, tabl.w, tabl.h, tabl.color, tabl.r, tabl.g, tabl.b, tabl.class, tabl.parent = (gridX-1)*(gridScale+1), (gridY-1)*(gridScale+1), gridScale, gridScale, color, colors[color][1], colors[color][2], colors[color][3], 'ant', ants
		--ссылки на свойства сетки
		tabl.gridX, tabl.gridY, tabl.gridScale, tabl.grid, tabl.house = gridX, gridY, gridScale, grid, house
		--искуственный интелект
		tabl.ai = ai
		--флаги
		tabl.haveFood = false
		return tabl
	end,
	getCell = function(self, direction)
		local target = self.grid[self.gridX + ((direction - 1) % 3 - 1)][self.gridY + (math.floor((direction - 1) / 3) - 1)]
		if target ~= nil then
			if target == self.house then
				return 'myhouse'
			else
				return self.grid[self.gridX + ((direction - 1) % 3 - 1)][self.gridY + (math.floor((direction - 1) / 3) - 1)].class
			end
		else
			return 'void'
		end
	end,
	dig = function(self, direction)
		local target = self.grid[self.gridX + ((direction - 1) % 3 - 1)][self.gridY + (math.floor((direction - 1) / 3) - 1)]
		if target ~= nil and target.class == 'ground' then
			grid[self.gridX + ((direction - 1) % 3 - 1)][self.gridY + (math.floor((direction - 1) / 3) - 1)] = nil
			self.ai.digs = self.ai.digs + 1
		end
	end,
	takeFood = function(self, direction)
		local target = self.grid[self.gridX + ((direction - 1) % 3 - 1)][self.gridY + (math.floor((direction - 1) / 3) - 1)]
		if target ~= nil and target.class == 'food' and not self.haveFood then
			grid[self.gridX + ((direction - 1) % 3 - 1)][self.gridY + (math.floor((direction - 1) / 3) - 1)] = nil
			self.haveFood = true
		end
	end,
	putFood = function(self, direction)
		local target = self.grid[self.gridX + ((direction - 1) % 3 - 1)][self.gridY + (math.floor((direction - 1) / 3) - 1)]
		if self.haveFood then
			if target == self.house then
				common.spawnAnt(self.house, self.ai, self.parent)
				self.haveFood = false
			elseif target == nil then
				grid[self.gridX + ((direction - 1) % 3 - 1)][self.gridY + (math.floor((direction - 1) / 3) - 1)] = object:new(self.gridScale, self.gridX + ((direction - 1) % 3 - 1), self.gridY + (math.floor((direction - 1) / 3) - 1), self.grid, 'food')
				self.haveFood = false
			end
		end
	end,
	move = function(self, direction)
		if grid[self.gridX + ((direction - 1) % 3 - 1)][self.gridY + (math.floor((direction - 1) / 3) - 1)] == nil then
			grid[self.gridX + ((direction - 1) % 3 - 1)][self.gridY + (math.floor((direction - 1) / 3) - 1)] = self
			grid[self.gridX][self.gridY] = nil
			self.gridX, self.gridY = self.gridX + ((direction - 1) % 3 - 1), self.gridY + (math.floor((direction - 1) / 3) - 1)
			self.x, self.y = (self.gridX-1)*(self.gridScale+1), (self.gridY-1)*(self.gridScale+1)
		end
	end,
	attack = function(self, direction)
		local target = self.grid[self.gridX + ((direction - 1) % 3 - 1)][self.gridY + (math.floor((direction - 1) / 3) - 1)]
		if target ~= nil and target.class == 'ant' and target.parent ~= self.parent then
			target.ai.ants = target.ai.ants - 1
			table.removeVal(target.parent, target)
			grid[self.gridX + ((direction - 1) % 3 - 1)][self.gridY + (math.floor((direction - 1) / 3) - 1)] = nil
			self.ai.kills = self.ai.kills + 1
		end
	end,
	getPopulation = function(self)
		return #self.parent
	end,
	setColor = function(self, col)
		self.r, self.g, self.b = colors[col][1], colors[col][2], colors[col][3]
	end,
	delete = function(self)
		self = nil
	end,
	draw = function(self)
		love.graphics.setColor(self.r, self.g, self.b)
		love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
		if self.haveFood then
			love.graphics.setColor(255, 255, 0)
			love.graphics.rectangle('fill', self.x+self.w/4, self.y+self.h/4, self.w/2, self.h/2)
		end
	end,
}

classes = {
  ["ground"] = ground,
	["ant"] = ant,
}
