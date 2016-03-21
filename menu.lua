button = {
  onClick = nil,
  new = function(self, tabl)
		tabl = tabl or {} -- создать таблицу, если пользователь не передал ее
		setmetatable(tabl, self)
		self.__index = self
		return tabl
	end,
  setColor = function(self, col)
		self.r, self.g, self.b = colors[col][1], colors[col][2], colors[col][3]
	end,
  editText = function(self, textIn)
    self.textIn = textIn
  end,
	draw = function(self)
		love.graphics.setColor(self.r, self.g, self.b)
    if self.type == 'rect' then
			love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
		end
    love.graphics.setColor(255, 255, 255)
		love.graphics.print(self.textIn, self.x, self.y)
	end,
}

text = {
  new = function(self, tabl)
		tabl = tabl or {} -- создать таблицу, если пользователь не передал ее
		setmetatable(tabl, self)
		self.__index = self
		return tabl
	end,
  setColor = function(self, col)
		self.r, self.g, self.b = colors[col][1], colors[col][2], colors[col][3]
	end,
  editText = function(self, textIn)
    self.textIn = textIn
  end,
	draw = function(self)
		love.graphics.setColor(self.r, self.g, self.b)
		love.graphics.print(self.textIn, self.x, self.y, self.orientation, self.scalex, self.scaley, self.offx, self.offy, self.shearx, self.sheary)
	end,
}

div = {
  objects = {},
  padding = 0,
  margin = 0,
  wrap = false,
  new = function(self, tabl)
		tabl = tabl or {} -- создать таблицу, если пользователь не передал ее
		setmetatable(tabl, self)
		self.__index = self
		return tabl
	end,
  setColor = function(self, col)
		self.r, self.g, self.b = colors[col][1], colors[col][2], colors[col][3]
	end,
  add = function(self, obj)
    table.insert(self.objects, obj)
  end,
  construct = function(self)
    local line = 0
    local xi = 0
    for k,v in pairs(self.objects) do
      v.x = self.x + self.margin + xi * (v.w + self.padding)
      v.y = self.y + self.margin + line * (v.h + self.padding)
      xi = xi + 1
      if v.x + v.w >= self.x + self.w - self.margin then
        line = line + 1
        xi = 0
      end
    end
    local lastObj = self.objects[#self.objects]
    if self.wrap and lastObj.y + lastObj.h >= self.y + self.h - self.margin then
      self.h = self.h + lastObj.h + self.padding * math.floor((lastObj.y + lastObj.h - self.y + self.h - self.margin) / (lastObj.y + lastObj.h))
    end
  end,
  draw = function(self)
		love.graphics.setColor(self.r, self.g, self.b)
		love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
	end,
}

altMenu = {
  choose = nil,
  new = function(self, tabl)
		tabl = tabl or {} -- создать таблицу, если пользователь не передал ее
		setmetatable(tabl, self)
		self.__index = self
		return tabl
	end,
  setColor = function(self, col)
		self.r, self.g, self.b = colors[col][1], colors[col][2], colors[col][3]
	end,
  addItem = function(self, ...)
    local arg = {...}
    for i=1,#arg do
      tabl = {}
      tabl.__index, tabl.id, tabl.x, tabl.y, tabl.w, tabl.h, tabl.textIn, tabl.r, tabl.g, tabl.b = self, #self + 1, #self * 55, 0, 50, 20, arg[i], colors[self.iColor][1], colors[self.iColor][2], colors[self.iColor][3]
      tabl.onClick = function(self)
                      self.__index.choose = self.id
                    end
      table.insert(self, tabl)
    end
  end,
  addSub = function(self, item, ...)
    local arg = {...}
    for i=1,#arg do
      tabl = {}
      tabl.__index, tabl.id, tabl.x, tabl.y, tabl.w, tabl.h, tabl.textIn = self[item], #self[item] + 1, self[item].x, self.h + #self[item] * self.h, self[item].w * 2, self.h, arg[i]
      table.insert(self[item], tabl)
    end
  end,
  removeItem = function(self, num)
    table.remove(self, num)
  end,
  draw = function(self)
		love.graphics.setColor(self.r, self.b, self.g)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), self.h)
    for i=1,#self do
      love.graphics.setColor(self[i].r, self[i].g, self[i].b)
      love.graphics.rectangle("fill", self[i].x, self[i].y, self[i].w, self[i].h)
      love.graphics.setColor(0, 0, 0)
      love.graphics.print(self[i].textIn, self[i].x, self[i].y)
    end
    if self.choose ~= nil then
      for j=1,#self[self.choose] do
        love.graphics.setColor(self[self.choose].r, self[self.choose].g, self[self.choose].b)
        love.graphics.rectangle("fill", self[self.choose][j].x, self[self.choose][j].y, self[self.choose][j].w, self[self.choose][j].h)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(self[self.choose][j].textIn, self[self.choose][j].x, self[self.choose][j].y)
      end
    end
	end,
}
textArea = {
  textIn = '',
  new = function(self, tabl)
    tabl = tabl or {} -- создать таблицу, если пользователь не передал ее
    setmetatable(tabl, self)
    self.__index = self
    return tabl
  end,
  setColor = function(self, col)
		self.r, self.g, self.b = colors[col][1], colors[col][2], colors[col][3]
	end,
  addKey = function(self, key)
    if self.limit then
      if #self.textIn + 1 <= self.limit then
        self.textIn = self.textIn .. key
      end
    else
      self.textIn = self.textIn .. key
    end
  end,
  editText = function(self, textIn)
    self.textIn = textIn
  end,
	draw = function(self)
		love.graphics.setColor(self.r, self.g, self.b)
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(0, 0, 0)
		love.graphics.print(self.textIn, self.x, self.y)
	end,
}

