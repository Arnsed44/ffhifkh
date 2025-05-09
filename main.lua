-- Enhanced Ghost Hunting Game Script
-- Credits to original author - Enhanced by Claude

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Constants & Data
local RAINBOW_SPEED = 0.03

-- Ghost Evidence Types
local EVIDENCE_TYPES = {
    "EMF Level 5",
    "Spirit Box",
    "Ghost Writing",
    "Handprints",
    "Freezing Temps",
    "Ghost Orb",
    "Laser Projector",
    "Wither"
}

-- Ghost Types, Evidence and Behaviors
local GHOST_DATA = {
    ["Aswang"] = {
        evidence = {"Wither", "EMF Level 5", "Ghost Writing"},
        behaviors = {
            "Speed increases every time they kill",
            "Salt slows them"
        }
    },
    ["Banshee"] = {
        evidence = {"Ghost Orb", "Handprints", "Freezing Temps"},
        behaviors = {
            "More likely to break glass",
            "Can sometimes let out a unique wail at the start of its hunt"
        }
    },
    ["Demon"] = {
        evidence = {"EMF Level 5", "Handprints", "Freezing Temps"},
        behaviors = {
            "Hunts frequently",
            "Crosses have a larger range with more effectiveness"
        }
    },
    ["Dullahan"] = {
        evidence = {"Wither", "Laser Projector", "Freezing Temps"},
        behaviors = {
            "Appear headless in photos, the Photo Camera will be useful",
            "Increases in speed the longer someone is within line-of-sight"
        }
    },
    ["Dybbuk"] = {
        evidence = {"Wither", "Handprints", "Freezing Temps"},
        behaviors = {
            "Stunned after music box first played",
            "Can throw corpses"
        }
    },
    ["Entity"] = {
        evidence = {"Spirit Box", "Handprints", "Laser Projector"},
        behaviors = {
            "Able to teleport between rooms",
            "Less likely to throw items compared to other ghosts"
        }
    },
    ["Ghoul"] = {
        evidence = {"Spirit Box", "Freezing Temps", "Ghost Orb"},
        behaviors = {
            "Using the Spirit Box could start a hunt",
            "Can't disable electronics"
        }
    },
    ["Leviathan"] = {
        evidence = {"Ghost Orb", "Ghost Writing", "Handprints"},
        behaviors = {
            "Turn off lights passively",
            "Throw multiple objects"
        }
    },
    ["Nightmare"] = {
        evidence = {"EMF Level 5", "Spirit Box", "Ghost Orb"},
        behaviors = {
            "Can cause hallucinations",
            "Afraid of lit rooms"
        }
    },
    ["Oni"] = {
        evidence = {"Spirit Box", "Freezing Temps", "Laser Projector"},
        behaviors = {
            "Extremely fast during hunts",
            "More likely to start ghost events and show its appearance"
        }
    },
    ["Phantom"] = {
        evidence = {"EMF Level 5", "Handprints", "Ghost Orb"},
        behaviors = {
            "Blinks in-and-out slower",
            "Lower chance of hunting when there is a group of 2 or above"
        }
    },
    ["Revenant"] = {
        evidence = {"Ghost Writing", "EMF Level 5", "Freezing Temps"},
        behaviors = {
            "Low hunting cooldown",
            "Stops hunting once a player is killed"
        }
    },
    ["Shadow"] = {
        evidence = {"EMF Level 5", "Ghost Writing", "Laser Projector"},
        behaviors = {
            "Lower temperature changes",
            "Walks slower in illuminated rooms"
        }
    },
    ["Siren"] = {
        evidence = {"Wither", "Spirit Box", "EMF Level 5"},
        behaviors = {
            "Respond with a female voice (Spirit Box responses, Music Box singing)",
            "Anyone within line-of-sight will be slowed down",
            "Can sing in a Spirit box instead of answering a question"
        }
    },
    ["Skinwalker"] = {
        evidence = {"Freezing Temps", "Ghost Writing", "Spirit Box"},
        behaviors = {
            "Fakes the Ghost Orb evidence",
            "Mimic other ghosts' abilities"
        }
    },
    ["Specter"] = {
        evidence = {"EMF Level 5", "Freezing Temps", "Laser Projector"},
        behaviors = {
            "Throw items frequently",
            "Do not roam and will only stick to their ghost room except while hunting"
        }
    },
    ["Spirit"] = {
        evidence = {"Handprints", "Ghost Writing", "Spirit Box"},
        behaviors = {
            "Can alter lit up candles"
        }
    },
    ["The Wisp"] = {
        evidence = {"Wither", "Laser Projector", "Ghost Orb"},
        behaviors = {
            "Can light candles",
            "Can only start a hunt when player is in the ghost's favorite room"
        }
    },
    ["Umbra"] = {
        evidence = {"Ghost Orb", "Laser Projector", "Handprints"},
        behaviors = {
            "Do not make footstep sounds",
            "Move slower in lit rooms"
        }
    },
    ["Wendigo"] = {
        evidence = {"Ghost Orb", "Ghost Writing", "Laser Projector"},
        behaviors = {
            "Less likely to start hunts near lit flames (Candles or Lantern)",
            "Increases in speed as average energy decreases"
        }
    },
    ["Wraith"] = {
        evidence = {"EMF Level 5", "Spirit Box", "Laser Projector"},
        behaviors = {
            "Depletes player's energy rapidly, roughly 0.2-0.4% per second",
            "Do not disturb salt"
        }
    }
}

