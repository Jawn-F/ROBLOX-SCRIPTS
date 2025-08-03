-- Dungeon Heroes Script with Basic UI Framework (DarkDex-like)
-- This script is designed to be standalone and executed directly by a Lua executor.
-- It does NOT rely on an external key system, webhook logging, or Platoboost.

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////// START BASIC UI LIBRARY (DARKDEX-LIKE) //////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local Library = {}
Library.__index = Library

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BasicUI_ScreenGui"
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150) -- Center of screen
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Seisen Hub - Dungeon Heroes"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 20
CloseButton.Parent = TopBar

local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 1, -30)
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local TabListFrame = Instance.new("Frame")
TabListFrame.Name = "TabListFrame"
TabListFrame.Size = UDim2.new(0, 120, 1, 0)
TabListFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TabListFrame.BorderSizePixel = 0
TabListFrame.Parent = TabContainer

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Vertical
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.Parent = TabListFrame

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -120, 1, 0)
ContentFrame.Position = UDim2.new(0, 120, 0, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0,0,0,0) -- Will be updated automatically
ContentFrame.ScrollBarTransparency = 0.5
ContentFrame.Parent = TabContainer

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.FillDirection = Enum.FillDirection.Vertical
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.Parent = ContentFrame

local ActiveTab = nil
local Tabs = {}

function Library:CreateWindow(title)
    TitleLabel.Text = title
    return setmetatable({}, Library) -- Return a table with library functions as metatable
end

function Library:AddTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Button"
    TabButton.Size = UDim2.new(1, -10, 0, 25)
    TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    TabButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
    TabButton.BorderSizePixel = 1
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.Parent = TabListFrame

    local TabContent = Instance.new("Frame")
    TabContent.Name = name .. "Content"
    TabContent.Size = UDim2.new(1, -20, 0, 0) -- Width adjusted for padding
    TabContent.BackgroundTransparency = 1
    TabContent.Parent = ContentFrame
    TabContent.Visible = false -- Hidden by default

    local TabContentLayout = Instance.new("UIListLayout")
    TabContentLayout.FillDirection = Enum.FillDirection.Vertical
    TabContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabContentLayout.Padding = UDim.new(0, 5)
    TabContentLayout.Parent = TabContent

    local self = {
        Name = name,
        Button = TabButton,
        Content = TabContent,
        Elements = {},
        Layout = TabContentLayout,
        ParentWindow = self,
    }

    function self:AddGroupbox(text)
        local GroupboxFrame = Instance.new("Frame")
        GroupboxFrame.Name = text .. "Groupbox"
        GroupboxFrame.Size = UDim2.new(1, 0, 0, 0) -- Dynamic height
        GroupboxFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        GroupboxFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
        GroupboxFrame.BorderSizePixel = 1
        GroupboxFrame.Parent = TabContent

        local GroupboxTitle = Instance.new("TextLabel")
        GroupboxTitle.Name = "Title"
        GroupboxTitle.Size = UDim2.new(1, 0, 0, 20)
        GroupboxTitle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        GroupboxTitle.BorderSizePixel = 0
        GroupboxTitle.Text = text
        GroupboxTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        GroupboxTitle.Font = Enum.Font.GothamBold
        GroupboxTitle.TextSize = 14
        GroupboxTitle.TextXAlignment = Enum.TextXAlignment.Left
        GroupboxTitle.Parent = GroupboxFrame

        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 5)
        Padding.Parent = GroupboxTitle

        local GroupboxContent = Instance.new("Frame")
        GroupboxContent.Name = "Content"
        GroupboxContent.Size = UDim2.new(1, -10, 0, 0)
        GroupboxContent.Position = UDim2.new(0, 5, 0, 20)
        GroupboxContent.BackgroundTransparency = 1
        GroupboxContent.Parent = GroupboxFrame

        local GroupboxLayout = Instance.new("UIListLayout")
        GroupboxLayout.FillDirection = Enum.FillDirection.Vertical
        GroupboxLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        GroupboxLayout.Padding = UDim.new(0, 5)
        GroupboxLayout.Parent = GroupboxContent

        local groupbox = {
            Frame = GroupboxFrame,
            Content = GroupboxContent,
            Layout = GroupboxLayout,
            Elements = {},
        }

        local function updateGroupboxSize()
            GroupboxFrame.Size = UDim2.new(1, 0, 0, GroupboxLayout.AbsoluteContentSize.Y + 20 + 10) -- 20 for title, 10 for padding
            ContentFrame.CanvasSize = UDim2.new(0,0,0,ContentLayout.AbsoluteContentSize.Y) -- Update scroll frame
        end
        GroupboxLayout.ChildAdded:Connect(updateGroupboxSize)
        GroupboxLayout.ChildRemoved:Connect(updateGroupboxSize)
        -- Initial size update
        task.defer(updateGroupboxSize)

        function groupbox:AddToggle(idx, info)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 20)
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Parent = GroupboxContent

            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 40, 1, 0)
            toggleButton.Position = UDim2.new(1, -40, 0, 0)
            toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            toggleButton.BorderColor3 = Color3.fromRGB(70, 70, 70)
            toggleButton.BorderSizePixel = 1
            toggleButton.Text = ""
            toggleButton.Parent = toggleFrame

            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0.5, -4, 0.9, -4)
            toggleCircle.Position = UDim2.new(0, 2, 0, 2)
            toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleCircle.BorderColor3 = Color3.fromRGB(90, 90, 90)
            toggleCircle.BorderSizePixel = 1
            toggleCircle.CornerRadius = UDim.new(1, 0)
            toggleCircle.Parent = toggleButton

            local toggleText = Instance.new("TextLabel")
            toggleText.Size = UDim2.new(1, -45, 1, 0)
            toggleText.BackgroundTransparency = 1
            toggleText.Text = info.Text
            toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleText.Font = Enum.Font.Gotham
            toggleText.TextSize = 14
            toggleText.TextXAlignment = Enum.TextXAlignment.Left
            toggleText.Parent = toggleFrame

            local value = info.Default
            local function updateToggleVisual()
                if value then
                    toggleButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
                    toggleCircle.Position = UDim2.new(0.5, 2, 0, 2)
                else
                    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    toggleCircle.Position = UDim2.new(0, 2, 0, 2)
                end
                if info.Callback then
                    info.Callback(value)
                end
            end

            toggleButton.MouseButton1Click:Connect(function()
                value = not value
                updateToggleVisual()
            })

            updateToggleVisual() -- Initial visual update

            groupbox.Elements[idx] = {
                Frame = toggleFrame,
                Value = function() return value end,
                SetValue = function(newValue) value = newValue updateToggleVisual() end
            }
            return groupbox.Elements[idx]
        end

        function groupbox:AddSlider(idx, info)
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 40)
            sliderFrame.BackgroundTransparency = 1
            sliderFrame.Parent = GroupboxContent

            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(1, 0, 0, 15)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            sliderLabel.Font = Enum.Font.Gotham
            sliderLabel.TextSize = 14
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame

            local sliderBar = Instance.new("Frame")
            sliderBar.Size = UDim2.new(1, 0, 0, 8)
            sliderBar.Position = UDim2.new(0, 0, 0, 20)
            sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            sliderBar.BorderColor3 = Color3.fromRGB(70, 70, 70)
            sliderBar.BorderSizePixel = 1
            sliderBar.Parent = sliderFrame

            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBar

            local value = info.Default
            local function updateSliderVisual()
                local percentage = (value - info.Min) / (info.Max - info.Min)
                sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                sliderLabel.Text = string.format("%s: %s%s%s", info.Text, info.Prefix or "", math.floor(value), info.Suffix or "")
                if info.Callback then
                    info.Callback(value)
                end
            end

            local isDragging = false
            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                end
            end)
            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
                    local mouseX = input.Position.X
                    local barX = sliderBar.AbsolutePosition.X
                    local barWidth = sliderBar.AbsoluteSize.X
                    
                    local rawPercentage = math.clamp((mouseX - barX) / barWidth, 0, 1)
                    local newValue = info.Min + (info.Max - info.Min) * rawPercentage
                    
                    if info.Rounding == 0 then
                        value = math.floor(newValue)
                    else
                        value = tonumber(string.format("%." .. info.Rounding .. "f", newValue))
                    end
                    updateSliderVisual()
                end
            end)

            updateSliderVisual() -- Initial visual update

            groupbox.Elements[idx] = {
                Frame = sliderFrame,
                Value = function() return value end,
                SetValue = function(newValue) value = newValue updateSliderVisual() end
            }
            return groupbox.Elements[idx]
        end

        function groupbox:AddDropdown(idx, info)
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
            dropdownFrame.BackgroundTransparency = 1
            dropdownFrame.Parent = GroupboxContent

            local dropdownLabel = Instance.new("TextLabel")
            dropdownLabel.Size = UDim2.new(1, 0, 0, 15)
            dropdownLabel.BackgroundTransparency = 1
            dropdownLabel.Text = info.Text
            dropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            dropdownLabel.Font = Enum.Font.Gotham
            dropdownLabel.TextSize = 14
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            dropdownLabel.Parent = dropdownFrame

            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Size = UDim2.new(1, 0, 0, 20)
            dropdownButton.Position = UDim2.new(0, 0, 0, 20)
            dropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            dropdownButton.BorderColor3 = Color3.fromRGB(70, 70, 70)
            dropdownButton.BorderSizePixel = 1
            dropdownButton.Text = info.Default or "Select..."
            dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            dropdownButton.Font = Enum.Font.Gotham
            dropdownButton.TextSize = 14
            dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
            dropdownButton.Parent = dropdownFrame

            local value = info.Default
            local function updateDropdownVisual()
                dropdownButton.Text = value
                if info.Callback then
                    info.Callback(value)
                end
            end

            local dropdownList = Instance.new("ScrollingFrame")
            dropdownList.Size = UDim2.new(1, 0, 0, 0) -- Dynamic height
            dropdownList.Position = UDim2.new(0, 0, 0, dropdownFrame.AbsolutePosition.Y + dropdownFrame.AbsoluteSize.Y)
            dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            dropdownList.BorderColor3 = Color3.fromRGB(60, 60, 60)
            dropdownList.BorderSizePixel = 1
            dropdownList.Visible = false
            dropdownList.ZIndex = 10 -- Ensure it's on top
            dropdownList.Parent = ScreenGui -- Parent to ScreenGui for overlay effect

            local listLayout = Instance.new("UIListLayout")
            listLayout.FillDirection = Enum.FillDirection.Vertical
            listLayout.Padding = UDim.new(0, 2)
            listLayout.Parent = dropdownList

            local function closeDropdown()
                dropdownList.Visible = false
            end

            dropdownButton.MouseButton1Click:Connect(function()
                dropdownList.Visible = not dropdownList.Visible
                if dropdownList.Visible then
                    -- Position correctly when opened
                    dropdownList.Position = UDim2.fromOffset(dropdownButton.AbsolutePosition.X, dropdownButton.AbsolutePosition.Y + dropdownButton.AbsoluteSize.Y)
                end
            end)

            for _, val in ipairs(info.Values) do
                local itemButton = Instance.new("TextButton")
                itemButton.Size = UDim2.new(1, 0, 0, 20)
                itemButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                itemButton.BorderColor3 = Color3.fromRGB(70, 70, 70)
                itemButton.BorderSizePixel = 0
                itemButton.Text = tostring(val)
                itemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                itemButton.Font = Enum.Font.Gotham
                itemButton.TextSize = 14
                itemButton.TextXAlignment = Enum.TextXAlignment.Left
                itemButton.Parent = dropdownList

                local padding = Instance.new("UIPadding")
                padding.PaddingLeft = UDim.new(0, 5)
                padding.Parent = itemButton

                itemButton.MouseButton1Click:Connect(function()
                    value = itemButton.Text
                    updateDropdownVisual()
                    closeDropdown()
                end)
            end

            -- Adjust dropdown list size based on content, clamped by MaxVisibleDropdownItems
            local maxVisibleItems = info.MaxVisibleDropdownItems or 8
            local listHeight = math.min(#info.Values, maxVisibleItems) * 20 + (#info.Values > maxVisibleItems and 5 or 0) -- 20 for item height, +5 for scrollbar padding
            dropdownList.Size = UDim2.new(1, 0, 0, listHeight)
            dropdownList.CanvasSize = UDim2.new(0, 0, 0, #info.Values * 20)

            -- Close dropdown when clicking outside
            game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if not dropdownButton:IsMouseOver() and not dropdownList:IsMouseOver() then
                        closeDropdown()
                    end
                end
            end)
            
            updateDropdownVisual()

            groupbox.Elements[idx] = {
                Frame = dropdownFrame,
                Value = function() return value end,
                SetValue = function(newValue) value = newValue updateDropdownVisual() end
            }
            return groupbox.Elements[idx]
        end

        function groupbox:AddButton(idx, info)
            local button = Instance.new("TextButton")
            button.Name = info.Text .. "Button"
            button.Size = UDim2.new(1, 0, 0, 25)
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            button.BorderColor3 = Color3.fromRGB(70, 70, 70)
            button.BorderSizePixel = 1
            button.Text = info.Text
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Font = Enum.Font.GothamBold
            button.TextSize = 14
            button.Parent = GroupboxContent

            button.MouseButton1Click:Connect(function()
                if info.Func then
                    info.Func()
                end
            })

            groupbox.Elements[idx] = {
                Frame = button,
            }
            return groupbox.Elements[idx]
        end

        function groupbox:AddInput(idx, info)
            local inputFrame = Instance.new("Frame")
            inputFrame.Size = UDim2.new(1, 0, 0, 40)
            inputFrame.BackgroundTransparency = 1
            inputFrame.Parent = GroupboxContent

            local inputLabel = Instance.new("TextLabel")
            inputLabel.Size = UDim2.new(1, 0, 0, 15)
            inputLabel.BackgroundTransparency = 1
            inputLabel.Text = info.Text
            inputLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            inputLabel.Font = Enum.Font.Gotham
            inputLabel.TextSize = 14
            inputLabel.TextXAlignment = Enum.TextXAlignment.Left
            inputLabel.Parent = inputFrame

            local inputTextBox = Instance.new("TextBox")
            inputTextBox.Size = UDim2.new(1, 0, 0, 20)
            inputTextBox.Position = UDim2.new(0, 0, 0, 20)
            inputTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            inputTextBox.BorderColor3 = Color3.fromRGB(70, 70, 70)
            inputTextBox.BorderSizePixel = 1
            inputTextBox.PlaceholderText = info.Placeholder
            inputTextBox.Text = info.Default or ""
            inputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            inputTextBox.Font = Enum.Font.Gotham
            inputTextBox.TextSize = 14
            inputTextBox.TextXAlignment = Enum.TextXAlignment.Left
            inputTextBox.Parent = inputFrame

            local value = info.Default or ""
            local function updateValue(text)
                value = text
                if info.Callback then
                    info.Callback(value)
                end
            end
            inputTextBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    updateValue(inputTextBox.Text)
                end
            })
            inputTextBox:GetPropertyChangedSignal("Text"):Connect(function()
                if not inputTextBox.Focused then -- Only update while typing if not focused, or on focus lost
                    updateValue(inputTextBox.Text)
                end
            })
            
            -- Set initial value based on config
            updateValue(inputTextBox.Text)

            groupbox.Elements[idx] = {
                Frame = inputFrame,
                Value = function() return value end,
                SetValue = function(newValue) value = newValue inputTextBox.Text = newValue updateValue(newValue) end
            }
            return groupbox.Elements[idx]
        end
        
        -- Placeholder for AddLabel, AddDivider, etc. as needed

        return groupbox
    end

    function self:AddLeftGroupbox(text)
        return self:AddGroupbox(text)
    end
    function self:AddRightGroupbox(text)
        return self:AddGroupbox(text)
    end
    
    TabButton.MouseButton1Click:Connect(function()
        if ActiveTab then
            ActiveTab.Content.Visible = false
            ActiveTab.Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            ActiveTab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        ActiveTab = self
        self.Content.Visible = true
        self.Button.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
        self.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        -- Update ContentFrame's CanvasSize to fit the new tab's content
        ContentFrame.CanvasSize = UDim2.new(0,0,0,self.Layout.AbsoluteContentSize.Y)
    end)

    Tabs[name] = self
    
    if not ActiveTab then
        TabButton.MouseButton1Click:Fire() -- Activate the first tab by default
    end

    return self
