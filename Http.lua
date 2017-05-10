local JSON = require('json')
require('File')

Http = {}

function Http:create(key)

    local http = {}
    http.key = key
    local host = Properties["HTTP Address"]
    local port = tonumber(Properties["HTTP Port"])
    local masterID = Properties["masterID"]
    local fileName = "keypad_258_1.plist"--string.format("keypad_%s_%d.plist",masterID,C4:RoomGetId())
    
    function http:prepareDownload()
	   local url = string.format("http://%s:%d/Cloud/download_plist.aspx",host,port)
	   
	   local md5 = File.md5(fileName)
	   local param = string.format("filename=%s&md5=%s",fileName,md5)
    
	   local ticketId = C4:urlPost(url, param)
	   return ticketId
    end
    
    function http:paserURL(responseData)
	   local json = JSON:decode(responseData)
	   return json["plist_url"] or ""
    end

    function http:ReceivedAsync(ticketId, strData, responseCode, tHeaders)
	   print('http:ReceivedAsync, ticketId = ' .. tostring(ticketId) .. ' responseCode = ' .. tostring(responseCode))
	   if (responseCode == 200) then
		  print(strData)
		  local url = self:paserURL(strData)
		  if url == "" then
			 local sceneid = parseToScene(fileName,self.key)
			 execute(sceneid)
		  else
			 self:download(url)
		  end
	   else
		  Dbg:Alert("ReceivedAsync: can not find command object!!")
	   end

    end
    
    function http:download(url)
	   C4:urlGet(url, {}, false,
		  function(ticketId, strData, responseCode, tHeaders, strError)
			 if (strError == nil) then
				print("C4:urlGet() succeeded: " .. strData)
				File.write(fileName,strData)
				local sceneid = parseToScene(fileName,self.key)
				execute(sceneid)
			 else
				print("C4:urlGet() failed: " .. strError)
			 end
	   end)

    end
    
    return http
end