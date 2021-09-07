-------------------------------------------------------------------------------
----------------------------- Gas Mitte Piepser -------------------------------
-------------------------------------------------------------------------------
beepmid=1 ------------------ Pipser 1=an, 0=aus -------------------------------
rangeschubmid=10 ----------- Schub mitte (für totpunkt Piepser -100 bis +100) -
rangeschubmid2=-10 ----------Schub mitte-(für totpunkt Piepser -100 bis +100) -
beepgasmitte=0 --Veränderbarer Beep-Punkt, Gas mitte ist 0, soll der Pipser ---
------------- schon bei z.B. -50% (Gas viertel) piepsen sind das -50 ----------
beeppause=0 -------------------------------------------------------------------
-------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------
--------------------- Akku Warning --------------------------------------------
Zellpowerwarn=3.5 --- Angabe für Warnung in Volt ------------------------------
-------------------------------------------------------------------------------

local head=0   
local pitch=0
local roll=0
local modus=0
local versy=20 ----- Y Pos obere Ecke Künstlicher Horizont 
local versx=84 ----- X Pos obere Ecke 
local versy=versy+21
local tab=0
local tabm=0

local timer2=0 
local timerflag1=0   
local timerflag2=0
local timerausgabe="0m0s"
local Schalter=0

 
local VoltMin=100
local ausgVoltMin=0
local ausgA=0
local ausgAccX=0
local ausgAccY=0
local ausgAccX2=0
local ausgAccY2=0 
local SendeleistungX1=0
 
LQH=0
LQHswitch=0
LQHsave=10
LQ=0
LQswitch=0
LQsave=100

ausgCurr=0
ausgabeleistung=0 
ausgrssi=110
pitchx2=0
rollx2=0
warnpause=0
Batterie=0

Mag=0
MagStrt=0
MagSwitch=0




local function akkuwarn ()
 if Zellpowerwarn >= (getValue("VFAS")/zell) and (getValue("VFAS")~=0) then 
  if warnpause<=0 then warnpause=20  
  playTone(100, 400, 200, 0,5) 
  end
  warnpause=warnpause-1
  warnblink=1
  end

end


local function mbeep ()
   schub = getValue('thr')
  if (schub>(rangeschubmid2*10.24)+(beepgasmitte*10.24) and schub<(rangeschubmid*10.24)+(beepgasmitte*10.24)) then 
  if (schub<(rangeschubmid2*10.24)+(beepgasmitte*10.24) or schub<(rangeschubmid*10.24)+(beepgasmitte*10.24)) then beeppause=0 end 
  if (beeppause<=0 and beepmid==1) then 
     beeppause=40
     playTone(4000, 100, 1000, PLAY_BACKGROUND,0) 
  end
     beeppause=beeppause-1
end
end

------------------------------------------------------------------------------- 
local function run(event)

if Schalter==0 then


map=getValue("Tmp1")
maparm = string.sub(map, 5, 5)
mapmode = string.sub(map, 4, 4)
mapmode2 = string.sub(map, 3, 3)
rss=getRSSI()

Batterie=getValue("RxBt")*10
Batterie=math.floor(Batterie)
Batterie=Batterie/10

zell=1
if Batterie>3.0  then zell=1 end 
if Batterie>4.2 then zell=2 end 
if Batterie>9.2 then zell=3 end 
if Batterie>13 then zell=4 end 
if Batterie>16.8 then zell=5 end 
if Batterie>21 then zell=6 end 

warnblink=0
akkuwarn () 
Link=getValue("RQly")
LQ=Link
LinkSp=getValue("RFMD")


Current=getValue("Capa")
if ausgCurr<Current then ausgCurr=Current end

Strom=getValue("Curr")*100
Strom=math.floor(Strom)
Strom=Strom/100


mode=getValue("FM")

if mode~=0 then

nBeginn, nEnde = string.find(mode, "*") 
if nBeginn~=nil then maparm="1" 
 mode=string.gsub ( mode, "*", "" ) 
