function dist(a, b)
  l = b.x-a.x
  m = b.y-a.y
  return math.sqrt(l*l+m*m)
end

function p2angle(p1, p2)
  return math.atan2(p1.x-p2.x,p1.y-p2.y)
end

function pointFromVec(point, line_p1, line_p2)
  D = {x = line_p2.x-line_p1.x, y = line_p2.y-line_p1.y}
  T = {x = point.x-line_p1.x, y = point.y-line_p1.y}
  return D.x*T.y-D.y*T.x
end

function wall_sInVision()
  rad = math.rad(perso.a-90-(perso.a_vision/2))
  d = pointFromVec(wall.s, perso, {x = perso.x+math.cos(rad)*1000, y = perso.y+math.sin(rad)*1000})
  if (d<=0)then return false end

  rad = math.rad(perso.a-90+(perso.a_vision/2))
  d = pointFromVec(wall.s, perso, {x = perso.x+math.cos(rad)*1000, y = perso.y+math.sin(rad)*1000})
  if (d>=0)then return false end
  return true
end
function wall_eInVision()
  rad = math.rad(perso.a-90-(perso.a_vision/2))
  d = pointFromVec(wall.e, perso, {x = perso.x+math.cos(rad)*1000, y = perso.y+math.sin(rad)*1000})
  if (d<=0)then return false end

  rad = math.rad(perso.a-90+(perso.a_vision/2))
  d = pointFromVec(wall.e, perso, {x = perso.x+math.cos(rad)*1000, y = perso.y+math.sin(rad)*1000})
  if (d>=0)then return false end
  return true
end

function wallInPersoVision(whats_in)
  whats_in.s = wall_sInVision()
  whats_in.e = wall_eInVision()
  if (whats_in.s or whats_in.e)then return true end
  res = {}
  cutPointAngleVisionAndWall(res)
  return res.cut_left and res.cut_right
end

function segmentSecant(A_B, C_D)
  CforA_B = pointFromVec(C_D.p1, A_B.p1, A_B.p2)
  DforA_B = pointFromVec(C_D.p2,A_B.p1, A_B.p2)
  if (CforA_B>0 and DforA_B>0) then return false end
  if (CforA_B<0 and DforA_B<0)then return false end
    
  AforC_D = pointFromVec(A_B.p1, C_D.p1, C_D.p2)
  BforC_D = pointFromVec(A_B.p2,C_D.p1, C_D.p2)
  if (AforC_D>0 and BforC_D>0) then return false end
  if (AforC_D<0 and BforC_D<0)then return false end
  
  return true
end

function cutPointAngleVisionAndWall(res, point)
  res.cut_left = false
  res.cut_right = false
  rad = math.rad(perso.a-90-(perso.a_vision/2))
  p_leftfield = {x = perso.x+math.cos(rad)*1000, y = perso.y+math.sin(rad)*1000}
  rad = math.rad(perso.a-90+(perso.a_vision/2))
  p_rightfield = {x = perso.x+math.cos(rad)*1000, y = perso.y+math.sin(rad)*1000}
  if(point ~= nil) then
    wall_f = {a = 0, b = 0}
    wall_f.a = (wall.e.y-wall.s.y)/(wall.e.x-wall.s.x)
    wall_f.b = wall.s.y-(wall_f.a*wall.s.x)
    
    left_field_f = {a = 0, b = 0}
    left_field_f.a = (p_leftfield.y-perso.y)/(p_leftfield.x-perso.x)
    left_field_f.b = perso.y-(left_field_f.a*perso.x)
    right_field_f = {a = 0, b = 0}
    right_field_f.a = (p_rightfield.y-perso.y)/(p_rightfield.x-perso.x)
    right_field_f.b = perso.y-(right_field_f.a*perso.x)
  end
  if (segmentSecant( {p1={x=perso.x,y=perso.y},p2=p_leftfield},{p1=wall.s,p2=wall.e} )) then --cut at left_field
    if (point ~= nil) then 
      a = wall_f.a-left_field_f.a
      r = left_field_f.b-wall_f.b
      point.x  = r/a
      point.y = wall_f.a*point.x+wall_f.b
    end
    res.cut_left = true
  end
  if (segmentSecant( {p1={x=perso.x,y=perso.y},p2=p_rightfield},{p1=wall.s,p2=wall.e} )) then --cut at right field
    if (point ~= nil) then 
      a = wall_f.a-right_field_f.a
      r = right_field_f.b-wall_f.b
      point.x  = r/a
      point.y = wall_f.a*point.x+wall_f.b
    end
    res.cut_right = true
  end
end