end

function Library:Toggle(value)
    if value ~= nil then
        MainFrame.Visible = value
    else
        MainFrame.Visible = not MainFrame.Visible
    end
end

CloseButton.MouseButton1Click:Connect(function()
    Library:Toggle(false)
end)

-- Initial Toggle (similar to AutoShow)
task.defer(function()
    Library:Toggle(true)
end)


-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////// END BASIC UI LIBRARY (DARKDEX-LIKE) //////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////// START DUNGEON HEROES SCRIPT LOGIC //////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- Services
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService") -- Keep HttpService for config saving
local Combat = RS:WaitForChild("Systems", 9e9):WaitForChild("Combat", 9e9):WaitForChild("PlayerAttack", 9e9)
local Effects = RS:WaitForChild("Systems", 9e9):WaitForChild("Effects", 9e9):WaitForChild("DoEffect", 9e9)
local Skills = RS:WaitForChild("Systems", 9e9):WaitForChild("Skills", 9e9):WaitForChild("UseSkill", 9e9)
local SkillAttack = RS:WaitForChild("Systems", 9e9):WaitForChild("Combat", 9e9):WaitForChild("PlayerSkillAttack", 9e9)
local mobFolder = workspace:WaitForChild("Mobs", 9e9)
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService") -- Added for toggle keybind

local LocalPlayer = Players.LocalPlayer
local Character = nil
local HRP = nil
local connections = {}

-- Anti-AFK System
local AntiAfkSystem = {
    setup = function()
        local conn = LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
        table.insert(connections, conn)
    end,
    cleanup = function()
        for _, conn in ipairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        connections = {}
    end
}
AntiAfkSystem.setup()

-- Try to get the skill system module
local skillSystem = nil
local profileSystem = nil
pcall(function()
    skillSystem = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Skills", 9e9))
    profileSystem = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Profile", 9e9))
end)

-- Update character references
local function updateCharacterReferences()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HRP = Character:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(updateCharacterReferences)
if LocalPlayer.Character then
    updateCharacterReferences()
end

-- Auto skill configuration
local CONFIG = {
    SKILL_SLOTS = {1, 2, 3, 4},
    FALLBACK_COOLDOWN = 2,
    SKILL_CHECK_INTERVAL = 0.5,
    SKILL_RANGE = 500,
}

-- Runtime state for auto skill
local RuntimeState = {
    autoSkillEnabled = false,
    lastUsed = {},
    skillData = {},
    selectedSkills = {},
    skillToggles = {},
}

-- Config (Loaded from file)
local configFolder = "SeisenHub"
local configFile = configFolder .. "/seisen_hub_dh.txt"

-- Default config values
local config = {
    killAuraEnabled = false,
    autoStartDungeon = false,
    autoReplyDungeon = false,
    autoNextDungeon = false,
    autoFarmEnabled = false,
    autoSkillEnabled = false,
    skillToggles = {},
    dungeonSequenceIndex = 1,
    normalDungeonName = "Shattered Forest lvl 1+",
    normalDungeonDifficulty = "Normal",
    normalDungeonPlayerLimit = 1,
    raidDungeonName = "Abyssal Depths",
    raidDungeonDifficulty = "RAID",
    raidDungeonPlayerLimit = 7,
    eventDungeonName = "Gauntlet",
    eventDungeonDifficulty = "Normal",
    eventDungeonPlayerLimit = 4,
    completedDungeons = {},
    autoClaimDailyQuest = false,
    autoEquipHighestWeapon = false,
    fpsBoostEnabled = false,
    maxfpsBoostenabled = false,
    supermaxfpsBoostenabled = false,
    autoSellEnabled = false,
    autoSellRarity = "Common",
    autoResetOnMiniBoss = false,
    miniBossRoomNumber = 6,
    uiToggleKey = "RightControl" -- Default key for UI toggle
}

