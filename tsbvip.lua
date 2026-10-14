-- Advanced Mobile Target Script (3 Modes + Blacklist + Follow Mode)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("AdvancedMobileMenu") then
    CoreGui.AdvancedMobileMenu:Destroy()
end

-- Biến cấu hình trạng thái
local currentMode = 1 -- 1: Chọn trong danh sách, 2: Nhập tên (Textbox), 3: Người ít máu nhất (Random ngoại trừ Blacklist)
local targetPlayer = nil
local isFollowing = false
local distanceOffset = 4 -- Khoảng cách mặc định phía sau lưng

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedMobileMenu"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 1. Nút Menu Di Chuyển Được (Draggable)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Parent = screenGui
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.BorderSizePixel = 0
toggleBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Text = "Menu"

local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(1, 0) c1.Parent = toggleBtn

-- Kéo thả nút Menu trên mobile
local dragging, dragInput, dragStart, startPos
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = toggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        local delta = input.Position - dragStart
        toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 2. Khung Giao Diện Chính
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.02, 0, 0.23, 0)
mainFrame.Size = UDim2.new(0, 230, 0, 330)
mainFrame.Visible = false
local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 8) c2.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Size = UDim2.new(1, 0, 0, 30)
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Text = "MENU ĐIỀU KHIỂN BÁM ĐUỔI"
local c3 = Instance.new("UICorner") c3.CornerRadius = UDim.new(0, 8) c3.Parent = title

-- Nút Chuyển Chế Độ (Mode Button)
local modeBtn = Instance.new("TextButton")
modeBtn.Parent = mainFrame
modeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
modeBtn.Position = UDim2.new(0, 10, 0, 38)
modeBtn.Size = UDim2.new(1, -20, 0, 25)
modeBtn.Font = Enum.Font.SourceSansBold
modeBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
modeBtn.TextSize = 12
modeBtn.Text = "Chế độ: 1 (Chọn từ danh sách)"
local cMode = Instance.new("UICorner") cMode.CornerRadius = UDim.new(0, 4) cMode.Parent = modeBtn

-- Textbox Nhập Tên (Dành cho Chế độ 2)
local nameBox = Instance.new("TextBox")
nameBox.Parent = mainFrame
nameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
nameBox.Position = UDim2.new(0, 10, 0, 68)
nameBox.Size = UDim2.new(1, -20, 0, 25)
nameBox.Font = Enum.Font.SourceSans
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.PlaceholderText = "Nhập tên mục tiêu (Chế độ 2)..."
nameBox.Text = ""
nameBox.TextSize = 12
local cBox = Instance.new("UICorner") cBox.CornerRadius = UDim.new(0, 4) cBox.Parent = nameBox

-- Textbox BlackList (Ngăn cách bằng dấu phẩy)
local blackBox = Instance.new("TextBox")
blackBox.Parent = mainFrame
blackBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
blackBox.Position = UDim2.new(0, 10, 0, 98)
blackBox.Size = UDim2.new(1, -20, 0, 25)
blackBox.Font = Enum.Font.SourceSans
blackBox.TextColor3 = Color3.fromRGB(255, 100, 100)
blackBox.PlaceholderText = "Ngoại lệ (vd: A,B,C)..."
blackBox.Text = ""
blackBox.TextSize = 12
local cBlack = Instance.new("UICorner") cBlack.CornerRadius = UDim.new(0, 4) cBlack.Parent = blackBox

-- Thanh điều chỉnh khoảng cách (Distance Slider / Buttons)
local distLabel = Instance.new("TextLabel")
distLabel.Parent = mainFrame
distLabel.Position = UDim2.new(0, 10, 0, 126)
distLabel.Size = UDim2.new(1, -20, 0, 18)
distLabel.BackgroundTransparency = 1
distLabel.Font = Enum.Font.SourceSans
distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distLabel.TextSize = 12
distLabel.Text = "Khoảng cách sau lưng: 4"

local minusDist = Instance.new("TextButton")
minusDist.Parent = mainFrame
minusDist.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minusDist.Position = UDim2.new(0, 10, 0, 146)
minusDist.Size = UDim2.new(0.48, 0, 0, 24)
minusDist.Text = "- Giảm"
minusDist.TextColor3 = Color3.fromRGB(255, 255, 255)
minusDist.TextSize = 12
local cMin = Instance.new("UICorner") cMin.CornerRadius = UDim.new(0, 4) cMin.Parent = minusDist

local plusDist = Instance.new("TextButton")
plusDist.Parent = mainFrame
plusDist.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
plusDist.Position = UDim2.new(0.52, 0, 0, 146)
plusDist.Size = UDim2.new(0.48, 0, 0, 24)
plusDist.Text = "+ Tăng"
plusDist.TextColor3 = Color3.fromRGB(255, 255, 255)
plusDist.TextSize = 12
local cPlu = Instance.new("UICorner") cPlu.CornerRadius = UDim.new(0, 4) cPlu.Parent = plusDist

-- ScrollingFrame danh sách (Cho chế độ 1)
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Parent = mainFrame
scrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.Position = UDim2.new(0, 10, 0, 175)
scrollingFrame.Size = UDim2.new(1, -20, 1, -182)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 3
local uiLayout = Instance.new("UIListLayout") uiLayout.Parent = scrollingFrame uiLayout.Padding = UDim.new(0, 4)