-- Equipment
local EQUIPMENT = {
    "EMF Reader",
    "Spirit Box",
    "Spirit Book",
    "UV Flashlight",
    "Thermometer",
    "Photo Camera",
    "Candle",
    "Lantern",
    "Salt",
    "Music Box",
    "Cross"
}

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Utility Functions
local function createRainbowEffect(obj, property, speed)
    speed = speed or RAINBOW_SPEED
    task.spawn(function()
        local hue = 0
        while true do
            if not obj or not obj.Parent then return end
            obj[property] = Color3.fromHSV(hue, 1, 1)
            hue = (hue + speed) % 1
            task.wait(0.03)
        end
    end)
end

local function createStrokeWithRainbow(parent)
    local stroke = Instance.new("UIStroke", parent)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 0, 0)
    createRainbowEffect(stroke, "Color")
    return stroke
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner", parent)
    corner.CornerRadius = UDim.new(0, radius or 12)
    return corner
end

-- Create GUI Framework
local function createGUI(name, size, position)
    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = name
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = size
    mainFrame.Position = position
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    createCorner(mainFrame)
    local stroke = createStrokeWithRainbow(mainFrame)
    
    return {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        Stroke = stroke
    }
end

local function createTitle(parent, text, size)
    local title = Instance.new("TextLabel", parent)
    title.Size = UDim2.new(1, -30, 0, size or 40)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Center
    createRainbowEffect(title, "TextColor3")
    return title
end

local function createMinimizeButton(parent)
    local button = Instance.new("TextButton", parent)
    button.Size = UDim2.new(0, 30, 0, 30)
    button.Position = UDim2.new(1, -35, 0, 5)
    button.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    button.Text = "-"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 24
    createCorner(button, 15)
    createRainbowEffect(button, "TextColor3")
    return button
end

local function createToggleButton(parent, text, position)
    local button = Instance.new("TextButton", parent)
    button.Size = UDim2.new(0, 200, 0, 30)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 18
    button.AutoButtonColor = true
    createCorner(button, 8)
    createRainbowEffect(button, "TextColor3")
    return button
end

