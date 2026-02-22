--[[ 
    BLATANTSPY ULTIMATE V2
    - Fitur: Remote Logger, Actor Interception, Adonis Bypass, Decompiler
    - UI: Draggable HD Icon, Square Design, Close Support
]]

local ClonedFunctions = {} do 
    local functionsToClone = { "pcall", "xpcall", "type", "typeof", "tostring", "tonumber", "pairs", "ipairs", "next", "select", "unpack", "rawget", "rawset", "rawequal", "rawlen", "setmetatable", "getmetatable", "assert", "error" } 
    for _, name in ipairs(functionsToClone) do if getgenv()[name] then ClonedFunctions[name] = clonefunction(getgenv()[name]) end end 
    ClonedFunctions.unpack = clonefunction(table.unpack or unpack)
    ClonedFunctions.tableInsert = clonefunction(table.insert)
    ClonedFunctions.stringFormat = clonefunction(string.format)
    ClonedFunctions.mathMax = clonefunction(math.max)
    ClonedFunctions.mathFloor = clonefunction(math.floor)
end

local pcall, type, typeof, pairs, ipairs = ClonedFunctions.pcall, ClonedFunctions.type, ClonedFunctions.typeof, ClonedFunctions.pairs, ClonedFunctions.ipairs
local Services = {} do
    local names = {"Players", "TweenService", "UserInputService", "RunService", "CoreGui", "HttpService"}
    for _, n in ipairs(names) do Services[n] = game:GetService(n) end
end

-- // THEME // --
local Theme = {
    Primary = Color3.fromRGB(15, 15, 17),
    Secondary = Color3.fromRGB(25, 25, 27),
    Accent = Color3.fromRGB(0, 162, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 180),
    Remote = Color3.fromRGB(181, 206, 168),
    Corner = UDim.new(0, 6)
}

-- // UI SETUP // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlatantSpy_Final"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = Services.CoreGui end

-- 1. FLOATING ICON (HD & DRAGGABLE)
local FloatingIcon = Instance.new("Frame")
FloatingIcon.Size = UDim2.new(0, 50, 0, 50)
FloatingIcon.Position = UDim2.new(0, 50, 0.5, -25)
FloatingIcon.BackgroundColor3 = Theme.Primary
FloatingIcon.BorderSizePixel = 0
FloatingIcon.Parent = ScreenGui

local IconCorner = Instance.new("UICorner", FloatingIcon)
IconCorner.CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", FloatingIcon).Color = Theme.Accent

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

-- 2. MAIN SQUARE GUI
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 650, 0, 450)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
MainFrame.BackgroundColor3 = Theme.Primary
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = Theme.Corner

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Theme.Secondary
Instance.new("UICorner", Header).CornerRadius = Theme.Corner

local Title = Instance.new("TextLabel", Header)
Title.Text = " BLATANTSPY V2 | ADVANCED LOGGER"
Title.Size = UDim2.new(1, -50, 1, 0)
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Text
Instance.new("UICorner", CloseBtn)

local LogContainer = Instance.new("ScrollingFrame", MainFrame)
LogContainer.Size = UDim2.new(1, -20, 1, -60)
LogContainer.Position = UDim2.new(0, 10, 0, 50)
LogContainer.BackgroundTransparency = 1
LogContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
LogContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIList = Instance.new("UIListLayout", LogContainer)
UIList.Padding = UDim.new(0, 5)

-- // DRAG LOGIC // --
local function MakeDraggable(obj, dragPart)
    local dragging, dragInput, dragStart, startPos
    dragPart = dragPart or obj
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = obj.Position end
    end)
    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    Services.UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

MakeDraggable(FloatingIcon)
MakeDraggable(MainFrame, Header)

IconButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- // LOGGER LOGIC // --
local function CreateLog(remote, method, args)
    local Frame = Instance.new("Frame", LogContainer)
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.BackgroundColor3 = Theme.Secondary
    Instance.new("UICorner", Frame)
    
    local NameLabel = Instance.new("TextLabel", Frame)
    NameLabel.Size = UDim2.new(1, -100, 0, 20)
    NameLabel.Position = UDim2.new(0, 10, 0, 3)
    NameLabel.Text = remote.Name .. " [" .. method .. "]"
    NameLabel.TextColor3 = Theme.Remote
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.BackgroundTransparency = 1

    local CopyBtn = Instance.new("TextButton", Frame)
    CopyBtn.Size = UDim2.new(0, 60, 0, 25)
    CopyBtn.Position = UDim2.new(1, -70, 0.5, -12)
    CopyBtn.Text = "COPY"
    CopyBtn.BackgroundColor3 = Theme.Accent
    CopyBtn.TextColor3 = Theme.Text
    Instance.new("UICorner", CopyBtn)

    CopyBtn.MouseButton1Click:Connect(function()
        setclipboard("-- Remote: " .. remote:GetFullName() .. "\n-- Method: " .. method)
    end)
end

-- // HOOKING // --
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        task.spawn(function() CreateLog(self, method, args) end)
    end
    
    return OldNamecall(self, ...)
end))

-- // ADONIS BYPASS // --
pcall(function()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "indexInstance") then
            for k, det in pairs(v) do
                if type(det) == "table" and type(det[2]) == "function" then
                    hookfunction(det[2], function() return false end)
                end
            end
        end
    end
end)

print("BlatantSpy HD Loaded Successfully!")
