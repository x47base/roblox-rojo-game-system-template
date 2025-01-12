local ClientController = {}
ClientController.MobileKeybinds = {}
ClientController.DeviceType = nil
ClientController.MobileDevice = false
ClientController.ControllerDevice = false
ClientController.ControllerType = nil
ClientController.ActionTypeAPositions = {
    ["Left"] = UDim2.new(-1.1, 0, 0, 0),
    ["TopLeft"] = UDim2.new(-1.1, 0, -1.1, 0),
    ["Top"] = UDim2.new(0, 0, -1.1, 0),
}
ClientController.ActionTypeBPositionsGrid = {
    [1] = UDim2.new(-1.25, 0, -4, 0),
    [2] = UDim2.new(-0.4, 0, -4, 0),
    [3] = UDim2.new(0.45, 0, -4, 0),
    [4] = UDim2.new(-1.25, 0, -3.15, 0),
    [5] = UDim2.new(-0.4, 0, -3.15, 0),
    [6] = UDim2.new(0.45, 0, -3.15, 0),
}

-- Services --
local PS = game:GetService("Players")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")

-- Player --
local player = PS.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if UIS.TouchEnabled then
    while not (playerGui:FindFirstChild("JumpButton", true) and playerGui:FindFirstChild("JumpButton", true).IsLoaded) do
		task.wait()
	end
	ClientController.jumpButton = playerGui:FindFirstChild("JumpButton", true)

    ClientController.MobileDevice = true
end

-- Module --

function ClientController:new(core)
	local self = setmetatable({}, ClientController)
	self.Core = core
	return self
end

function ClientController:init(core)
	self.Core = core
	self.CanInitialize = true
	self:setup()
end

function ClientController:setup()
    ClientController:DetectDevice()
end

function ClientController:PrintDeviceDetails()
    print("--------")
    print("Device Details:")
    print(string.format("  Device Type: %s", self.DeviceType or "Unknown"))
    print(string.format("  Touchscreen Connected: %s", tostring(self.MobileDevice or false)))
    print(string.format("  Controller Connected: %s", tostring(self.ControllerDevice or false)))

    if self.ControllerDevice and self.ControllerType then
        print(string.format("  Controller Type: %s", self.ControllerType))
    end
    print("--------")
end

function ClientController:DetectDevice()
    local keyboard = UIS.KeyboardEnabled
    local touchscreen = UIS.TouchEnabled
    local controller = UIS.GamepadEnabled

    if keyboard and not touchscreen and not controller then
        -- desktop :  Laptop/PC
        ClientController.DeviceType = "desktop"

    elseif keyboard and touchscreen and not controller then
        -- desktop : Laptop/PC with touch screen
        ClientController.DeviceType = "desktop"

    elseif not keyboard and touchscreen and not controller then
        -- mobile : phone/ipad
        ClientController.DeviceType = "mobile"
        ClientController.MobileDevice = true

    elseif not keyboard and not touchscreen and controller then
        -- console : xbox or ps4/5 console
        self.DeviceType = "console"
        self.ControllerDevice = true
        --self:DetectControllerType()

    elseif keyboard and not touchscreen and controller then
        -- desktop+console : Laptop/PC with controller connected
        self.DeviceType = "desktop+console"
        self.ControllerDevice = true
        --self:DetectControllerType()

    elseif keyboard and touchscreen and controller then
        -- desktop+console : Laptop/PC with touch screen and controller connected
        self.DeviceType = "desktop+console"
        self.ControllerDevice = true
        --self:DetectControllerType()

    elseif not keyboard and touchscreen and controller then
        -- mobile+console : phone/ipad with controller connected
        self.DeviceType = "mobile+console"
        self.MobileDevice = true
        self.ControllerDevice = true
        --self:DetectControllerType()

    else
        -- No input device detected
        ClientController.DeviceType = "unknown"

    end
end

function ClientController:DetectControllerType()
    local Xbox = {
        ButtonA = Enum.KeyCode.ButtonA, 
        ButtonB = Enum.KeyCode.ButtonB, 
        ButtonX = Enum.KeyCode.ButtonX, 
        ButtonY = Enum.KeyCode.ButtonY, 
        ButtonLB = Enum.KeyCode.ButtonL1, 
        ButtonLT = Enum.KeyCode.ButtonL2, 
        ButtonLS = Enum.KeyCode.ButtonL3, 
        DPadUp = Enum.KeyCode.DPadUp, 
        DPadDown = Enum.KeyCode.DPadDown, 
        DPadLeft = Enum.KeyCode.DPadLeft, 
        DPadRight = Enum.KeyCode.DPadRight, 
        ButtonRB = Enum.KeyCode.ButtonR1, 
        ButtonRT = Enum.KeyCode.ButtonR2, 
        ButtonRS = Enum.KeyCode.ButtonR3, 
        ButtonStart = Enum.KeyCode.ButtonStart, 
        ButtonSelect = Enum.KeyCode.ButtonSelect
    };
    local Ps = {
        ButtonA = "ButtonCross",
        ButtonB = "ButtonCircle",
        ButtonX = "ButtonSquare",
        ButtonY = "ButtonTriangle",
        ButtonLB = "ButtonL1",
        ButtonLT = "ButtonL2",
        ButtonLS = "ButtonL3",
        DPadUp = "DPadUp",
        DPadDown = "DPadDown",
        DPadLeft = "DPadLeft",
        DPadRight = "DPadRight",
        ButtonRB = "ButtonR1",
        ButtonRT = "ButtonR2",
        ButtonRS = "ButtonR3",
        ButtonStart = "ButtonOptions",
        ButtonSelect = "ButtonTouchpad"
    };

    local connectedGamepads = UIS:GetConnectedGamepads()
    if #connectedGamepads > 0 then
        local firstGamepad = connectedGamepads[1]
        local SupportedKeyCodes = UIS:GetSupportedGamepadKeyCodes(firstGamepad)

        local xboxKeyCount = 0
        local psKeyCount = 0

        for _, key in ipairs(SupportedKeyCodes) do
            if table.find(Xbox, key) then
                xboxKeyCount += 1
            elseif table.find(Ps, key) then
                psKeyCount += 1
            end
        end

        if xboxKeyCount > psKeyCount then
            self.ControllerType = "Xbox"
        elseif psKeyCount > xboxKeyCount then
            self.ControllerType = "PlayStation"
        else
            self.ControllerType = "Unknown"
        end
    else
        self.ControllerType = "No Controller Connected"
    end

    print(string.format("Detected Controller Type: %s", self.ControllerType))
