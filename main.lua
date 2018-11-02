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

wall_img = love.graphics.newImage("wall1.jpg")
sky_img = love.graphics.newImage("ciel.jpg")

wall = {
  s = {x = 237, y = 267},
  e = {x = 525, y = 267},
  h = 180
}

walls = {}
walls[1] = {
  s = {x = 237, y = 267},
  e = {x = 525, y = 267},
  c = {r=255, g=0, b=0},
  img = love.graphics.newImage("wall1.jpg")
}

walls[2] = {
  s = {x = 525, y = 267},
  e = {x = 685, y = 90},
  c = {r=0, g=255, b=0},
  img = love.graphics.newImage("wall2.jpg")
}

wallsorder = {}

for i=1, #walls, 1 do
  wallsorder[i] = walls[i]
end

mode =0--mode normal 1, mode first person 2, mode pseudo 3d 3, mode0 for help


function love.load()
  love.window.setMode(w, h)
  love.keyboard.setKeyRepeat(true)
  updateWallsOrder()
  love.mouse.setVisible(false)
end

function love.update()
  v = 10
  prec = {x = perso.x, y = perso.y}
  if (love.keyboard.isDown("d")) then
    rad = math.rad(perso.a)
    perso.x = perso.x+math.cos(rad)*v
    perso.y = perso.y+math.sin(rad)*v
  end
  if (love.keyboard.isDown("q")) then
    rad = math.rad(perso.a-180)
    perso.x = perso.x+math.cos(rad)*v
    perso.y = perso.y+math.sin(rad)*v
  end
  if (love.keyboard.isDown("z")) then
    rad = math.rad(perso.a-90)
    perso.x = perso.x+math.cos(rad)*v
    perso.y = perso.y+math.sin(rad)*v
  end
  if (love.keyboard.isDown("s")) then
    rad = math.rad(perso.a+90)
    perso.x = perso.x+math.cos(rad)*v
    perso.y = perso.y+math.sin(rad)*v
  end
  if (love.keyboard.isDown("space")) then
    perso.h = perso.h + 20
  end
  if (love.keyboard.isDown("lshift")) then
    perso.h = perso.h - 20
    if (perso.h<150) then perso.h = 150 end
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


function love.draw()
  
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
  elseif (mode == 2)then
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
  elseif(mode == 3) then
    love.graphics.draw(sky_img, 0, 0)
    
    love.graphics.setColor(0, 0, 255)
    hhorizon = (90-perso.h_vision_min)*h*2/perso.h_a_vision
    love.graphics.rectangle('fill', 0, hhorizon, w, h-hhorizon)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("mode 3")
    love.graphics.setColor(255, 0, 0)
    render3d()
    love.graphics.setColor(255, 255, 255)
  else
    love.graphics.print("Demos 3d walls wolfenstein like, Scott Hamilton © 2018", 150, 75);
    love.graphics.print("Change the render mode with tab", 20, 500);
    love.graphics.print("move with ZQSD.", 300, 200);
    love.graphics.print("Move your head with the mouse.", 500, 400);
    love.graphics.print("Fly up with space and fly down with left shift!!", 100, 350);
  end
  
  --love.graphics.draw(wall_img, 0, 0)
end

function love.keypressed(key)
  
  if (key == "tab") then
    mode = mode+1
    if (mode>3)then mode = 1 end
  end
  
end

function love.mousemoved(x, y, dx, dy)
  if (x ~= 400 and y ~= 300 and mode >0) then
    perso.a=perso.a+dx
    perso.rad = math.rad(perso.a-90)
    if (mode == 3) then
    perso.h_vision_min=perso.h_vision_min+dy
    perso.h_vision_max=perso.h_vision_max+dy
    end
  end
  if(x<10 or y<10 or x>790 or y>590) then
    love.mouse.setPosition(400, 300)
  end
end

function love.mousepressed(x, y)
  print("press at : "..x..", "..y)
end
