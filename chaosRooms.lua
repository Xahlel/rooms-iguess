
pcall(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    if LocalPlayer then
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            local oldGui = playerGui:FindFirstChild("ChaosRoomsHUD")
            if oldGui then oldGui:Destroy() end
        end
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local oldLight = root:FindFirstChild("FakeLight")
                if oldLight then oldLight:Destroy() end
            end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 end
        end
    end
end)

local success, err = pcall(function()
    getgenv().glitchme = function() return end
    local originalNamecall
    originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and (self.Name:lower():find("cheat") or self.Name:lower():find("anticheat") or self.Name:lower():find("damage") or self.Name:lower():find("death")) then
            return 
        end
        return originalNamecall(self, ...)
    end)
end)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = PlayerGui or LocalPlayer:WaitForChild("PlayerGui")

getgenv().ChaosSettings = {
    BatteriesESP = true,
    FakeLight = true,
    SpeedMode = 16,
    CustomSpeed = 16,
    MonsterNotifier = true
}

local processedItems = {}

local notificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/laagginq/ui-libraries/main/xaxas-notification/src.lua"))();

local function notifytext(text, rgb, dur)
    if not getgenv().ChaosSettings.MonsterNotifier and text:lower():find("monster") then return end
    pcall(function()
        local notifications = notificationLibrary.new({            
            NotificationLifetime = dur or 3, 
            NotificationPosition = "Middle",
            TextFont = Enum.Font.Jura,
            TextColor = rgb,
            TextSize = 25,
            TextStrokeTransparency = 0, 
            TextStrokeColor = Color3.fromRGB(0, 0, 0)
        })
        notifications:BuildNotificationUI()
        notifications:Notify(text)
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChaosRoomsHUD"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 210, 0, 215)
MainFrame.Position = UDim2.new(0.02, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

local Title = Instance.new("TextButton") -- Сделано кнопкой для перетаскивания окна
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.BorderSizePixel = 0
Title.Text = "ChaosDev : [Hold Alt to Drag/Mouse]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 11
Title.Font = Enum.Font.Jura
Title.LayoutOrder = 1
Title.AutoButtonColor = false
Title.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 6)
titleCorner.Parent = Title

-- Логика перетаскивания GUI (Draggable)
local dragging, dragInput, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local UIList = Instance.new("UIListLayout")
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 3)
UIList.Parent = MainFrame

local function refreshHUD() end

local function createStatusButton(layoutOrder, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 25)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.Jura
    btn.LayoutOrder = layoutOrder
    btn.AutoButtonColor = true
    btn.Parent = MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local applySpeed = nil

local btnBatteries = createStatusButton(2, function()
    getgenv().ChaosSettings.BatteriesESP = not getgenv().ChaosSettings.BatteriesESP
    refreshHUD()
end)

local btnLight = createStatusButton(3, function()
    getgenv().ChaosSettings.FakeLight = not getgenv().ChaosSettings.FakeLight
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local l = char.HumanoidRootPart:FindFirstChild("FakeLight")
        if l then l.Enabled = getgenv().ChaosSettings.FakeLight end
    end
    refreshHUD()
end)

local btnSpeed = createStatusButton(4, function()
    local current = getgenv().ChaosSettings.SpeedMode
    if current == 16 then
        applySpeed(22)
    elseif current == 22 then
        applySpeed(28)
    else
        applySpeed(16)
    end
end)

local btnMonsters = createStatusButton(5, function()
    getgenv().ChaosSettings.MonsterNotifier = not getgenv().ChaosSettings.MonsterNotifier
    refreshHUD()
end)

refreshHUD = function()
    local i = getgenv().ChaosSettings.BatteriesESP
    btnBatteries.Text = "[F1] Batteries ESP: " .. (i and "ON" or "OFF")
    btnBatteries.TextColor3 = i and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)

    local l = getgenv().ChaosSettings.FakeLight
    btnLight.Text = "[F2] Fake Light: " .. (l and "ON" or "OFF")
    btnLight.TextColor3 = l and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)

    local spd = getgenv().ChaosSettings.SpeedMode
    btnSpeed.Text = "[F3-F5] Speed: " .. tostring(spd)
    btnSpeed.TextColor3 = (spd > 16) and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)

    local m = getgenv().ChaosSettings.MonsterNotifier
    btnMonsters.Text = "[F6] Monster Alert: " .. (m and "ON" or "OFF")
    btnMonsters.TextColor3 = m and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
end

refreshHUD()

applySpeed = function(val)
    getgenv().ChaosSettings.SpeedMode = val
    getgenv().ChaosSettings.CustomSpeed = val
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = 16 end
    end
    refreshHUD()
end

RunService.RenderStepped:Connect(function(dt)
    local spd = getgenv().ChaosSettings.CustomSpeed
    if spd <= 16 then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    local moveDir = humanoid.MoveDirection
    if moveDir.Magnitude > 0 then
        root.CFrame = root.CFrame + (moveDir * (spd - 16) * dt)
    end
end)

-- Зажатие LeftAlt для освобождения мыши
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        return
    end

    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        getgenv().ChaosSettings.BatteriesESP = not getgenv().ChaosSettings.BatteriesESP
        refreshHUD()
    elseif input.KeyCode == Enum.KeyCode.F2 then
        getgenv().ChaosSettings.FakeLight = not getgenv().ChaosSettings.FakeLight
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local l = char.HumanoidRootPart:FindFirstChild("FakeLight")
            if l then l.Enabled = getgenv().ChaosSettings.FakeLight end
        end
        refreshHUD()
    elseif input.KeyCode == Enum.KeyCode.F3 then applySpeed(16)
    elseif input.KeyCode == Enum.KeyCode.F4 then applySpeed(22)
    elseif input.KeyCode == Enum.KeyCode.F5 then applySpeed(28)
    elseif input.KeyCode == Enum.KeyCode.F6 then
        getgenv().ChaosSettings.MonsterNotifier = not getgenv().ChaosSettings.MonsterNotifier
        refreshHUD()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
