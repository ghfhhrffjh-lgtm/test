-- MOD BY ROSE V2.1 | MAX CODING
-- FLESH MODE (Суперскорость как у Флэша)
-- Telegram: https://t.me/rosemod_deep

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ========== НАСТРОЙКИ ==========
local normalSpeed = 16          -- стандартная скорость
local flashSpeed = 200          -- скорость Флэша
local normalJump = 50           -- стандартный прыжок
local flashJump = 150           -- прыжок Флэша
local isFlash = false           -- состояние

-- ========== GUI (КНОПКА) ==========
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false
gui.Name = "FlashGUI"

-- Основная кнопка
local button = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0, 100, 0, 100)          -- квадратная
button.Position = UDim2.new(0.85, 0, 0.5, -50)   -- справа по центру
button.BackgroundColor3 = Color3.fromRGB(128, 0, 255) -- фиолетовый
button.BackgroundTransparency = 0.1
button.BorderColor3 = Color3.fromRGB(0, 0, 0)    -- чёрная обводка
button.BorderSizePixel = 4
button.Text = "FLESH"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.TextSize = 30

-- Скруглённые углы (50% = круг, но по заданию "округлённые края" — 15% подойдёт)
local corner = Instance.new("UICorner")
corner.Parent = button
corner.CornerRadius = UDim.new(0, 15)  -- 15 пикселей радиус

-- ========== ВИЗУАЛЬНЫЕ ЭФФЕКТЫ ФЛЭША ==========
local lightningParts = {}

local function spawnLightning()
    -- Создаём молнии вокруг персонажа
    for i = 1, 6 do
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.5, 0.5, math.random(5, 15))
        part.Shape = Enum.PartType.Block
        part.Material = Enum.Material.Neon
        part.BrickColor = BrickColor.new("Bright blue")
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.3
        part.Parent = workspace
        -- Располагаем вокруг игрока
        local angle = math.rad(i * 60 + math.random(-10, 10))
        local radius = 6
        part.Position = rootPart.Position + Vector3.new(math.cos(angle)*radius, math.random(-2, 4), math.sin(angle)*radius)
        part.Orientation = Vector3.new(math.random(-30,30), math.random(-180,180), math.random(-30,30))
        table.insert(lightningParts, part)
    end
end

local function clearLightning()
    for _, part in ipairs(lightningParts) do
        part:Destroy()
    end
    lightningParts = {}
end

local lightningConnection = nil

local function updateLightning()
    if not isFlash then
        clearLightning()
        return
    end
    -- Обновляем позиции молний (следуют за игроком)
    for i, part in ipairs(lightningParts) do
        if part and part.Parent then
            local angle = math.rad(i * 60 + math.random(-5, 5))
            local radius = 5 + math.sin(os.time() + i) * 1.5
            part.Position = rootPart.Position + Vector3.new(math.cos(angle)*radius, math.random(-2, 4), math.sin(angle)*radius)
            part.Orientation = Vector3.new(math.random(-30,30), math.random(-180,180), math.random(-30,30))
        end
    end
end

-- ========== ВКЛЮЧЕНИЕ/ВЫКЛЮЧЕНИЕ РЕЖИМА ==========
local function toggleFlash()
    if not character or not humanoid then
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
    end

    isFlash = not isFlash

    if isFlash then
        -- Включаем суперскорость
        humanoid.WalkSpeed = flashSpeed
        humanoid.JumpPower = flashJump
        -- Добавляем эффекты
        spawnLightning()
        if not lightningConnection then
            lightningConnection = game:GetService("RunService").Heartbeat:Connect(updateLightning)
        end
        button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- зелёный при активации
        button.Text = "⚡FLESH"
        print("⚡ Режим Флэша АКТИВИРОВАН!")
    else
        -- Отключаем
        humanoid.WalkSpeed = normalSpeed
        humanoid.JumpPower = normalJump
        clearLightning()
        if lightningConnection then
            lightningConnection:Disconnect()
            lightningConnection = nil
        end
        button.BackgroundColor3 = Color3.fromRGB(128, 0, 255) -- фиолетовый
        button.Text = "FLESH"
        print("🛑 Режим Флэша ВЫКЛЮЧЕН")
    end
end

-- ========== ПРИВЯЗКА К КНОПКЕ ==========
button.MouseButton1Click:Connect(toggleFlash)

-- ========== ЗАЩИТА ПРИ РЕСПАВНЕ ==========
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    -- Если был включён Флэш, выключаем
    if isFlash then
        isFlash = false
        humanoid.WalkSpeed = normalSpeed
        humanoid.JumpPower = normalJump
        clearLightning()
        if lightningConnection then
            lightningConnection:Disconnect()
            lightningConnection = nil
        end
        button.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
        button.Text = "FLESH"
    end
end)

print("✅ MOD BY ROSE | FLESH MODE LOADED")
print("📱 Telegram: https://t.me/rosemod_deep")