-- Ensure config folder exists
if not isfolder(configFolder) then
    makefolder(configFolder)
end

-- Load config
if isfile(configFile) then
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(configFile))
    end)
    if ok and type(data) == "table" then
        for k, v in pairs(data) do
            config[k] = v
        end
    end
end

-- Save config
local function saveConfig()
    writefile(configFile, HttpService:JSONEncode(config))
end

-- Initialize global/local variables from config
_G.killAuraEnabled = config.killAuraEnabled
local autoStartDungeon = config.autoStartDungeon
local autoReplyDungeon = config.autoReplyDungeon
local autoNextDungeon = config.autoNextDungeon
local autoFarmEnabled = config.autoFarmEnabled
RuntimeState.autoSkillEnabled = config.autoSkillEnabled
RuntimeState.skillToggles = config.skillToggles or {}
local dungeonSequenceIndex = config.dungeonSequenceIndex or 1
local normalDungeonName = config.normalDungeonName
local normalDungeonDifficulty = config.normalDungeonDifficulty
local normalDungeonPlayerLimit = config.normalDungeonPlayerLimit
local raidDungeonName = config.raidDungeonName
local raidDungeonDifficulty = config.raidDungeonDifficulty
local raidDungeonPlayerLimit = config.raidDungeonPlayerLimit
local eventDungeonName = config.eventDungeonName
local eventDungeonDifficulty = config.eventDungeonDifficulty
local eventDungeonPlayerLimit = config.eventDungeonPlayerLimit
local autoClaimDailyQuest = config.autoClaimDailyQuest
local autoEquipHighestWeapon = config.autoEquipHighestWeapon
local fpsBoostEnabled = config.fpsBoostEnabled
local supermaxfpsBoostenabled = config.supermaxfpsBoostenabled
local maxfpsBoostenabled = config.maxfpsBoostenabled
local autoSellEnabled = config.autoSellEnabled
local selectedRarity = config.autoSellRarity
local autoResetOnMiniBoss = config.autoResetOnMiniBoss
local miniBossRoomNumber = config.miniBossRoomNumber

