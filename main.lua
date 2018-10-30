io.stdout:setvbuf('no')

-- Empèche Love de filtrer les contours des images quand elles sont redimentionnées
-- Indispensable pour du pixel art
love.graphics.setDefaultFilter("nearest", "nearest")

-- Cette ligne permet de déboguer pas à pas dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end

require("mathplus")

w = 800
h = 600

perso = {}
perso.x = 400
perso.y = 500
perso.a = 0
perso.rad = math.rad(perso.a)
perso.a_vision = 150 
perso.h = 150
perso.h_vision_min = 40
perso.h_vision_max = 260
perso.h_a_vision = perso.h_vision_max-perso.h_vision_min

wall = {
  s = {x = 237, y = 267},
  e = {x = 525, y = 267},
  h = 180
}

walls = {}
walls[1] = {
  s = {x = 237, y = 267},
  e = {x = 525, y = 267},
  c = {r=255, g=0, b=0}
}

walls[2] = {
  s = {x = 525, y = 267},
  e = {x = 685, y = 90},
  c = {r=0, g=255, b=0}
}

wallsorder = {}

for i=1, #walls, 1 do
  wallsorder[i] = walls[i]
end

mode = 1--mode normal 1, mode first person 0, mode pseudo 3d 2

function love.load()
  love.window.setMode(w, h)
  love.keyboard.setKeyRepeat(true)
  updateWallsOrder()
end

function love.update()
end


function love.draw()
  love.graphics.setColor(0, 0, 255)
  hhorizon = 280
  love.graphics.rectangle('fill', 0, hhorizon, w, h-hhorizon)
  love.graphics.setColor(255, 255, 255)
  if (mode == 1) then
    love.graphics.print("mode 1")
    love.graphics.circle("fill", perso.x, perso.y, 3) -- perso
    for i = 1,#walls,1 do
      wall.s = walls[i].s
      wall.e = walls[i].e
      love.graphics.line(wall.s.x, wall.s.y, wall.e.x, wall.e.y) --wall
    end
    rad = math.rad(perso.a-90)
    love.graphics.line(perso.x, perso.y, perso.x+math.cos(rad)*20, perso.y+math.sin(rad)*20);  --perso eye direction
    rad = math.rad(perso.a-90-(perso.a_vision/2))
    love.graphics.line(perso.x, perso.y, perso.x+math.cos(rad)*1000, perso.y+math.sin(rad)*1000); -- angle left vision
    rad = math.rad(perso.a-90+(perso.a_vision/2))
    love.graphics.line(perso.x, perso.y, perso.x+math.cos(rad)*1000, perso.y+math.sin(rad)*1000); -- angle right vision
  elseif (mode == 0)then
    love.graphics.print("mode 2")
    love.graphics.setColor(0, 255, 0)
    v = {x = 400-perso.x, y = 500-perso.y }
    love.graphics.circle("fill", 400, 500, 3) --perso
    for i = 1,#walls,1 do
      wall.s = walls[i].s
      wall.e = walls[i].e
      p_s = pRel2Perso(wall.s)
      p_e = pRel2Perso(wall.e)
      love.graphics.line(p_s.x, p_s.y, p_e.x, p_e.y) --wall
    end
    love.graphics.line(400, 500, 400, 480);  --perso eye direction
    rad = math.rad(-perso.a_vision/2-90)
    love.graphics.line(400, 500, 400+math.cos(rad)*1000, 500+math.sin(rad)*1000); -- angle left vision
    rad = math.rad(perso.a_vision/2-90)
    love.graphics.line(400, 500, 400+math.cos(rad)*1000, 500+math.sin(rad)*1000); -- angle right vision
    love.graphics.setColor(255, 255, 255)
  else
    love.graphics.print("mode 3")
    love.graphics.setColor(255, 0, 0)
    render3d()
    love.graphics.setColor(255, 255, 255)
  end
end

function love.keypressed(key)
  v = 10
  prec = {x = perso.x, y = perso.y}
  if (key == "q") then
    perso.a = perso.a-10;
    perso.rad = math.rad(perso.a-90)
  elseif (key == "d") then
    perso.a = perso.a+10;
    perso.rad = math.rad(perso.a-90)
  elseif (key == "right") then
    rad = math.rad(perso.a)
    perso.x = perso.x+math.cos(rad)*v
    perso.y = perso.y+math.sin(rad)*v
  elseif (key == "left") then
    rad = math.rad(perso.a-180)
    perso.x = perso.x+math.cos(rad)*v
    perso.y = perso.y+math.sin(rad)*v
  elseif (key == "up") then
    rad = math.rad(perso.a-90)
    perso.x = perso.x+math.cos(rad)*v
    perso.y = perso.y+math.sin(rad)*v
  elseif (key == "down") then
    rad = math.rad(perso.a+90)
    perso.x = perso.x+math.cos(rad)*v
    perso.y = perso.y+math.sin(rad)*v
  elseif (key == "space") then
    mode = mode-1
    if (mode<0)then mode = 2 end
  end
  if (perso.x ~= prec.x or perso.y ~= prec.y) then
    replaced = false
    pmove = {p1={x=prec.x,y=prec.y},p2={x=perso.x,y=perso.y}}
    for i = 1,#walls,1 do
      wall.s = walls[i].s
      wall.e = walls[i].e
      if (segmentSecant(pmove, {p1=wall.s, p2=wall.e})) then
        perso.x = prec.x
        perso.y = prec.y
        replaced = true
        break
      end
    end
    if (not replaced) then
      updateWallsOrder()
    end
  end
end

function love.mousepressed(x, y)
  print("press at : "..x..", "..y)
end
