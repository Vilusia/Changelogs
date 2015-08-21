util.AddNetworkString("updateServer")
util.AddNetworkString("loadserver")
util.AddNetworkString("removefile")
util.AddNetworkString("updateclient")

net.Receive("updateServer", function(len, ply)
	if !ply:IsAdmin() then return end
	local content = net.ReadString()
	text = content
	if !file.Exists("changelog", "DATA") then
		file.CreateDir("changelog")
	end
	file.Write( "changelog/" .. os.date("%m-%d-%y %I-%M-%S%p" .. ".txt" ), text )
end)

net.Receive("loadserver", function(len, ply)

	local files = file.Find( "changelog/*.txt", "DATA", "date" )
	local tabs = {}
	for _,filename in pairs (files) do 
		local filedate = string.sub(filename,0,#filename-4)
		tabs[filedate] = file.Read("changelog/" .. filename)
	end
	PrintTable(tabs)
	net.Start("updateclient")
	net.WriteTable(tabs)
	net.Send(ply)
end)

net.Receive("removefile",function(len, ply)
	if !ply:IsAdmin() then return end
	local tabname = net.ReadString()
	file.Delete("changelog/" .. tabname .. ".txt")

end)