else
maparm="5"
end
else 
maparm="2"
mode="NONE"
end

Herz=getValue("RFMD")
LQH=Herz
if Herz==0 then Herz=4 end
if Herz==1 then Herz=50 end
if Herz==2 then Herz=150 end
  

mbeep ()

lcd.clear()

 
roll = getValue("Roll")
roll=math.floor(math.deg(roll),1)

pitch=getValue("Ptch")
pitch=math.floor(math.deg(pitch),1) 



SendeleistungX0= getValue("TPWR") 
rollx2=(math.floor(rollx2*10))/10
pitchx2=(math.floor(pitchx2*10))/10

if ausgAccY2<rollx2 and maparm=="5" then ausgAccY2=rollx2 end   -------------- Auswertung
if ausgAccY>rollx2 and maparm=="5" then ausgAccY=rollx2 end
if ausgAccX>pitchx2 and maparm=="5" then ausgAccX=pitchx2 end
if ausgAccX2<pitchx2 and maparm=="5" then ausgAccX2=pitchx2 end

if SendeleistungX0>SendeleistungX1 and maparm=="5" then SendeleistungX1=SendeleistungX0 end


SendeleistungX0=SendeleistungX0*100

SendeleistungX0= math.floor(SendeleistungX0)/100


-- Kompass

head=getValue("Yaw")
head=math.floor(math.deg(head))
if head<=-1 then
  head=360+head
end

if MagSwitch==0 and maparm=="5" then 
  MagStrt=head
  MagSwitch=1  
end 

Mag=MagStrt-head
if Mag<=-1 then
  Mag=360+Mag
end
Mag=Mag-360
Mag=math.abs(Mag)
if Mag==360 then Mag=0 end

-- Link Quality


if LQHswitch==0 and maparm=="5" then LQHswitch=1 end
if LQHsave>LQH and maparm=="5" then LQHsave=LQH end

if LQswitch==0 and maparm=="5" then LQswitch=1 end
if LQsave>LQ and LQHsave==LQH and maparm=="5" then LQsave=LQ end
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------


PitchLine=(pitch/5)+versy
RollLine= (roll/5)+85+21 


if event==EVT_MINUS_FIRST or event==EVT_MINUS_RPT then
Schalter=1
end

-------------------------------------------------------------------------------
------------------------------Timer -------------------------------------------
-------------------------------------------------------------------------------


if event==EVT_PLUS_FIRST or event==EVT_PLUS_RPT then
        timer2=0
timer=0
timerflag1=0
timerflag2=0
timerausgabe="0m0s"
end


if maparm=="5" then timerflag1=1 end




if timerflag1==1 then
  timer1=getTime()
  timer1=timer1-timer2
  timerausgabes=math.floor(timer1/100)
  timerausgabem=math.floor(timerausgabes/60)
  timerausgabes=timerausgabes-(timerausgabem*60)
  timerausgabe= (timerausgabem.."m"..timerausgabes.."s")
  
  
  --timerausgabe=timer1
  
  timerflag1=2
 end
 
if timerflag1==0 then
  timerausgabe="0m0s"
  timer2 = getTime()
end





-------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------------------------------------
-------------------------------------- Horizont -------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

rollx=getValue("Roll")*90
rollx=roll
hor=((getValue("Ptch")*100)/8)*-1

 --------------------------------
for i = 40,1,-1
do
  
 
 hor=math.floor(hor)
 
 rollx=math.floor(rollx)
 
 
 if SendeleistungX0>=0 then 
     
if (rollx<=45 and rollx>=-45 and SendeleistungX0>=0) then 
  ausgabex=(math.cos(3.14*rollx/180)*i+(versx+21))
  ausgabey=((math.sin(3.14*rollx/180)* -1)*i+versy)+hor*2
  lcd.drawLine(ausgabex,ausgabey,ausgabex,60, SOLID, FORCE+GREY(5))
