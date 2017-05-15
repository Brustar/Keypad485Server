Scene = {}

function Scene.start(data)
    for i,v in ipairs(data.devices) do
	   --switch
	   if v.isPoweron == true or v.poweron == true or v.swithon == true or v.unlock == true or v.pushing == true or v.showed == true or v.waiting == true then
		  C4:SendToDevice(v.devceiID,"ON",{})
	   end
	   
	   if v.isPoweron == false or v.poweron == false or v.swithon == false or v.pushing == false or v.showed == false or v.waiting == false then
		  C4:SendToDevice(v.devceiID,"OFF",{})
	   end
	   
	   --light
	   if v.brightness then
		  C4:SendToDevice(v.deviceID,"RAMP_TO_LEVEL", {LEVEL = v.brightness, TIME = 1000})
	   if #v.color>0 then
		  C4:SendToDevice(v.deviceID,"SET_BUTTON_COLOR", {ON_COLOR = string.format("%2x%2x%2x",v.color[1],v.color[2],v.color[3])})
	   end
	   
	   --blind
	   if v.openvalue>0 then
		  
	   end
	   
	   --TV
	   if v.volume then
		  C4:SendToDevice(v.deviceID,"SET_VOLUME_LEVEL",{LEVEL = v.volume})
	   end
	   
	   if v.channelID then
		  
	   end
	   
	   --DVD
	   if v.dvolume then
		  C4:SendToDevice(v.deviceID,"SET_VOLUME_LEVEL",{LEVEL = v.dvolume})
	   end
	   
	   --bgmusic
	   if v.bgvolume then
		  C4:SendToDevice(v.deviceID,"SET_VOLUME_LEVEL",{LEVEL = v.bgvolume})
	   end
    end
end