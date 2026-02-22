--[[ 
    FIXED BLATANTSPY V2
    Perbaikan: Memastikan UI muncul di CoreGui dan bypass deteksi awal.
]]

-- 1. Pastikan Script tidak double run
if getgenv().BlatantSpyLoaded then return end
getgenv().BlatantSpyLoaded = true

local ClonedFunctions = {} do 
    ClonedFunctions.pcall = clonefunction(pcall)
    ClonedFunctions.unpack = clonefunction(table.unpack or unpack)
end

-- [ BYPASS & UTILS ]
local function SecureGetHUI()
    local success, result = pcall(function() return gethui() end)
    if success and result then return result end
    success, result = pcall(function() return game:GetService("CoreGui") end)
    if success and result then return result end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local Utils = {}
function Utils.GetPath(instance)
    local path = instance.Name
    local current = instance.Parent
    while current and current ~= game do
        path = current.Name .. "." .. path
        current = current.Parent
    end
    return "game." .. path
end

-- [ THEME ]
local Theme = {
    Primary = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(255, 255, 255)
}

-- [ UI BUILDER ]
local UI = {}
UI.MainGui = Instance.new("ScreenGui")
UI.MainGui.Name = "BlatantSpy_Final"
UI.MainGui.Parent = SecureGetHUI()

local MainFrame = Instance.new("Frame", UI.MainGui)
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.BackgroundColor3 = Theme.Primary
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Deprecated but effective for basic execution

local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Header.Text = "  BLATANTSPY | LOGGER ACTIVE"
Header.TextColor3 = Theme.Accent
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Font = Enum.Font.GothamBold

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 2

local List = Instance.new("UIListLayout", Scroll)
List.Padding = UDim.new(0, 5)

function UI:Log(name, method, path)
    local entry = Instance.new("TextLabel", Scroll)
    entry.Size = UDim2.new(1, 0, 0, 30)
    entry.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    entry.Text = string.format("[%s] %s", method, name)
    entry.TextColor3 = Theme.Text
    entry.TextSize = 10
    entry.Font = Enum.Font.Code
    Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y)
end

-- [ LOGIC INTEGRATION ]
local RawMetatable = getrawmetatable(game)
local OldNamecall = RawMetatable.__namecall
setreadonly(RawMetatable, false)

RawMetatable.__namecall = newcclosure(function(self, ...)
    local Method = getnamecallmethod()
    
    if not checkcaller() then
        if Method == "FireServer" or Method == "InvokeServer" then
            UI:Log(self.Name, Method, Utils.GetPath(self))
        end
    end
    
    return OldNamecall(self, ...)
end)

setreadonly(RawMetatable, true)
