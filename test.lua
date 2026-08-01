-- MOD BY ROSE V2.1 | MAX CODING
-- Telegram: https://t.me/rosemod_deep

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- СОЗДАНИЕ GUI (КНОПКА)
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.Name = "RoseExplosionGUI"
gui.ResetOnSpawn = false -- Кнопка не исчезает после смерти/респавна

local button = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0, 120, 0, 60)
button.Position = UDim2.new(0.02, 0, 0.45, 0)
button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "💥 ВЗРЫВ"
button.Font = Enum.Font.GothamBold
button.TextSize = 20
button.BorderSizePixel = 0
button.BackgroundTransparency = 0.15
button.Name = "ExplosionButton"

-- ЗАЩИТА ОТ СМЕРТИ (ты не умираешь)
local function protectPlayer()
    if character and humanoid then
        humanoid.Health = humanoid.MaxHealth
        humanoid.BreakJointsOnDeath = false
    end
end

-- ВИЗУАЛЬНЫЙ ЭФФЕКТ ВЗРЫВА
local function createExplosion(position)
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = 35
    explosion.BlastPressure = 1000000 -- МАКСИМАЛЬНАЯ СИЛА
    explosion.ExplosionType = Enum.ExplosionType.NoCraters
    explosion.Parent = workspace
    explosion.Hit:Connect(function(part, distance)
        -- Защищаем свои части от урона
        if part:IsDescendantOf(character) then
            protectPlayer()
        end
    end)
    
    -- Световая вспышка
    local light = Instance.new("PointLight")
    light.Parent = workspace.Terrain
    light.Position = position
    light.Color = Color3.fromRGB(255, 200, 100)
    light.Range = 60
    light.Brightness = 15
    game:GetService("Debris"):AddItem(light, 0.5)
    
    -- Частицы
    for i = 1, 40 do
        local particle = Instance.new("Part")
        particle.Size = Vector3.new(2, 2, 2)
        particle.Shape = Enum.PartType.Ball
        particle.Material = Enum.Material.Neon
        particle.BrickColor = BrickColor.new("Bright orange")
        particle.Position = position + Vector3.new(
            math.random(-20, 20),
            math.random(-5, 15),
            math.random(-20, 20)
        )
        particle.Velocity = Vector3.new(
            math.random(-200, 200),
            math.random(150, 400),
            math.random(-200, 200)
        )
        particle.CanCollide = false
        particle.Anchored = false
        particle.Parent = workspace
        game:GetService("Debris"):AddItem(particle, 2.5)
    end
end

-- ОТТАЛКИВАНИЕ ИГРОКОВ (УСИЛЕННОЕ)
local function pushPlayers(centerPosition)
    local radius = 45
    local baseForce = 400 -- ОГРОМНАЯ СИЛА
    
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = plr.Character.HumanoidRootPart
            local distance = (rootPart.Position - centerPosition).Magnitude
            
            if distance < radius then
                -- Направление от центра
                local direction = (rootPart.Position - centerPosition).Unit
                if distance < 1 then distance = 1 end
                local forceMultiplier = 1 + (radius - distance) / radius * 2
                local finalForce = baseForce * forceMultiplier
                
                -- ОЧИСТКА СТАРЫХ СИЛ
                for _, v in ipairs(rootPart:GetChildren()) do
                    if v:IsA("BodyVelocity") or v:IsA("BodyForce") then
                        v:Destroy()
                    end
                end
                
                -- ПРЯМОЕ ПРИМЕНЕНИЕ СИЛЫ (гарантированный полёт)
                rootPart.Velocity = Vector3.new(0, 0, 0)
                rootPart.AssemblyLinearVelocity = direction * finalForce + Vector3.new(0, finalForce * 0.8, 0)
                rootPart.AssemblyAngularVelocity = Vector3.new(
                    math.random(-50, 50),
                    math.random(-50, 50),
                    math.random(-50, 50)
                )
                
                -- ДОПОЛНИТЕЛЬНЫЙ ИМПУЛЬС (BodyVelocity на случай сброса)
                local bodyVel = Instance.new("BodyVelocity")
                bodyVel.Parent = rootPart
                bodyVel.MaxForce = Vector3.new(1e7, 1e7, 1e7)
                bodyVel.Velocity = direction * finalForce * 1.2 + Vector3.new(0, finalForce * 0.6, 0)
                game:GetService("Debris"):AddItem(bodyVel, 1.5)
                
                -- УРОН (небольшой)
                local targetHumanoid = plr.Character:FindFirstChild("Humanoid")
                if targetHumanoid and targetHumanoid.Health > 0 then
                    targetHumanoid.Health = targetHumanoid.Health - math.random(10, 30)
                end
            end
        end
    end
end

-- ВЗРЫВ ПО КНОПКЕ
button.MouseButton1Click:Connect(function()
    if not character or not humanoidRootPart then
        character = player.Character or player.CharacterAdded:Wait()
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoid = character:WaitForChild("Humanoid")
    end
    
    local position = humanoidRootPart.Position
    
    -- Защита себя перед взрывом
    protectPlayer()
    
    -- Создаём взрыв
    createExplosion(position)
    
    -- Отталкиваем игроков
    pushPlayers(position)
    
    -- Дополнительная защита после взрыва
    task.wait(0.1)
    protectPlayer()
    
    -- Тряска камеры
    if player:FindFirstChild("Camera") then
        local camera = player.Camera
        for i = 1, 8 do
            camera.CFrame = camera.CFrame * CFrame.Angles(
                math.rad(math.random(-8, 8)),
                math.rad(math.random(-8, 8)),
                math.rad(math.random(-3, 3))
            )
            task.wait(0.03)
        end
    end
    
    -- УВЕДОМЛЕНИЕ
    local notif = Instance.new("TextLabel")
    notif.Parent = player.PlayerGui
    notif.Size = UDim2.new(0, 350, 0, 60)
    notif.Position = UDim2.new(0.4, 0, 0.8, 0)
    notif.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.Text = "💥 ВЗРЫВ! Игроки разлетелись!"
    notif.TextScaled = true
    notif.BackgroundTransparency = 0.4
    task.wait(2)
    notif:Destroy()
end)

-- АВТОЗАЩИТА ПРИ РЕСПАВНЕ
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    task.wait(0.5)
    protectPlayer()
end)

-- ПЕРВИЧНАЯ ЗАЩИТА
protectPlayer()

print("MOD BY ROSE V2.1 | ВЗРЫВНАЯ КНОПКА (УЛУЧШЕННАЯ) АКТИВИРОВАНА")
print("Telegram: https://t.me/rosemod_deep")
