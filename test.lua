-- MOD BY ROSE V2.1 | MAX CODING
-- IRON MAN FLIGHT SCRIPT for Roblox (Delta)
-- Telegram: https://t.me/rosemod_deep

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ========== НАСТРОЙКИ ==========
local flightSpeed = 80        -- скорость полёта
local upwardForce = 60        -- сила подъёма
local useParticles = true     -- эффекты струй
local useSounds = false       -- звуки (если есть звуки в игре)

-- ========== ПЕРЕМЕННЫЕ ==========
local flying = false
local flightConnection = nil
local bodyVelocity = nil
local bodyGyro = nil

-- ========== GUI (КНОПКА) ==========
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false
gui.Name = "IronManGUI"

local button = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0, 140, 0, 60)
button.Position = UDim2.new(0.02, 0, 0.4, 0)
button.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- золотой
button.TextColor3 = Color3.fromRGB(255, 0, 0)
button.Text = "🦾 ВЗЛЁТ"
button.Font = Enum.Font.GothamBold
button.TextSize = 20
button.BorderSizePixel = 0
button.BackgroundTransparency = 0.2

-- ========== ЭФФЕКТЫ (реактивные струи) ==========
local function createJetEffect(position, direction)
    if not useParticles then return end
    for i = 1, 5 do
        local particle = Instance.new("Part")
        particle.Size = Vector3.new(1, 1, 1)
        particle.Shape = Enum.PartType.Ball
        particle.Material = Enum.Material.Neon
        particle.BrickColor = BrickColor.new("Bright orange")
        particle.Position = position + direction * 2
        particle.Velocity = -direction * math.random(50, 150) + Vector3.new(
            math.random(-20, 20),
            math.random(-20, 20),
            math.random(-20, 20)
        )
        particle.CanCollide = false
        particle.Anchored = false
        particle.Parent = workspace
        game:GetService("Debris"):AddItem(particle, 0.5)
    end
end

-- ========== ФУНКЦИЯ ПОЛЁТА ==========
local function startFlight()
    if flying then return end
    flying = true
    button.Text = "🛬 ПОСАДКА"
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    
    -- Отключаем гравитацию
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    humanoid.PlatformStand = true
    
    -- BodyVelocity для движения
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Parent = rootPart
    bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    
    -- BodyGyro для управления поворотами
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Parent = rootPart
    bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bodyGyro.CFrame = rootPart.CFrame
    
    -- Основной цикл полёта (событие для обновления)
    flightConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
        if not flying or not character or not rootPart then
            stopFlight()
            return
        end
        
        -- Получаем ввод (WASD + пробел + Shift)
        local moveDirection = Vector3.new(0, 0, 0)
        local userInput = game:GetService("UserInputService")
        
        if userInput:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Vector3.new(0, 0, -1) end
        if userInput:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection + Vector3.new(0, 0, 1) end
        if userInput:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection + Vector3.new(-1, 0, 0) end
        if userInput:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Vector3.new(1, 0, 0) end
        if userInput:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if userInput:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection + Vector3.new(0, -1, 0) end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end
        
        -- Преобразуем направление относительно камеры
        local camera = workspace.CurrentCamera
        if not camera then return end
        local camCFrame = camera.CFrame
        local forward = camCFrame.LookVector * moveDirection.Z
        local right = camCFrame.RightVector * moveDirection.X
        local up = camCFrame.UpVector * moveDirection.Y
        
        local velocity = (forward + right + up) * flightSpeed
        
        -- Применяем скорость
        bodyVelocity.Velocity = velocity
        
        -- Если летим вверх, добавляем реактивные струи
        if moveDirection.Y > 0 then
            local pos = rootPart.Position - Vector3.new(0, 2, 0)
            createJetEffect(pos, Vector3.new(0, -1, 0))
            -- Ещё струи по бокам
            createJetEffect(pos + Vector3.new(0.5, 0, 0.5), Vector3.new(0, -1, 0))
            createJetEffect(pos - Vector3.new(0.5, 0, 0.5), Vector3.new(0, -1, 0))
        end
        
        -- Если летим вниз, также струи вверх
        if moveDirection.Y < 0 then
            local pos = rootPart.Position + Vector3.new(0, 2, 0)
            createJetEffect(pos, Vector3.new(0, 1, 0))
        end
        
        -- Поворачиваем персонажа в направлении движения (если есть)
        if velocity.Magnitude > 1 then
            local lookAt = rootPart.Position + velocity.Unit * 10
            bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, lookAt)
        end
    end)
    
    print("🦾 Iron Man Flight ACTIVATED!")
end

-- ========== ОСТАНОВКА ПОЛЁТА ==========
local function stopFlight()
    if not flying then return end
    flying = false
    button.Text = "🦾 ВЗЛЁТ"
    button.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    
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

-- ========== ОБРАБОТЧИК КНОПКИ ==========
button.MouseButton1Click:Connect(function()
    if flying then
        stopFlight()
    else
        startFlight()
    end
end)

-- ========== ЗАЩИТА ПРИ РЕСПАВНЕ ==========
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    if flying then stopFlight() end
    task.wait(0.5)
    -- Автоматически включаем полёт, если хочешь, можно раскомментировать:
    -- startFlight()
end)

print("✅ MOD BY ROSE V2.1 | IRON MAN FLIGHT SCRIPT LOADED")
print("📱 Telegram: https://t.me/rosemod_deep")
