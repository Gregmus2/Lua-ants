blue = {

  color = 'blue',

  debug = function(this)
    for k,v in pairs(this.house.memory) do
      for k2,v2 in pairs(v) do
        print(k,k2,v2)
      end
    end
  end,

  houseCreate = function(house)
    house.memory = {}
    for i=-1,3 do
      house.memory[i] = {}
      for j=-1,3 do
        house.memory[i][j] = 'void'
      end
    end
    house.memory[1][1] = 'myhouse'
  end,

  start = function(this)
    this.memory = {}
    this.mypos = {}
    for i=1,9 do
      if this:getCell(i) == 'myhouse' then
        this.memory[1] = {}
        this.memory[1][1] = 'myhouse'
        this.mypos.x = (9-i) % 3
        this.mypos.y = math.floor((9-i)/3)
        break
      end
    end
    --копание
    if this.house.freeCol == nil then
      this.house.freeCol = 0
    end
    --this.ai.setTarget(this, this.house.freeCol * 3 + 1, -1)
    this.ai.setTarget(this, 1, 3)
  end,

  update = function(this)
    if this.going then
      this.ai.goto(this)
    end
  end,
}

function blue.putMemory(this, direction)
  if this:getCell(direction) == 'myhouse' then
    for x,v in pairs(this.memory) do
      for y,v2 in pairs(v) do
        if this.house.memory[x] == nil then
          this.house.memory[x] = {}
        end
        this.house.memory[x][y] = v2
      end
    end
    this.memory = {}
    this.memory[1] = {}
    this.memory[1][1] = 'myhouse'
  end
end

function blue.savePos(this, direction) --сохранить позицию
  this.mypos.x = this.mypos.x + (direction-1) % 3 - 1
  this.mypos.y = this.mypos.y + math.floor((direction-1) / 3) - 1
  if this.house.memory[this.mypos.x] == nil or this.house.memory[this.mypos.x][this.mypos.y] ~= 'void' then
    if this.memory[this.mypos.x] == nil then
      this.memory[this.mypos.x] = {}
    end
    this.memory[this.mypos.x][this.mypos.y] = 'void'
  end
end

function blue.setTarget(this, x, y)
  path = this.ai.buildPath(this, x, y)
  -- pDir priorityDirection
  -- this.pDirX = this.ai.incToDir(math.abs(x - this.mypos.x)/(x - this.mypos.x), 0)
  -- this.pDirY = this.ai.incToDir(0, math.abs(y - this.mypos.y)/(y - this.mypos.y))
  -- this.target.x, this.target.y = x, y
end

function blue.buildPath(this, x, y)
  require "astar"

  local valid_node_func = function ( node, target )
  	if target.equal == 'void' and astar.distance ( node.x, node.y, target.x, target.y ) < 2 then
  		return true
  	else
  	 return false
    end
  end

  local specGrid = {}
  local i = 1
  for k,v in pairs(this.house.memory) do
    for k2,v2 in pairs(v) do
      specGrid[i] = {}
      specGrid[i].x = k
      specGrid[i].y = k2
      specGrid[i].equal = v2
      i = i + 1
    end
  end

  local start = {x = this.mypos.x, y = this.mypos.y, equal = 'ant'}
  local finish = {x = 1, y = 3, equal = 'void'}
  print(specGrid[2].y)
  local path = astar.path ( start, specGrid[2], specGrid, true, valid_node_func )
  if not path then
  	print ( "No valid path found" )
  else
  	for i, node in ipairs ( path ) do
  		print ( "Step " .. i .. " >> " .. node.x .. node.y )
  	end
  end

  local path = {}
  return path
end

function blue.goto(this) --следовать в точку
  if this.target.x ~= this.mypos.x and this.ai.isFreeToGoing(this, this.pDirX) then
    this.ai.cellAction(this, this.pDirX)
  elseif this.target.y ~= this.mypos.y and this.ai.isFreeToGoing(this, this.pDirY) then
    this.ai.cellAction(this, this.pDirY)
  else
    local dir
    if math.abs(this.target.x - this.mypos.x) > math.abs(this.target.y - this.mypos.y) then
      if this.pDirY == 2 then
        dir = 8
      else
        dir = 2
      end
      this.ai.cellAction(this, dir)
    elseif math.abs(this.target.x - this.mypos.x) < math.abs(this.target.y - this.mypos.y) then
      if this.pDirX == 6 then
        dir = 4
      else
        dir = 6
      end
      this.ai.cellAction(this, dir)
    end
  end
  if this.target.x == this.mypos.x and this.target.y == this.mypos.y then
    this.target = nil
  end
end

function blue.isFreeToGoing(this, direction)
  local target = this:getCell(direction)
  return target ~= 'wall' and target ~= 'house' and target ~= 'myhouse' and target ~= 'food'
end

function blue.cellAction(this, direction) --взаимодействие с клеткой
 local target = this:getCell(direction)
  if target == 'ground' then
    this:dig(direction)
  elseif target == 'void' then
    this:move(direction)
    this.ai.savePos(this, direction)
  elseif target == 'ant' then
    this:attack(direction)
  end
end

function blue.incToDir(x, y) --преобразует прибавку к координате в направление
  if x > 0 then
    return 6
  end
  if x < 0 then
    return 4
  end
  if y > 0 then
    return 8
  end
  if y < 0 then
    return 2
  end
end

return blue