rollx=rollx-180 
  ausgabex=(math.cos(3.14*rollx/180)*i+(versx+21))
  ausgabey=((math.sin(3.14*rollx/180)* -1)*i+versy)+hor*2
  lcd.drawLine(ausgabex,ausgabey,ausgabex,60, SOLID, FORCE+GREY(5))
rollx=rollx+180

end

if (rollx<=-45 and rollx>=-90 and SendeleistungX0>=0) then
  ausgabex=(math.cos(3.14*rollx/180)*i+(versx+21))
  ausgabey=((math.sin(3.14*rollx/180)* -1)*i+versy)+hor*2
  lcd.drawLine(ausgabex,ausgabey,80,ausgabey, SOLID, FORCE+GREY(5))
rollx=rollx-180
  ausgabex=(math.cos(3.14*rollx/180)*i+(versx+21))
  ausgabey=((math.sin(3.14*rollx/180)* -1)*i+versy)+hor*2
  lcd.drawLine(ausgabex,ausgabey,80,ausgabey, SOLID, FORCE+GREY(5))
rollx=rollx+180  

end 

 if (rollx>=45 and rollx<=90 and SendeleistungX0>=0) then
  ausgabex=(math.cos(3.14*rollx/180)*i+(versx+21))
  ausgabey=((math.sin(3.14*rollx/180)* -1)*i+versy)+hor*2
  lcd.drawLine(ausgabex,ausgabey,125,ausgabey, SOLID, FORCE+GREY(5))
rollx=rollx-180
  ausgabex=(math.cos(3.14*rollx/180)*i+(versx+21))
  ausgabey=((math.sin(3.14*rollx/180)* -1)*i+versy)+hor*2
  lcd.drawLine(ausgabex,ausgabey,125,ausgabey, SOLID, FORCE+GREY(5))
rollx=rollx+180  

end

else

end
end 
------------------------------------- Umfeld löschen----------------------------------------

 lcd.drawFilledRectangle(0, 0, 212, 20, ERASE)
 lcd.drawFilledRectangle(0, 0, 84, 64, ERASE)
 lcd.drawFilledRectangle(127, 0, 90, 64, ERASE)
 lcd.drawFilledRectangle(0, 62, 212, 5, ERASE)

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

 lcd.drawRectangle(84, 20, 43, 41, ERASE) 
 lcd.drawRectangle(84, 20, 43, 41, 0) 



lcd.drawLine(94,40,116,40,SOLID,FORCE) 
lcd.drawLine(98,30,112,30,SOLID,FORCE)
lcd.drawLine(98,50,112,50,SOLID,FORCE)
lcd.drawLine(102,35,108,35,SOLID,FORCE)
lcd.drawLine(102,55,108,55,SOLID,FORCE)
lcd.drawLine(102,25,108,25,SOLID,FORCE)
lcd.drawLine(102,45,108,45,SOLID,FORCE)

lcd.drawLine(105,20,105,60,SOLID,FORCE)

-------------------------------------------------------------------------
-------------------------------------------------------------------------


rollx=roll*0.9
pitchx=pitch*0.9
Batterie=Batterie/zell

Batterie=(math.floor(Batterie*100))/100


lcd.drawRectangle(1,2,15,7,0)
lcd.drawFilledRectangle(16,3,1,5,0)
if Batterie>=(3.5) then lcd.drawFilledRectangle(3,4,2,3,0) end
if Batterie>=(3.7) then lcd.drawFilledRectangle(6,4,2,3,0) end
if Batterie>=(3.9) then lcd.drawFilledRectangle(9,4,2,3,0) end
if Batterie>=(4.1) then lcd.drawFilledRectangle(12,4,2,3,0) end

x=155 
lcd.drawLine(x,2,6+x,2,SOLID,FORCE)
lcd.drawLine(1+x,4,5+x,4,SOLID,FORCE)
lcd.drawLine(2+x,6,4+x,6,SOLID,FORCE)
lcd.drawLine(3+x,8,3+x,8,SOLID,FORCE)
lcd.drawLine(0,0,212,0,SOLID,FORCE)
lcd.drawLine(0,10,212,10,SOLID,FORCE)