function pRel2Perso(p)
  a = p2angle(perso, p)
  d = dist(perso, p)
  rad= a+math.rad(perso.a-90)
  return {x = 400-math.cos(rad)*d, y = 500+math.sin(rad)*d}
end

function render3d()
  for i = 1,#wallsorder,1 do
    wall.s = {x = wallsorder[i].s.x, y = wallsorder[i].s.y}
    wall.e = {x = wallsorder[i].e.x, y = wallsorder[i].e.y}
    love.graphics.setColor(wallsorder[i].c.r, wallsorder[i].c.g, wallsorder[i].c.b)
    whats_in = {}
    if (wallInPersoVision(whats_in)) then
      
      isInverse = pointFromVec(perso, wall.s, wall.e)<0
      
      perso_rel = {x = 400, y = 500}
      
      wall_rel = {s={},e={}}
      
      left_field = 180-perso.a_vision/2
      right_field = 180+perso.a_vision/2
      if (not whats_in.e or not whats_in.s) then
        point = {x = 0, y = 0}
        res = {}
        cutPointAngleVisionAndWall(res, point)
        if (dir == -1) then print("error not cutting!!") end
        if (res.cut_left) then
          wall_angle_s = left_field
          wall_rel.s = pRel2Perso(point)
          if (isInverse) then
            wall_rel.e = pRel2Perso(wall.s)
          else
            wall_rel.e = pRel2Perso(wall.e)
          end
        wall_angle_e = 180-math.deg(p2angle(perso_rel, wall_rel.e))
          
        end
        if (res.cut_right) then
          wall_angle_e = right_field
          wall_rel.e = pRel2Perso(point)
          if (not cut_left) then
            if (isInverse) then
              wall_rel.s = pRel2Perso(wall.e)
            else
              wall_rel.s = pRel2Perso(wall.s)
            end
            wall_angle_s = 180-math.deg(p2angle(perso_rel, wall_rel.s))
          end
        end
      else
        wall_rel.s = pRel2Perso(wall.s)
        wall_rel.e = pRel2Perso(wall.e)
        wall_angle_s = 180-math.deg(p2angle(perso_rel, wall_rel.s))
        wall_angle_e = 180-math.deg(p2angle(perso_rel, wall_rel.e))
      end
      
      if (wall_rel.s.x == nil) then print("nil!!") end
            
      if (wall_angle_e<0)then wall_angle_e = wall_angle_e+360 end
      if (wall_angle_s<0)then wall_angle_s = wall_angle_s+360 end

      
      inv = false
    
      left_wall_a = wall_angle_s
      right_wall_a = wall_angle_e

      vec_a = wall_angle_e-wall_angle_s
      if (left_wall_a>360) then left_wall_a = left_wall_a-360 end
      if (right_wall_a>360) then right_wall_a = right_wall_a-360 end
      startx = (left_wall_a-left_field)*w/perso.a_vision
      endx = (right_wall_a-left_field)*w/perso.a_vision
      
      dist_s = dist(perso_rel, wall_rel.s)
      wall_angle_s_top = math.abs(math.deg(p2angle({x = 0, y = -perso.h} , {x = dist_s, y = -wall.h})))
      wall_angle_s_bottom = math.abs(math.deg(p2angle({x = 0, y = -perso.h} , {x = dist_s, y = 0})))
      
      starty_s = (wall_angle_s_top-perso.h_vision_min)*h*2/perso.h_a_vision
      endy_s = (wall_angle_s_bottom-perso.h_vision_min)*h*2/perso.h_a_vision
      
      dist_e = dist(perso_rel, wall_rel.e)
      wall_angle_e_top = math.abs(math.deg(p2angle({x = 0, y = -perso.h} , {x = dist_e, y = -wall.h})))
      wall_angle_e_bottom = math.abs(math.deg(p2angle({x = 0, y = -perso.h} , {x = dist_e, y = 0})))
      
      starty_e = (wall_angle_e_top-perso.h_vision_min)*h*2/perso.h_a_vision
      endy_e = (wall_angle_e_bottom-perso.h_vision_min)*h*2/perso.h_a_vision
      
      love.graphics.polygon("fill", startx, starty_s, startx, endy_s, endx, endy_e, endx, starty_e)
    end
    love.graphics.setColor(255, 255, 255)
  end
end 