end)

local function playSound(soundId)
    pcall(function()
        local soundObj = Instance.new("Sound")
        soundObj.SoundId = soundId
        soundObj.Volume = 0.1
        soundObj.Parent = PlayerGui
        soundObj:Play()
        Debris:AddItem(soundObj, 3)
    end)
end

local function highlight(child, rgbcolor)
    if not child:FindFirstChild("highlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "highlight"
        hl.OutlineTransparency = 1
        hl.FillTransparency = 0.35
        hl.FillColor = rgbcolor
        hl.Parent = child
    end
end

if game.PlaceId == 12208518151 then
    playSound("rbxassetid://4590662766")
    notifytext("Welcome " .. LocalPlayer.DisplayName .. "! Script loaded successfully.", Color3.fromRGB(196, 69, 0), 3)

    task.spawn(function()
        task.wait(3.5)
        playSound("rbxassetid://4590662766")
        notifytext("[Self-Test] Batteries ESP: Operational", Color3.fromRGB(100, 255, 100), 2)
        task.wait(2.2)
        playSound("rbxassetid://4590662766")
        notifytext("[Self-Test] Fake Light & Speed: Active", Color3.fromRGB(100, 255, 100), 2)
        task.wait(2.2)
        playSound("rbxassetid://6176997734")
        notifytext("[Self-Test] Monster Notifier: Online", Color3.fromRGB(255, 100, 100), 2)
    end)

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local light = Instance.new("PointLight")
    light.Name = "FakeLight"
    light.Range = 60
    light.Brightness = 1.5
    light.Parent = rootPart

    Workspace.ChildAdded:Connect(function(child)
        if child:IsA("Part") and child.Name == "monster" then
            if getgenv().ChaosSettings.MonsterNotifier then
                playSound("rbxassetid://6176997734")
            end
            notifytext("Monster: A-60 is spawned, hide on Locker!", Color3.fromRGB(122, 0, 0), 3)
        elseif child:IsA("Part") and child.Name == "monster2" then
            if getgenv().ChaosSettings.MonsterNotifier then
                playSound("rbxassetid://6176997734")
            end
            notifytext("Monster: A-120/A-200 have been spawned hide to locker wait until dissapears...", Color3.fromRGB(122, 0, 0), 3)
        elseif child:IsA("Model") and child.Name == "Spirit" then
            if getgenv().ChaosSettings.MonsterNotifier then
                playSound("rbxassetid://8509804480")
            end
            notifytext("Monster: A-100 is spawned dont make any noise!", Color3.fromRGB(66, 49, 49), 3)
            if child:FindFirstChild("torso") then
                highlight(child.torso, Color3.fromRGB(128, 13, 0))
            end
        elseif child.Name == "handdebris" then
            if getgenv().ChaosSettings.MonsterNotifier then
                playSound("rbxassetid://6176997734")
            end
            notifytext("Monster: A-250 is shak", Color3.fromRGB(66, 49, 49), 3)
        end
    end)

    Workspace.ChildRemoved:Connect(function(child)
        if child:IsA("Part") and child.Name == "monster2" then
            if getgenv().ChaosSettings.MonsterNotifier then
                playSound("rbxassetid://4590662766")
            end
            notifytext("Monster Gone: A-120/A-200 has been gone you can leave from locker.", Color3.fromRGB(122, 0, 0), 3)
        end
    end)

    if Workspace:FindFirstChild("rooms") then
        Workspace.rooms.DescendantAdded:Connect(function(child)
            if not child:IsA("Instance") then return end
            
            local char = LocalPlayer.Character
            if char and (child:IsDescendantOf(char) or child:IsDescendantOf(LocalPlayer.Backpack)) then return end

            if child:IsA("Model") and child.Name == "jack" then
                if getgenv().ChaosSettings.MonsterNotifier then
                    playSound("rbxassetid://6176997734")
                end
                notifytext("Monster: A-40 have been detect on locker highlighted the locker and make sure dont enter!", Color3.fromRGB(143, 137, 137), 3)
                task.delay(0.1, function()
                    if child.Parent then highlight(child.Parent, Color3.fromRGB(102, 102, 102)) end
                end)
            end

            local nameLower = child.Name:lower()
            if nameLower == "battery" and (child:IsA("Model") or child:IsA("Part")) then
                local batteryRoot = child
                if child:IsA("Part") then batteryRoot = child.Parent or child end
                
                local partToCheck = batteryRoot:IsA("Model") and batteryRoot.PrimaryPart or batteryRoot:FindFirstChildWhichIsA("BasePart")
                if partToCheck and char and char:FindFirstChild("HumanoidRootPart") then
                    if (partToCheck.Position - char.HumanoidRootPart.Position).Magnitude < 7 then
                        return
                    end
                end
                
                if not processedItems[batteryRoot] then
                    processedItems[batteryRoot] = true
                    
                    task.delay(0.3, function()
                        if batteryRoot.Parent then
                            playSound("rbxassetid://4590662766")
                            notifytext("Battery has been spawned make sure get it!", Color3.fromRGB(196, 62, 0), 3)
                            if getgenv().ChaosSettings.BatteriesESP then
                                highlight(batteryRoot, Color3.fromRGB(255, 143, 74))
                            end
                        end
                    end)
                end
            end
        end)
    end
end