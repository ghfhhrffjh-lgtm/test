-- MOD BY ROSE V2.1 | MAX CODING
-- Telegram: https://t.me/rosemod_deep

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- СОЗДАНИЕ GUI
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.Name = "RoseExplosionGUI"

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

-- ЭФФЕКТ ВЗРЫВА
local function createExplosion(position)
    -- Визуальный эффект (вспышка)
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = 30
    explosion.BlastPressure = 500000
    explosion.ExplosionType = Enum.ExplosionType.NoCraters
    explosion.Parent = workspace
    
    -- Дополнительная вспышка (свет)
    local light = Instance.new("PointLight")
    light.Parent = workspace.Terrain
    light.Position = position
    light.Color = Color3.fromRGB(255, 200, 100)
    light.Range = 50
    light.Brightness = 10
    game:GetService("Debris"):AddItem(light, 0.5)
    
    -- Частицы (огонь/дым)
    for i = 1, 30 do
        local particle = Instance.new("Part")
        particle.Size = Vector3.new(2, 2, 2)
        particle.Shape = Enum.PartType.Ball
        particle.Material = Enum.Material.Neon
        particle.BrickColor = BrickColor.new("Bright orange")
        particle.Position = position + Vector3.new(
            math.random(-15, 15),
            math.random(-5, 10),
            math.random(-15, 15)
        )
        particle.Velocity = Vector3.new(
            math.random(-150, 150),
            math.random(100, 300),
            math.random(-150, 150)
        )
        particle.CanCollide = false
        particle.Anchored = false
        particle.Parent = workspace
        game:GetService("Debris"):AddItem(particle, 2)
        
        -- Затухание
        local color = particle.BrickColor
        game:GetService("TweenService"):Create(
            particle,
            TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Transparency = 1}
        ):Play()
    end
end

-- ОТТАЛКИВАНИЕ ВСЕХ ИГРОКОВ
local function pushPlayers(centerPosition)
    local radius = 40
    local pushForce = 250
    
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = plr.Character.HumanoidRootPart
            local distance = (rootPart.Position - centerPosition).Magnitude
            
            if distance < radius then
                -- Направление от центра взрыва
                local direction = (rootPart.Position - centerPosition).Unit
                local force = pushForce * (1 - distance / radius) * 2
                
                -- Применяем силу
                rootPart.Velocity = Vector3.new(0, 0, 0)
                rootPart.AssemblyLinearVelocity = direction * force + Vector3.new(0, force * 0.5, 0)
                
                -- Добавляем импульс
                local bodyVel = Instance.new("BodyVelocity")
                bodyVel.Parent = rootPart
                bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bodyVel.Velocity = direction * force + Vector3.new(0, force * 0.5, 0)
                game:GetService("Debris"):AddItem(bodyVel, 0.8)
                
                -- Наносим урон (если есть Health)
                local humanoid = plr.Character:FindFirstChild("Humanoid")
                if humanoid then
                    local damage = math.random(20, 60)
                    humanoid.Health = humanoid.Health - damage
                end
            end
        end
    end
end

-- КНОПКА ВЗРЫВА
button.MouseButton1Click:Connect(function()
    if not character or not humanoidRootPart then
        character = player.Character or player.CharacterAdded:Wait()
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    end
    
    local position = humanoidRootPart.Position
    
    -- Визуальный эффект
    createExplosion(position)
    
    -- Отталкивание игроков
    pushPlayers(position)
    
    -- Тряска камеры (эффект)
    if player:FindFirstChild("Camera") then
        local camera = player.Camera
        for i = 1, 5 do
            camera.CFrame = camera.CFrame * CFrame.Angles(
                math.rad(math.random(-5, 5)),
                math.rad(math.random(-5, 5)),
                0
            )
            wait(0.05)
        end
    end
    
    -- Уведомление
    local notif = Instance.new("TextLabel")
    notif.Parent = player.PlayerGui
    notif.Size = UDim2.new(0, 300, 0, 50)
    notif.Position = UDim2.new(0.4, 0, 0.85, 0)
    notif.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.Text = "💥 ВЗРЫВ АКТИВИРОВАН!"
    notif.TextScaled = true
    notif.BackgroundTransparency = 0.3
    wait(1.5)
    notif:Destroy()
end)

print("MOD BY ROSE V2.1 | ВЗРЫВНАЯ КНОПКА АКТИВИРОВАНА")
print("Telegram: https://t.me/rosemod_deep")