local function createLabelWithValue(parent, text, value, position)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -30, 0, 25)
    label.Position = position
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(170, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.Text = text .. ": " .. value
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

local function createDropdownButton(parent, text, yPos)
    local button = Instance.new("TextButton", parent)
    button.Size = UDim2.new(0, 200, 0, 30)
    button.Position = UDim2.new(0.5, -100, 0, yPos)
    button.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 18
    createCorner(button, 8)
    createRainbowEffect(button, "TextColor3")
    
    local arrow = Instance.new("TextLabel", button)
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(1, -25, 0.5, -10)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    
    return button, arrow
end

-- Create Dropdown Menu
local function createDropdown(parent, options, position, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(0, 200, 0, 30)
    container.Position = position
    container.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    container.ClipsDescendants = true
    container.ZIndex = 10
    createCorner(container, 8)
    
    local selectedLabel = Instance.new("TextLabel", container)
    selectedLabel.Size = UDim2.new(1, -30, 1, 0)
    selectedLabel.Position = UDim2.new(0, 10, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = options[1] or "Select..."
    selectedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectedLabel.Font = Enum.Font.GothamSemibold
    selectedLabel.TextSize = 16
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.ZIndex = 11
    
    local arrow = Instance.new("TextButton", container)
    arrow.Size = UDim2.new(0, 30, 0, 30)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 16
    arrow.ZIndex = 11
    
    local optionsList = Instance.new("ScrollingFrame", container)
    optionsList.Size = UDim2.new(1, 0, 0, 0)
    optionsList.Position = UDim2.new(0, 0, 1, 0)
    optionsList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    optionsList.BorderSizePixel = 0
    optionsList.ScrollBarThickness = 4
    optionsList.Visible = false
    optionsList.ZIndex = 12
    optionsList.ScrollingDirection = Enum.ScrollingDirection.Y
    optionsList.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
    createCorner(optionsList, 8)
    
    local listLayout = Instance.new("UIListLayout", optionsList)
    listLayout.Padding = UDim.new(0, 2)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local isOpen = false
    
    local function toggleDropdown()
        isOpen = not isOpen
        arrow.Text = isOpen and "▲" or "▼"
        
        if isOpen then
            optionsList.Visible = true
            TweenService:Create(optionsList, TweenInfo.new(0.3), {
                Size = UDim2.new(1, 0, 0, math.min(#options * 30, 150))
            }):Play()
        else
            TweenService:Create(optionsList, TweenInfo.new(0.3), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            task.wait(0.3)
            optionsList.Visible = false
        end
    end
    
    arrow.MouseButton1Click:Connect(toggleDropdown)
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton", optionsList)
        optionButton.Size = UDim2.new(0.95, 0, 0, 28)
        optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionButton.Font = Enum.Font.GothamSemibold
        optionButton.TextSize = 14
        optionButton.ZIndex = 13
        createCorner(optionButton, 6)
        
        optionButton.MouseButton1Click:Connect(function()
            selectedLabel.Text = option
            toggleDropdown()
            if callback then callback(option) end
        end)
    end
    
    return container, selectedLabel
end

local function findGhostType(evidenceFound)
    local possibleGhosts = {}
    
    for ghostName, ghostInfo in pairs(GHOST_DATA) do
        local matches = true
        for _, evidence in ipairs(evidenceFound) do
            if not table.find(ghostInfo.evidence, evidence) then
                matches = false
                break
            end
        end
        
        if matches then
            table.insert(possibleGhosts, ghostName)
        end
    end
    
    return possibleGhosts
end

-- Ghost Stats GUI
local ghostStats = createGUI(
    "GhostStatsGUI", 
    UDim2.new(0, 320, 0, 40), 
    UDim2.new(0.5, -160, 0.15, 0)
)

local statsTitle = createTitle(ghostStats.MainFrame, "Ghost Stats")
local statsMinimize = createMinimizeButton(ghostStats.MainFrame)

-- Stats Labels
local stats = {
    ["Gender"] = "...",
    ["Ghost Orbs"] = "Checking...",
    ["Handprints"] = "Checking...",
    ["Freezing Temps"] = "Checking...",
    ["EMF Level"] = "Checking...",
    ["Spirit Box"] = "Checking...",
    ["Ghost Writing"] = "Checking...",
    ["Laser Projector"] = "Checking...",
    ["Wither"] = "Checking...",
    ["Favorite Room"] = "...",
    ["Current Room"] = "...",
    ["Current Temp"] = "...",
    ["Favorite Temp"] = "...",
    ["Possible Ghost Types"] = "..."
}

local labels, yOffset = {}, 50
local foundEvidence = {}

for statName, statValue in pairs(stats) do
    labels[statName] = createLabelWithValue(
        ghostStats.MainFrame, 
        statName, 
        statValue, 
        UDim2.new(0, 15, 0, yOffset)
    )
    labels[statName].Visible = false
    yOffset += 30
end

-- Button Toggles GUI
local buttonToggles = createGUI(
    "ButtonTogglesGUI", 
    UDim2.new(0, 240, 0, 190), 
    UDim2.new(0.5, -120, 0.4, 0)
)

local buttonsTitle = createTitle(buttonToggles.MainFrame, "Ghost Hunter")
local buttonsMinimize = createMinimizeButton(buttonToggles.MainFrame)

-- Buttons
local buttons = {}
local buttonYPos = 45
local buttonStep = 35

local function createToggleButtonWithState(text, yPos)
    local btn = createToggleButton(buttonToggles.MainFrame, text .. ": OFF", UDim2.new(0.5, -100, 0, yPos))
    local state = false
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        return state
    end)
    
    table.insert(buttons, btn)
    return btn, function() return state end
end

-- ESP Button
local espBtn, getEspState = createToggleButtonWithState("ESP", buttonYPos)
buttonYPos += buttonStep
local ghostESP

-- Fullbright Button
local fullbrightBtn, getFullbrightState = createToggleButtonWithState("Fullbright", buttonYPos)
buttonYPos += buttonStep
local oldLightingProps = {}

-- Hunt TP Button
local huntTpBtn, getHuntTpState = createToggleButtonWithState("Hunt TP", buttonYPos)
buttonYPos += buttonStep

-- Auto Equipment Button
local autoEquipBtn = createToggleButton(
    buttonToggles.MainFrame, 
    "Pickup & Drop Items", 
    UDim2.new(0.5, -100, 0, buttonYPos)
)
table.insert(buttons, autoEquipBtn)
buttonYPos += buttonStep

-- Ghost Detector Button
local ghostDetectorBtn = createToggleButton(
    buttonToggles.MainFrame, 
    "Ghost Detector", 
    UDim2.new(0.5, -100, 0, buttonYPos)
)
table.insert(buttons, ghostDetectorBtn)
buttonYPos += buttonStep

-- Show Equipment Button
local showEquipmentBtn = createToggleButton(
    buttonToggles.MainFrame, 
    "Show Equipment GUI", 
    UDim2.new(0.5, -100, 0, buttonYPos)
)
table.insert(buttons, showEquipmentBtn)
buttonYPos += buttonStep

-- Evil Tags Button (highlights ghost)
local evilTagsBtn, getEvilTagsState = createToggleButtonWithState("Evil Tags", buttonYPos)
buttonYPos += buttonStep

-- Equipment GUI
local equipmentGUI = createGUI(
    "EquipmentGUI", 
    UDim2.new(0, 220, 0, 40), 
    UDim2.new(0.05, 0, 0.2, 0)
)
equipmentGUI.ScreenGui.Enabled = false

local equipTitle = createTitle(equipmentGUI.MainFrame, "Equipment")
local equipMinimize = createMinimizeButton(equipmentGUI.MainFrame)

-- Equipment Checklist
local equipLabels = {}
local equipYOffset = 50

for _, equipment in ipairs(EQUIPMENT) do
    local checkBox = Instance.new("Frame", equipmentGUI.MainFrame)
    checkBox.Size = UDim2.new(0, 20, 0, 20)
    checkBox.Position = UDim2.new(0, 15, 0, equipYOffset)
    checkBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    createCorner(checkBox, 4)
    
    local check = Instance.new("TextLabel", checkBox)
    check.Size = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Text = "✓"
    check.TextColor3 = Color3.fromRGB(0, 255, 0)
    check.Font = Enum.Font.GothamBold
    check.TextSize = 16
    check.Visible = false
    
    local label = Instance.new("TextLabel", equipmentGUI.MainFrame)
    label.Size = UDim2.new(1, -50, 0, 20)
    label.Position = UDim2.new(0, 45, 0, equipYOffset)
    label.BackgroundTransparency = 1
    label.Text = equipment
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    label.MouseEnter:Connect(function()
        label.TextColor3 = Color3.fromRGB(255, 255, 0)
    end)
    
    label.MouseLeave:Connect(function()
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    checkBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            check.Visible = not check.Visible
        end
    end)
    
    label.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            check.Visible = not check.Visible
        end
    end)
    
    table.insert(equipLabels, {box = checkBox, check = check, label = label})
    checkBox.Visible = false
    label.Visible = false
    equipYOffset += 30
end

-- Evidence Tracker GUI
local evidenceGUI = createGUI(
    "EvidenceGUI", 
    UDim2.new(0, 240, 0, 40), 
    UDim2.new(0.8, -120, 0.2, 0)
)
evidenceGUI.ScreenGui.Enabled = true

local evidenceTitle = createTitle(evidenceGUI.MainFrame, "Evidence Tracker")
local evidenceMinimize = createMinimizeButton(evidenceGUI.MainFrame)

-- Evidence Checklist
local evidenceChecks = {}
local evidenceYOffset = 50

for _, evidence in ipairs(EVIDENCE_TYPES) do
    local checkBox = Instance.new("Frame", evidenceGUI.MainFrame)
    checkBox.Size = UDim2.new(0, 20, 0, 20)
    checkBox.Position = UDim2.new(0, 15, 0, evidenceYOffset)
    checkBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    createCorner(checkBox, 4)
    
    local check = Instance.new("TextLabel", checkBox)
    check.Size = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Text = "✓"
    check.TextColor3 = Color3.fromRGB(0, 255, 0)
    check.Font = Enum.Font.GothamBold
    check.TextSize = 16
    check.Visible = false
    
    local label = Instance.new("TextLabel", evidenceGUI.MainFrame)
    label.Size = UDim2.new(1, -50, 0, 20)
    label.Position = UDim2.new(0, 45, 0, evidenceYOffset)
    label.BackgroundTransparency = 1
    label.Text = evidence
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local function updateEvidence()
        local isChecked = check.Visible
        if isChecked then
            if not table.find(foundEvidence, evidence) then
                table.insert(foundEvidence, evidence)
            end
        else
            local index = table.find(foundEvidence, evidence)
            if index then
                table.remove(foundEvidence, index)
            end
        end
        
        local possibleGhosts = findGhostType(foundEvidence)
        if #possibleGhosts > 0 then
            labels["Possible Ghost Types"].Text = "Possible Ghost Types: " .. table.concat(possibleGhosts, ", ")
        else
            labels["Possible Ghost Types"].Text = "Possible Ghost Types: Unknown"
        end
    end
    
    checkBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            check.Visible = not check.Visible
            updateEvidence()
        end
    end)
    
    label.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            check.Visible = not check.Visible
            updateEvidence()
        end
    end)
    
    table.insert(evidenceChecks, {box = checkBox, check = check, label = label})
    checkBox.Visible = false
    label.Visible = false
    evidenceYOffset += 30
end

-- Ghost Info GUI
local ghostInfoGUI = createGUI(
    "GhostInfoGUI", 
    UDim2.new(0, 300, 0, 40), 
    UDim2.new(0.2, 0, 0.6, 0)
)
ghostInfoGUI.ScreenGui.Enabled = false

local ghostInfoTitle = createTitle(ghostInfoGUI.MainFrame, "Ghost Info")
local ghostInfoMinimize = createMinimizeButton(ghostInfoGUI.MainFrame)

-- Ghost Dropdown
local ghostTypes = {}
for ghostName, _ in pairs(GHOST_DATA) do
    table.insert(ghostTypes, ghostName)
end
table.sort(ghostTypes)

-- Ghost selection dropdown
local ghostDropdown, ghostSelected = createDropdown(
    ghostInfoGUI.MainFrame,
    ghostTypes,
    UDim2.new(0.5, -100, 0, 50),
    function(selected)
        -- Update ghost info display when selected
        if GHOST_DATA[selected] then
            -- Clear previous info
            for i, child in ipairs(ghostInfoGUI.MainFrame:GetChildren()) do
                if child:IsA("TextLabel") and child.Name == "GhostInfo" then
                    child:Destroy()
                end
            end
            
            -- Create evidence list
            local infoYPos = 90
            
            -- Evidence header
            local evidenceHeader = Instance.new("TextLabel", ghostInfoGUI.MainFrame)
            evidenceHeader.Size = UDim2.new(1, -30, 0, 20)
            evidenceHeader.Position = UDim2.new(0, 15, 0, infoYPos)
            evidenceHeader.BackgroundTransparency = 1
            evidenceHeader.TextColor3 = Color3.fromRGB(255, 200, 0)
            evidenceHeader.Font = Enum.Font.GothamBold
            evidenceHeader.TextSize = 16
            evidenceHeader.Text = "Evidence:"
            evidenceHeader.TextXAlignment = Enum.TextXAlignment.Left
            evidenceHeader.Name = "GhostInfo"
            infoYPos += 25
            
            -- Evidence items
            for _, evidence in ipairs(GHOST_DATA[selected].evidence) do
                local evidenceItem = Instance.new("TextLabel", ghostInfoGUI.MainFrame)
                evidenceItem.Size = UDim2.new(1, -40, 0, 20)
                evidenceItem.Position = UDim2.new(0, 25, 0, infoYPos)
                evidenceItem.BackgroundTransparency = 1
                evidenceItem.TextColor3 = Color3.fromRGB(255, 255, 255)
                evidenceItem.Font = Enum.Font.Gotham
                evidenceItem.TextSize = 14
                evidenceItem.Text = "â€¢ " .. evidence
                evidenceItem.TextXAlignment = Enum.TextXAlignment.Left
                evidenceItem.Name = "GhostInfo"
                infoYPos += 20
            end
            
            infoYPos += 15
            
            -- Behaviors header
            local behaviorHeader = Instance.new("TextLabel", ghostInfoGUI.MainFrame)
            behaviorHeader.Size = UDim2.new(1, -30, 0, 20)
            behaviorHeader.Position = UDim2.new(0, 15, 0, infoYPos)
            behaviorHeader.BackgroundTransparency = 1
            behaviorHeader.TextColor3 = Color3.fromRGB(255, 200, 0)
            behaviorHeader.Font = Enum.Font.GothamBold
            behaviorHeader.TextSize = 16
            behaviorHeader.Text = "Behaviors:"
            behaviorHeader.TextXAlignment = Enum.TextXAlignment.Left
            behaviorHeader.Name = "GhostInfo"
            infoYPos += 25
            
            -- Behavior items
            for _, behavior in ipairs(GHOST_DATA[selected].behaviors) do
                local behaviorItem = Instance.new("TextLabel", ghostInfoGUI.MainFrame)
                behaviorItem.Size = UDim2.new(1, -40, 0, 40)
                behaviorItem.Position = UDim2.new(0, 25, 0, infoYPos)
                behaviorItem.BackgroundTransparency = 1
                behaviorItem.TextColor3 = Color3.fromRGB(255, 255, 255)
                behaviorItem.Font = Enum.Font.Gotham
                behaviorItem.TextSize = 14
                behaviorItem.Text = "â€¢ " .. behavior
                behaviorItem.TextXAlignment = Enum.TextXAlignment.Left
                behaviorItem.TextWrapped = true
                behaviorItem.Name = "GhostInfo"
                infoYPos += 45
            end
            
            -- Resize the frame to fit all content
            ghostInfoGUI.MainFrame.Size = UDim2.new(0, 300, 0, infoYPos + 10)
        end
    end
)

-- Minimize Button Functions
local function setupMinimizeFunction(gui, title, minimizeBtn)
    local minimized = false
    local originalSize = gui.MainFrame.Size
    local minimizedSize = UDim2.new(0, originalSize.X.Offset, 0, 40)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        minimizeBtn.Text = minimized and "+" or "-"
        
        if minimized then
            TweenService:Create(gui.MainFrame, TweenInfo.new(0.3), {
                Size = minimizedSize
            }):Play()
            
            -- Hide all children except title and this button
            for _, child in ipairs(gui.MainFrame:GetChildren()) do
                if child ~= title and child ~= minimizeBtn and child ~= gui.Stroke then
                    child.Visible = false
                end
            end
        else
            TweenService:Create(gui.MainFrame, TweenInfo.new(0.3), {
                Size = originalSize
            }):Play()
            
            -- Show all children
            task.wait(0.1)
            for _, child in ipairs(gui.MainFrame:GetChildren()) do
                if child ~= title and child ~= minimizeBtn and child ~= gui.Stroke then
                    child.Visible = true
                end
            end
        end
    end)
end

-- Setup minimize buttons for all GUIs
setupMinimizeFunction(ghostStats, statsTitle, statsMinimize)
setupMinimizeFunction(buttonToggles, buttonsTitle, buttonsMinimize)
setupMinimizeFunction(equipmentGUI, equipTitle, equipMinimize)
setupMinimizeFunction(evidenceGUI, evidenceTitle, evidenceMinimize)
setupMinimizeFunction(ghostInfoGUI, ghostInfoTitle, ghostInfoMinimize)

-- ESP Function
local function createESP(player)
    local highlightClone = Instance.new("Highlight")
    highlightClone.Name = "PlayerESP"
    highlightClone.FillColor = Color3.fromRGB(0, 255, 0)
    highlightClone.OutlineColor = Color3.fromRGB(0, 255, 0)
    highlightClone.FillTransparency = 0.5
    highlightClone.OutlineTransparency = 0
    highlightClone.Adornee = player.Character
    highlightClone.Parent = player.Character
    
    return highlightClone
end

-- Evil Tags Function
local function createEvilTag(character)
    local evl = Instance.new("Highlight")
    evl.Name = "EvilTag"
    evl.FillColor = Color3.fromRGB(255, 0, 0)
    evl.OutlineColor = Color3.fromRGB(255, 0, 0)
    evl.FillTransparency = 0.5
    evl.OutlineTransparency = 0
    evl.Adornee = character
    evl.Parent = character
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "EvilTagLabel"
    billboardGui.Size = UDim2.new(0, 100, 0, 40)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = character
    
    local label = Instance.new("TextLabel", billboardGui)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "GHOST"
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 20
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    createRainbowEffect(label, "TextColor3")
    
    return evl, billboardGui
end

-- Fullbright Function
local function setFullbright(enabled)
    if enabled then
        -- Save current lighting properties
        oldLightingProps = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            Ambient = Lighting.Ambient
        }
        
        -- Set fullbright
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    else
        -- Restore lighting properties
        Lighting.Brightness = oldLightingProps.Brightness
        Lighting.ClockTime = oldLightingProps.ClockTime
        Lighting.FogEnd = oldLightingProps.FogEnd
        Lighting.GlobalShadows = oldLightingProps.GlobalShadows
        Lighting.Ambient = oldLightingProps.Ambient
    end
