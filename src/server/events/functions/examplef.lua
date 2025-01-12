local TemplateFunction = {}
TemplateFunction.__index = TemplateFunction

TemplateFunction.__FUNCTION__ = "TemplateFunction"

function TemplateFunction:init(core, remoteFunction)
	self.Core = core
	self.RemoteFunction = remoteFunction
	self:setup()
end

function TemplateFunction:setup()
	self.RemoteFunction.OnServerInvoke = function(player, ...)
		return self:onInvoke(player, ...)
	end
end

function TemplateFunction:onInvoke(player, ...)
	print("TemplateFunction invoked by", player.Name)
	return "Response from TemplateFunction"
end

return TemplateFunction
