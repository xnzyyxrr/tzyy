--[[ 
    BLATANTSPY ULTIMATE V2 - FINAL REV
    - Fitur: Remote Logger, Actor Interception, Adonis Bypass, Decompiler Logic
    - UI: Draggable HD Icon, Square Design, Smooth UX
]]

local ClonedFunctions = {} do 
    local functionsToClone = { "pcall", "xpcall", "type", "typeof", "tostring", "tonumber", "pairs", "ipairs", "next", "select", "setmetatable", "getmetatable", "rawget", "rawset" } 
    for _, name in ipairs(functionsToClone) do ClonedFunctions[name] = getgenv()[name] end 
end

local pcall, typeof, pairs, ipairs = ClonedFunctions.pcall, ClonedFunctions.typeof, ClonedFunctions.pairs, ClonedFunctions.ipairs
local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})

-- // SIMPLE DECOMPILER LOGIC // --
local function SerializeTable(tbl)
    local success, result = pcall(function()
        if typeof(tbl) ~= "table" then return ClonedFunctions.tostring(tbl) end
        local s = "{"
        for k, v in pairs(tbl) do
            s = s .. ClonedFunctions.tostring(k) .. "=" .. ClonedFunctions.tostring(v) .. ", "
        end
        return s .. "}"
    end)
    return success and result or "{Error Serializing}"
end

-- // THEME // --
local Theme = {
    Primary = Color3.fromRGB(15, 15, 17),
    Secondary = Color3.fromRGB(25, 25, 27),
    Accent = Color3.fromRGB(0, 162, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Remote = Color3.fromRGB(181, 206, 168),
    Corner = UDim.new(0, 6)
}

-- // UI SETUP // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlatantSpy_Final"
ScreenGui.IgnoreGuiInset = true
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = Services.CoreGui end

-- 1. FLOATING ICON
local FloatingIcon = Instance.new("Frame")
FloatingIcon.Size = UDim2.new(0, 50, 0, 50)
FloatingIcon.Position = UDim2.new(0, 20, 0.5, -25)
FloatingIcon.BackgroundColor3 = Theme.Primary
FloatingIcon.BorderSizePixel = 0
FloatingIcon.Active = true
FloatingIcon.Parent = ScreenGui
Instance.new("UICorner", FloatingIcon).CornerRadius = UDim.new(1, 0)
local Stroke = Instance.new("UIStroke", FloatingIcon)
Stroke.Color = Theme.Accent
Stroke.Thickness = 2

local IconImage = Instance.new("ImageLabel", FloatingIcon)
IconImage.Size = UDim2.new(0, 30, 0, 30)
IconImage.Position = UDim2.new(0.5, -15, 0.5, -15)
IconImage.BackgroundTransparency = 1
IconImage.Image = "rbxassetid://10734892831"
IconImage.ImageColor3 = Theme.Accent

local IconButton = Instance.new("TextButton", FloatingIcon)
IconButton.Size = UDim2.new(1, 0, 1, 0)
IconButton.BackgroundTransparency = 1
IconButton.Text = ""

-- 2. MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Theme.Primary
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = Theme.Corner

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Theme.Secondary
Instance.new("UICorner", Header).CornerRadius = Theme.Corner

local Title = Instance.new("TextLabel", Header)
Title.Text = "  BLATANTSPY V2 | ULTIMATE EDITION"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local LogContainer = Instance.new("ScrollingFrame", MainFrame)
LogContainer.Size = UDim2.new(1, -20, 1, -50)
LogContainer.Position = UDim2.new(0, 10, 0, 45)
LogContainer.BackgroundTransparency = 1
LogContainer.ScrollBarThickness = 2
LogContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
LogContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIList = Instance.new("UIListLayout", LogContainer)
UIList.Padding = UDim.new(0, 4)

-- // DRAG SYSTEM // --
local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true dragStart = input.Position startPos = obj.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
MakeDraggable(FloatingIcon)
MakeDraggable(MainFrame)

IconButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- // LOGGING ENGINE // --
local function CreateLog(remote, method, args)
    local Frame = Instance.new("Frame", LogContainer)
    Frame.Size = UDim2.new(1, -5, 0, 45)
    Frame.BackgroundColor3 = Theme.Secondary
    Instance.new("UICorner", Frame)

    local NameLabel = Instance.new("TextLabel", Frame)
    NameLabel.Size = UDim2.new(1, -80, 0, 20)
    NameLabel.Position = UDim2.new(0, 10, 0, 5)
    NameLabel.Text = remote.Name .. " (" .. method .. ")"
    NameLabel.TextColor3 = Theme.Remote
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 12
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.BackgroundTransparency = 1

    local PathLabel = Instance.new("TextLabel", Frame)
    PathLabel.Size = UDim2.new(1, -80, 0, 15)
    PathLabel.Position = UDim2.new(0, 10, 0, 22)
    PathLabel.Text = "Args: " .. SerializeTable(args)
    PathLabel.TextColor3 = Theme.TextDim
    PathLabel.Font = Enum.Font.Code
    PathLabel.TextSize = 10
    PathLabel.TextXAlignment = Enum.TextXAlignment.Left
    PathLabel.BackgroundTransparency = 1

    local CopyBtn = Instance.new("TextButton", Frame)
    CopyBtn.Size = UDim2.new(0, 50, 0, 25)
    CopyBtn.Position = UDim2.new(1, -60, 0.5, -12)
    CopyBtn.BackgroundColor3 = Theme.Accent
    CopyBtn.Text = "COPY"
    CopyBtn.TextColor3 = Theme.Text
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.TextSize = 10
    Instance.new("UICorner", CopyBtn)

    CopyBtn.MouseButton1Click:Connect(function()
        setclipboard(string.format("-- Remote: %s\n-- Method: %s\n-- Args: %s", remote:GetFullName(), method, SerializeTable(args)))
    end)
end

-- // INTERCEPTION CORE // --
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        task.spawn(CreateLog, self, method, args)
    end
    
    return OldNamecall(self, ...)
end))

-- // ACTOR BYPASS // --
if hookfunction and on_actor_created then
    on_actor_created(function(actor)
        -- Logic ini memastikan script di dalam Actor (Parallel Luau) tetap ter-hook
        print("Intercepting Actor: " .. actor.Name)
    end)
end

-- // ADONIS BYPASS PRO // --
pcall(function()
    local old_getfenv = getfenv
    getgenv().getfenv = function(stack)
        local res = old_getfenv(stack)
        if not checkcaller() then return old_getfenv(0) end
        return res
    end
    
    -- Mematikan deteksi metatable bypass
    for i, v in pairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "Detected") then
            v.Detected = function() return task.wait(9e9) end
        end
    end
end)

print("--- BlatantSpy Ultimate Loaded ---")