end

-- Equipment GUI Toggle
showEquipmentBtn.MouseButton1Click:Connect(function()
    equipmentGUI.ScreenGui.Enabled = not equipmentGUI.ScreenGui.Enabled
    
    if equipmentGUI.ScreenGui.Enabled then
        equipmentGUI.MainFrame.Size = UDim2.new(0, 220, 0, equipYOffset + 10)
        
        for _, item in ipairs(equipLabels) do
            item.box.Visible = true
            item.label.Visible = true
        end
    end
    
    showEquipmentBtn.Text = "Equipment GUI: " .. (equipmentGUI.ScreenGui.Enabled and "ON" or "OFF")
end)

-- Ghost Info GUI Toggle
local ghostInfoBtn = createToggleButton(
    buttonToggles.MainFrame, 
    "Ghost Info GUI", 
    UDim2.new(0.5, -100, 0, buttonYPos)
)
table.insert(buttons, ghostInfoBtn)

ghostInfoBtn.MouseButton1Click:Connect(function()
    ghostInfoGUI.ScreenGui.Enabled = not ghostInfoGUI.ScreenGui.Enabled
    ghostInfoBtn.Text = "Ghost Info GUI: " .. (ghostInfoGUI.ScreenGui.Enabled and "ON" or "OFF")
end)

