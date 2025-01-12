local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Core Table
local Core = {
	Services = {},
    Modules = {},
    RemoteEvents = {},
    RemoteFunctions = {},
    Settings = require(script.Parent.config.settings)
}

local ServiceModulesToPreload = {
    --[[ "Name" of the ModuleScript

        Example: Datastore.lua -> "Datastore"
                 ServiceModulesToPreload = {"Datastore"}
    ]]

}

local function contains(str, substr)
    return string.find(string.lower(str), string.lower(substr)) ~= nil
end

local function preloadServices()
    local serviceFolder = script.Parent.Parent.services
    for _, moduleName in ServiceModulesToPreload do
        local modFile = serviceFolder:FindFirstChild(moduleName)
        if modFile:IsA("ModuleScript") then
            local success, serviceModule = pcall(require, modFile)
            if success and serviceModule.__SERVICE__ then
                Core.Services[serviceModule.__SERVICE__] = serviceModule
                if serviceModule.CanInitialize and serviceModule.init then
                    local initSuccess, initError = pcall(function()
                        serviceModule:init(Core)
                    end)
                    if not initSuccess then
                        warn(string.format("Failed to initialize service '%s': %s", serviceModule.__SERVICE__, initError))
                    else
                        print(string.format("Service '%s' initialized successfully.", serviceModule.__SERVICE__))
                    end
                end
            end
        end
    end
end

local function loadServices()
    local servicesFolder = script.Parent.Parent.services
    for _, service in ipairs(servicesFolder:GetChildren()) do
        if service:IsA("ModuleScript") and not contains(service.Name, "template") then
            local success, serviceModule = pcall(require, service)
            if success and serviceModule.__SERVICE__ and not Core.Services[serviceModule.__SERVICE__] then
                Core.Services[serviceModule.__SERVICE__] = serviceModule
                if serviceModule.CanInitialize and serviceModule.init then
                    local initSuccess, initError = pcall(function()
                        serviceModule:init(Core)
                    end)
                    if not initSuccess then
                        warn(string.format("Failed to initialize service '%s': %s", serviceModule.__SERVICE__, initError))
                    else
                        print(string.format("Service '%s' initialized successfully.", serviceModule.__SERVICE__))
                    end
                end
            else
                warn(string.format("Failed to load service '%s'. Ensure it has a '__SERVICE__' identifier.", service.Name))
            end
        end
    end
end

local function loadModules()
    local modulesFolder = script.Parent.Parent.modules
    for _, module in ipairs(modulesFolder:GetChildren()) do
        if module:IsA("ModuleScript") and not contains(module.Name, "template") then
            local success, moduleObj = pcall(require, module)
            if success then
                if moduleObj.CanInitialize and moduleObj.init then
                    local initSuccess, initError = pcall(function()
                        moduleObj:init(Core)
                    end)
                    if not initSuccess then
                        warn(string.format("Failed to initialize module '%s': %s", module.Name, initError))
                    end
                end
                table.insert(Core.Modules, moduleObj)
            else
                warn(string.format("Failed to load module '%s'.", module.Name))
            end
        end
    end
end

local function loadRemoteEvents()
    local eventsFolder = script.Parent.Parent.events.remotes
    for _, event in ipairs(eventsFolder:GetChildren()) do
        if event:IsA("ModuleScript") and not contains(event.Name, "template") then
            local success, eventModule = pcall(require, event)
            if success and eventModule.__EVENT__ then
                local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
                if not remoteEventsFolder then
                    remoteEventsFolder = Instance.new("Folder")
                    remoteEventsFolder.Name = "RemoteEvents"
                    remoteEventsFolder.Parent = ReplicatedStorage
                end

                local existingEvent = remoteEventsFolder:FindFirstChild(eventModule.__EVENT__)
                if existingEvent then
                    existingEvent:Destroy()
                end

                local replicatedEvent = Instance.new("RemoteEvent")
                replicatedEvent.Name = eventModule.__EVENT__
                replicatedEvent.Parent = remoteEventsFolder
                Core.RemoteEvents[eventModule.__EVENT__] = replicatedEvent

                local initSuccess, initError = pcall(function()
                    eventModule:init(Core, replicatedEvent)
                end)
                if not initSuccess then
                    warn(string.format("Failed to initialize RemoteEvent '%s': %s", eventModule.__EVENT__, initError))
                else
                    print(string.format("RemoteEvent '%s' initialized successfully.", eventModule.__EVENT__))
                end
            else
                warn(string.format("Failed to load RemoteEvent '%s'. Ensure it has a '__EVENT__' identifier.", event.Name))
            end
        end
    end
end

local function loadRemoteFunctions()
    local functionsFolder = script.Parent.Parent.events.functions
    for _, func in ipairs(functionsFolder:GetChildren()) do
        if func:IsA("ModuleScript") and not contains(func.Name, "template") then
            local success, funcModule = pcall(require, func)
            if success and funcModule.__FUNCTION__ then
                local remoteFunctionsFolder = ReplicatedStorage:FindFirstChild("RemoteFunctions")
                if not remoteFunctionsFolder then
                    remoteFunctionsFolder = Instance.new("Folder")
                    remoteFunctionsFolder.Name = "RemoteFunctions"
                    remoteFunctionsFolder.Parent = ReplicatedStorage
                end

                local existingFunction = remoteFunctionsFolder:FindFirstChild(funcModule.__FUNCTION__)
                if existingFunction then
                    existingFunction:Destroy()
                end

                local replicatedFunction = Instance.new("RemoteFunction")
                replicatedFunction.Name = funcModule.__FUNCTION__
                replicatedFunction.Parent = remoteFunctionsFolder
                Core.RemoteFunctions[funcModule.__FUNCTION__] = replicatedFunction

                local initSuccess, initError = pcall(function()
                    funcModule:init(Core, replicatedFunction)
                end)
                if not initSuccess then
                    warn(string.format("Failed to initialize RemoteFunction '%s': %s", funcModule.__FUNCTION__, initError))
                else
                    print(string.format("RemoteFunction '%s' initialized successfully.", funcModule.__FUNCTION__))
                end
            else
                warn(string.format("Failed to load RemoteFunction '%s'. Ensure it has a '__FUNCTION__' identifier.", func.Name))
            end
        end
    end
end

local function init()
    local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not remoteEventsFolder then
        remoteEventsFolder = Instance.new("Folder")
        remoteEventsFolder.Name = "RemoteEvents"
        remoteEventsFolder.Parent = ReplicatedStorage
    end

    local remoteFunctionsFolder = ReplicatedStorage:FindFirstChild("RemoteFunctions")
    if not remoteFunctionsFolder then
        remoteFunctionsFolder = Instance.new("Folder")
        remoteFunctionsFolder.Name = "RemoteFunctions"
        remoteFunctionsFolder.Parent = ReplicatedStorage
    end

    preloadServices()
    loadServices()

    loadRemoteEvents()
    loadRemoteFunctions()

    loadModules()

    local LoadedValue = Instance.new("BoolValue", ReplicatedStorage)
    LoadedValue.Name = "SystemLoaded"
    LoadedValue.Value = true

    print("Core initialized successfully.")
end

-- Initialization
init()