-- Skill Data Initialization
local function initializeSkillData()
    RuntimeState.skillData = {
        ["Whirlwind"] = {["DisplayName"] = "Whirlwind", ["Cooldown"] = 6, ["UseLength"] = 1.9, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 0.7},{["Type"] = "Normal", ["Damage"] = 0.7},{["Type"] = "Normal", ["Damage"] = 0.7},{["Type"] = "Normal", ["Damage"] = 0.7},{["Type"] = "Normal", ["Damage"] = 0.7},{["Type"] = "Normal", ["Damage"] = 0.7}}},
        ["FerociousRoar"] = {["DisplayName"] = "Ferocious Roar", ["Cooldown"] = 9, ["UseLength"] = 1.5, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 0.5},{["Type"] = "Normal", ["Damage"] = 0.5},{["Type"] = "Normal", ["Damage"] = 0.5},{["Type"] = "Normal", ["Damage"] = 0.5},{["Type"] = "Normal", ["Damage"] = 0.5},{["Type"] = "Normal", ["Damage"] = 0.5},{["Type"] = "Normal", ["Damage"] = 0.5},{["Type"] = "Normal", ["Damage"] = 0.5},{["Type"] = "Normal", ["Damage"] = 0.5},{["Type"] = "Normal", ["Damage"] = 0.5}}},
        ["Rumble"] = {["DisplayName"] = "Rumble", ["Cooldown"] = 10, ["UseLength"] = 1.2, ["CanMultiHit"] = false, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 4},{["Type"] = "Normal", ["Damage"] = 4},{["Type"] = "Normal", ["Damage"] = 4},{["Type"] = "Normal", ["Damage"] = 4},{["Type"] = "Normal", ["Damage"] = 4}}},
        ["PiercingWave"] = {["DisplayName"] = "Piercing Wave", ["Cooldown"] = 8, ["UseLength"] = 0.7, ["CanMultiHit"] = false, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 2.8},{["Type"] = "Normal", ["Damage"] = 2.8},{["Type"] = "Normal", ["Damage"] = 2.8},{["Type"] = "Normal", ["Damage"] = 2.8},{["Type"] = "Normal", ["Damage"] = 2.8}}},
        ["Fireball"] = {["DisplayName"] = "Fireball", ["Cooldown"] = 8, ["UseLength"] = 1.2, ["CanMultiHit"] = false, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 4}}},
        ["DrillStrike"] = {["DisplayName"] = "Drill Strike", ["Cooldown"] = 9, ["UseLength"] = 1, ["CanMultiHit"] = false, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 3.5},{["Type"] = "Normal", ["Damage"] = 3.5},{["Type"] = "Normal", ["Damage"] = 3.5},{["Type"] = "Normal", ["Damage"] = 3.5},{["Type"] = "Normal", ["Damage"] = 3.5},{["Type"] = "Normal", ["Damage"] = 3.5},{["Type"] = "Normal", ["Damage"] = 3.5}}},
        ["FireBreath"] = {["DisplayName"] = "Fire Breath", ["Cooldown"] = 13, ["UseLength"] = 3.5, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 2},{["Type"] = "Normal", ["Damage"] = 2},{["Type"] = "Normal", ["Damage"] = 2},{["Type"] = "Normal", ["Damage"] = 2},{["Type"] = "Normal", ["Damage"] = 2}}},
        ["FrenziedStrike"] = {["DisplayName"] = "Frenzied Strike", ["Cooldown"] = 14, ["UseLength"] = 2.6, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 2.5},{["Type"] = "Normal", ["Damage"] = 2.5},{["Type"] = "Normal", ["Damage"] = 2.5}}},
        ["Eruption"] = {["DisplayName"] = "Eruption", ["Cooldown"] = 16, ["UseLength"] = 4, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 8}}},
        ["SerpentStrike"] = {["DisplayName"] = "Serpent Strike", ["Cooldown"] = 10, ["UseLength"] = 1.6, ["CanMultiHit"] = false, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 2.5},{["Type"] = "Normal", ["Damage"] = 2.5},{["Type"] = "Normal", ["Damage"] = 2.5},{["Type"] = "Normal", ["Damage"] = 2.5},{["Type"] = "Normal", ["Damage"] = 2.5},{["Type"] = "Normal", ["Damage"] = 2.5},{["Type"] = "Normal", ["Damage"] = 2.5}}},
        ["Cannonball"] = {["DisplayName"] = "Cannonball", ["Cooldown"] = 12, ["UseLength"] = 1.8, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 3}}},
        ["Skybreaker"] = {["DisplayName"] = "Skybreaker", ["Cooldown"] = 8, ["UseLength"] = 1.6, ["CanMultiHit"] = false, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 5},{["Type"] = "Normal", ["Damage"] = 5},{["Type"] = "Normal", ["Damage"] = 5},{["Type"] = "Normal", ["Damage"] = 5},{["Type"] = "Normal", ["Damage"] = 5},{["Type"] = "Normal", ["Damage"] = 5},{["Type"] = "Normal", ["Damage"] = 5},{["Type"] = "Normal", ["Damage"] = 5},{["Type"] = "Normal", ["Damage"] = 5},{["Type"] = "Normal", ["Damage"] = 5}}},
        ["Eviscerate"] = {["DisplayName"] = "Eviscerate", ["Cooldown"] = 16, ["UseLength"] = {1.7, 0.6, 0.6}, ["CanMultiHit"] = true, ["NumCharges"] = 3, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 2}}},
        ["Thunderclap"] = {["DisplayName"] = "Thunderclap", ["Cooldown"] = 11, ["UseLength"] = 2.3, ["CanMultiHit"] = false, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 3}}},
        ["HammerStorm"] = {["DisplayName"] = "Hammer Storm", ["Cooldown"] = 18, ["UseLength"] = 2.4, ["CanMultiHit"] = false, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 13},{["Type"] = "Normal", ["Damage"] = 7},{["Type"] = "Normal", ["Damage"] = 4},{["Type"] = "Normal", ["Damage"] = 2},{["Type"] = "Normal", ["Damage"] = 1}}},
        ["FrostArc"] = {["DisplayName"] = "Frost Arc", ["Cooldown"] = 10, ["UseLength"] = 0.7, ["CanMultiHit"] = false, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 2.5, ["Status"] = "Chilled", ["StatusDuration"] = 3}}},
        ["HolyLight"] = {["DisplayName"] = "Holy Light", ["Cooldown"] = 25, ["UseLength"] = 1.5, ["CanMultiHit"] = false, ["Hits"] = {}, ["DamagePerRarity"] = 0.5, ["PreloadAnimation"] = "HolyLight"},
        ["Whirlpool"] = {["DisplayName"] = "Whirlpool", ["Cooldown"] = 22, ["UseLength"] = 1.5, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},{["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},{["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},{["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},{["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},{["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},{["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},{["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},{["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},{["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05}}, ["DamagePerRarity"] = 0.25, ["PreloadAnimation"] = "Whirlpool"},
        ["MeteorShower"] = {["DisplayName"] = "Meteor Shower", ["Cooldown"] = 20, ["UseLength"] = 2.5, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Magic", ["Damage"] = 3.5},{["Type"] = "Magic", ["Damage"] = 3.5},{["Type"] = "Magic", ["Damage"] = 3.5},{["Type"] = "Magic", ["Damage"] = 3.5},{["Type"] = "Magic", ["Damage"] = 3.5}}, ["PreloadAnimation"] = "MeteorShower"},
        ["ShadowStrike"] = {["DisplayName"] = "Shadow Strike", ["Cooldown"] = 12, ["UseLength"] = 1.1, ["CanMultiHit"] = false, ["Hits"] = {{["Type"] = "Dark", ["Damage"] = 5, ["Status"] = "Blind", ["StatusDuration"] = 2}}, ["PreloadAnimation"] = "ShadowStrike"},
        ["Berserk"] = {["DisplayName"] = "Berserk", ["Cooldown"] = 18, ["UseLength"] = 2, ["CanMultiHit"] = false, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 6, ["Status"] = "Rage", ["StatusDuration"] = 5}}, ["PreloadAnimation"] = "Berserk"},
        ["ChainHeal"] = {["DisplayName"] = "Chain Heal", ["Cooldown"] = 20, ["UseLength"] = 1.5, ["CanMultiHit"] = true, ["Hits"] = {}, ["PreloadAnimation"] = "ChainHeal"},
        ["ChainLightning"] = {["DisplayName"] = "Chain Lightning", ["Cooldown"] = 14, ["UseLength"] = 1.7, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Magic", ["Damage"] = 2.8},{["Type"] = "Magic", ["Damage"] = 2.2},{["Type"] = "Magic", ["Damage"] = 1.6}}, ["PreloadAnimation"] = "ChainLightning"},
        ["FlameRider"] = {["DisplayName"] = "Flame Rider", ["Cooldown"] = 16, ["UseLength"] = 2.2, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Fire", ["Damage"] = 3.5},{["Type"] = "Fire", ["Damage"] = 3.5}}},
        ["MagicMissiles"] = {["DisplayName"] = "Magic Missiles", ["Cooldown"] = 10, ["UseLength"] = 1.2, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Magic", ["Damage"] = 1.5},{["Type"] = "Magic", ["Damage"] = 1.5},{["Type"] = "Magic", ["Damage"] = 1.5}}},
        ["SelfHeal"] = {["DisplayName"] = "Self Heal", ["Cooldown"] = 18, ["UseLength"] = 1.1, ["CanMultiHit"] = false, ["Hits"] = {}, ["PreloadAnimation"] = "SelfHeal"},
        ["MeteorStorm"] = {["DisplayName"] = "Meteor Storm", ["Cooldown"] = 26, ["UseLength"] = 1.6, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 2.25},{["Type"] = "Normal", ["Damage"] = 2.25},{["Type"] = "Normal", ["Damage"] = 2.25},{["Type"] = "Normal", ["Damage"] = 2.25},{["Type"] = "Normal", ["Damage"] = 2.25},{["Type"] = "Normal", ["Damage"] = 2.25}}, ["DamagePerRarity"] = 0.6, ["PreloadAnimation"] = "MeteorStorm"},
        ["PantherPounce"] = {["DisplayName"] = "Panther Pounce", ["Cooldown"] = 8, ["UseLength"] = 1.5, ["CanMultiHit"] = false, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 4, ["Status"] = "Punctured", ["StatusDuration"] = 5}}},
        ["NaturesGrasp"] = {["DisplayName"] = "Nature's Grasp", ["Cooldown"] = 10, ["UseLength"] = 1.1, ["CanMultiHit"] = false, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 2, ["Status"] = "Snare", ["StatusDuration"] = 4}}},
        ["CallOfTheWild"] = {["DisplayName"] = "Call of the Wild", ["Cooldown"] = 12, ["UseLength"] = 1.1, ["CanMultiHit"] = false, ["Hits"] = {}},
        ["PartyAnimal"] = {["DisplayName"] = "Party Animal", ["Cooldown"] = 24, ["UseLength"] = 2, ["CanMultiHit"] = false, ["Hits"] = {}},
        ["MonkeyKing"] = {["DisplayName"] = "Monkey King", ["Cooldown"] = 15, ["UseLength"] = 1.8, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Heal", ["Damage"] = 2.5},{["Type"] = "Heal", ["Damage"] = 2.5},{["Type"] = "Heal", ["Damage"] = 2.5},{["Type"] = "Heal", ["Damage"] = 2.5},{["Type"] = "Heal", ["Damage"] = 2.5},{["Type"] = "Heal", ["Damage"] = 2.5}}},
        ["ConsecutiveLightning"] = {["DisplayName"] = "Consecutive Lightning", ["Cooldown"] = 21, ["UseLength"] = {0.3, 0.4, 0.25, 0.35, 0.5}, ["CanMultiHit"] = true, ["Hits"] = {{["Type"] = "Normal", ["Damage"] = 2.5, ["Status"] = "ElectricShock", ["StatusDuration"] = 8}}},
        ["Supercharge"] = {["DisplayName"] = "Supercharge", ["Cooldown"] = 25, ["UseLength"] = 1.8, ["CanMultiHit"] = false, ["Hits"] = {}},
        ["MagicCircle"] = {["DisplayName"] = "Magic Circle", ["Cooldown"] = 22, ["UseLength"] = 2.4, ["CanMultiHit"] = false, ["Hits"] = {}},
    }
    RuntimeState.selectedSkills = {"Whirlwind", "FerociousRoar", "Rumble"}
end
initializeSkillData()

-- Auto Skill Helper Functions
local function getEnemiesInRange(range)
    local enemies = {}
    if not LocalPlayer.Character or not HRP or not mobFolder then return enemies end
    for _, mob in ipairs(mobFolder:GetChildren()) do
        if mob:IsA("Model") then
            local mobHrp = mob:FindFirstChild("HumanoidRootPart")
            if mobHrp then
                local isAlive = false
                local mobHumanoid = mob:FindFirstChild("Humanoid")
                if mobHumanoid then isAlive = mobHumanoid.Health > 0 end
                if not isAlive then
                    local healthbar = mob:FindFirstChild("Healthbar")
                    if healthbar then
                        local healthValue = healthbar:FindFirstChild("Health") or healthbar:FindFirstChild("HP") or healthbar:FindFirstChild("CurrentHealth")
                        if healthValue and healthValue:IsA("NumberValue") then isAlive = healthValue.Value > 0 end
                    end
                end
                if not isAlive then isAlive = true end -- Assume alive if no health system found
                
                if isAlive then
                    local distance = (mobHrp.Position - HRP.Position).Magnitude
                    if distance <= range then
                        table.insert(enemies, mob)
                    end
                end
            end
        end
    end
    table.sort(enemies, function(a, b)
        return (a.HumanoidRootPart.Position - HRP.Position).Magnitude < (b.HumanoidRootPart.Position - HRP.Position).Magnitude
    end)
    return enemies
end

local function getNearestMob(maxDistance) return getEnemiesInRange(maxDistance or CONFIG.SKILL_RANGE)[1] end
local function faceTarget(target) if not Character or not HRP or not target then return end local dir = (target.Position - HRP.Position).Unit HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + Vector3.new(dir.X, 0, dir.Z)) end
local function getSkillCooldown(skillName) local skillData = RuntimeState.skillData[skillName] if skillData then return skillData.Cooldown end return CONFIG.FALLBACK_COOLDOWN end
local function useSkill(skillName, target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    local skillData = RuntimeState.skillData[skillName]
    if not skillData then return end
    local enemiesToHit = {}
    local enemies = getEnemiesInRange(CONFIG.SKILL_RANGE)
    for i = 1, math.min(10, #enemies) do table.insert(enemiesToHit, enemies[i]) end
    pcall(function() Skills:FireServer(skillName, 1) end)
    task.wait(0.1)
    local numHits = #skillData.Hits
    if numHits > 1 then
        for hitIndex = 1, numHits do pcall(function() SkillAttack:FireServer(enemiesToHit, skillName, hitIndex) end) task.wait(0.05) end
    else pcall(function() SkillAttack:FireServer(enemiesToHit, skillName, 1) end) end
    task.wait(0.1)
    for _, enemy in pairs(enemiesToHit) do pcall(function() Effects:FireServer("SlashHit", enemy.HumanoidRootPart.Position, {enemy.HumanoidRootPart.CFrame, nil, Color3.new(0.866667, 0.603922, 0.364706), 30, 1.5}) end) task.wait(0.02) end
end

-- Auto Skill loop
task.spawn(function()
    while true do
        if RuntimeState.autoSkillEnabled and Character and HRP then
            for skillName, enabled in pairs(RuntimeState.skillToggles) do
                if enabled then
                    local cooldown = getSkillCooldown(skillName)
                    local last = RuntimeState.lastUsed[skillName] or 0
                    local timeSinceLastUse = tick() - last
                    if timeSinceLastUse >= cooldown then
                        local target = getNearestMob()
                        if target then
                            faceTarget(target.HumanoidRootPart)
                            pcall(function() useSkill(skillName, target) end)
                            RuntimeState.lastUsed[skillName] = tick()
                        end
                    end
                end
            end
        end
        task.wait(CONFIG.SKILL_CHECK_INTERVAL)
    end
end)

-- Auto Farm Loop
local autoFarmHeight = 50
local autoFarmSpeed = 80
local autoFarmCheckInterval = 0.2
local noclipConnection = nil
task.spawn(function()
    local bodyVelocity = nil
    local currentMob = nil
    while true do
        if autoFarmEnabled and Character and HRP then
            local found = false
            for _, mob in ipairs(mobFolder:GetChildren()) do
                if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") then
                    if mob:FindFirstChild("PetHealthbar") or mob:FindFirstChild("PetIItemRef") or mob.Name == "TargetDummy" then continue end
                    local mobHRP = mob.HumanoidRootPart
                    local healthbar = mob:FindFirstChild("Healthbar")
                    if healthbar and mobHRP then currentMob = mob; found = true; break end
                end
            end
            if found and currentMob then
                local mobHRP = currentMob:FindFirstChild("HumanoidRootPart")
                local healthbar = currentMob:FindFirstChild("Healthbar")
                if mobHRP and healthbar then
                    if not bodyVelocity or bodyVelocity.Parent ~= HRP then
                        if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) end
                        bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                        bodyVelocity.P = 1e4
                        bodyVelocity.Parent = HRP
                    end
                    local targetPos = mobHRP.Position + Vector3.new(0, autoFarmHeight, 0)
                    local direction = (targetPos - HRP.Position)
                    local distance = direction.Magnitude
                    if distance > 1 then bodyVelocity.Velocity = direction.Unit * math.min(distance * 4, autoFarmSpeed) else bodyVelocity.Velocity = Vector3.new(0,0,0) end
                else
                    if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) bodyVelocity = nil end
                    currentMob = nil
                end
            else
                if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) bodyVelocity = nil end
                currentMob = nil
            end
        else
            if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) bodyVelocity = nil end
            currentMob = nil
        end
        task.wait(autoFarmCheckInterval)
    end