menu = {
  addButton = function(self, x, y, textIn, w, h, color, type)
    w = w or 80
    h = h or 30
    type = type or 'rect'
    tabl = button:new()
    tabl.x, tabl.y, tabl.w, tabl.h, tabl.r, tabl.g, tabl.b, tabl.type, tabl.class, tabl.textIn = x, y, w, h, colors[color][1], colors[color][2], colors[color][3], type, 'button', textIn
		return tabl
  end,
  addText = function(self, textIn, x, y, color, orientation, scalex, scaley, offx, offy, shearx, sheary)
    tabl = text:new()
    tabl.textIn, tabl.x, tabl.y, tabl.r, tabl.g, tabl.b, tabl.orientation, tabl.scalex, tabl.scaley, tabloffx, tabl.offy, tabl.shearx, tabl.sheary, tabl.class = textIn, x, y, colors[color][1], colors[color][2], colors[color][3], orientation, scalex, scaley, offx, offy, shearx, sheary, 'text'
    return tabl
  end,
  addDiv = function(self, x, y, w, h, color, padding, margin, wrap)
    tabl = div:new()
    tabl.x, tabl.y, tabl.w, tabl.h, tabl.r, tabl.g, tabl.b, tabl.class, tabl.padding, tabl.margin, tabl.wrap = x, y, w, h, colors[color][1], colors[color][2], colors[color][3], 'div', padding, margin, wrap
    return tabl
  end,
  addAltMenu = function(self, h, color, icolor)
    color = color or 'white'
    icolor = icolor or 'grey'
    h = h or 20
    tabl = altMenu:new()
    tabl.h, tabl.r, tabl.g, tabl.b, tabl.class, tabl.iColor = h, colors[color][1], colors[color][2], colors[color][3], 'altMenu', icolor
    return tabl
  end,
  addTextArea = function(self, x, y, w, h, color, limit)
    w = w or 80
    h = h or 20
    tabl = textArea:new()
    tabl.x, tabl.y, tabl.w, tabl.h, tabl.r, tabl.g, tabl.b, tabl.class, tabl.limit = x, y, w, h, colors[color][1], colors[color][2], colors[color][3], 'textArea', limit
		return tabl
  end,
}
