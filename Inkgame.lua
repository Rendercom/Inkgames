mko:
-- ScriptHub for Hacker Simulator
-- ✅ Speed, JumpPower, Inf Jump, Noclip, Fling
-- ✅ Mobile friendly, smaller size, draggable hub

local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- UI Builder
local function I(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props) do inst[k] = v end
    return inst
end

-- Main ScreenGui
local gui = I("ScreenGui", {Name="ScriptHub", Parent=player:WaitForChild("PlayerGui"), ResetOnSpawn=false})

-- Open Button
local openBtn = I("TextButton", {
    Parent=gui, Size=UDim2.new(0,90,0,35), Position=UDim2.new(0,10,1,-45),
    Text="Open Hub", BackgroundColor3=Color3.fromRGB(40,40,40), TextColor3=Color3.fromRGB(255,255,255)
})

-- Hub Frame (smaller now + draggable)
local hub = I("Frame", {
    Parent=gui, Size=UDim2.new(0,220,0,260), Position=UDim2.new(0.35,0,0.35,0),
    BackgroundColor3=Color3.fromRGB(25,25,25), Visible=false
})
I("UICorner",{Parent=hub,CornerRadius=UDim.new(0,10)})

local closeBtn = I("TextButton", {
    Parent=hub, Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-33,0,5),
    Text="X", BackgroundColor3=Color3.fromRGB(200,50,50), TextColor3=Color3.fromRGB(255,255,255)
})

-- === Make Hub Draggable ===
local dragging, dragStart, startPos
hub.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true
        dragStart=input.Position
        startPos=hub.Position
        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then
                dragging=false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-dragStart
        hub.Position=UDim2.new(
            startPos.X.Scale, startPos.X.Offset+delta.X,
            startPos.Y.Scale, startPos.Y.Offset+delta.Y
        )
    end
end)

-- Open/Close
openBtn.MouseButton1Click:Connect(function() hub.Visible=true; openBtn.Visible=false end)
closeBtn.MouseButton1Click:Connect(function() hub.Visible=false; openBtn.Visible=true end)

-- Scrollable content
local content = I("ScrollingFrame", {
    Parent=hub, Size=UDim2.new(1,-10,1,-40), Position=UDim2.new(0,5,0,35),
    CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=6, BackgroundTransparency=1
})
local layout = I("UIListLayout",{Parent=content,Padding=UDim.new(0,6)})

-- Helper: make buttons
local function makeBtn(text,callback)
    local b = I("TextButton", {
        Parent=content, Size=UDim2.new(1,-12,0,30), Text=text,
        BackgroundColor3=Color3.fromRGB(45,45,45), TextColor3=Color3.fromRGB(255,255,255),
        Font=Enum.Font.Gotham, TextSize=14
    })
    I("UICorner",{Parent=b,CornerRadius=UDim.new(0,6)})
    b.MouseButton1Click:Connect(callback)
    return b
end

-- === FEATURES ===

-- WalkSpeed Button
local speed = 16
local speedBtn = makeBtn("WalkSpeed: "..speed, function()
    speed += 16
    if speed>500 then speed=0 end
    speedBtn.Text="WalkSpeed: "..speed
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed=speed
    end
end)

-- JumpPower Button
local jp = 50
local jpBtn = makeBtn("JumpPower: "..jp, function()
    jp += 10
    if jp>100 then jp=0 end
    jpBtn.Text="JumpPower: "..jp
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        local hum=player.Character:FindFirstChildOfClass("Humanoid")
        hum.UseJumpPower=true; hum.JumpPower=jp
    end
end)

-- Infinite Jump
local infJump=false
makeBtn("Toggle Infinite Jump", function()
    infJump = not infJump
end)
UserInputService.JumpRequest:Connect(function()
    if infJump and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Noclip
local noclip=false
makeBtn("Toggle Noclip", function() noclip=not noclip end)
RunService.Stepped:Connect(function()
    if noclip and player.Character then
        for _,p in ipairs(player.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end
end)

-- Fling (username box)
local flingBox = I("TextBox", {
    Parent=content, Size=UDim2.new(1,-12,0,28),
    PlaceholderText="Enter Username", BackgroundColor3=Color3.fromRGB(30,30,30),
    TextColor3=Color3.fromRGB(255,255,255), ClearTextOnFocus=false, Font=Enum.Font.Gotham, TextSize=14
})
I("UICorner",{Parent=flingBox,CornerRadius=UDim.new(0,6)})

makeBtn("Fling Player", function()
    local targetName = flingBox.Text
    local target = game.Players:FindFirstChild(targetName)
    local char = player.Character
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        -- teleport to target
        hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
        -- insane spin
        local spin = Instance.new("BodyAngularVelocity")
        spin.AngularVelocity = Vector3.new(0,999999,0)
        spin.MaxTorque = Vector3.new(1e9,1e9,1e9)
        spin.Parent = hrp
        game:GetService("Debris"):AddItem(spin,2)
    end
end)
