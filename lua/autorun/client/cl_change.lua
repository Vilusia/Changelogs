include("changelogs_config.lua")

local TextBoxContent = ""
local OnClientUpdate = function() end
net.Receive("updateclient", function() OnClientUpdate() end)

surface.CreateFont( "BestFont", {
	font = "Arial",
	size = 22,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

function AddTab(sheet, name, edit)
	local ply = LocalPlayer()
	local panel1 = vgui.Create( "DPanel", sheet )
	panel1.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,CConfig.Foreground)
	end
	local tab = sheet:AddSheet( name, panel1)
	local text = vgui.Create("DTextEntry", panel1)
	text:SetPos(5, 5)
	text:SetSize(665, 525)
	text:SetEditable(edit)
	text:SetTextColor(edit and Color( 0,0,0,255) or CConfig.TextColor)
	text:SetFont( "BestFont" )
	text:SetMultiline(true)
	text:SetDrawBackground(edit)
	panel1:SizeToContents()
	text:SizeToContents()
	if CAllowed_Groups[ply:GetNWString("usergroup")] then
		local DeleteButton = vgui.Create("DButton",panel1)
		DeleteButton:SetSize(130,30)
		DeleteButton:SetPos(405,535)
		DeleteButton:SetText("")
		DeleteButton.Paint = function(self,w,h)
			draw.RoundedBox(0,0,0,w,h,CConfig.Buttons)
			surface.SetTextColor(Color( 180,180,180))
			surface.SetFont("Trebuchet24")
			local x = surface.GetTextSize("DELETE LOG")/2
			surface.SetTextPos((w/2)-x,0)
			surface.DrawText("DELETE LOG")
		end
		DeleteButton.DoClick = function(self)	
			net.Start("removefile")
			print("Removing File.")
				net.WriteString(name)
			net.SendToServer()
			Frame:Close()
		end
	end
	return text,tab,panel1
end

function Changelogs()
	local ply = LocalPlayer()
	net.Start("loadserver")
	net.SendToServer()
	
	Frame = vgui.Create("DFrame")
	Frame:SetSize(700,640)
	Frame:Center()
	Frame:SetVisible(true)
	Frame:MakePopup()
	Frame:SetDeleteOnClose(true)
	Frame:ShowCloseButton(false)
	Frame:SetTitle("")
	Frame.Paint = function(self , w ,h)
		draw.RoundedBox(0,0,0,w,h,CConfig.MainBox)
		draw.RoundedBox(0,0,0,w,30,CConfig.Titlebg)
	end
	Frame.OnClose = function(self)
		self:Remove()
	end
	local sheet = vgui.Create( "DPropertySheet", Frame )
	sheet:Dock( FILL )
	
	CloseButton = vgui.Create("DButton",Frame)
	CloseButton:SetSize(30,30)
	CloseButton:SetPos(700-30,0)
	CloseButton:SetText("")
	CloseButton.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,CConfig.Buttons)
		surface.SetTextColor(Color( 180,180,180))
		surface.SetFont("Trebuchet24")
		local x = surface.GetTextSize("X")/2
		surface.SetTextPos((w/2)-x,0)
		surface.DrawText("X")
	end
	CloseButton.DoClick = function(self)	
		Frame:Close()
	end

	local Servertext = vgui.Create("DLabel",Frame)
	Servertext:SetSize(500,20)
	Servertext:SetPos(40 - 25,5)
	Servertext:SetText(CConfig.Name .. " Changelogs")
	Servertext:SetFont("Trebuchet24")	
	
	if CAllowed_Groups[ply:GetNWString("usergroup")] then
		local AddButton = vgui.Create("DButton",Frame)
		AddButton:SetSize(130,30)
		AddButton:SetPos(700-146,592)
		AddButton:SetText("")
		AddButton.Paint = function(self,w,h)
			draw.RoundedBox(0,0,0,w,h,CConfig.Buttons)
			surface.SetTextColor(Color( 180,180,180))
			surface.SetFont("Trebuchet24")
			local x = surface.GetTextSize("ADD LOG")/2
			surface.SetTextPos((w/2)-x,0)
			surface.DrawText("ADD LOG")
		end
		AddButton.DoClick = function(self)	
			local text,tab,tabpanel = AddTab(sheet,"Log",true)
			sheet:SetActiveTab(tab.Tab)
			
			local SaveButton = vgui.Create("DButton",tabpanel)
			SaveButton:SetSize(130,30)
			SaveButton:SetPos(3,535)
			SaveButton:SetText("")
			SaveButton.Paint = function(self,w,h)
				draw.RoundedBox(0,0,0,w,h,CConfig.Buttons)
				surface.SetTextColor(Color( 180,180,180))
				surface.SetFont("Trebuchet24")
				local x = surface.GetTextSize("SAVE LOG")/2
				surface.SetTextPos((w/2)-x,0)
				surface.DrawText("SAVE LOG")
			end
			SaveButton.DoClick = function(self)	
				net.Start("updateServer")
					net.WriteString(text:GetText())
				net.SendToServer()
				Frame:Close()
			end
		end
	end
	
	OnClientUpdate = function() 
		local tabs = net.ReadTable()
		local newTabs = {}
		for name,content in pairs(tabs) do
			table.insert(newTabs, { name = name, content = content })
		end
		table.SortByMember(newTabs, "name")
		for _,log in pairs(newTabs) do
			local text = AddTab(sheet, log.name)
			text:SetText(log.content)
		end
		OnClientUpdate = function() end
	end

end


hook.Add("OnPlayerChat","openlogs",function(ply,text)
	if ply == LocalPlayer() then
		if string.lower(text) == "!logs" or string.lower(text) == "/logs" then
			Changelogs()
		end
	end
end)

concommand.Add( "changelogs_open", Changelogs )
