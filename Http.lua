local JSON = require('json')
require('File')
require('Plist')
require('Scene')

Http = {}

function Http:create(key)

    local http = {}
    http.key = key
    http.httpID = 0
    local host = Properties["HTTP Address"]
    local port = tonumber(Properties["HTTP Port"])
    local masterID = Properties["masterID"]
    
    function http:prepareDownload(fileName)
	   self.fileName = fileName
	   local url = string.format("http://%s:%d/Cloud/download_plist.aspx",host,port)
	   
	   local md5 = File.md5(fileName)
	   local param = string.format("filename=%s&md5=%s",self.fileName,md5)
    
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
		  local url = self:paserURL(strData)
		  if url == "" then
			 if ticketId == self.httpID then
				self:startScene()
			 else
				local sceneID = Plist.parseToSceneID(self.fileName,self.key)
				self:execute(sceneID)
			 end
		  else
			 return self:download(url,ticketId)
		  end
	   else
		  Dbg:Alert("ReceivedAsync: can not find command object!!")
	   end

    end
    
    function http:download(url,ticketID)
	   
	   C4:urlGet(url, {}, false,
		  function(ticketId, strData, responseCode, tHeaders, strError)
			 if (strError == nil) then
				print("C4:urlGet() succeeded: " .. strData)
				C4:FileDelete(self.fileName)
				File.write(self.fileName,strData)
				if self.httpID == ticketID then
				    self:startScene()
				else
				    local sceneID = Plist.parseToSceneID(self.fileName,self.key)
				    self:execute(sceneID)
				end
			 else
				print("C4:urlGet() failed: " .. strError)
				
			 end
	   end)

    end
    
    function http:execute(sceneID)
	   local path = string.format("%s_%d.plist",masterID,sceneID)
	   self.httpID = self:prepareDownload(path)
	   
	   table.insert(gTicketIdMap, self.httpID, self)
    end
    
    function http:startScene()
	   local sceneData = Plist.parseToTable(self.fileName)
	   Scene.start(sceneData)
    end
    
    return http
end