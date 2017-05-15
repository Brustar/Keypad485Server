require("Http")

EX_CMD = {}
gTicketIdMap = {}

function OnDriverInit()
    C4:SetVariable("Addr",Properties["Addr"])
end

function OnPropertyChanged(strProperty)
    if (strProperty == "Addr") then
	   C4:SetVariable("Addr",Properties["Addr"])
    end
end

function getDeviceVariableID(deviceID,key)
	   key = key or "CONTROL_CMD"
	   for id,i in pairs(C4:GetDeviceVariables(deviceID)) do
		  for k,v in pairs(i) do
			 if k == "name" and v == key then
			    return id 
			 end
		  end
	   end
	   return 0
end

EX_CMD["custom key"] = function(tParams)
    local key = tParams["key_value"]

    local http = Http:create(key)
    local path = string.format("keypad_%s_%d.plist",masterID,C4:RoomGetId())
    local ticketId = http:prepareDownload(path)
    table.insert(gTicketIdMap, ticketId, http)
end

function ExecuteCommand(sCommand, tParams)
    -- Remove any spaces (trim the command)
	local trimmedCommand = string.gsub(sCommand, " ", "")

	-- if function exists then execute (non-stripped)
	if (EX_CMD[sCommand] ~= nil and type(EX_CMD[sCommand]) == "function") then
		EX_CMD[sCommand](tParams)
	-- elseif trimmed function exists then execute
	elseif (EX_CMD[trimmedCommand] ~= nil and type(EX_CMD[trimmedCommand]) == "function") then
		EX_CMD[trimmedCommand](tParams)
	-- handle the command
	elseif (EX_CMD[sCommand] ~= nil) then
		QueueCommand(EX_CMD[sCommand])
	else
		Dbg:Alert("ExecuteCommand: Unhandled command = " .. sCommand)
	end
end


function EX_CMD.LUA_ACTION(tParams)
	   local action = tParams["ACTION"]
	   local connectID = tonumber(Properties["Server ID"])
	   local variableID = getDeviceVariableID(connectID)
	   
	   if action == "low" then
		  C4:SetDeviceVariable(connectID, variableID, 1)
	   end
    
	   if action == "middle" then
		  C4:SetDeviceVariable(connectID, variableID, 2)
	   end
    
	   if action == "high" then
		  C4:SetDeviceVariable(connectID, variableID, 3)
	   end
	   
	   if action == "dry" then
		  C4:SetDeviceVariable(connectID, variableID, 4)
	   end
    
	   if action == "fan" then
		  C4:SetDeviceVariable(connectID, variableID, 5)
	   end
	   
	   if action == "heat" then
		  C4:SetDeviceVariable(connectID, variableID, 6)
	   end
	   
	   if action == "cool" then
		  C4:SetDeviceVariable(connectID, variableID, 7)
	   end
	   
	   if action == "on" then
		  C4:SetDeviceVariable(connectID, variableID, 8)
	   end
    
	   if action == "off" then
		  C4:SetDeviceVariable(connectID, variableID, 9)
	   end
    
	   if action == "away" then
		  C4:SetDeviceVariable(connectID, variableID, 10)
	   end
    
	   if action == "query" then
		  C4:SetDeviceVariable(connectID, variableID, 11)
	   end
	   
	   if action == "degree18" then
		  C4:SetDeviceVariable(connectID, variableID, 18)
	   end
	   
	   if action == "degree22" then
		  C4:SetDeviceVariable(connectID, variableID, 22)
	   end
	   
	   if action == "degree26" then
		  C4:SetDeviceVariable(connectID, variableID, 26)
	   end
    
	   if action == "degree30" then
		  C4:SetDeviceVariable(connectID, variableID, 30)
	   end
end

function ReceivedAsync(ticketId, strData, responseCode, tHeaders)
    local this = gTicketIdMap[ticketId]
    if this then
        this:ReceivedAsync(ticketId, strData, responseCode, tHeaders)
        gTicketIdMap[ticketId] = nil
    else
        Dbg:Alert("ReceivedAsync: can not find command object!!")
    end
end

C4:AddVariable("Addr", "03", "STRING")