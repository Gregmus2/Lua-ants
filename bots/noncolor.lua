noncolor = {

  houseCreate = function(house)

  end,

  start = function(this)

  end,

  update = function(this)
    local target = math.random(4) * 2
    local targetType = this:getCell(target)
    if targetType == 'ground' then
      this:dig(target)
    elseif targetType == 'food' then
      this:takeFood(target)
    elseif targetType == 'house' then
      this:putFood(target)
    elseif targetType == 'ant' then
      this:attack(target)
    end
    this:move(target)
  end,
}

return noncolor