function render3dOld()
  whats_in = {}
  if (wallInPersoVision(whats_in)) then
    
    isInverse = pointFromVec(perso, wall.s, wall.e)<0
    
    perso_rel = {x = 400, y = 500}
    
    wall_rel = {s={},e={}}
    
    left_field = 180-perso.a_vision/2
    right_field = 180+perso.a_vision/2
    if (not whats_in.e or not whats_in.s) then
      point = {x = 0, y = 0}
      res = {}
      cutPointAngleVisionAndWall(res, point)
      if (dir == -1) then print("error not cutting!!") end
      if (isInverse) then 
        res.cut_left = not res.cut_left
        res.cut_right = not res.cut_right
        x = left_field
        left_field = right_field
        right_field = x
      end
      if (res.cut_left) then
        wall_angle_s = left_field
        wall_rel.s = pRel2Perso(point)
        wall_rel.e = pRel2Perso(wall.e)
        wall_angle_e = 180-math.deg(p2angle(perso_rel, wall_rel.e))
      end
      if (res.cut_right) then
        wall_angle_e = right_field
        wall_rel.e = pRel2Perso(point)
        if (not cut_left) then
          wall_rel.s = pRel2Perso(wall.s)
          wall_angle_s = 180-math.deg(p2angle(perso_rel, wall_rel.s))
        end
      end
      if (isInverse) then 
        x = left_field
        left_field = right_field
        right_field = x
      end
    else
      wall_rel.s = pRel2Perso(wall.s)
      wall_rel.e = pRel2Perso(wall.e)
      wall_angle_s = 180-math.deg(p2angle(perso_rel, wall_rel.s))
      wall_angle_e = 180-math.deg(p2angle(perso_rel, wall_rel.e))
    end
          
    if (wall_angle_e<0)then wall_angle_e = wall_angle_e+360 end
    if (wall_angle_s<0)then wall_angle_s = wall_angle_s+360 end

    
    inv = false
    
    
    portion_size_a = math.rad(1)
    nb = math.floor(math.abs(wall_angle_s-wall_angle_e)/portion_size_a)
    --print("nb : "..nb)
    vec = {x = wall_rel.e.x-wall_rel.s.x, y = wall_rel.e.y-wall_rel.s.y}
    d = dist({x = 0, y = 0}, vec)
    vec.x = vec.x
    vec.y = vec.y
    
    for i = 0, nb-1, 1 do
      pc = (i+1)/nb
      if (i == 0) then
        left_wall_a = wall_angle_s
      else
        left_wall_a = prev_wall_e
      end
      
      vec_a = wall_angle_e-wall_angle_s
      right_wall_a = wall_angle_s+vec_a*pc
      prev_wall_e = right_wall_a
      
      if (left_wall_a>360) then left_wall_a = left_wall_a-360 end
      if (right_wall_a>360) then right_wall_a = right_wall_a-360 end
      if (i == 0) then startx = (left_wall_a-left_field)*w/perso.a_vision end
      endx = (right_wall_a-left_field)*w/perso.a_vision
      p_portion = {x = wall_rel.s.x+vec.x*pc, y = wall_rel.s.y+vec.y*pc}
      dist_e_portion = dist(perso_rel, p_portion)
      wall_angle_e_top = math.abs(math.deg(p2angle({x = 0, y = -perso.h} , {x = dist_e_portion, y = -wall.h})))
      wall_angle_e_bottom = math.abs(math.deg(p2angle({x = 0, y = -perso.h} , {x = dist_e_portion, y = 0})))
      
      starty_e = (wall_angle_e_top-perso.h_vision_min)*h*2/perso.h_a_vision
      endy_e = (wall_angle_e_bottom-perso.h_vision_min)*h*2/perso.h_a_vision
      
      if (i == 0) then
        if (flip) then x = w-endx
        else x = startx end
        love.graphics.rectangle("fill", x, starty_e, math.abs(endx-startx), math.abs(endy_e-starty_e))
      else
        if (flip) then x = w-endx
        else x = before_endx end
        love.graphics.rectangle("fill", x, starty_e, math.abs(endx-before_endx), math.abs(endy_e-starty_e))
      end
      before_endx = endx
    end
  end
end

function updateWallsOrder()
  tmpwalls = {}
  wallsorder = {}
  for i = 1, #walls, 1 do tmpwalls[i] = walls[i]
    tmpwalls[i].d = nil
  end
  while #tmpwalls>0 do
    bestindex = 0
    bestdist = 0
    for i=1, #tmpwalls,1 do
      if (tmpwalls[i].d == nil) then
        d1 = dist(perso, tmpwalls[i].s)
        d2 = dist(perso, tmpwalls[i].e)
        d = math.min(d1, d2)
        tmpwalls[i].d = d
      end 
      if i == 1 or tmpwalls[i].d > bestdist then
        bestdist = tmpwalls[i].d
        bestindex = i
      end
    end
    wallsorder[#wallsorder+1] = tmpwalls[bestindex]
    table.remove(tmpwalls, bestindex)
  end
end