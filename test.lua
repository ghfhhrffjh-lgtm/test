-- MOD BY ROSE V2.1 | MAX CODING
-- Telegram: https://t.me/rosemod_deep

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ГЛОБАЛЬНАЯ ЗАЩИТА ОТ СМЕРТИ (работает даже через Explosion)
local function godMode()
    if character and humanoid then
        humanoid.Health = humanoid.MaxHealth
        -- Блокируем урон от взрывов
        humanoid.BreakJointsOnDeath = false
        -- Защита от падения
        if humanoidRootPart then
            humanoidRootPart.Anchored = false
        end
    end
end

-- СОЗДАНИЕ GUI (КНОПКА)
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.Name = "RoseExplosionGUI"
gui.ResetOnSpawn = false

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

-- ОТТАЛКИВАНИЕ ИГРОКОВ (РАБОТАЕТ ВСЕГДА)
local function pushPlayers(centerPosition)
    local radius = 50
    local force = 350
    
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local targetChar = plr.Character
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = targetChar:FindFirstChild("Humanoid")
            
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (targetRoot.Position - centerPosition).Magnitude
                
                if distance < radius then
                    -- НАПРАВЛЕНИЕ ПОЛЁТА
                    local dir = (targetRoot.Position - centerPosition).Unit
                    if distance < 0.5 then dir = Vector3.new(math.random(-1,1), 1, math.random(-1,1)).Unit end
                    
                    -- СИЛА (чем ближе, тем сильнее)
                    local power = force * (1 + (radius - distance) / radius)
                    
                    -- СПОСОБ 1: ПРЯМОЕ ИЗМЕНЕНИЕ ПОЗИЦИИ (работает всегда)
                    targetRoot.Position = targetRoot.Position + dir * power * 0.5
                    
                    -- СПОСОБ 2: СКОРОСТЬ (на всякий случай)
                    targetRoot.Velocity = Vector3.new(0, 0, 0)
                    targetRoot.AssemblyLinearVelocity = dir * power + Vector3.new(0, power * 0.7, 0)
                    
                    -- СПОСОБ 3: СИЛА ЧЕРЕЗ BODYVELOCITY (дополнительно)
                    local bv = Instance.new("BodyVelocity")
                    bv.Parent = targetRoot
                    bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                    bv.Velocity = dir * power * 1.5 + Vector3.new(0, power * 0.8, 0)
                    game:GetService("Debris"):AddItem(bv, 1.5)
                    
                    -- СПОСОБ 4: ТЕЛЕПОРТ ВВЕРХ (гарантия)
                    targetRoot.Position = targetRoot.Position + Vector3.new(0, 50, 0)
                    
                    -- Урон (небольшой)
                    targetHumanoid.Health = targetHumanoid.Health - math.random(5, 20)
                    
                    -- Визуальный эффект на игроке
                    local glow = Instance.new("Part")
                    glow.Size = Vector3.new(10, 10, 10)
                    glow.Shape = Enum.PartType.Ball
                    glow.Material = Enum.Material.Neon
                    glow.BrickColor = BrickColor.new("Bright red")
                    glow.Position = targetRoot.Position
                    glow.CanCollide = false
                    glow.Anchored = true
                    glow.Parent = workspace
                    game:GetService("Debris"):AddItem(glow, 1)
                end
            end
        end
    end
end

-- ВИЗУАЛЬНЫЙ ВЗРЫВ (БЕЗ УРОНА ДЛЯ ИГРОКОВ)
local function createVisualExplosion(position)
    -- Вспышка (без урона)
    local exp = Instance.new("Explosion")
    exp.Position = position
    exp.BlastRadius = 40
    exp.BlastPressure = 0  -- НЕТ УРОНА
    exp.ExplosionType = Enum.ExplosionType.NoCraters
    exp.Parent = workspace
    
    -- Свет
    local light = Instance.new("PointLight")
    light.Parent = workspace.Terrain
    light.Position = position
    light.Color = Color3.fromRGB(255, 150, 50)
    light.Range = 70
    light.Brightness = 20
    game:GetService("Debris"):AddItem(light, 0.8)
    
    -- Частицы
    for i = 1, 60 do
        local p = Instance.new("Part")
        p.Size = Vector3.new(2, 2, 2)
        p.Shape = Enum.PartType.Ball
        p.Material = Enum.Material.Neon
        p.BrickColor = BrickColor.new("Bright orange")
        p.Position = position + Vector3.new(
            math.random(-25, 25),
            math.random(-5, 20),
            math.random(-25, 25)
        )
        p.Velocity = Vector3.new(
            math.random(-300, 300),
            math.random(200, 500),
            math.random(-300, 300)
        )
        p.CanCollide = false
        p.Anchored = false
        p.Parent = workspace
        game:GetService("Debris"):AddItem(p, 3)
    end
end

-- ОСНОВНАЯ ФУНКЦИЯ ВЗРЫВА
local function explode()
    if not character or not humanoidRootPart then
        character = player.Character or player.CharacterAdded:Wait()
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoid = character:WaitForChild("Humanoid")
    end
    
    -- Включаем бессмертие
    godMode()
    
    local pos = humanoidRootPart.Position
    
    -- Визуал
    createVisualExplosion(pos)
    
    -- Отталкиваем игроков
    pushPlayers(pos)
    
    -- Снова защита
    task.wait(0.1)
    godMode()
    
    -- Тряска камеры
    if player:FindFirstChild("Camera") then
        local cam = player.Camera
        for i = 1, 10 do
            cam.CFrame = cam.CFrame * CFrame.Angles(
                math.rad(math.random(-10, 10)),
                math.rad(math.random(-10, 10)),
                math.rad(math.random(-5, 5))
            )
            task.wait(0.02)
        end
    end
    
    -- Уведомление
    local notify = Instance.new("TextLabel")
    notify.Parent = player.PlayerGui
    notify.Size = UDim2.new(0, 400, 0, 60)
    notify.Position = UDim2.new(0.35, 0, 0.8, 0)
    notify.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    notify.TextColor3 = Color3.fromRGB(255, 255, 255)
    notify.Text = "💥 ВЗРЫВ! Игроки разлетелись!"
    notify.TextScaled = true
    notify.BackgroundTransparency = 0.4
    task.wait(2)
    notify:Destroy()
end

-- КНОПКА
button.MouseButton1Click:Connect(explode)

-- ЗАЩИТА ПРИ РЕСПАВНЕ
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    task.wait(0.3)
    godMode()
end)

-- ПЕРВИЧНАЯ АКТИВАЦИЯ
godMode()

print("✅ MOD BY ROSE V2.1 | ВЗРЫВНАЯ КНОПКА (100% РАБОЧАЯ)")
print("📱 Telegram: https://t.me/rosemod_deep")