end)

-- Kill Aura Loop
local attackInterval = 0.35
local attackRange = 100
task.spawn(function()
    while true do
        if _G.killAuraEnabled and Character and HRP then
            local nearestMob = nil
            local nearestDist = math.huge
            for _, mob in ipairs(mobFolder:GetChildren()) do
                if mob:FindFirstChild("HumanoidRootPart") then
                    local mobHRP = mob.HumanoidRootPart
                    local dist = (HRP.Position - mobHRP.Position).Magnitude
                    if dist <= attackRange and dist < nearestDist then nearestDist = dist; nearestMob = mob end
                end
            end
            if nearestMob then
                local mobHRP = nearestMob:FindFirstChild("HumanoidRootPart")
                if mobHRP then
                    Effects:FireServer("SlashHit", mobHRP.Position, { mobHRP.CFrame })
                    Combat:FireServer({ nearestMob })
                end
            end
        end
        task.wait(attackInterval)
    end
end)

-- Auto Start Dungeon Loop
task.spawn(function()
    while true do
        if autoStartDungeon then
            local success, err = pcall(function()
                RS:WaitForChild("Systems", 9e9):WaitForChild("Dungeons", 9e9):WaitForChild("TriggerStartDungeon", 9e9):FireServer()
            end)
            if not success then warn("[Auto Start Dungeon] Error:", err) end
        end
        task.wait(0.5)
    end
end)

-- Auto Reply Dungeon Loop
task.spawn(function()
    while true do
        if autoReplyDungeon then
            pcall(function()
                RS:WaitForChild("Systems", 9e9):WaitForChild("Dungeons", 9e9):WaitForChild("SetExitChoice", 9e9):FireServer("GoAgain")
            end)
        end
        task.wait(1.5)
    end
end)

-- Dungeon Sequence and Mini-Boss / Final Boss Detection
local function getLastRoom()
    local DungeonRooms = workspace:FindFirstChild("DungeonRooms")
    if not DungeonRooms then return nil end
    local lastRoom = nil
    local maxNum = -math.huge
    for _, room in ipairs(DungeonRooms:GetChildren()) do
        local num = tonumber(room.Name)
        if num and num > maxNum then maxNum = num; lastRoom = room end
    end
    return lastRoom
end

local function getMiniBossNameFromRoom(roomNumber)
    local targetRoom = workspace:FindFirstChild("DungeonRooms"):FindFirstChild(tostring(roomNumber))
    if not targetRoom then return nil end
    local mobSpawns = targetRoom:FindFirstChild("MobSpawns")
    if mobSpawns then
        local spawns = mobSpawns:FindFirstChild("Spawns")
        if spawns then
            for _, mob in ipairs(spawns:GetChildren()) do return mob.Name end
        end
    end
    return nil
end

local function getLastRoomBossName()
    local lastRoom = getLastRoom()
    if not lastRoom then return nil end
    local mobSpawns = lastRoom:FindFirstChild("MobSpawns")
    if mobSpawns then
        local spawns = mobSpawns:FindFirstChild("Spawns")
        if spawns then
            for _, boss in ipairs(spawns:GetChildren()) do return boss.Name end
        end
    end
    return nil
end

local function bossInMobs(bossName)
    local Mobs = workspace:FindFirstChild("Mobs")
    if not Mobs then return false end
    return Mobs:FindFirstChild(bossName) ~= nil
end

local completedDungeons = config.completedDungeons or {}

local dungeonSequence = {
    {name = "ForestDungeon", difficulty = 1}, {name = "ForestDungeon", difficulty = 2}, {name = "ForestDungeon", difficulty = 3}, {name = "ForestDungeon", difficulty = 4},
    {name = "MountainDungeon", difficulty = 1}, {name = "MountainDungeon", difficulty = 2}, {name = "MountainDungeon", difficulty = 3}, {name = "MountainDungeon", difficulty = 4},
    {name = "CoveDungeon", difficulty = 1}, {name = "CoveDungeon", difficulty = 2}, {name = "CoveDungeon", difficulty = 3}, {name = "CoveDungeon", difficulty = 4},
    {name = "CastleDungeon", difficulty = 1}, {name = "CastleDungeon", difficulty = 2}, {name = "CastleDungeon", difficulty = 3}, {name = "CastleDungeon", difficulty = 4},
    {name = "JungleDungeon", difficulty = 1}, {name = "JungleDungeon", difficulty = 2}, {name = "JungleDungeon", difficulty = 3}, {name = "JungleDungeon", difficulty = 4},
    {name = "AstralDungeon", difficulty = 1}, {name = "AstralDungeon", difficulty = 2}, {name = "AstralDungeon", difficulty = 3}, {name = "AstralDungeon", difficulty = 4},
    {name = "DesertDungeon", difficulty = 1}, {name = "DesertDungeon", difficulty = 2}, {name = "DesertDungeon", difficulty = 3}, {name = "DesertDungeon", difficulty = 4},
    {name = "CaveDungeon", difficulty = 1}, {name = "CaveDungeon", difficulty = 2}, {name = "CaveDungeon", difficulty = 3}, {name = "CaveDungeon", difficulty = 4},
    {name = "MushroomDungeon", difficulty = 1}, {name = "MushroomDungeon", difficulty = 2}, {name = "MushroomDungeon", difficulty = 3}, {name = "MushroomDungeon", difficulty = 4},
    {name = "GoldDungeon", difficulty = 1}, {name = "GoldDungeon", difficulty = 2}, {name = "GoldDungeon", difficulty = 3}, {name = "GoldDungeon", difficulty = 4},
}

local function getDungeonKey(entry) return tostring(entry.name) .. "_" .. tostring(entry.difficulty) end

