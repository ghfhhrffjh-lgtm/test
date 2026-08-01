-- MOD BY ROSE V2.1 | MAX CODING
-- IRON MAN FLIGHT (использует стандартный джойстик Roblox)
-- Telegram: https://t.me/rosemod_deep

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ========== НАСТРОЙКИ ==========
local forwardSpeed = 50        -- постоянная скорость вперёд (можно менять)
local maxLateralSpeed = 60     -- скорость влево/вправо (от джойстика)
local maxVerticalSpeed = 50    -- скорость вверх/вниз (от джойстика)

-- ========== ПЕРЕМЕННЫЕ ==========
local flying = false
local flightConnection = nil
local bodyVelocity = nil
local bodyGyro = nil

-- ========== СОЗДАНИЕ КНОПКИ ВКЛ/ВЫКЛ ==========
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false
gui.Name = "IronManGUI"

local toggleBtn = Instance.new("TextButton")
toggleBtn.Parent = gui
toggleBtn.Size = UDim2.new(0, 120, 0, 50)
toggleBtn.Position = UDim2.new(0.8, 0, 0.05, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
toggleBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
toggleBtn.Text = "🦾 ВЗЛЁТ"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.BorderSizePixel = 0
toggleBtn.BackgroundTransparency = 0.2

-- ========== ФУНКЦИЯ ЭФФЕКТОВ СТРУЙ ==========
local function createJetEffect(position, direction)
    for i = 1, 3 do
        local p = Instance.new("Part")
        p.Size = Vector3.new(1, 1, 1)
        p.Shape = Enum.PartType.Ball
        p.Material = Enum.Material.Neon
        p.BrickColor = BrickColor.new("Bright orange")
        p.Position = position + direction * 2
        p.Velocity = -direction * math.random(40, 100) + Vector3.new(math.random(-10,10), math.random(-10,10), math.random(-10,10))
        p.CanCollide = false
        p.Anchored = false
        p.Parent = workspace
        game:GetService("Debris"):AddItem(p, 0.5)
    end
end

-- ========== ЗАПУСК ПОЛЁТА ==========
local function startFlight()
    if flying then return end
    flying = true
    toggleBtn.Text = "🛬 ПОСАДКА"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

    -- Отключаем стандартное управление и гравитацию
    humanoid.PlatformStand = true
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

    -- BodyVelocity для управления скоростью
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Parent = rootPart
    bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    
    -- BodyGyro для поворотов
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Parent = rootPart
    bodyGyro.MaxTorque = Vector3.new(1e7, 1e7, 1e7)

    -- Цикл обновления (читаем джойстик каждый кадр)
    flightConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not flying or not character or not rootPart then
            stopFlight()
            return
        end

        -- Получаем направление от стандартного джойстика
        local moveDir = humanoid.MoveDirection  -- это Vector3 (X, 0, Z) на плоскости

        -- Преобразуем в координаты камеры
        local camera = workspace.CurrentCamera
        if not camera then return end
        local camCF = camera.CFrame

        -- Раскладываем moveDir на компоненты в пространстве камеры
        -- moveDir.X - это влево/вправо (в локальных осях камеры?)
        -- На самом деле MoveDirection уже в мировых координатах, но мы хотим, чтобы вперёд было по камере.
        -- Поэтому мы преобразуем moveDir в локальные координаты камеры.
        local localDir = camCF:VectorToObjectSpace(moveDir) -- (X, Y, Z) в системе камеры
        
        -- Теперь localDir.X - влево/вправо, localDir.Z - вперёд/назад (отрицательный Z - вперёд)
        -- Но мы хотим, чтобы localDir.Y отвечал за вертикаль.
        -- Вместо этого мы используем localDir.Z для вертикали (если джойстик тянем вперёд - подъём, назад - спуск)
        -- И localDir.X для горизонтального поворота.
        -- А также всегда добавляем постоянную скорость вперёд.
        
        -- Собираем вектор скорости в мировых координатах:
        -- Вперёд (постоянно) + вертикаль (от localDir.Z) + горизонталь (от localDir.X)
        local forwardWorld = camCF.LookVector  -- направление вперёд (камера)
        local rightWorld = camCF.RightVector
        local upWorld = camCF.UpVector

        -- Вертикаль: чем сильнее тянем джойстик вперёд (localDir.Z > 0), тем больше подъём
        -- localDir.Z: если положительный - вперёд (по камере), отрицательный - назад
        local verticalInput = -localDir.Z  -- инвертируем, чтобы вперёд = вверх
        local verticalVelocity = upWorld * verticalInput * maxVerticalSpeed

        -- Горизонтальный поворот (влево-вправо)
        local lateralVelocity = rightWorld * localDir.X * maxLateralSpeed

        -- Постоянная скорость вперёд (можно настроить)
        local constantForward = forwardWorld * forwardSpeed

        -- Итоговая скорость
        local finalVelocity = constantForward + lateralVelocity + verticalVelocity

        -- Применяем
        bodyVelocity.Velocity = finalVelocity

        -- Поворачиваем персонажа в направлении движения (по горизонтали)
        local horizDir = Vector3.new(finalVelocity.X, 0, finalVelocity.Z)
        if horizDir.Magnitude > 0.5 then
            local lookAt = rootPart.Position + horizDir.Unit * 10
            bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, lookAt)
        end

        -- Эффекты струй при вертикальном движении
        if verticalInput > 0.2 then
            createJetEffect(rootPart.Position - Vector3.new(0, 2, 0), Vector3.new(0, -1, 0))
        elseif verticalInput < -0.2 then
            createJetEffect(rootPart.Position + Vector3.new(0, 2, 0), Vector3.new(0, 1, 0))
        end
    end)

    print("🦾 Iron Man Flight ACTIVATED (Built-in joystick)")
end

-- ========== ОСТАНОВКА ПОЛЁТА ==========
local function stopFlight()
    if not flying then return end
    flying = false
    toggleBtn.Text = "🦾 ВЗЛЁТ"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)

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

-- ========== КНОПКА ==========
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

print("✅ MOD BY ROSE | IRON MAN FLIGHT (STANDARD JOYSTICK) LOADED")
print("📱 Telegram: https://t.me/rosemod_deep")
