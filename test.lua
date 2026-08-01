-- MOD BY ROSE V2.1 | MAX CODING
-- IRON MAN FLIGHT (Mobile) for Delta
-- Telegram: https://t.me/rosemod_deep

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ========== НАСТРОЙКИ ==========
local flightSpeed = 70       -- скорость горизонтального полёта
local verticalSpeedStep = 25 -- шаг изменения вертикальной скорости
local maxVerticalSpeed = 80  -- макс. скорость вверх/вниз

-- ========== ПЕРЕМЕННЫЕ ==========
local flying = false
local verticalSpeed = 0
local flightConnection = nil
local bodyVelocity = nil
local bodyGyro = nil

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false
gui.Name = "IronManMobileGUI"

-- Фоновый фрейм (чтобы кнопки не мешали)
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 200, 0, 200)
frame.Position = UDim2.new(0.02, 0, 0.6, 0)
frame.BackgroundTransparency = 1
frame.Name = "ControlFrame"

-- Кнопка ВЗЛЁТ/ПОСАДКА (основная)
local mainBtn = Instance.new("TextButton")
mainBtn.Parent = frame
mainBtn.Size = UDim2.new(0, 130, 0, 60)
mainBtn.Position = UDim2.new(0.35, -65, 0.8, 0)
mainBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
mainBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
mainBtn.Text = "🦾 ВЗЛЁТ"
mainBtn.Font = Enum.Font.GothamBold
mainBtn.TextSize = 20
mainBtn.BorderSizePixel = 0
mainBtn.BackgroundTransparency = 0.2

-- Кнопка ВВЕРХ ▲
local upBtn = Instance.new("TextButton")
upBtn.Parent = frame
upBtn.Size = UDim2.new(0, 70, 0, 70)
upBtn.Position = UDim2.new(0, 0, 0, 0)
upBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.Text = "▲"
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 30
upBtn.BorderSizePixel = 0
upBtn.BackgroundTransparency = 0.3

-- Кнопка ВНИЗ ▼
local downBtn = Instance.new("TextButton")
downBtn.Parent = frame
downBtn.Size = UDim2.new(0, 70, 0, 70)
downBtn.Position = UDim2.new(0, 0, 0.6, 0)
downBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.Text = "▼"
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 30
downBtn.BorderSizePixel = 0
downBtn.BackgroundTransparency = 0.3

-- ========== ФУНКЦИЯ СОЗДАНИЯ СТРУЙ ==========
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

-- ========== ЗАПУСК ПОЛЁТА ==========
local function startFlight()
    if flying then return end
    flying = true
    verticalSpeed = 0
    mainBtn.Text = "🛬 ПОСАДКА"
    mainBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    
    -- Отключаем гравитацию и стандартное управление
    humanoid.PlatformStand = true
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    
    -- BodyVelocity для движения
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Parent = rootPart
    bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    
    -- BodyGyro для поворотов
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Parent = rootPart
    bodyGyro.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
    bodyGyro.CFrame = rootPart.CFrame
    
    -- Цикл обновления
    flightConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not flying or not character or not rootPart then
            stopFlight()
            return
        end
        
        -- Получаем направление от джойстика (левая часть экрана)
        local moveDir = humanoid.MoveDirection
        -- Если джойстик не активен, moveDir = Vector3.new(0,0,0)
        
        -- Горизонтальная скорость
        local horizontalVelocity = moveDir * flightSpeed
        -- Вертикальная скорость (от кнопок)
        local verticalVelocity = Vector3.new(0, verticalSpeed, 0)
        
        -- Итоговая скорость
        local finalVelocity = horizontalVelocity + verticalVelocity
        bodyVelocity.Velocity = finalVelocity
        
        -- Поворачиваем персонажа в направлении движения (если есть горизонтальная скорость)
        if moveDir.Magnitude > 0.1 then
            local lookAt = rootPart.Position + moveDir * 10
            bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, lookAt)
        end
        
        -- Эффекты струй при подъёме или спуске
        if verticalSpeed > 1 then
            createJetEffect(rootPart.Position - Vector3.new(0, 2, 0), Vector3.new(0, -1, 0))
        elseif verticalSpeed < -1 then
            createJetEffect(rootPart.Position + Vector3.new(0, 2, 0), Vector3.new(0, 1, 0))
        end
    end)
    
    print("🦾 Iron Man Flight ACTIVATED (Mobile)")
end

-- ========== ОСТАНОВКА ==========
local function stopFlight()
    if not flying then return end
    flying = false
    mainBtn.Text = "🦾 ВЗЛЁТ"
    mainBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    
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
    verticalSpeed = 0
    
    print("🛬 Flight deactivated.")
end

-- ========== ОБРАБОТЧИКИ КНОПОК ==========
mainBtn.MouseButton1Click:Connect(function()
    if flying then stopFlight() else startFlight() end
end)

-- Вверх
upBtn.MouseButton1Click:Connect(function()
    if flying then
        verticalSpeed = math.min(verticalSpeed + verticalSpeedStep, maxVerticalSpeed)
    end
end)
-- Зажимание для непрерывного подъёма (можно добавить, но пока просто по клику)

-- Вниз
downBtn.MouseButton1Click:Connect(function()
    if flying then
        verticalSpeed = math.max(verticalSpeed - verticalSpeedStep, -maxVerticalSpeed)
    end
end)

-- ========== ЗАЩИТА ПРИ РЕСПАВНЕ ==========
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    if flying then stopFlight() end
end)

print("✅ MOD BY ROSE | IRON MAN FLIGHT (MOBILE) LOADED")
print("📱 Telegram: https://t.me/rosemod_deep")