lcd.drawText(8,13, "ARM TIME: "..timerausgabe,SMLSIZE) -------------------------- Timer


batt=Batterie*zell 

if warnblink==1 then 
lcd.drawText(20, 2,(batt).."V "..zell.."S", 0+BLINK+INVERS, FORCE) 
else
lcd.drawText(20, 2,(batt).."V "..zell.."S", 0, FORCE) 
end
lcd.drawText(163,2, rss) 
lcd.drawText(140,13, "V. Zell: "..Batterie.."V",SMLSIZE) -------------------------- Volt/Zelle
lcd.drawText(180, 2, "Q"..LinkSp..":"..Link) 
lcd.drawText(70,2, "RaceTel CR V1.2", INVERS) 
lcd.drawFilledRectangle(0,0,69,10,GREY(12)) 
lcd.drawFilledRectangle(146,0,66,10,GREY(12)) 

 


lcd.drawText(8,23,"Power Status:",SMLSIZE) 
lcd.drawText(8,32,"Current: ",SMLSIZE)
lcd.drawText(52,32,Strom.."A", SMLSIZE)
lcd.drawText(8,40, "Verbr.: ",SMLSIZE)
lcd.drawText(42,40,Current.."mAh", SMLSIZE) 
lcd.drawText(8,48, "Leistung: ",SMLSIZE)
Leistung=math.floor(Strom*(Batterie*4))

if Leistung>ausgabeleistung then ausgabeleistung=Leistung end


lcd.drawText(52,48, Leistung.."W", SMLSIZE)

lcd.drawText(140, 23,"Multicopter:", SMLSIZE)
lcd.drawText(140, 32, "Roll Y:", SMLSIZE)
if rollx>=0 then x=183 else x=178 end
lcd.drawText(x, 32, roll..string.char(64), SMLSIZE)
lcd.drawText(140, 40, "Pitch X:", SMLSIZE)
if pitchx>=0 then x=183 else x=178 end  
lcd.drawText(x,40, pitch..string.char(64), SMLSIZE) 

SendeleistungX0=SendeleistungX0*100
SendeleistungX0=math.floor(SendeleistungX0)
SendeleistungX0=SendeleistungX0/100
lcd.drawText(140, 48, "TX:",SMLSIZE)
if SendeleistungX0>=0 then x=153 else x=148 end
lcd.drawText(x, 48,SendeleistungX0.."mW/"..Herz.."Hz", SMLSIZE)  

if ausgA<Strom and maparm=="5" then ausgA=Strom end

if ausgrssi>rss and maparm=="5" and rss>0 then ausgrssi=rss end --------------------------------------- Auswertung 




lcd.drawText(8, 57, "MODE: "..mode, SMLSIZE) 

--maparm="1"
arm="NO CONNECT"
if (maparm=="" or maparm=="0") then lcd.drawText(140, 57,"  NO CONNECT  ", SMLSIZE+INVERS) end 
if (maparm=="5") then lcd.drawText(140, 57," COPTER ARMED ", SMLSIZE+INVERS) end 
if (maparm=="5" and VoltMin >= Batterie) then VoltMin=Batterie end 

if (maparm=="1") then lcd.drawText(140, 57,"   DISARMED", SMLSIZE) end
if (maparm=="2") then lcd.drawText(150, 57," WARNING ", SMLSIZE+BLINK+INVERS) end
 


lcd.drawLine(0,21,83,21,SOLID,0)
lcd.drawLine(127,21,212,21,SOLID,0)
lcd.drawLine(0,30,83,30,SOLID,0)
lcd.drawLine(127,30,212,30,SOLID,0)
lcd.drawFilledRectangle(0,22,84,8,0) 
lcd.drawFilledRectangle(127,22,85,8,0) 
lcd.drawLine(0,55,83,55,SOLID,0)
lcd.drawLine(127,55,212,55,SOLID,0)
lcd.drawPoint(84,60,ERASE)
lcd.drawPoint(126,60,ERASE)
lcd.drawPoint(84,20,ERASE)
lcd.drawPoint(126,20,ERASE)

