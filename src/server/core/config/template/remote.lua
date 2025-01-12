local TemplateEvent = {}
TemplateEvent.__index = TemplateEvent

TemplateEvent.__EVENT__ = "TemplateEvent"

function TemplateEvent:init(core, remoteEvent)
	self.Core = core
	self.RemoteEvent = remoteEvent
	self:setup()
end

function TemplateEvent:setup()
	self.RemoteEvent.OnServerEvent:Connect(function(player, ...)
		self:onEvent(player, ...)
	end)
end

function TemplateEvent:onEvent(player, ...)
	print("TemplateEvent triggered by", player.Name)
end

return TemplateEvent
