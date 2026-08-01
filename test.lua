-- MOD BY ROSE V2.1 | MAX CODING
-- IRON MAN FLIGHT (Joystick как кнопка, 100% работает)
-- Telegram: https://t.me/rosemod_deep

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ========== НАСТРОЙКИ ==========
local maxSpeed = 80
local deadZone = 0.15
local forwardBias = 0.7
local joystickRadius = 60 -- радиус в пикселях

-- ========== ПЕРЕМЕННЫЕ ==========
local flying = false
local flightConnection = nil
local bodyVelocity = nil
local bodyGyro = nil
local joystickActive = false
local joystickDir = Vector3.new(0, 0, 0)

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false
gui.Name = "IronManGUI"

-- Кнопка ВЗЛЁТ/ПОСАДКА
local toggleBtn = Instance.new("TextButton")
toggleBtn.Parent = gui
toggleBtn.Size = UDim2.new(0, 120, 0, 50)
toggleBtn.Position = UDim2.new(0.02, 0, 0.05, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
toggleBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
toggleBtn.Text = "🦾 ВЗЛЁТ"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.BorderSizePixel = 0
toggleBtn.BackgroundTransparency = 0.2

-- ДЖОЙСТИК (прозрачная кнопка-область)
local joystickButton = Instance.new("TextButton")
joystickButton.Parent = gui
joystickButton.Size = UDim2.new(0, 150, 0, 150)
joystickButton.Position = UDim2.new(0.75, -75, 0.38, -75)
joystickButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
joystickButton.BackgroundTransparency = 0.8
joystickButton.BorderSizePixel = 2
joystickButton.BorderColor3 = Color3.fromRGB(200, 200, 200)
joystickButton.Text = ""
joystickButton.Visible = false
-- Делаем круглой
local corner = Instance.new("UICorner")
corner.Parent = joystickButton
corner.CornerRadius = UDim.new(1, 0)

-- Кружок (индикатор положения пальца)
local knob = Instance.new("Frame")
knob.Parent = joystickButton
knob.Size = UDim2.new(0, 40, 0, 40)
knob.Position = UDim2.new(0.5, -20, 0.5, -20)
knob.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
knob.BackgroundTransparency = 0.4
knob.BorderSizePixel = 0
local knobCorner = Instance.new("UICorner")
knobCorner.Parent = knob
knobCorner.CornerRadius = UDim.new(1, 0)

-- ========== ЭФФЕКТЫ СТРУЙ ==========
local function createJetEffect(position, direction)
    for i = 1, 4 do
        local p = Instance.new("Part")
        p.Size = Vector3.new(1, 1, 1)
        p.Shape = Enum.PartType.Ball
        p.Material = Enum.Material.Neon
        p.BrickColor = BrickColor.new("Bright orange")
        p.Position = position + direction * 2
        p.Velocity = -direction * math.random(40, 120) + Vector3.new(math.random(-15,15), math.random(-15,15), math.random(-15,15))
        p.CanCollide = false
        p.Anchored = false
        p.Parent = workspace
        game:GetService("Debris"):AddItem(p, 0.6)
    end
end

-- ========== ОБНОВЛЕНИЕ ПОЛЁТА ==========
local function updateFlight()
    if not flying or not bodyVelocity then return end

    local dir = joystickDir
    if dir.Magnitude < deadZone then
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then return end
    local camCF = camera.CFrame
    local forward = -camCF.LookVector
    local right = camCF.RightVector
    local up = camCF.UpVector

    local dirNorm = dir.Unit
    local velocity = forward * forwardBias + right * dirNorm.X + up * dirNorm.Y
    velocity = velocity.Unit * maxSpeed

    bodyVelocity.Velocity = velocity

    local horizDir = Vector3.new(velocity.X, 0, velocity.Z)
    if horizDir.Magnitude > 0.5 then
        local lookAt = rootPart.Position + horizDir.Unit * 10
        bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, lookAt)
    end

    if dirNorm.Y > 0.2 then
        createJetEffect(rootPart.Position - Vector3.new(0, 2, 0), Vector3.new(0, -1, 0))
    elseif dirNorm.Y < -0.2 then
        createJetEffect(rootPart.Position + Vector3.new(0, 2, 0), Vector3.new(0, 1, 0))
    end
end

-- ========== ЗАПУСК ==========
local function startFlight()
    if flying then return end
    flying = true
    toggleBtn.Text = "🛬 ПОСАДКА"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    joystickButton.Visible = true

    humanoid.PlatformStand = true
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Parent = rootPart
    bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Parent = rootPart
    bodyGyro.MaxTorque = Vector3.new(1e7, 1e7, 1e7)

    flightConnection = game:GetService("RunService").Heartbeat:Connect(updateFlight)
    print("🦾 Iron Man Flight ACTIVATED")
end

-- ========== ОСТАНОВКА ==========
local function stopFlight()
    if not flying then return end
    flying = false
    toggleBtn.Text = "🦾 ВЗЛЁТ"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    joystickButton.Visible = false
    joystickDir = Vector3.new(0, 0, 0)
    knob.Position = UDim2.new(0.5, -20, 0.5, -20)

    if flightConnection then
        flightConnection:Disconnect()
        flightConnection = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    humanoid.PlatformStand = false
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    print("🛬 Flight deactivated.")
end

-- ========== ОБРАБОТКА ДЖОЙСТИКА (через события кнопки) ==========
local function handleJoystickTouch(input)
    if not flying then return end
    -- Получаем размеры кнопки
    local btnSize = joystickButton.AbsoluteSize
    local center = joystickButton.AbsolutePosition + btnSize / 2
    local touchPos = input.Position
    local delta = touchPos - center
    local maxDelta = joystickRadius
    local clamped = delta.Unit * math.min(delta.Magnitude, maxDelta)
    joystickDir = clamped / maxDelta
    knob.Position = UDim2.new(0.5, clamped.X, 0.5, clamped.Y)
end

joystickButton.TouchStart:Connect(function(input)
    joystickActive = true
    handleJoystickTouch(input)
end)

joystickButton.TouchMoved:Connect(function(input)
    if joystickActive then
        handleJoystickTouch(input)
    end
end)

joystickButton.TouchEnded:Connect(function(input)
    if joystickActive then
        joystickActive = false
        joystickDir = Vector3.new(0, 0, 0)
        knob.Position = UDim2.new(0.5, -20, 0.5, -20)
    end
end)

-- Также поддерживаем мышь для теста на ПК (необязательно)
joystickButton.MouseButton1Down:Connect(function()
    -- Для ПК можно добавить, но на телефоне это не нужно
end)

-- ========== КНОПКА ВКЛ/ВЫКЛ ==========
toggleBtn.MouseButton1Click:Connect(function()
    if flying then stopFlight() else startFlight() end
end)

-- ========== ЗАЩИТА ПРИ РЕСПАВНЕ ==========
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    if flying then stopFlight() end
end)

print("✅ MOD BY ROSE | IRON MAN FLIGHT (FIXED JOYSTICK) LOADED")
print("📱 Telegram: https://t.me/rosemod_deep")
