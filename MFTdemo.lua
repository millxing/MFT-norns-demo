-- Twister Demo
-- v2.2.8 @spunoza
-- llllllll.co/t/?????
-- demo for MIDI
-- Fighter Twister

-- This script assumes the default 
-- MFT configuration, which can
-- be chosen by selecting a factory
-- reset from the MF Utility menu.

local bank
local maxscreen = 10

local channel = 99
local cc = 99
local value = 99
local mftype = ''

local twists = {}
local pushes = {}
local sides = {}
local mx = {}
local mn = {}

engine.name = 'PolyPerc'

-- midi code
m2 = midi.connect(2) -- assumes Twister is assigned to MIDI device 2 in norns

bank = 1

m2.event = function(data)
  local d = midi.to_msg(data)

  if d.type=="cc" then
    --print(" XXX  type = " .. d.type .. "  ch = " .. d.ch .. "   cc = " .. d.cc .. "   val = " .. d.val)
    channel = d.ch; cc = d.cc; value = d.val
    
    if channel==4 and cc==0 then bank = 1; if value==127 then print("Change Bank   : bank = " .. bank) end; mftype = 'change bank'; end
    if channel==4 and cc==1 then bank = 2; if value==127 then print("Change Bank   : bank = " .. bank) end; mftype = 'change bank'; end
    if channel==4 and cc==2 then bank = 3; if value==127 then print("Change Bank   : bank = " .. bank) end; mftype = 'change bank'; end
    if channel==4 and cc==3 then bank = 4; if value==127 then print("Change Bank   : bank = " .. bank) end; mftype = 'change bank'; end
  
    if channel ~= 4 then
      cc = cc % 16
    end
    
    if channel==1 then twistEncoder(bank, cc, value) end
    if channel==2 then pushEncoder(bank,cc, value) end
    
    if channel==4 and cc>3 then pushSideButton(bank, cc, value) end
    
    redraw_twister()
    redraw()     
    
  end
end

function twistEncoder(bank, cc, value)
  print("Twist Encoder : bank = " .. bank .. "  cc = " .. cc .. "  value = " .. value)
  twists[(bank - 1) * 16 + cc] = encoder_to_value(value, mn[(bank - 1) * 16 + cc], mx[(bank - 1) * 16 + cc])
  mftype = 'twist'
end

function pushEncoder(bank, cc, value)
  print("Push Encoder  : bank = " .. bank .. "  cc = " .. cc .. "  value = " .. value)
  pushes[(bank - 1) * 16 + cc] = value
  mftype = 'push'
end

function pushSideButton(bank, cc, value)
  cc = cc - (bank-1)*6
  print("Push Button   : bank = " .. bank .. "  cc = " .. cc .. "  value = " .. value)
  sides[cc] = value
  mftype = 'side'
end

function redraw_twister()
    m2:cc(bank-1,127,4)  
    local j
    local k
    for j = 0,3 do
        for k = 0,15 do
          m2:cc(k+(j*16),value_to_encoder(twists[k+(j*16)],mn[k+(j*16)],mx[k+(j*16)]),1)
          m2:cc(k+(j*16),value_to_encoder(pushes[k+(j*16)],mn[k+(j*16)],mx[k+(j*16)]),2)
        end
    end
end

function value_to_encoder(val,vemn,vemx)
   pct = (val-vemn) / (vemx-vemn)
   return round(127*pct)
end    
function encoder_to_value(enc,evmn,evmx)
   pct = enc / 127
   return round(evmn + (evmx-evmn) * pct)
end  

function init()
  -- initialization
  local i
  for i = 0,63 do 
    twists[i] = 0
    pushes[i] = 0
    sides[i] = 0
    mx[i] = 127
    mn[i] = 0
  end
  
  redraw_twister()
  redraw()    
end

function key(n,z)
  -- key actions: n = number, z = state
end

function enc(n,d)
  -- encoder actions: n = number, d = delta
end

function redraw()
    screen.clear()
    screen.font_size(8); 
    screen.level(maxscreen)
    local g = 0
    g = g + 1
    screen.move(0,10+9*(g-1))
    screen.text("type     : " .. mftype)
    g = g + 1
    screen.move(0,10+9*(g-1))
    screen.text("bank     : " .. bank)
    g = g + 1
    screen.move(0,10+9*(g-1))
    screen.text("channel  : " .. channel)
    g = g + 1
    screen.move(0,10+9*(g-1))
    screen.text("cc        : " .. cc)
    g = g + 1
    screen.move(0,10+9*(g-1))
    screen.text("val       : " .. value)
    screen.update()
end

-- round to nearest integer
function round(num)
    under = math.floor(num)
    upper = math.floor(num) + 1
    underV = -(under - num)
    upperV = upper - num
    if (upperV > underV) then; return under; else return upper; end
end