-- Show/Hide Stats
statsMinimize.MouseButton1Click:Connect(function()
    local minimized = ghostStats.MainFrame.Size.Y.Offset <= 45
    
    for statName, label in pairs(labels) do
        label.Visible = not minimized
    end
    
    ghostStats.MainFrame.Size = minimized 
        and UDim2.new(0, 320, 0, yOffset) 
        or UDim2.new(0, 320, 0, 40)
end)

-- Show/Hide Evidence
evidenceMinimize.MouseButton1Click:Connect(function()
    local minimized = evidenceGUI.MainFrame.Size.Y.Offset <= 45
    
    for _, evidence in ipairs(evidenceChecks) do
        evidence.box.Visible = not minimized
        evidence.label.Visible = not minimized
    end
    
    evidenceGUI.MainFrame.Size = minimized 
        and UDim2.new(0, 240, 0, evidenceYOffset) 
        or UDim2.new(0, 240, 0, 40)
end)

-- Game Logic Connections
-- Find ghost parts
local function findGhostModel()
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and (model.Name:find("Ghost") or model.Name:find("Evil")) then
            return model
        end
    end
    
    return nil
end

-- ESP Update Loop
task.spawn(function()
    local playerESP = {}
    
    while true do
        task.wait(0.5)
        
        local espEnabled = getEspState()
        local evilTagsEnabled = getEvilTagsState()
        
        -- Player ESP
        if espEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if not playerESP[player.Name] then
                        playerESP[player.Name] = createESP(player)
                    end
                end
            end
        else
            for playerName, esp in pairs(playerESP) do
                esp:Destroy()
                playerESP[playerName] = nil
            end
        end
        
        -- Evil Tags (Ghost Highlighting)
        if evilTagsEnabled then
            local ghostModel = findGhostModel()
            if ghostModel and not ghostModel:FindFirstChild("EvilTag") then
                createEvilTag(ghostModel)
            end
        else
            for _, model in ipairs(Workspace:GetChildren()) do
                if model:IsA("Model") then
                    local evilTag = model:FindFirstChild("EvilTag")
                    local evilLabel = model:FindFirstChild("EvilTagLabel")
                    
                    if evilTag then evilTag:Destroy() end
                    if evilLabel then evilLabel:Destroy() end
                end
            end
        end
        
        -- Fullbright
        setFullbright(getFullbrightState())
        
        -- Update Ghost Stats
        local ghostModel = findGhostModel()
        if ghostModel then
            local ghostNode
            
            -- Look for a ghost node in ReplicatedStorage
            for _, node in ipairs(ReplicatedStorage:GetDescendants()) do
                if node:IsA("ModuleScript") and node.Name:find("Ghost") then
                    ghostNode = node
                    break
                end
            end
            
            -- Update ghost info if possible
            if ghostNode then
                -- This is placeholder logic since we don't know the actual game's structure
                -- In a real implementation, you'd need to access the ghost data from the game
                labels["Gender"].Text = "Gender: Unknown"
                labels["Favorite Room"].Text = "Favorite Room: Unknown"
                labels["Current Room"].Text = "Current Room: Unknown"
                labels["Current Temp"].Text = "Current Temp: Unknown"
                labels["Favorite Temp"].Text = "Favorite Temp: Unknown"
            end
        end
    end
end)

