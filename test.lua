-- MOD BY ROSE V2.1 | MAX CODING
-- FLESH MODE v2 (20 молний, отбрасывание врагов, бессмертие)
-- Telegram: https://t.me/rosemod_deep

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ========== НАСТРОЙКИ ==========
local normalSpeed = 16
local flashSpeed = 200
local normalJump = 50
local flashJump = 150
local isFlash = false

local lightningParts = {}
local lightningConnection = nil
local protectConnection = nil

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false
gui.Name = "FlashGUI"

local button = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0, 100, 0, 100)
button.Position = UDim2.new(0.85, 0, 0.5, -50)
button.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
button.BackgroundTransparency = 0.1
button.BorderColor3 = Color3.fromRGB(0, 0, 0)
button.BorderSizePixel = 4
button.Text = "FLESH"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.TextSize = 30

local corner = Instance.new("UICorner")
corner.Parent = button
corner.CornerRadius = UDim.new(0, 15)

-- ========== ЗАЩИТА ОТ СМЕРТИ ==========
local function protectPlayer()
    if not character or not humanoid then return end
    humanoid.Health = humanoid.MaxHealth
    humanoid.BreakJointsOnDeath = false
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
end

local function startProtection()
    if protectConnection then return end
    protectConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if isFlash and character and humanoid then
            protectPlayer()
        end
    end)
end

local function stopProtection()
    if protectConnection then
        protectConnection:Disconnect()
        protectConnection = nil
    end
end

-- ========== СОЗДАНИЕ МОЛНИЙ ==========
local function createLightningPart()
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.5, 0.5, 2 + math.random()*4)
    part.Shape = Enum.PartType.Block
    part.Material = Enum.Material.Neon
    part.BrickColor = BrickColor.new("Bright blue")
    part.Anchored = false
    part.CanCollide = true
    part.Transparency = 0.2
    part.AssemblyAngularVelocity = Vector3.new(math.random(-10,10), math.random(-10,10), math.random(-10,10))
    local dir = Vector3.new(math.random(-1,1), math.random(-0.5,0.5), math.random(-1,1)).Unit
    part.Velocity = dir * 20
    return part
end

local function spawnLightning()
    clearLightning()
    for i = 1, 20 do
        local part = createLightningPart()
        part.Parent = workspace
        local angle = math.rad(i * 18 + math.random(-5,5))
        local radius = 5 + math.random()*3
        part.Position = rootPart.Position + Vector3.new(math.cos(angle)*radius, math.random(-2,4), math.sin(angle)*radius)
        part.Touched:Connect(function(hit)
            if not isFlash then return end
            local hitParent = hit.Parent
            if hitParent and hitParent:FindFirstChild("Humanoid") and hitParent ~= character then
                local targetHumanoid = hitParent:FindFirstChild("Humanoid")
                local targetRoot = hitParent:FindFirstChild("HumanoidRootPart")
                if targetHumanoid and targetHumanoid.Health > 0 and targetRoot then
                    local pushForce = 5000
                    local direction = (targetRoot.Position - rootPart.Position).Unit
                    if direction.Magnitude < 0.5 then
                        direction = Vector3.new(math.random(-1,1), math.random(0.5,1), math.random(-1,1)).Unit
                    end
                    targetRoot.AssemblyLinearVelocity = direction * pushForce + Vector3.new(0, 1000, 0)
                    local bv = Instance.new("BodyVelocity")
                    bv.Parent = targetRoot
                    bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
                    bv.Velocity = direction * pushForce + Vector3.new(0, 2000, 0)
                    game:GetService("Debris"):AddItem(bv, 0.5)
                end
            end
        end)
        table.insert(lightningParts, part)
    end
end

local function clearLightning()
    for _, part in ipairs(lightningParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    lightningParts = {}
end

-- ========== ОБНОВЛЕНИЕ МОЛНИЙ ==========
local function updateLightning()
    if not isFlash then
        clearLightning()
        return
    end
    for i, part in ipairs(lightningParts) do
        if part and part.Parent then
            local angle = math.rad(i * 18 + os.clock() * 30)
            local radius = 5 + math.sin(os.clock() + i) * 1.5
            local heightOffset = math.sin(os.clock() * 2 + i) * 2
            local targetPos = rootPart.Position + Vector3.new(math.cos(angle)*radius, heightOffset, math.sin(angle)*radius)
            part.Position = part.Position + (targetPos - part.Position) * 0.15
            part.Orientation = Vector3.new(math.sin(os.clock()+i)*30, os.clock()*50, math.cos(os.clock()+i)*30)
            part.Velocity = (targetPos - part.Position) * 3 + Vector3.new(math.random(-5,5), math.random(-5,5), math.random(-5,5))
        end
    end
end

-- ========== ВКЛЮЧЕНИЕ/ВЫКЛЮЧЕНИЕ ==========
local function toggleFlash()
    if not character or not humanoid then
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
    end

    isFlash = not isFlash

    if isFlash then
        humanoid.WalkSpeed = flashSpeed
        humanoid.JumpPower = flashJump
        spawnLightning()
        if not lightningConnection then
            lightningConnection = game:GetService("RunService").Heartbeat:Connect(updateLightning)
        end
        startProtection()
        button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        button.Text = "⚡FLESH"
        print("⚡ Flash mode ON")
    else
        humanoid.WalkSpeed = normalSpeed
        humanoid.JumpPower = normalJump
        clearLightning()
        if lightningConnection then
            lightningConnection:Disconnect()
            lightningConnection = nil
        end
        stopProtection()
        button.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
        button.Text = "FLESH"
        print("🛑 Flash mode OFF")
    end
end

button.MouseButton1Click:Connect(toggleFlash)

-- ========== ЗАЩИТА ПРИ РЕСПАВНЕ ==========
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    if isFlash then
        isFlash = false
        toggleFlash()
    end
end)

print("✅ MOD BY ROSE | FLESH MODE v2 LOADED")
print("📱 Telegram: https://t.me/rosemod_deep")
