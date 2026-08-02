-- MOD BY ROSE V2.1 | MAX CODING
-- DROPKICK SCRIPT (Оригинальная механика + кнопка)
-- Telegram: https://t.me/rosemod_deep

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ========== НАСТРОЙКИ ==========
local kickForce = 150          -- сила пинка (чем выше, тем дальше летят)
local upwardForce = 80         -- дополнительная сила вверх
local range = 25               -- радиус действия (в стопах)
local duration = 0.8           -- время, в течение которого ты прозрачен и невидим

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false
gui.Name = "DropKickGUI"

local button = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0, 100, 0, 100)
button.Position = UDim2.new(0.85, 0, 0.5, -50)  -- справа
button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- красный
button.BackgroundTransparency = 0.2
button.BorderColor3 = Color3.fromRGB(0, 0, 0)
button.BorderSizePixel = 3
button.Text = "🦵\nKICK"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.TextSize = 30
local corner = Instance.new("UICorner")
corner.Parent = button
corner.CornerRadius = UDim.new(0, 15)

-- ========== NOCLIP (прохождение сквозь стены/игроков) ==========
local function setNoClip(state)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
            if state then
                part.Transparency = 0.5  -- прозрачность как в оригинале
            else
                part.Transparency = 0
            end
        end
    end
end

-- ========== ОТБРАСЫВАНИЕ ИГРОКОВ ==========
local function kickPlayers()
    local center = rootPart.Position
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local targetChar = plr.Character
            if targetChar then
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetChar:FindFirstChild("Humanoid")
                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                    local dist = (targetRoot.Position - center).Magnitude
                    if dist < range then
                        -- Направление от центра
                        local dir = (targetRoot.Position - center).Unit
                        if dist < 0.5 then
                            dir = Vector3.new(math.random(-1,1), 1, math.random(-1,1)).Unit
                        end
                        -- Сила с учётом расстояния
                        local power = kickForce * (1 + (range - dist) / range)
                        -- Отбрасывание
                        targetRoot.Velocity = Vector3.new(0,0,0)
                        targetRoot.AssemblyLinearVelocity = dir * power + Vector3.new(0, upwardForce * (1 + (range - dist) / range), 0)
                        -- Дополнительный импульс
                        local bv = Instance.new("BodyVelocity")
                        bv.Parent = targetRoot
                        bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
                        bv.Velocity = dir * power * 0.8 + Vector3.new(0, upwardForce * 0.6, 0)
                        game:GetService("Debris"):AddItem(bv, 0.8)
                        -- Визуальный эффект удара
                        local flash = Instance.new("Part")
                        flash.Size = Vector3.new(6, 6, 6)
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
    end
end

-- ========== ОСНОВНАЯ ФУНКЦИЯ ==========
local function performKick()
    if not character or not rootPart then
        character = player.Character or player.CharacterAdded:Wait()
        rootPart = character:WaitForChild("HumanoidRootPart")
        humanoid = character:WaitForChild("Humanoid")
    end

    -- Включаем NoClip (проходим сквозь всех)
    setNoClip(true)
    -- Защита от смерти (на всякий случай)
    humanoid.Health = humanoid.MaxHealth

    -- Небольшая задержка для эффекта
    task.wait(0.1)

    -- Отбрасываем игроков
    kickPlayers()

    -- Тряска камеры
    if player:FindFirstChild("Camera") then
        local cam = player.Camera
        for i = 1, 5 do
            cam.CFrame = cam.CFrame * CFrame.Angles(
                math.rad(math.random(-5,5)),
                math.rad(math.random(-5,5)),
                math.rad(math.random(-3,3))
            )
            task.wait(0.02)
        end
    end

    -- Возвращаем коллизию через duration секунд
    task.wait(duration)
    setNoClip(false)

    -- Уведомление
    local notif = Instance.new("TextLabel")
    notif.Parent = player.PlayerGui
    notif.Size = UDim2.new(0, 250, 0, 50)
    notif.Position = UDim2.new(0.4, 0, 0.8, 0)
    notif.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.Text = "🦵 DROPKICK!"
    notif.TextScaled = true
    notif.BackgroundTransparency = 0.4
    task.wait(1.5)
    notif:Destroy()
end

-- ========== ПРИВЯЗКА К КНОПКЕ ==========
button.MouseButton1Click:Connect(performKick)

-- ========== ЗАЩИТА ПРИ РЕСПАВНЕ ==========
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    setNoClip(false)  -- сбрасываем на всякий случай
end)

print("✅ MOD BY ROSE | DROPKICK SCRIPT LOADED")
print("📱 Telegram: https://t.me/rosemod_deep")