end

function ClientController:CreateMobileConfig(text: string, image: string, position: UDim2, color3: Color3, transparency: number)
    return {
        Text = text,
        Image = image, -- rbxassetid://id
        Position = position,
        ImageColor3 = color3,
        Transparency = transparency,
    }
end

-- // Jump Button Area
function ClientController:AddActionTypeA(actionName: string, priority: number, func, key: Enum.KeyCode, mobileConfig, consoleKey)
    local function FunctionWrapper(_actionName, _inputState)
        if _actionName == actionName and _inputState == Enum.UserInputState.Begin then
            func()
        end
    end

    CAS:BindActionAtPriority(actionName, FunctionWrapper, false, priority, key, consoleKey)

    if ClientController.MobileDevice then
        local ImageButton = Instance.new("ImageButton")
        ImageButton.Name = actionName
        ImageButton.BackgroundTransparency = mobileConfig.Transparency
        ImageButton.BackgroundColor3 = Color3.new(0, 0, 0)
        ImageButton.ImageTransparency = mobileConfig.Transparency
        ImageButton.ImageColor3 = mobileConfig.ImageColor3
        ImageButton.BorderSizePixel = 0
        ImageButton.Position = mobileConfig.Position
        ImageButton.Size = UDim2.new(1, 0, 1, 0)
        ImageButton.Image = mobileConfig.Image
        ImageButton.MouseButton1Click:Connect(function()
            func()
        end)

        local UICorner = Instance.new("UICorner", ImageButton)
        UICorner.CornerRadius = UDim.new(1, 0)

        local textLabel = Instance.new("TextLabel", ImageButton)
        textLabel.BackgroundTransparency = 1
        textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.BorderSizePixel = 0
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Font = Enum.Font.Unknown
        textLabel.Text = mobileConfig.Text
        textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextSize = 20
        textLabel.TextWrapped = true

        ImageButton.Parent = ClientController.jumpButton

        ClientController.MobileKeybinds[actionName] = ImageButton
    end
end

function ClientController:AddActionTypeB(actionName: string, priority: number, func, key: Enum.KeyCode, mobileConfig, consoleKey)
    local function FunctionWrapper(_actionName, _inputState)
        if _actionName == actionName and _inputState == Enum.UserInputState.Begin then
            func()
        end
    end

    CAS:BindActionAtPriority(actionName, FunctionWrapper, false, priority, key, consoleKey)

    if ClientController.MobileDevice then
        local ImageButton = Instance.new("ImageButton")
        ImageButton.Name = actionName
        ImageButton.BackgroundTransparency = mobileConfig.Transparency
        ImageButton.BackgroundColor3 = mobileConfig.ImageColor3
        ImageButton.ImageTransparency = mobileConfig.Transparency
        ImageButton.ImageColor3 = mobileConfig.ImageColor3
        ImageButton.BorderSizePixel = 0
        ImageButton.Position = mobileConfig.Position + UDim2.new(0, 0, 0, 80)
        ImageButton.Size = UDim2.new(0.70, 0, 0.70, 0)
        ImageButton.Image = mobileConfig.Image
        ImageButton.MouseButton1Click:Connect(function()
            func()
        end)

        local UICorner = Instance.new("UICorner", ImageButton)
        UICorner.CornerRadius = UDim.new(1, 0)

        local textLabel = Instance.new("TextLabel", ImageButton)
        textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.BackgroundTransparency = 1
        textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.BorderSizePixel = 0
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Font = Enum.Font.Unknown
        textLabel.Text = mobileConfig.Text
        textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextSize = 20
        textLabel.TextWrapped = true

        ImageButton.Parent = ClientController.jumpButton

        ClientController.MobileKeybinds[actionName] = ImageButton
    end
end

function ClientController:RemoveAction(actionName)
    CAS:UnbindAction(actionName)
    if ClientController.MobileKeybinds[actionName] then
        ClientController.MobileKeybinds[actionName]:Destroy()
    end
end

return ClientController