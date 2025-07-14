local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local aimbotEnabled = false
local noclipEnabled = false
local FOV_RADIUS = 150
local MAX_DISTANCE = 500
local FOV_COLOR = Color3.fromRGB(255, 255, 0)

-- Cria ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LUCCAHUB"
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Frame principal
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 240, 0, 240)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.3
frame.Active = true
frame.Draggable = true

-- Título
local titleLabel = Instance.new("TextLabel", frame)
titleLabel.Size = UDim2.new(1, 0, 0, 20)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Text = "LUCCAHUB V1.0"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Botão Toggle Aimbot
local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(0, 200, 0, 30)
toggleButton.Position = UDim2.new(0, 20, 0, 25)
toggleButton.Text = "Ligar Aimbot"
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20

-- Status
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(0, 200, 0, 20)
statusLabel.Position = UDim2.new(0, 20, 0, 60)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
statusLabel.Text = "Status: OFF"
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 18
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Botão aumentar FOV
local fovIncreaseButton = Instance.new("TextButton", frame)
fovIncreaseButton.Size = UDim2.new(0, 200, 0, 25)
fovIncreaseButton.Position = UDim2.new(0, 20, 0, 90)
fovIncreaseButton.Text = "Aumentar FOV"
fovIncreaseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
fovIncreaseButton.TextColor3 = Color3.new(1,1,1)
fovIncreaseButton.Font = Enum.Font.SourceSansBold
fovIncreaseButton.TextSize = 18

-- Botão diminuir FOV
local fovDecreaseButton = Instance.new("TextButton", frame)
fovDecreaseButton.Size = UDim2.new(0, 200, 0, 25)
fovDecreaseButton.Position = UDim2.new(0, 20, 0, 120)
fovDecreaseButton.Text = "Diminuir FOV"
fovDecreaseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
fovDecreaseButton.TextColor3 = Color3.new(1,1,1)
fovDecreaseButton.Font = Enum.Font.SourceSansBold
fovDecreaseButton.TextSize = 18

-- Botão mudar cor FOV
local colorButton = Instance.new("TextButton", frame)
colorButton.Size = UDim2.new(0, 200, 0, 25)
colorButton.Position = UDim2.new(0, 20, 0, 150)
colorButton.Text = "Mudar cor FOV"
colorButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
colorButton.TextColor3 = Color3.new(1,1,1)
colorButton.Font = Enum.Font.SourceSansBold
colorButton.TextSize = 18

-- Botão Noclip
local noclipButton = Instance.new("TextButton", frame)
noclipButton.Size = UDim2.new(0, 200, 0, 25)
noclipButton.Position = UDim2.new(0, 20, 0, 180)
noclipButton.Text = "Ativar Noclip"
noclipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
noclipButton.TextColor3 = Color3.new(1,1,1)
noclipButton.Font = Enum.Font.SourceSansBold
noclipButton.TextSize = 18

-- Remove círculo antigo
if _G.LUCCAHUB_FOV_CIRCLE then
    _G.LUCCAHUB_FOV_CIRCLE:Remove()
end

local circle = Drawing.new("Circle")
circle.Radius = FOV_RADIUS
circle.Color = FOV_COLOR
circle.Thickness = 1
circle.Transparency = 0.6
circle.Filled = false
circle.Visible = true

_G.LUCCAHUB_FOV_CIRCLE = circle

-- ESP Boxes
local espBoxes = {}

local function createESP(player)
    if espBoxes[player] then return end
    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Transparency = 0.8
    box.Visible = false
    espBoxes[player] = box
end

local function removeESP(player)
    if espBoxes[player] then
        espBoxes[player]:Remove()
        espBoxes[player] = nil
    end
end

for _,plr in pairs(Players:GetPlayers()) do
    if plr ~= localPlayer then
        createESP(plr)
    end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= localPlayer then
        createESP(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
end)

local function getClosestEnemy()
    local closest = nil
    local minDistScreen = FOV_RADIUS
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= localPlayer and plr.Team ~= localPlayer.Team and plr.Character and plr.Character:FindFirstChild("Head") then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local headPos = plr.Character.Head.Position
                local dist3D = (headPos - camera.CFrame.Position).Magnitude
                if dist3D <= MAX_DISTANCE then
                    local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
                    if onScreen then
                        local distScreen = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if distScreen < minDistScreen then
                            minDistScreen = distScreen
                            closest = plr
                        end
                    end
                end
            end
        end
    end
    return closest
end

toggleButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        toggleButton.Text = "Desligar Aimbot"
        statusLabel.Text = "Status: ON"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        toggleButton.Text = "Ligar Aimbot"
        statusLabel.Text = "Status: OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

noclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        noclipButton.Text = "Desativar Noclip"
    else
        noclipButton.Text = "Ativar Noclip"
        -- Reativa colisão ao desativar
        local character = localPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

fovIncreaseButton.MouseButton1Click:Connect(function()
    FOV_RADIUS = FOV_RADIUS + 25
    circle.Radius = FOV_RADIUS
end)

fovDecreaseButton.MouseButton1Click:Connect(function()
    FOV_RADIUS = math.max(25, FOV_RADIUS - 25)
    circle.Radius = FOV_RADIUS
end)

colorButton.MouseButton1Click:Connect(function()
    if FOV_COLOR == Color3.fromRGB(255,255,0) then
        FOV_COLOR = Color3.fromRGB(0,255,0)
    else
        FOV_COLOR = Color3.fromRGB(255,255,0)
    end
    circle.Color = FOV_COLOR
end)

RunService.RenderStepped:Connect(function()
    -- Círculo no centro
    circle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    circle.Visible = true

    -- Noclip: desativa colisão constantemente
    if noclipEnabled then
        local character = localPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end

    -- ESP
    for player, box in pairs(espBoxes) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (camera.CFrame.Position - hrp.Position).Magnitude
                local size = math.clamp(2000 / dist, 20, 300)
                box.Size = Vector2.new(size, size)
                box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end

    -- Aimbot
    if not aimbotEnabled then return end
    local success, err = pcall(function()
        local target = getClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            local camPos = camera.CFrame.Position
            camera.CFrame = CFrame.new(camPos, headPos)
        end
    end)
    if not success then
        warn("Erro no aimbot:", err)
    end
end)