-- Hunt TP Logic (teleport to safe spot during ghost hunts)
local safePosition = Vector3.new(0, 100, 0) -- This should be set to a known safe position

task.spawn(function()
    while true do
        task.wait(0.5)
        
        if getHuntTpState() then
            -- Check for hunt indicators (game-specific)
            local isHunting = false
            
            -- This is placeholder logic
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Sound") and obj.Playing and obj.Name:find("Hunt") then
                    isHunting = true
                    break
                end
            end
            
            if isHunting and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- Teleport to safe position
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
            end
        end
    end
end)

-- Auto Equipment Logic
autoEquipBtn.MouseButton1Click:Connect(function()
    local state = not autoEquipBtn.Text:find("ON")
    autoEquipBtn.Text = "Pickup & Drop Items: " .. (state and "ON" or "OFF")
    
    if state then
        -- Auto collect all items in range
        local itemsCollected = 0
        
        for _, item in ipairs(Workspace:GetDescendants()) do
            if item:IsA("Tool") and item:FindFirstChild("Handle") then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - item.Handle.Position).Magnitude
                
                if distance < 10 then
                    item.Parent = LocalPlayer.Backpack
                    itemsCollected += 1
                end
            end
        end
        
        -- Notify
        if itemsCollected > 0 then
            local notification = Instance.new("TextLabel")
            notification.Size = UDim2.new(0, 200, 0, 50)
            notification.Position = UDim2.new(0.5, -100, 0.8, 0)
            notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            notification.BackgroundTransparency = 0.5
            notification.TextColor3 = Color3.fromRGB(255, 255, 255)
            notification.Text = "Collected " .. itemsCollected .. " items"
            notification.Font = Enum.Font.GothamBold
            notification.TextSize = 18
            notification.Parent = CoreGui
            createCorner(notification, 8)
            
            game:GetService("Debris"):AddItem(notification, 3)
        end
    end