task.spawn(function()
    while true do
        if autoNextDungeon then
            local nextIndex = nil
            local nextEntry = nil
            for i = 1, #dungeonSequence do
                local idx = ((dungeonSequenceIndex + i - 2) % #dungeonSequence) + 1
                local entry = dungeonSequence[idx]
                local key = getDungeonKey(entry)
                if not completedDungeons[key] then nextIndex = idx; nextEntry = entry; break end
            end

            if not nextIndex then
                print("[AutoNextDungeon] All dungeons completed. Disabling auto next dungeon.")
                autoNextDungeon = false
                config.autoNextDungeon = false
                saveConfig()
                break
            end

            dungeonSequenceIndex = nextIndex
            local entry = dungeonSequence[dungeonSequenceIndex]
            local key = getDungeonKey(entry)

            local targetMobName = nil
            local targetMobDescription = ""
            if autoResetOnMiniBoss then
                targetMobName = getMiniBossNameFromRoom(miniBossRoomNumber)
                targetMobDescription = "mini-boss in Room " .. miniBossRoomNumber
            else
                targetMobName = getLastRoomBossName()
                targetMobDescription = "final boss in last room"
            end

            if targetMobName then
                print("[AutoNextDungeon] Waiting for " .. targetMobDescription .. ": " .. targetMobName .. " to appear...")
                local appeared = false
                for i = 1, 300 do
                    if bossInMobs(targetMobName) then appeared = true; print("[AutoNextDungeon] " .. targetMobDescription .. " appeared: " .. targetMobName); break end
                    task.wait(1)
                end

                if appeared then
                    print("[AutoNextDungeon] Waiting for " .. targetMobDescription .. " to be defeated...")
                    for i = 1, 60 do
                        if not bossInMobs(targetMobName) then print("[AutoNextDungeon] " .. targetMobDescription .. " defeated: " .. targetMobName); break end
                        task.wait(1)
                    end
                    task.wait(math.random(2,4))
                else
                    print("[AutoNextDungeon] " .. targetMobDescription .. " did not appear in mobs in time or was already defeated.")
                end
            else
                print("[AutoNextDungeon] No target mob (" .. targetMobDescription .. ") found to track. Proceeding without specific mob defeat check.")
            end

            print("[AutoNextDungeon] Starting next dungeon:", entry.name, "Difficulty:", entry.difficulty)
            local args = { [1] = entry.name, [2] = entry.difficulty, [3] = 1, [4] = false, [5] = false }
            pcall(function() RS:WaitForChild("Systems", 9e9):WaitForChild("Parties", 9e9):WaitForChild("SetSettings", 9e9):FireServer(unpack(args)) end)
            task.wait(0.5)
            pcall(function() RS:WaitForChild("Systems", 9e9):WaitForChild("Dungeons", 9e9):WaitForChild("TriggerStartDungeon", 9e9):FireServer() end)

            print("[AutoNextDungeon] Marking dungeon as completed:", key)
            completedDungeons[key] = true
            config.completedDungeons = completedDungeons
            saveConfig()

            dungeonSequenceIndex = dungeonSequenceIndex + 1
            if dungeonSequenceIndex > #dungeonSequence then dungeonSequenceIndex = 1 end
        end
        task.wait(2)
    end
end)

-- Auto Claim Daily Quest
task.spawn(function()
    while true do
        if autoClaimDailyQuest then
            local profile = nil
            pcall(function()
                local profileSystem = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Profile", 9e9))
                profile = profileSystem:GetProfile(LocalPlayer)
            end)
            if profile and profile.DailyQuests and profile.DailyQuests.QuestProgress then
                for _, quest in ipairs(profile.DailyQuests.QuestProgress:GetChildren()) do
                    local questId = tonumber(quest.Name)
                    if questId and not profile.DailyQuests.ClaimedRewards:FindFirstChild(quest.Name) then
                        local goal = quest:GetAttribute("Goal") or 1
                        if quest.Value >= goal then
                            pcall(function()
                                RS:WaitForChild("Systems", 9e9):WaitForChild("Quests", 9e9):WaitForChild("ClaimDailyQuestReward", 9e9):FireServer(questId)
                            end)
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
        task.wait(3)
    end
end)

-- Auto Equip Highest Weapon
task.spawn(function()
    while true do
        if autoEquipHighestWeapon then
            local profile = nil
            pcall(function()
                local profileSystem = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Profile", 9e9))
                profile = profileSystem:GetProfile(LocalPlayer)
            end)
            if profile and profile.Inventory and profile.Equipped then
                local itemsModule = nil
                pcall(function() itemsModule = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Items", 9e9)) end)
                if not itemsModule then continue end

                local function getEquippedItemAndLevel(slot, typeName)
                    local equippedFolder = profile.Equipped:FindFirstChild(slot)
                    if equippedFolder then
                        for _, equippedItem in ipairs(equippedFolder:GetChildren()) do
                            local itemData = itemsModule:GetItemData(equippedItem.Name)
                            if itemData and (not typeName or itemData.Type == typeName) then return equippedItem, itemData.Level or 1 end
                        end
                    end
                    return nil, -math.huge
                end

                local function findBestInInventory(category, typeName, equippedItem)
                    local bestItem = nil; local bestLevel = -math.huge; local bestRarity = -math.huge
                    for _, item in ipairs(profile.Inventory:GetChildren()) do
                        if not equippedItem or item ~= equippedItem then
                            local itemData = itemsModule:GetItemData(item.Name)
                            if itemData and itemData.Category == category and (not typeName or itemData.Type == typeName) then
                                local lvl = itemData.Level or 1
                                local rarity = itemsModule:GetRarity(item)
                                if rarity > bestRarity or (rarity == bestRarity and lvl > bestLevel) then
                                    bestRarity = rarity; bestLevel = lvl; bestItem = item
                                end
                            end
                        end
                    end
                    return bestItem, bestLevel
                end

                local equippedWeapon, equippedWeaponLevel = getEquippedItemAndLevel("Right")
                local bestWeaponItem, bestWeaponLevel = findBestInInventory("Weapon", nil, equippedWeapon)
                if bestWeaponItem and bestWeaponLevel > equippedWeaponLevel then
                    pcall(function() RS:WaitForChild("Systems", 9e9):WaitForChild("Equipment", 9e9):WaitForChild("Equip", 9e9):FireServer("Right", bestWeaponItem) end)
                end
                
                local equippedShirt, equippedShirtLevel = getEquippedItemAndLevel("Shirt", "Shirt")
                local bestShirtItem, bestShirtLevel = findBestInInventory("Armor", "Shirt", equippedShirt)
                if bestShirtItem and bestShirtLevel > equippedShirtLevel then
                    pcall(function() RS:WaitForChild("Systems", 9e9):WaitForChild("Equipment", 9e9):WaitForChild("EquipArmor", 9e9):FireServer(bestShirtItem) end)
                end
                
                local equippedPants, equippedPantsLevel = getEquippedItemAndLevel("Pants", "Pants")
                local bestPantsItem, bestPantsLevel = findBestInInventory("Armor", "Pants", equippedPants)
                if bestPantsItem and bestPantsLevel > equippedPantsLevel then
                    pcall(function() RS:WaitForChild("Systems", 9e9):WaitForChild("Equipment", 9e9):WaitForChild("EquipArmor", 9e9):FireServer(bestPantsItem) end)
                end
            end
        end
        task.wait(1)
    end
end)

-- Auto Sell
local rarityList = {"Common", "Uncommon", "Rare", "Epic", "Legendary"}
local rarityIndexMap = {Common=1, Uncommon=2, Rare=3, Epic=4, Legendary=5}
task.spawn(function()
    while true do
        if autoSellEnabled then
            local profile = nil; local itemsModule = nil
            pcall(function()
                itemsModule = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Items", 9e9))
                local profileSystem = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Profile", 9e9))
                profile = profileSystem:GetProfile(LocalPlayer)
            end)
            if profile and profile.Inventory and itemsModule then
                local toSell = {}; local rarityLimit = rarityIndexMap[selectedRarity]
                for _, item in ipairs(profile.Inventory:GetChildren()) do
                    local itemData = itemsModule:GetItemData(item.Name)
                    local rarity = itemsModule:GetRarity(item)
                    if itemData and (itemData.Category == "Weapon" or itemData.Category == "Armor") and rarity <= rarityLimit then
                        table.insert(toSell, item)
                    end
                end
                if #toSell > 0 then pcall(function() RS:WaitForChild("Systems", 9e9):WaitForChild("ItemSelling", 9e9):WaitForChild("SellItem", 9e9):FireServer(toSell, {}) end) end
            end
        end
        task.wait(1)
    end
end)

-- Dungeon Name Mappings
local normalDungeonNameMap = {
    ["Shattered Forest lvl 1+"] = "ForestDungeon", ["Orion's Peak lvl 15+"] = "MountainDungeon",
    ["Deadman's Cove lvl 30+"] = "CoveDungeon", ["Flaming Depths lvl 45+"] = "CastleDungeon",
    ["Mosscrown Jungle lvl 60+"] = "JungleDungeon", ["Astral Abyss lvl 75+"] = "AstralDungeon",
    ["Shifting Sands lvl 90+"] = "VolcanoDungeon", ["Shimmering Caves lvl 105+"] = "CaveDungeon",
    ["Mushroom Forest lvl 120+"] = "MushroomDungeon", ["Golden ream lvl 135+"] = "GoldDungeon"
}
local raidDungeonNameMap = { ["Abyssal Depths"] = "AbyssDungeon", ["Sky Citadel"] = "SkyDungeon", ["Molten Volcano"] = "VolcanoDungeon" }
local eventDungeonNameMap = { ["The Gauntlet"] = "Gauntlet", ["Halloween Dungeon"] = "HalloweenDungeon", ["Christmas Dungeon"] = "ChristmasDungeon" }

-- FPS Boost Utilities
local maxFpsBoostConn, superMaxFpsBoostConn
local originalFpsCastShadows = {}; local originalFpsTransparency = {}; local originalFpsParticleStates = {}; local originalFpsMaterial = {}

local function enableCustomFpsBoost()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.TextureQuality = Enum.TextureQuality.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Low
        game:GetService("Lighting").GlobalShadows = false
        for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("Texture") or v:IsA("Decal") then v.Transparency = 1 end end
    end)
end
local function disableCustomFpsBoost()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        settings().Rendering.TextureQuality = Enum.TextureQuality.Automatic
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Automatic
        game:GetService("Lighting").GlobalShadows = true
        for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("Texture") or v:IsA("Decal") then v.Transparency = 0 end end
    end)
end

function enableMaxFpsBoost()
    enableCustomFpsBoost()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj and typeof(obj) == "Instance" then
            if obj:IsA("BasePart") and obj.Parent then
                if originalFpsCastShadows[obj] == nil then originalFpsCastShadows[obj] = obj.CastShadow end
                if originalFpsMaterial[obj] == nil then originalFpsMaterial[obj] = obj.Material end
                pcall(function() obj.CastShadow = false; obj.Material = Enum.Material.Slate; obj.Color = Color3.fromRGB(60, 60, 60) end)
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") then
                if originalFpsParticleStates[obj] == nil then originalFpsParticleStates[obj] = obj.Enabled end
                pcall(function() obj.Enabled = false end)
            end
        end
    end
    if maxFpsBoostConn then maxFpsBoostConn:Disconnect() end
    maxFpsBoostConn = workspace.DescendantAdded:Connect(function(obj)
        if obj and typeof(obj) == "Instance" then
            if obj:IsA("BasePart") and obj.Parent then
                if originalFpsCastShadows[obj] == nil then originalFpsCastShadows[obj] = obj.CastShadow end
                if originalFpsMaterial[obj] == nil then originalFpsMaterial[obj] = obj.Material end
                pcall(function() obj.CastShadow = false; obj.Material = Enum.Material.Slate; obj.Color = Color3.fromRGB(60, 60, 60) end)
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") then
                if originalFpsParticleStates[obj] == nil then originalFpsParticleStates[obj] = obj.Enabled end
                pcall(function() obj.Enabled = false end)
            end
        end
    end)
end

