local TemplateModule = {}
TemplateModule.__index = TemplateModule

TemplateModule.CanInitialize = false

function TemplateModule:new(core)
	local self = setmetatable({}, TemplateModule)
	self.Core = core
	return self
end

function TemplateModule:init(core)
	self.Core = core
	self.CanInitialize = true
	self:setup()
end

function TemplateModule:setup()
	-- Setup module functionality here
end

function TemplateModule:publicMethod()
	-- Define public methods here
end

return TemplateModule