-- Xử lý thay đổi khoảng cách
minusDist.MouseButton1Click:Connect(function()
    distanceOffset = math.clamp(distanceOffset - 1, 1, 15)
    distLabel.Text = "Khoảng cách sau lưng: " .. distanceOffset
end)
plusDist.MouseButton1Click:Connect(function()
    distanceOffset = math.clamp(distanceOffset + 1, 1, 15)
    distLabel.Text = "Khoảng cách sau lưng: " .. distanceOffset
end)

-- Chuyển chế độ
modeBtn.MouseButton1Click:Connect(function()
    currentMode = currentMode + 1
    if currentMode > 3 then currentMode = 1 end
    
    if currentMode == 1 then
        modeBtn.Text = "Chế độ: 1 (Chọn từ danh sách)"
        scrollingFrame.Visible = true
    elseif currentMode == 2 then
        modeBtn.Text = "Chế độ: 2 (Textbox nhận diện)"
        scrollingFrame.Visible = false
    elseif currentMode == 3 then
        modeBtn.Text = "Chế độ: 3 (Ít máu nhất + Ngoại lệ)"
        scrollingFrame.Visible = false
        -- Tự động chọn người ít máu ngay lập tức cho chế độ 3
    end
end)

-- Hàm kiểm tra Blacklist
local function isBlacklisted(pName)
    local text = blackBox.Text
    for name in string.gmatch(text, "([^,]+)") do
        local cleanName = name:gsub("^%s*(.-)%s*$", ""):lower()
        if cleanName ~= "" and string.lower(pName):find(cleanName) then
            return true
        end
    end
    return false
end

-- Hàm tìm mục tiêu theo Chế độ 2
local function findTargetByText(query)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and not isBlacklisted(p.Name) and (p.DisplayName and string.lower(p.DisplayName):sub(1, #query) == string.lower(query) or string.lower(p.Name):sub(1, #query) == string.lower(query)) then
            return p
        end
    end
    return nil
end

-- Hàm tìm người ít máu nhất cho Chế độ 3
local function getLowestHealthPlayer()
    local lowestP = nil
    local minHealth = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and not isBlacklisted(p.Name) and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum.Health > 0 and hum.Health < minHealth then
                minHealth = hum.Health
                lowestP = p
            end
        end
    end
    return lowestP
end

-- Vòng lặp bám dính liên tục (RenderStepped) giữ nhân vật luôn ở sau lưng, nhìn thẳng và bắt buộc dừng khi thoát/tắt
RunService.RenderStepped:Connect(function()
    if not isFollowing then return end
    
    -- Nếu ở chế độ 2, cập nhật target theo textbox liên tục nếu tên khớp
    if currentMode == 2 then
        local query = nameBox.Text
        if query ~= "" then
            targetPlayer = findTargetByText(query)
        end
    elseif currentMode == 3 then
        targetPlayer = getLowestHealthPlayer()
    end
    
    -- Kiểm tra nếu mục tiêu thoát game hoặc chết thì dừng
    if not targetPlayer or not targetPlayer.Parent or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        isFollowing = false
        targetPlayer = nil
        return
    end
    
    local char = player.Character
    local targetChar = targetPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local targetHRP = targetChar.HumanoidRootPart
        
        -- Luôn tính toán vị trí bám sát ngay phía sau lưng và hướng mặt về phía lưng họ
        local offset = targetHRP.CFrame * CFrame.new(0, 0, distanceOffset)
        local lookAtTarget = CFrame.new(offset.Position, targetHRP.Position)
        
        hrp.CFrame = lookAtTarget
        -- Đóng băng vận tốc để tránh bị văng vật lý
        hrp.Velocity = Vector3.new(0, 0, 0)
    end
end)

-- Cập nhật danh sách cho Chế độ 1
local function updateList()
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton")
            btn.Parent = scrollingFrame
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.Size = UDim2.new(1, -5, 0, 28)
            btn.Font = Enum.Font.SourceSans
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 12
            btn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            local cBtn = Instance.new("UICorner") cBtn.CornerRadius = UDim.new(0, 4) cBtn.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                targetPlayer = p
                isFollowing = true -- Bật chế độ bám đuổi liên tục
            end)
        end
    end
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiLayout.AbsoluteContentSize.Y + 5)
end

-- Nhập dữ liệu xong ở ô textbox chế độ 2 thì tự động bắt đầu bám đuổi
nameBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and currentMode == 2 then
        local found = findTargetByText(nameBox.Text)
        if found then
            targetPlayer = found
            isFollowing = true
        end
    end
end)

-- Khi chọn chế độ 3, tự động kích hoạt bám theo người ít máu nhất
modeBtn.MouseButton1Click:Connect(function()
    if currentMode == 3 then
        local found = getLowestHealthPlayer()
        if found then
            targetPlayer = found
            isFollowing = true
        end
    end
end)

-- Bật/tắt Menu UI chính
toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible and currentMode == 1 then
        updateList()
    end
end)

Players.PlayerAdded:Connect(function() if mainFrame.Visible and currentMode == 1 then updateList() end end)
Players.PlayerRemoving:Connect(function(p)
    if p == targetPlayer then
        isFollowing = false
        targetPlayer = nil
    end
    if mainFrame.Visible and currentMode == 1 then updateList() end
end)

print("Advanced Target Script Loaded Successfully!")
