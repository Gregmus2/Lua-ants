require('object')
require('constants')
require('menu')

AIs = {}
local teamColors = {'red', 'blue', 'yellow', 'green', 'aqua', 'white', 'silver', 'orange'}
for f in io.popen("dir bots /B"):lines() do
  local bot = require('bots/' .. string.sub(f, 0, string.find(f, '.lua') - 1))
  if type(bot) ~= 'boolean' then
    table.insert(AIs, bot)
    AIs[#AIs].name = string.sub(f, 0, string.find(f, '.lua') - 1)
    if AIs[#AIs].color == nil then
      AIs[#AIs].color = teamColors[1]
      table.remove(teamColors, 1)
    else
      table.removeVal(teamColors, AIs[#AIs].color)
      table.sort(teamColors)
    end
  end
end

--инициализация случайностей
math.randomseed(os.time())

--массив, для записи в него созданных объектов
grid = {}

--массив муравьёв
ants = {}

--массив элементов панели
panel = {}

--сетка
panelW = 150
gridScale = 5
gridH = math.floor(love.graphics.getHeight() / (gridScale+1))
gridW = math.floor((love.graphics.getWidth() - panelW) / (gridScale+1))
  --инициализация сетки
for x=1,gridW do
  grid[x] = {}
  for y=1,gridH do
    grid[x][y] = {}
  end
end
  --заполнение землёй
for x=2,#grid-1 do
  for y=2,#grid[x]-1 do
    grid[x][y] = object:new(gridScale, x, y, grid, 'ground')
  end
end
  --заполнение стенки
for x=1,gridW do
  grid[x][1] = object:new(gridScale, x, 1, grid, 'wall')
  grid[x][gridH] = object:new(gridScale, x, gridH, grid, 'wall')
end
for y=1,gridH do
  grid[1][y] = object:new(gridScale, 1, y, grid, 'wall')
  grid[gridW][y] = object:new(gridScale, gridW, y, grid, 'wall')
end

--еда
foodCount = math.random((gridW-1) * (gridH-1) * 0.05, (gridW-1) * (gridH-1) * 0.07)
for i=1,foodCount do
  local x = math.random(2, gridW-1)
  local y = math.random(2, gridH-1)
  grid[x][y] = object:new(gridScale, x, y, grid, 'food')
end

--наполнение панели текстом
for i=1,#AIs do
  panel[i] = {}
  panel[i]['title'] = menu:addText(AIs[i].name, love.graphics.getWidth() - panelW/4*3, (i-1)*100+50, AIs[i].color)
  panel[i]['digs'] = menu:addText('digs:', love.graphics.getWidth() - panelW/6*5, (i-1)*100+50+15, 'white')
  AIs[i].digs = 0
  panel[i]['ants'] = menu:addText('ants:', love.graphics.getWidth() - panelW/6*5, (i-1)*100+50+30, 'white')
  AIs[i].ants = 0
  panel[i]['kills'] = menu:addText('kills:', love.graphics.getWidth() - panelW/6*5, (i-1)*100+50+45, 'white')
  AIs[i].kills = 0
end

function love.load()
  --команды
  for i=1,#AIs do
    ants[i] = {}
  end
  --создание гнезда
  houses = {}
  for i=1,#AIs do
    local x = math.random(math.floor((gridW-6)/#AIs)*(i-1)+4, math.floor((gridW-6)/#AIs)*i-4)
    local y = math.random(4, gridH-3)
    grid[x][y] = object:new(gridScale, x, y, grid, 'house')
    table.insert(houses, grid[x][y])
    for n=x-2,x+2 do
      for m=y-2,y+2 do
        if n ~= x or m ~= y then
          grid[n][m] = nil
        end
      end
    end
    AIs[i].houseCreate(grid[x][y])
  end
end

function love.keypressed(key)
  --создание муравья
  if key == 'space' then
    for i=1,#ants do
      common.spawnAnt(houses[i], AIs[i], ants[i])
    end
  end
  if key == 'q' then
    local next = next(ants[1])
    ants[1][next].ai.debug(ants[1][next])
  end
end

function love.update(dt)
  for k,v in pairs(ants) do
    for k2,v2 in pairs(v) do
      v2.ai.update(v2)
    end
  end
  -- изменение текста в панели
  for k,v in pairs(panel) do
    for k2,v2 in pairs(v) do
      if k2 ~= 'title' then
        v2:editText(k2 .. ': ' .. AIs[k][k2])
      end
    end
  end
end

function love.mousepressed(x, y, button)

end

function love.mousereleased(x, y, button)

end

function love.draw()
  -- прорисовка объектов
  for k,v in pairs(grid) do
    for k2,v2 in pairs(v) do
      v2:draw()
    end
  end
  --отрисовка текста в панели
  for k,v in pairs(panel) do
    for k2,v2 in pairs(v) do
      v2:draw()
    end
  end
end