function disableMaxFpsBoost()
    disableCustomFpsBoost()
    for obj, val in pairs(originalFpsCastShadows) do if obj and typeof(obj) == "Instance" and obj:IsA("BasePart") and obj.Parent then pcall(function() obj.CastShadow = val end) end end; originalFpsCastShadows = {}
    for obj, val in pairs(originalFpsMaterial) do if obj and typeof(obj) == "Instance" and obj:IsA("BasePart") and obj.Parent then pcall(function() obj.Material = val end) end end; originalFpsMaterial = {}
    for obj, val in pairs(originalFpsParticleStates) do if obj and typeof(obj) == "Instance" and (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke")) then pcall(function() obj.Enabled = val end) end end; originalFpsParticleStates = {}
    if maxFpsBoostConn then maxFpsBoostConn:Disconnect(); maxFpsBoostConn = nil end
end

function enableSuperMaxFpsBoost()
    enableMaxFpsBoost()
    local playerChar = LocalPlayer.Character
    local whitelist = {"Mobs", "QuestNPCs", "Ores", "MobPortals", "FishingSpots", "Dungeon", "Drops", "CraftingStations", "Characters", "BossRoom", "BossArenas"}
    local whitelistFolders = {}
    for _, name in ipairs(whitelist) do local folder = workspace:FindFirstChild(name) if folder then table.insert(whitelistFolders, folder) end end
    local function isWhitelisted(obj) for _, folder in ipairs(whitelistFolders) do if obj:IsDescendantOf(folder) then return true end end return false end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj and typeof(obj) == "Instance" then
            if obj:IsA("BasePart") and obj.Parent and (not playerChar or not obj:IsDescendantOf(playerChar)) then
                if not isWhitelisted(obj) then if originalFpsTransparency[obj] == nil then originalFpsTransparency[obj] = obj.Transparency end pcall(function() obj.Transparency = 1 end) else pcall(function() obj.CanCollide = false end) end
            elseif (obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") or obj:IsA("Adornment")) and not isWhitelisted(obj) then pcall(function() obj.Enabled = false end) end
        end
    end
    if superMaxFpsBoostConn then superMaxFpsBoostConn:Disconnect() end
    superMaxFpsBoostConn = workspace.DescendantAdded:Connect(function(obj)
        if obj and typeof(obj) == "Instance" then
            if obj:IsA("BasePart") and obj.Parent and (not playerChar or not obj:IsDescendantOf(playerChar)) then
                if not isWhitelisted(obj) then if originalFpsTransparency[obj] == nil then originalFpsTransparency[obj] = obj.Transparency end pcall(function() obj.Transparency = 1 end) else pcall(function() obj.CanCollide = false end) end
            elseif (obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") or obj:IsA("Adornment")) and not isWhitelisted(obj) then pcall(function() obj.Enabled = false end) end
        end
    end)
end

function disableSuperMaxFpsBoost()
    disableMaxFpsBoost()
    for obj, val in pairs(originalFpsTransparency) do if obj and typeof(obj) == "Instance" and obj:IsA("BasePart") and obj.Parent then pcall(function() obj.Transparency = val end) end end; originalFpsTransparency = {}
    if superMaxFpsBoostConn then superMaxFpsBoostConn:Disconnect(); superMaxFpsBoostConn = nil end
end

-- Apply FPS boost settings from config on script load
if config.supermaxfpsBoostenabled then enableSuperMaxFpsBoost()
elseif config.maxfpsBoostenabled then enableMaxFpsBoost()
elseif config.fpsBoostEnabled then enableCustomFpsBoost()
else disableSuperMaxFpsBoost(); disableMaxFpsBoost(); disableCustomFpsBoost() end

-- UI Creation
local Window = Library:CreateWindow("Seisen Hub - Dungeon Heroes")

local MainTab = Window:AddTab("Main")
local DungeonTab = Window:AddTab("Dungeon")
local SettingsTab = Window:AddTab("Settings")

local FeaturesBox = MainTab:AddLeftGroupbox("Features")
local AutoSkillBox = MainTab:AddRightGroupbox("Auto Skill")
local NormalDungeonBox = DungeonTab:AddLeftGroupbox("Normal Dungeon")
local RaidDungeonBox = DungeonTab:AddRightGroupbox("Raid Dungeon")
local EventDungeonBox = DungeonTab:AddLeftGroupbox("Event Dungeon")
local ThemeTab = SettingsTab:AddLeftGroupbox("Graphics & UI")

-- Function to set up UI elements and load their states from config
local function setupUI()
    -- Features Tab
    local autoFarmToggleUI = FeaturesBox:AddToggle("AutoFarm", {
        Text = "Auto Farm",
        Default = config.autoFarmEnabled,
        Tooltip = "Automatically moves above mobs and attacks them",
        Callback = function(Value)
            autoFarmEnabled = Value
            config.autoFarmEnabled = Value
            saveConfig()
            if Value then
                if not noclipConnection then
                    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                        if Character then
                            for _, part in ipairs(Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                end
            else
                if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
                if Character then for _, part in ipairs(Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end end
            end
        end
    })
    autoFarmToggleUI:SetValue(config.autoFarmEnabled)

    local autoFarmHeightSliderUI = FeaturesBox:AddSlider("AutoFarmHeight", {
        Text = "Auto Farm Height", Min = 10, Max = 80, Default = config.autoFarmHeight, Suffix = " studs", Rounding = 0,
        Callback = function(Value) autoFarmHeight = Value; config.autoFarmHeight = Value; saveConfig() end
    })
    autoFarmHeightSliderUI:SetValue(config.autoFarmHeight)

    local killAuraToggleUI = FeaturesBox:AddToggle("KillAura", {
        Text = "Kill Aura", Default = config.killAuraEnabled, Tooltip = "Automatically attacks nearby mobs",
        Callback = function(Value) _G.killAuraEnabled = Value; config.killAuraEnabled = Value; saveConfig() end
    })
    killAuraToggleUI:SetValue(config.killAuraEnabled)

    local autoReplyDungeonToggleUI = FeaturesBox:AddToggle("AutoReplyDungeon", {
        Text = "Auto Replay Dungeon", Default = config.autoReplyDungeon, Tooltip = "Automatically replies 'GoAgain' to dungeon exit prompt",
        Callback = function(Value) autoReplyDungeon = Value; config.autoReplyDungeon = Value; saveConfig() end
    })
    autoReplyDungeonToggleUI:SetValue(config.autoReplyDungeon)

    local autoClaimDailyQuestToggleUI = FeaturesBox:AddToggle("AutoClaimDailyQuest", {
        Text = "Auto Claim Daily Quest", Default = config.autoClaimDailyQuest, Tooltip = "Automatically claims all available daily quest rewards",
        Callback = function(Value) autoClaimDailyQuest = Value; config.autoClaimDailyQuest = Value; saveConfig() end
    })
    autoClaimDailyQuestToggleUI:SetValue(config.autoClaimDailyQuest)

    local autoEquipHighestWeaponToggleUI = FeaturesBox:AddToggle("AutoEquipHighestWeapon", {
        Text = "Auto Equip Highest Equipment", Default = config.autoEquipHighestWeapon, Tooltip = "Automatically equips your highest attack weapon",
        Callback = function(Value) autoEquipHighestWeapon = Value; config.autoEquipHighestWeapon = Value; saveConfig() end
    })
    autoEquipHighestWeaponToggleUI:SetValue(config.autoEquipHighestWeapon)
    
    local autoSellToggleUI = FeaturesBox:AddToggle("AutoSell", {
        Text = "Auto Sell", Default = config.autoSellEnabled, Tooltip = "Automatically sells items of selected rarity and below (except skills)",
        Callback = function(Value) autoSellEnabled = Value; config.autoSellEnabled = Value; saveConfig() end
    })
    autoSellToggleUI:SetValue(config.autoSellEnabled)

    local autoSellRarityDropdownUI = FeaturesBox:AddDropdown("AutoSellRarity", {
        Text = "Auto Sell Rarity", Values = rarityList, Default = config.autoSellRarity, Tooltip = "Sell items of this rarity and below",
        Callback = function(Value) selectedRarity = Value; config.autoSellRarity = Value; saveConfig() end
    })
    autoSellRarityDropdownUI:SetValue(config.autoSellRarity)

    -- Auto Skill Box
    local autoSkillToggleUI = AutoSkillBox:AddToggle("AutoSkill", {
        Text = "Enable Auto Skill", Default = config.autoSkillEnabled, Tooltip = "Automatically uses selected skills on nearby mobs",
        Callback = function(Value) RuntimeState.autoSkillEnabled = Value; config.autoSkillEnabled = Value; saveConfig() end
    })
    autoSkillToggleUI:SetValue(config.autoSkillEnabled)

    local skillNames = {}
    for skillName in pairs(RuntimeState.skillData) do table.insert(skillNames, skillName) end
    table.sort(skillNames, function(a, b) return RuntimeState.skillData[a].DisplayName:lower() < RuntimeState.skillData[b].DisplayName:lower() end)

    for _, skillName in ipairs(skillNames) do
        local skillData = RuntimeState.skillData[skillName]
        local skillToggleUI = AutoSkillBox:AddToggle(skillName, {
            Text = skillData.DisplayName, Default = config.skillToggles[skillName] or false,
            Tooltip = "Use " .. skillData.DisplayName .. " (Cooldown: " .. (skillData.Cooldown or "?") .. "s)",
            Callback = function(Value) RuntimeState.skillToggles[skillName] = Value; config.skillToggles[skillName] = Value; saveConfig() end
        })
        skillToggleUI:SetValue(config.skillToggles[skillName] or false)
    end

    -- Normal Dungeon Box
    local autoNextDungeonToggleUI = NormalDungeonBox:AddToggle("AutoNextDungeon", {
        Text = "Auto Next Dungeon Sequence", Default = config.autoNextDungeon, Tooltip = "Automatically cycles through a dungeon/difficulty list",
        Callback = function(Value) autoNextDungeon = Value; config.autoNextDungeon = Value; saveConfig() end
    })
    autoNextDungeonToggleUI:SetValue(config.autoNextDungeon)

    local autoResetOnMiniBossToggleUI = NormalDungeonBox:AddToggle("AutoResetOnMiniBoss", {
        Text = "Auto Reset on Mini-Boss Defeat", Default = config.autoResetOnMiniBoss, Tooltip = "Resets dungeon after the mob in the specified room is defeated instead of the final boss.",
        Callback = function(Value) autoResetOnMiniBoss = Value; config.autoResetOnMiniBoss = Value; saveConfig() end
    })
    autoResetOnMiniBossToggleUI:SetValue(config.autoResetOnMiniBoss)

    local miniBossRoomNumberInputUI = NormalDungeonBox:AddInput("MiniBossRoomNumber", {
        Text = "Mini-Boss Room Number", Default = tostring(config.miniBossRoomNumber), Placeholder = "e.g., 6", Tooltip = "The room number where the mini-boss is located.",
        Callback = function(Value)
            local num = tonumber(Value)
            if num and num > 0 then miniBossRoomNumber = num; config.miniBossRoomNumber = num; saveConfig()
            else print("Invalid input for Mini-Boss Room Number. Please enter a valid number.") end
        end
    })
    miniBossRoomNumberInputUI:SetValue(tostring(config.miniBossRoomNumber))

    local normalDungeonNameDropdownUI = NormalDungeonBox:AddDropdown("NormalDungeonName", {
        Text = "Dungeon Name", Values = {"Shattered Forest lvl 1+", "Orion's Peak lvl 15+", "Deadman's Cove lvl 30+", "Flaming Depths lvl 45+", "Mosscrown Jungle lvl 60+", "Astral Abyss lvl 75+", "Shifting Sands lvl 90+", "Shimmering Caves lvl 105+", "Mushroom Forest lvl 120+", "Golden ream lvl 135+"},
        Default = config.normalDungeonName,
        Callback = function(Value) normalDungeonName = Value; config.normalDungeonName = Value; saveConfig() end
    })
    normalDungeonNameDropdownUI:SetValue(config.normalDungeonName)

    local normalDungeonDifficultyDropdownUI = NormalDungeonBox:AddDropdown("NormalDungeonDifficulty", {
        Text = "Difficulty", Values = {"Normal", "Medium", "Hard", "Insane", "Extreme"}, Default = config.normalDungeonDifficulty,
        Callback = function(Value) normalDungeonDifficulty = Value; config.normalDungeonDifficulty = Value; saveConfig() end
    })
    normalDungeonDifficultyDropdownUI:SetValue(config.normalDungeonDifficulty)

    local normalDungeonPlayerLimitDropdownUI = NormalDungeonBox:AddDropdown("NormalDungeonPlayerLimit", {
        Text = "Player Limit", Values = {"1","2","3","4","5","6","7"}, Default = tostring(config.normalDungeonPlayerLimit),
        Callback = function(Value) normalDungeonPlayerLimit = tonumber(Value); config.normalDungeonPlayerLimit = normalDungeonPlayerLimit; saveConfig() end
    })
    normalDungeonPlayerLimitDropdownUI:SetValue(tostring(config.normalDungeonPlayerLimit))

    NormalDungeonBox:AddButton("StartNormalDungeon", {
        Text = "Start Dungeon",
        Func = function()
            local difficultyIndexMap = {Normal=1, Medium=2, Hard=3, Insane=4, Extreme=5}
            local args = {
                [1] = normalDungeonNameMap[normalDungeonName] or "ForestDungeon",
                [2] = difficultyIndexMap[normalDungeonDifficulty] or 1,
                [3] = normalDungeonPlayerLimit,
                [4] = false,
                [5] = false
            }
            local success, err = pcall(function()
                RS:WaitForChild("Systems", 9e9):WaitForChild("Parties", 9e9):WaitForChild("SetSettings", 9e9):FireServer(unpack(args))
            end)
            if not success then warn("[Start Normal Dungeon] Error:", err) end
        end
    })

    -- Raid Dungeon Box
    local raidDungeonNameDropdownUI = RaidDungeonBox:AddDropdown("RaidDungeonName", {
        Text = "Dungeon Name", Values = {"Abyssal Depths", "Sky Citadel", "Molten Volcano"}, Default = config.raidDungeonName,
        Callback = function(Value) raidDungeonName = Value; config.raidDungeonName = Value; saveConfig() end
    })
    raidDungeonNameDropdownUI:SetValue(config.raidDungeonName)

    local raidDungeonDifficultyDropdownUI = RaidDungeonBox:AddDropdown("RaidDungeonDifficulty", {
        Text = "Difficulty", Values = {"RAID"}, Default = config.raidDungeonDifficulty,
        Callback = function(Value) raidDungeonDifficulty = Value; config.raidDungeonDifficulty = Value; saveConfig() end
    })
    raidDungeonDifficultyDropdownUI:SetValue(config.raidDungeonDifficulty)

    local raidDungeonPlayerLimitDropdownUI = RaidDungeonBox:AddDropdown("RaidDungeonPlayerLimit", {
        Text = "Player Limit", Values = {"5","6","7"}, Default = tostring(config.raidDungeonPlayerLimit),
        Callback = function(Value) raidDungeonPlayerLimit = tonumber(Value); config.raidDungeonPlayerLimit = raidDungeonPlayerLimit; saveConfig() end
    })
    raidDungeonPlayerLimitDropdownUI:SetValue(tostring(config.raidDungeonPlayerLimit))

    RaidDungeonBox:AddButton("StartRaidDungeon", {
        Text = "Start Raid Dungeon",
        Func = function()
            local difficultyIndex = {RAID=7}
            local args = {
                [1] = raidDungeonNameMap[raidDungeonName] or "AbyssDungeon",
                [2] = raidDungeonPlayerLimit,
                [3] = difficultyIndex[raidDungeonDifficulty] or 7,
                [4] = false,
                [5] = false
            }
            local success, err = pcall(function()
                RS:WaitForChild("Systems", 9e9):WaitForChild("Parties", 9e9):WaitForChild("SetSettings", 9e9):FireServer(unpack(args))
            end)
            if not success then warn("[Start Raid Dungeon] Error:", err) end
        end
    })

    -- Event Dungeon Box
    local eventDungeonNameDropdownUI = EventDungeonBox:AddDropdown("EventDungeonName", {
        Text = "Dungeon Name", Values = {"Gauntlet", "Halloween Dungeon", "Christmas Dungeon"}, Default = config.eventDungeonName,
        Callback = function(Value) eventDungeonName = Value; config.eventDungeonName = Value; saveConfig() end
    })
    eventDungeonNameDropdownUI:SetValue(config.eventDungeonName)

    local eventDungeonDifficultyDropdownUI = EventDungeonBox:AddDropdown("EventDungeonDifficulty", {
        Text = "Difficulty", Values = {"Normal", "Hard", "Insane"}, Default = config.eventDungeonDifficulty,
        Callback = function(Value) eventDungeonDifficulty = Value; config.eventDungeonDifficulty = Value; saveConfig() end
    })
    eventDungeonDifficultyDropdownUI:SetValue(config.eventDungeonDifficulty)

    local eventDungeonPlayerLimitDropdownUI = EventDungeonBox:AddDropdown("EventDungeonPlayerLimit", {
        Text = "Player Limit", Values = {"1","2","3","4","5"}, Default = tostring(config.eventDungeonPlayerLimit),
        Callback = function(Value) eventDungeonPlayerLimit = tonumber(Value); config.eventDungeonPlayerLimit = eventDungeonPlayerLimit; saveConfig() end
    })
    eventDungeonPlayerLimitDropdownUI:SetValue(tostring(config.eventDungeonPlayerLimit))

    EventDungeonBox:AddButton("StartEventDungeon", {
        Text = "Start Event Dungeon",
        Func = function()
            local difficultyIndexMap = {Normal=1, Hard=3, Insane=4}
            local args = {
                [1] = eventDungeonNameMap[eventDungeonName] or "Gauntlet",
                [2] = eventDungeonPlayerLimit,
                [3] = difficultyIndexMap[eventDungeonDifficulty] or 1,
                [4] = false
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Systems", 9e9):WaitForChild("Parties", 9e9):WaitForChild("SetSettings", 9e9):FireServer(unpack(args))
        end
    })

    -- Settings Tab (Graphics & UI)
    local fpsBoostToggleUI = ThemeTab:AddToggle("FpsBoost", {
        Text = "FPS Boost", Default = config.fpsBoostEnabled, Tooltip = "Reduces graphics for better performance",
        Callback = function(Value)
            fpsBoostEnabled = Value; config.fpsBoostEnabled = Value; saveConfig()
            if Value then enableCustomFpsBoost() else disableCustomFpsBoost() end
        end
    })
    fpsBoostToggleUI:SetValue(config.fpsBoostEnabled)

    local maxFpsBoostToggleUI = ThemeTab:AddToggle("MaxFpsBoost", {
        Text = "Max FPS Boost", Default = config.maxfpsBoostenabled, Tooltip = "Disables most effects for maximum FPS (also sets all parts to SmoothPlastic)",
        Callback = function(Value)
            maxfpsBoostenabled = Value; config.maxfpsBoostenabled = Value; saveConfig()
            if Value then enableMaxFpsBoost() else disableMaxFpsBoost() end
        end
    })
    maxFpsBoostToggleUI:SetValue(config.maxfpsBoostenabled)

    local superMaxFpsBoostToggleUI = ThemeTab:AddToggle("SuperMaxFpsBoost", {
        Text = "Super Max FPS Boost", Default = config.supermaxfpsBoostenabled, Tooltip = "Hides almost everything except mobs and some objects for ultimate FPS",
        Callback = function(Value)
            supermaxfpsBoostenabled = Value; config.supermaxfpsBoostenabled = Value; saveConfig()
            if Value then enableSuperMaxFpsBoost() else disableSuperMaxFpsBoost() end
        end
    })
    superMaxFpsBoostToggleUI:SetValue(config.supermaxfpsBoostenabled)

    ThemeTab:AddButton("UnloadUI", {
        Text = "Unload UI",
        Func = function()
            -- Destroy UI created by this script
            pcall(function() ScreenGui:Destroy() end)

            -- Disconnect all running connections and tasks (clean up anti-afk, noclip, etc.)
            if noclipConnection then pcall(function() noclipConnection:Disconnect() end) noclipConnection = nil end
            AntiAfkSystem.cleanup()

            -- Stop all task.spawn loops by setting flags to false
            _G.killAuraEnabled = false
            if RuntimeState then
                RuntimeState.autoSkillEnabled = false
                RuntimeState.skillToggles = {}
            end
            autoFarmEnabled = false
            autoStartDungeon = false
            autoReplyDungeon = false
            autoNextDungeon = false
            autoClaimDailyQuest = false
            autoEquipHighestWeapon = false
            autoResetOnMiniBoss = false
            autoSellEnabled = false

            -- Attempt to destroy any leftover BodyVelocity
            pcall(function()
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    for _, obj in ipairs(Character.HumanoidRootPart:GetChildren()) do
                        if obj:IsA("BodyVelocity") then
                            obj:Destroy()
                        end
                    end
                end
            end)

            -- Disconnect FPS boost connections and restore settings
            if maxFpsBoostConn then pcall(function() maxFpsBoostConn:Disconnect() end) maxFpsBoostConn = nil end
            if superMaxFpsBoostConn then pcall(function() superMaxFpsConn:Disconnect() end) superMaxFpsConn = nil end
            disableCustomFpsBoost()
            disableMaxFpsBoost()
            disableSuperMaxFpsBoost()
            
            -- Re-enable MouseIcon (if your executor supports it)
            game:GetService("UserInputService").MouseIconEnabled = true
        end
    })

    -- Add UI toggle keybind
    local uiToggleKeybind = config.uiToggleKey -- Load from config
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent and input.KeyCode == Enum.KeyCode[uiToggleKeybind] then
            Library:Toggle()
        end
    end)
end

-- Initialize UI
setupUI()

print("Dungeon Heroes Script Loaded Successfully!")