-- MOD BY ROSE V2.1 | MAX CODING
-- DROPKICK + NOCLIP + ВЗРЫВ
-- Telegram: https://t.me/rosemod_deep

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ========== NOCLIP (ПРОХОЖДЕНИЕ СКВОЗЬ ИГРОКОВ) ==========
local function enableNoClip()
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                -- Делаем прозрачным (как в DropKick)
                part.Transparency = 0.5
            end
        end
        -- Отключаем коллизию с другими игроками
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CanCollide = false
        end
    end
end

-- ========== ОТКЛЮЧЕНИЕ NOCLIP ==========
local function disableNoClip()
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
                part.Transparency = 0
            end
        end
    end
end

-- ========== ЗАЩИТА ОТ СМЕРТИ ==========
local function godMode()
    if character and humanoid then
        humanoid.Health = humanoid.MaxHealth
        humanoid.BreakJointsOnDeath = false
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end
end

-- ========== GUI (КНОПКА) ==========
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.Name = "RoseDropKickGUI"
gui.ResetOnSpawn = false

local button = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0, 130, 0, 60)
button.Position = UDim2.new(0.02, 0, 0.45, 0)
button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "🦵 DROPKICK"
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.BorderSizePixel = 0
button.BackgroundTransparency = 0.15

-- ========== DROPKICK ОТБРАСЫВАНИЕ (с NoClip) ==========
local function dropkickPlayers(centerPos)
    local radius = 40
    local basePower = 150
    local upwardPower = 100
    
    -- ВКЛЮЧАЕМ NOCLIP (чтобы проходить сквозь игроков)
    enableNoClip()
    
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local targetChar = plr.Character
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = targetChar:FindFirstChild("Humanoid")
            
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local dist = (targetRoot.Position - centerPos).Magnitude
                
                if dist < radius then
                    -- Очистка старых сил
                    for _, v in ipairs(targetRoot:GetChildren()) do
                        if v:IsA("BodyVelocity") or v:IsA("BodyForce") then
                            v:Destroy()
                        end
                    end
                    
                    -- Направление от центра
                    local dir = (targetRoot.Position - centerPos).Unit
                    if dist < 0.5 then
                        dir = Vector3.new(math.random(-1,1), 1, math.random(-1,1)).Unit
                    end
                    
                    -- Сила
                    local power = basePower * (1 + (radius - dist) / radius)
                    
                    -- ТОЛЧОК (как в DropKick)
                    targetRoot.Velocity = Vector3.new(0, 0, 0)
                    targetRoot.AssemblyLinearVelocity = dir * power + Vector3.new(0, upwardPower * (1 + (radius - dist) / radius), 0)
                    
                    -- BodyVelocity для удержания
                    local bv = Instance.new("BodyVelocity")
                    bv.Parent = targetRoot
                    bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
                    bv.Velocity = dir * power * 0.8 + Vector3.new(0, upwardPower * 0.6, 0)
                    game:GetService("Debris"):AddItem(bv, 1.0)
                    
                    -- Телепорт вверх
                    targetRoot.Position = targetRoot.Position + Vector3.new(0, 15, 0)
                    
                    -- Урон
                    targetHumanoid.Health = targetHumanoid.Health - math.random(10, 25)
                    
                    -- Эффект удара
                    local flash = Instance.new("Part")
                    flash.Size = Vector3.new(8, 8, 8)
                    flash.Shape = Enum.PartType.Ball
                    flash.Material = Enum.Material.Neon
                    flash.BrickColor = BrickColor.new("Bright red")
                    flash.Position = targetRoot.Position
                    flash.CanCollide = false
                    flash.Anchored = true
                    flash.Parent = workspace
                    game:GetService("Debris"):AddItem(flash, 0.5)
                end
            end
        end
    end
    
    -- ВЫКЛЮЧАЕМ NOCLIP через 0.5 секунды
    task.wait(0.5)
    disableNoClip()
end

-- ========== ВИЗУАЛЬНЫЙ ВЗРЫВ ==========
local function createExplosionVisual(centerPos)
    local exp = Instance.new("Explosion")
    exp.Position = centerPos
    exp.BlastRadius = 35
    exp.BlastPressure = 0
    exp.ExplosionType = Enum.ExplosionType.NoCraters
    exp.Parent = workspace
    
    local light = Instance.new("PointLight")
    light.Parent = workspace.Terrain
    light.Position = centerPos
    light.Color = Color3.fromRGB(255, 200, 100)
    light.Range = 60
    light.Brightness = 15
    game:GetService("Debris"):AddItem(light, 0.6)
    
    for i = 1, 50 do
        local p = Instance.new("Part")
        p.Size = Vector3.new(2, 2, 2)
        p.Shape = Enum.PartType.Ball
        p.Material = Enum.Material.Neon
        p.BrickColor = BrickColor.new("Bright orange")
        p.Position = centerPos + Vector3.new(
            math.random(-20, 20),
            math.random(-5, 15),
            math.random(-20, 20)
        )
        p.Velocity = Vector3.new(
            math.random(-250, 250),
            math.random(150, 400),
            math.random(-250, 250)
        )
        p.CanCollide = false
        p.Anchored = false
        p.Parent = workspace
        game:GetService("Debris"):AddItem(p, 2.5)
    end
end

-- ========== АКТИВАЦИЯ ==========
local function activateDropKick()
    if not character or not humanoidRootPart then
        character = player.Character or player.CharacterAdded:Wait()
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoid = character:WaitForChild("Humanoid")
    end
    
    godMode()
    
    local pos = humanoidRootPart.Position
    
    -- Визуал
    createExplosionVisual(pos)
    
    -- DropKick + NoClip
    dropkickPlayers(pos)
    
    -- Защита
    task.wait(0.1)
    godMode()
    
    -- Тряска камеры
    if player:FindFirstChild("Camera") then
        local cam = player.Camera
        for i = 1, 8 do
            cam.CFrame = cam.CFrame * CFrame.Angles(
                math.rad(math.random(-8, 8)),
                math.rad(math.random(-8, 8)),
                math.rad(math.random(-4, 4))
            )
            task.wait(0.02)
        end
    end
    
    local notif = Instance.new("TextLabel")
    notif.Parent = player.PlayerGui
    notif.Size = UDim2.new(0, 350, 0, 50)
    notif.Position = UDim2.new(0.35, 0, 0.8, 0)
    notif.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.Text = "🦵 DROPKICK ВЗРЫВ! Все разлетелись!"
    notif.TextScaled = true
    notif.BackgroundTransparency = 0.4
    task.wait(2)
    notif:Destroy()
end

-- ========== ПРИВЯЗКА К КНОПКЕ ==========
button.MouseButton1Click:Connect(activateDropKick)

-- ========== ЗАЩИТА ПРИ РЕСПАВНЕ ==========
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    task.wait(0.3)
    godMode()
    enableNoClip()
end)

-- ========== АКТИВАЦИЯ ==========
godMode()
enableNoClip() -- Включаем NoClip сразу

print("✅ MOD BY ROSE V2.1 | DROPKICK + NOCLIP + ВЗРЫВ")
print("📱 Telegram: https://t.me/rosemod_deep")