lcd.drawPoint(0,21,ERASE)
lcd.drawPoint(83,21,ERASE)
lcd.drawPoint(127,21,ERASE)
lcd.drawPoint(211,21,ERASE)
if (Mag<=9) then lcd.drawText(103,13,Mag..string.char(64),SMLSIZE) end
if (Mag>=10 and Mag<=99) then lcd.drawText(100,13,Mag..string.char(64),SMLSIZE) end
if (Mag>=100) then lcd.drawText(98,13,Mag..string.char(64),SMLSIZE) end

 

end

if Schalter==1 or Schalter==2 then
    
  if event==EVT_PLUS_BREAK then
Schalter=2
end
--------------------------------------------------------------------------------------------
-------------------------------------- Zusammenfassung -------------------------------------
--------------------------------------------------------------------------------------------
  lcd.clear()
  
 if event==EVT_ENTER_BREAK then
Schalter=0
end 

lcd.drawText(10,14,"Arm Time: "..timerausgabe,SMLSIZE)
lcd.drawText(10,22,"Maximale A: ",SMLSIZE)
lcd.drawText(64,22,ausgA.."A",SMLSIZE) 
lcd.drawText(10,30,"Verbraucht: ",SMLSIZE)
lcd.drawText(64,30,ausgCurr.."mAh",SMLSIZE)
lcd.drawText(10,38,"Max Leistung: ",SMLSIZE)
lcd.drawText(76,38,ausgabeleistung.."W",SMLSIZE)

ausgVoltMin=VoltMin
if ausgVoltMin==100 then ausgVoltMin=0 end
lcd.drawText(100,14,"Min V. Zell: "..ausgVoltMin.."V",SMLSIZE)
if ausgrssi==110 then ausgrssi=0 end
lcd.drawText(100,22,"Min RSSI:",SMLSIZE)
lcd.drawText(154,22,ausgrssi,SMLSIZE)
lcd.drawText(100,30,"Min. Link: ",SMLSIZE)
if LQHsave~=10 then
lcd.drawText(154,30,LQHsave..":"..LQsave,SMLSIZE)
else
lcd.drawText(154,30,"-:---",SMLSIZE)
end
--lcd.drawText(100,30,"Max. Roll: ",SMLSIZE)
--lcd.drawText(154,30,ausgAccY..string.char(64).."/"..ausgAccY2..string.char(64),SMLSIZE)  

SendeleistungX1=(math.floor(SendeleistungX1*1000)/1000)



lcd.drawText(100,38,"Max TX Lstg.: ",SMLSIZE)
lcd.drawText(168,38,SendeleistungX1.."mW",SMLSIZE)  
 

lcd.drawFilledRectangle(0,55,212,8,0)
lcd.drawText(1,56,"Daten Loeschen mit +",SMLSIZE+INVERS)
lcd.drawText(131,56,"Zurueck mit ENT",SMLSIZE+INVERS)
lcd.drawFilledRectangle(0,0,212,8,0)
--lcd.drawText(10,1,pitch,SMLSIZE+INVERS)  
 lcd.drawText(10,1,"  DROHNEN-FORUM.EU Telemetrie Daten",SMLSIZE+INVERS)  
   
  
 if Schalter==2 then 
   
ausgCurr=0
ausgA=0
ausgAccX=0
ausgAccY=0
ausgAccX2=0
ausgAccY2=0
SendeleistungX1=0

ausgabeleistung=0
timer2=0
timerflag1=0
timerflag2=0
timerausgabe="0m0s"
ausgrssi=110
pitchx2=0
rollx2=0
ausgVoltMin=0
VoltMin=100
Schalter=1
Mag=0
MagStrt=0
MagSwitch=0

LQH=0
LQHswitch=0
LQHsave=10
LQ=0
LQswitch=0
LQsave=100

  end
  end
--------------------------------------------------------------------------------------------

end
return{run=run}