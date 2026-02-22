-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- 1. Setup UI Utama
local sg = Instance.new("ScreenGui")
sg.Name = "CyberScanner_X"
sg.Parent = game:GetService("CoreGui") -- Biar tidak hilang saat reset
sg.ResetOnSpawn = false

-- 2. Main Frame (Persegi Neon)
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 300)
main.Position = UDim2.new(0.5, -200, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Visible = true
main.Parent = sg

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 255)
stroke.Parent = main

-- 3. Header & Title
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 30)
header.Text = " [ REMOTE EXECUTOR SCANNER ] "
header.TextColor3 = Color3.fromRGB(0, 255, 255)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.Font = Enum.Font.Code
header.TextSize = 14
header.Parent = main

-- 4. Scrolling Log (Tempat hasil scan muncul)
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -80)
scroll.Position = UDim2.new(0, 10, 0, 40)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 4
scroll.Parent = main

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scroll
listLayout.Padding = UDim.new(0, 5)

-- 5. Scan Button
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(1, -20, 0, 30)
scanBtn.Position = UDim2.new(0, 10, 1, -35)
scanBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
scanBtn.Text = "START DEEP SCAN"
scanBtn.Font = Enum.Font.Code
scanBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
scanBtn.Parent = main

-- 6. Animasi Scanline (Radar Effect)
local scanline = Instance.new("Frame")
scanline.Size = UDim2.new(1, 0, 0, 2)
scanline.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
scanline.BackgroundTransparency = 0.5
scanline.Parent = main

TweenService:Create(scanline, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.new(0, 0, 1, 0)}):Play()

--- LOGIKA SCANNER (Disesuaikan dari kode kamu) ---

local function addLog(txt, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = "> " .. txt
    l.TextColor3 = color or Color3.new(1, 1, 1)
    l.Font = Enum.Font.Code
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = scroll
    scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

scanBtn.MouseButton1Click:Connect(function()
    scroll:ClearAllChildren()
    listLayout.Parent = scroll -- Re-add layout
    addLog("Initializing Scanner...", Color3.fromRGB(255, 255, 0))
    
    local RemoteEventsCount = 0
    local RemoteFunctionsCount = 0
    
    task.spawn(function()
        for _, v in next, game:GetDescendants() do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                -- Filtering sesuai permintaanmu
                if not v:FindFirstAncestor("DefaultChatSystemChatEvents") and 
                   not v:FindFirstAncestor("RobloxReplicatedStorage") and 
                   v.Name ~= "CharacterSoundEvent" then
                    
                    if v:IsA("RemoteEvent") then RemoteEventsCount += 1 else RemoteFunctionsCount += 1 end
                    
                    addLog(v.ClassName .. " | " .. v.Name, Color3.fromRGB(0, 255, 150))
                    task.wait() -- Biar tidak lag saat scanning ribuan objek
                end
            end
        end
        addLog("SCAN COMPLETE!", Color3.fromRGB(0, 255, 255))
        addLog("Events: " .. RemoteEventsCount .. " | Functions: " .. RemoteFunctionsCount, Color3.new(1, 1, 1))
    end)
end)

-- FITUR DRAGGABLE (SUPAYA BISA DIGESER)
local dragging, dragInput, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