end)

-- Ghost Detection Logic  
ghostDetectorBtn.MouseButton1Click:Connect(function()
    local state = not ghostDetectorBtn.Text:find("ON")
    ghostDetectorBtn.Text = "Ghost Detector: " .. (state and "ON" or "OFF")
    
    if state then
        -- Create arrow pointing to ghost
        local arrow = Instance.new("ImageLabel", CoreGui)
        arrow.Size = UDim2.new(0, 50, 0, 50)
        arrow.Position = UDim2.new(0.5, -25, 0.5, -25)
        arrow.BackgroundTransparency = 1
        arrow.Image = "rbxassetid://7734010488" -- Arrow image ID
        arrow.ImageColor3 = Color3.fromRGB(255, 0, 0)
        arrow.Name = "GhostDetectorArrow"
        
        createRainbowEffect(arrow, "ImageColor3")
        
        -- Arrow update loop
        task.spawn(function()
            while ghostDetectorBtn.Text:find("ON") and arrow and arrow.Parent do
                task.wait(0.1)
                
                local ghostModel = findGhostModel()
                if ghostModel and ghostModel:FindFirstChild("HumanoidRootPart") and 
                   LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    
                    -- Calculate direction
                    local ghostPos = ghostModel.HumanoidRootPart.Position
                    local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
                    local direction = (ghostPos - playerPos).Unit
                    
                    -- Calculate angle
                    local lookvector = LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector
                    local angle = math.atan2(direction.X, direction.Z) - math.atan2(lookvector.X, lookvector.Z)
                    
                    -- Update arrow rotation
                    arrow.Rotation = math.deg(angle)
                    
                    -- Update distance indicator
                    local distance = (ghostPos - playerPos).Magnitude
                    
                    -- Change color based on distance
                    local distanceColor
                    if distance < 10 then
                        distanceColor = Color3.fromRGB(255, 0, 0) -- Red (close)
                    elseif distance < 30 then
                        distanceColor = Color3.fromRGB(255, 255, 0) -- Yellow (medium)
                    else
                        distanceColor = Color3.fromRGB(0, 255, 0) -- Green (far)
                    end
                    
                    arrow.ImageColor3 = distanceColor
                end
            end
            
            if arrow and arrow.Parent then
                arrow:Destroy()
            end
        end)
    else
        -- Remove ghost detector arrow
        for _, item in ipairs(CoreGui:GetChildren()) do
            if item.Name == "GhostDetectorArrow" then
                item:Destroy()
            end
        end
    end
end)

