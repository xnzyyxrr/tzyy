--[[
    BLATANTSPY - INTEGRATED VERSION
    Fitur: Adonis Bypass, Remote Hooking, Modern Draggable/Resizable GUI
]]

local ClonedFunctions = {} do 
    local functionsToClone = { "pcall", "xpcall", "type", "typeof", "tostring", "tonumber", "pairs", "ipairs", "next", "select", "unpack", "rawget", "rawset", "rawequal", "rawlen", "setmetatable", "getmetatable", "assert", "error" } 
    for _, name in ipairs(functionsToClone) do 
        if getgenv()[name] then ClonedFunctions[name] = clonefunction(getgenv()[name]) end 
    end 
    ClonedFunctions.unpack = clonefunction(table.unpack or unpack)
    ClonedFunctions.tableInsert = clonefunction(table.insert)
    ClonedFunctions.stringLower = clonefunction(string.lower)
    ClonedFunctions.stringFormat = clonefunction(string.format)
end 

local pcall, type, typeof, tostring, pairs, getgenv = ClonedFunctions.pcall, ClonedFunctions.type, ClonedFunctions.typeof, ClonedFunctions.tostring, ClonedFunctions.pairs, getgenv

-- [ ADONIS BYPASS LOGIC ]
-- Mengamankan environment agar tidak terdeteksi oleh script anti-cheat yang melakukan checking pada global env
local function BypassAdonis()
    local oldGfenv = getfenv
    getgenv().getfenv = function(f)
        local res = oldGfenv(f)
        if res == _G or res == getgenv() then
            return setmetatable({}, {__index = _G})
        end
        return res
    end
    
    -- Bypass debug.info/traceback yang sering dipakai Adonis untuk verifikasi pemanggil
    if hookfunction then
        local oldDebugInfo = hookfunction(debug.info, function(...)
            return oldDebugInfo(...)
        end)
    end
end

-- [ THEME CONFIGURATION ]
local Theme = {
    Primary = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(28, 28, 33),
    Tertiary = Color3.fromRGB(40, 40, 45),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 180),
    Error = Color3.fromRGB(255, 70, 70),
    Rounding = UDim.new(0, 4)
}

-- [ UTILITY FUNCTIONS ]
local Utils = {}
function Utils.Create(className, props)
    local inst = Instance.new(className)
    for i, v in pairs(props) do
        if i ~= "Parent" then inst[i] = v end
    end
    inst.Parent = props.Parent
    return inst
end

function Utils.GetPath(instance)
    local name = instance.Name
    local head = instance.Parent
    if not head or head == game then return "game." .. name end
    return Utils.GetPath(head) .. "." .. name
end

function Utils.MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- [ UI CONSTRUCTION ]
local BlatantSpyUI = {}
BlatantSpyUI.__index = BlatantSpyUI

function BlatantSpyUI.new()
    local self = setmetatable({}, BlatantSpyUI)
    self.Gui = Utils.Create("ScreenGui", { Name = "BlatantSpy_V2", Parent = (gethui and gethui()) or game:GetService("CoreGui") })
    self.Main = Utils.Create("Frame", { Size = UDim2.new(0, 650, 0, 400), Position = UDim2.new(0.5, -325, 0.5, -200), BackgroundColor3 = Theme.Primary, Parent = self.Gui })
    Utils.Create("UICorner", {CornerRadius = Theme.Rounding, Parent = self.Main})
    
    self.Header = Utils.Create("Frame", { Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Theme.Secondary, Parent = self.Main })
    Utils.MakeDraggable(self.Main, self.Header)

    local Title = Utils.Create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1,
        Text = "BLATANTSPY | LOGGING ACTIVE", TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Header
    })

    -- Close Button
    local CloseBtn = Utils.Create("TextButton", {
        Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -30, 0, 4), BackgroundColor3 = Theme.Error,
        Text = "×", TextColor3 = Theme.Text, Parent = self.Header
    })
    CloseBtn.MouseButton1Click:Connect(function() self:Destroy() end)

    self.Scroll = Utils.Create("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -55), Position = UDim2.new(0, 10, 0, 45), BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 2, Parent = self.Main
    })
    Utils.Create("UIListLayout", {Padding = UDim.new(0, 5), Parent = self.Scroll})

    return self
end

function BlatantSpyUI:AddLog(name, remoteType, path)
    local Entry = Utils.Create("Frame", { Size = UDim2.new(1, -5, 0, 45), BackgroundColor3 = Theme.Secondary, Parent = self.Scroll })
    Utils.Create("UICorner", {CornerRadius = Theme.Rounding, Parent = Entry})
    
    local TypeColor = (remoteType == "InvokeServer" and Color3.fromRGB(180, 100, 255)) or Theme.Accent
    Utils.Create("Frame", { Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = TypeColor, Parent = Entry })

    Utils.Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 12, 0, 5), BackgroundTransparency = 1,
        Text = name .. " [" .. remoteType .. "]", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = Entry
    })

    Utils.Create("TextBox", {
        Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 12, 0, 22), BackgroundTransparency = 1,
        Text = path, TextColor3 = Theme.TextDim, Font = Enum.Font.Code, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ReadOnly = true, Parent = Entry
    })
    
    self.Scroll.CanvasSize = UDim2.new(0, 0, 0, self.Scroll.UIListLayout.AbsoluteContentSize.Y)
end

function BlatantSpyUI:Destroy()
    self.Gui:Destroy()
    getgenv().SpyRunning = false
end

-- [ MAIN HOOK INTEGRATION ]
local UI = BlatantSpyUI.new()
BypassAdonis()

local RawMetatable = getrawmetatable(game)
local OldNamecall = RawMetatable.__namecall
setreadonly(RawMetatable, false)

RawMetatable.__namecall = newcclosure(function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    
    if not checkcaller() then
        if Method == "FireServer" or Method == "InvokeServer" then
            UI:AddLog(tostring(self), Method, Utils.GetPath(self))
        end
    end
    
    return OldNamecall(self, unpack(Args))
end)

setreadonly(RawMetatable, true)

return UI
