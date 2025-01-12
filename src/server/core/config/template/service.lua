local TemplateService = {}
TemplateService.__index = TemplateService

TemplateService.__SERVICE__ = "TemplateService"
TemplateService.CanInitialize = true

function TemplateService:new(core)
	local self = setmetatable({}, TemplateService)
	self.Core = core
	return self
end

function TemplateService:init(core)
	self.Core = core
	self.CanInitialize = true
	self:setup()
end

function TemplateService:setup()
	-- Setup service functionality here
end

function TemplateService:publicServiceMethod()
	-- Define service methods here
end

return TemplateService