-- Initialize all GUI sizes
ghostStats.MainFrame.Size = UDim2.new(0, 320, 0, yOffset)
evidenceGUI.MainFrame.Size = UDim2.new(0, 240, 0, evidenceYOffset)
equipmentGUI.MainFrame.Size = UDim2.new(0, 220, 0, equipYOffset + 10)

-- Show all elements initially
for statName, label in pairs(labels) do
    label.Visible = true
end

for _, evidence in ipairs(evidenceChecks) do
    evidence.box.Visible = true
    evidence.label.Visible = true
end

for _, equipment in ipairs(equipLabels) do
    equipment.box.Visible = true
    equipment.label.Visible = true
end

-- Initial notification
local startNotification = Instance.new("TextLabel", CoreGui)
startNotification.Size = UDim2.new(0, 300, 0, 60)
startNotification.Position = UDim2.new(0.5, -150, 0.2, 0)
startNotification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
startNotification.BackgroundTransparency = 0.5
startNotification.TextColor3 = Color3.fromRGB(255, 255, 255)
startNotification.Text = "Ghost Hunter Loaded!\nUse the GUI to track evidence and find ghosts."
startNotification.Font = Enum.Font.GothamBold
startNotification.TextSize = 16
startNotification.TextWrapped = true
createCorner(startNotification, 10)
createStrokeWithRainbow(startNotification)

-- Auto-remove notification
task.delay(5, function()
    TweenService:Create(startNotification, TweenInfo.new(1), {
        BackgroundTransparency = 1,
        TextTransparency = 1
    }):Play()
    
    task.delay(1, function()
        startNotification:Destroy()
    end)
end)

-- Return the main GUI handles for potential future use
return {
    GhostStats = ghostStats,
    ButtonToggles = buttonToggles,
    EquipmentGUI = equipmentGUI,
    EvidenceGUI = evidenceGUI,
    GhostInfoGUI = ghostInfoGUI
}
