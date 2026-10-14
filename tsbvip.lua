-- Advanced Mobile Menu v6 (TSB Ultimate Edition: Ultra-fast 0.1s Behind Loop, Split Mode 3 & 4 with Instant Target Switch on Death)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("AdvancedMobileMenuV6") then
    CoreGui.AdvancedMobileMenuV6:Destroy()
end

-- Cấu hình trạng thái
local isEnabled = false
local currentMode = 3 -- 1: Danh sách, 2: Textbox, 3: Random riêng, 4: Ít máu nhất riêng
local targetPlayer = nil
local isFollowing = false
local distanceOffset = 4

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedMobileMenuV6"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 1. NÚT MENU TRÒN MỞ BẢNG (Di chuyển được)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Parent = screenGui
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.BorderSizePixel = 0
toggleBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 13
toggleBtn.Text = "Menu"
local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(1, 0) c1.Parent = toggleBtn

-- Hàm kéo thả chung cho UI
local function makeDraggable(guiObject)
    local dragging, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(toggleBtn)

-- 2. KHUNG MENU CHÍNH (Kéo thả toàn bộ khung)
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.02, 0, 0.23, 0)
mainFrame.Size = UDim2.new(0, 230, 0, 360)
mainFrame.Visible = false
local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 8) c2.Parent = mainFrame
makeDraggable(mainFrame)

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Size = UDim2.new(1, 0, 0, 30)
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Text = "☰ TSB MENU (Kéo bất kỳ)"
local c3 = Instance.new("UICorner") c3.CornerRadius = UDim.new(0, 8) c3.Parent = title

-- Nút ON / OFF Tổng
local powerBtn = Instance.new("TextButton")
powerBtn.Parent = mainFrame
powerBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
powerBtn.Position = UDim2.new(0, 10, 0, 36)
powerBtn.Size = UDim2.new(1, -20, 0, 28)
powerBtn.Font = Enum.Font.SourceSansBold
powerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
powerBtn.TextSize = 13
powerBtn.Text = "Trạng thái: OFF"
local cPow = Instance.new("UICorner") cPow.CornerRadius = UDim.new(0, 4) cPow.Parent = powerBtn

-- Nút Chuyển Chế Độ (1: Danh sách, 2: Textbox, 3: Random riêng, 4: Ít máu nhất riêng)
local modeBtn = Instance.new("TextButton")
modeBtn.Parent = mainFrame
modeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
modeBtn.Position = UDim2.new(0, 10, 0, 68)
modeBtn.Size = UDim2.new(1, -20, 0, 25)
modeBtn.Font = Enum.Font.SourceSansBold
modeBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
modeBtn.TextSize = 12
modeBtn.Text = "Chế độ: 3 (Random người chơi)"
local cMode = Instance.new("UICorner") cMode.CornerRadius = UDim.new(0, 4) cMode.Parent = modeBtn

-- Textbox Nhập Tên (Chế độ 2)
local nameBox = Instance.new("TextBox")
nameBox.Parent = mainFrame
nameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
nameBox.Position = UDim2.new(0, 10, 0, 96)
nameBox.Size = UDim2.new(1, -20, 0, 25)
nameBox.Font = Enum.Font.SourceSans
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.PlaceholderText = "Nhập tên mục tiêu (Chế độ 2)..."
nameBox.Text = ""
nameBox.TextSize = 12
local cBox = Instance.new("UICorner") cBox.CornerRadius = UDim.new(0, 4) cBox.Parent = nameBox

-- Textbox BlackList (Ngăn cách dấu phẩy)
local blackBox = Instance.new("TextBox")
blackBox.Parent = mainFrame
blackBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
blackBox.Position = UDim2.new(0, 10, 0, 124)
blackBox.Size = UDim2.new(1, -20, 0, 25)
blackBox.Font = Enum.Font.SourceSans
blackBox.TextColor3 = Color3.fromRGB(255, 100, 100)
blackBox.PlaceholderText = "Ngoại lệ (vd: A,B,C)..."
blackBox.Text = ""
blackBox.TextSize = 12
local cBlack = Instance.new("UICorner") cBlack.CornerRadius = UDim.new(0, 4) cBlack.Parent = blackBox

-- Điều chỉnh khoảng cách
local distLabel = Instance.new("TextLabel")
distLabel.Parent = mainFrame
distLabel.Position = UDim2.new(0, 10, 0, 152)
distLabel.Size = UDim2.new(1, -20, 0, 18)
distLabel.BackgroundTransparency = 1
distLabel.Font = Enum.Font.SourceSans
distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distLabel.TextSize = 12
distLabel.Text = "Khoảng cách sau lưng: 4"

local minusDist = Instance.new("TextButton")
minusDist.Parent = mainFrame
minusDist.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minusDist.Position = UDim2.new(0, 10, 0, 172)
minusDist.Size = UDim2.new(0.48, 0, 0, 24)
minusDist.Text = "- Giảm"
minusDist.TextColor3 = Color3.fromRGB(255, 255, 255)
minusDist.TextSize = 12
local cMin = Instance.new("UICorner") cMin.CornerRadius = UDim.new(0, 4) cMin.Parent = minusDist

local plusDist = Instance.new("TextButton")
plusDist.Parent = mainFrame
plusDist.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
plusDist.Position = UDim2.new(0.52, 0, 0, 172)
plusDist.Size = UDim2.new(0.48, 0, 0, 24)
plusDist.Text = "+ Tăng"
plusDist.TextColor3 = Color3.fromRGB(255, 255, 255)
plusDist.TextSize = 12
local cPlu = Instance.new("UICorner") cPlu.CornerRadius = UDim.new(0, 4) cPlu.Parent = plusDist

-- ScrollingFrame danh sách (Chế độ 1)
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Parent = mainFrame
scrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.Position = UDim2.new(0, 10, 0, 200)
scrollingFrame.Size = UDim2.new(1, -20, 1, -208)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 3
local uiLayout = Instance.new("UIListLayout") uiLayout.Parent = scrollingFrame uiLayout.Padding = UDim.new(0, 4)
scrollingFrame.Visible = false

-- 3. NÚT ĐẶC BIỆT TRÒN (Void Loop + Icon Khóa 🔓/🔒)
local specialContainer = Instance.new("Frame")
specialContainer.Parent = screenGui
specialContainer.BackgroundTransparency = 1
specialContainer.Position = UDim2.new(0.02, 0, 0.42, 0)
specialContainer.Size = UDim2.new(0, 50, 0, 75)

local voidLoopBtn = Instance.new("TextButton")
voidLoopBtn.Parent = specialContainer
voidLoopBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
voidLoopBtn.Size = UDim2.new(0, 50, 0, 50)
voidLoopBtn.Font = Enum.Font.SourceSansBold
voidLoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
voidLoopBtn.TextSize = 10
voidLoopBtn.Text = "Void Loop"
local cVoid = Instance.new("UICorner") cVoid.CornerRadius = UDim.new(1, 0) cVoid.Parent = voidLoopBtn

local lockBtn = Instance.new("TextButton")
lockBtn.Parent = specialContainer
lockBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
lockBtn.Position = UDim2.new(0, 5, 0, 53)
lockBtn.Size = UDim2.new(0, 40, 0, 18)
lockBtn.Font = Enum.Font.SourceSansBold
lockBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
lockBtn.TextSize = 12
lockBtn.Text = "🔓"
local cLock = Instance.new("UICorner") cLock.CornerRadius = UDim.new(0, 4) cLock.Parent = lockBtn

-- Logic Khóa/Mở icon khóa
local isLocked = false
lockBtn.MouseButton1Click:Connect(function()
    isLocked = not isLocked
    if isLocked then
        lockBtn.Text = "🔒"
        lockBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        lockBtn.Text = "🔓"
        lockBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

-- Kéo thả nút đặc biệt
local sDragging, sDragStart, sStartPos
specialContainer.InputBegan:Connect(function(input)
    if not isLocked and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        sDragging = true
        sDragStart = input.Position
        sStartPos = specialContainer.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then sDragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not isLocked and sDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        local delta = input.Position - sDragStart
        specialContainer.Position = UDim2.new(sStartPos.X.Scale, sStartPos.X.Offset + delta.X, sStartPos.Y.Scale, sStartPos.Y.Offset + delta.Y)
    end
end)

-- Logic nút Bật/Tắt Tổng
powerBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        powerBtn.Text = "Trạng thái: ON"
        powerBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        isFollowing = true
    else
        powerBtn.Text = "Trạng thái: OFF"
        powerBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        isFollowing = false
        targetPlayer = nil
    end
end)

-- Điều chỉnh khoảng cách
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
    if currentMode > 4 then currentMode = 1 end
    
    if currentMode == 1 then
        modeBtn.Text = "Chế độ: 1 (Chọn từ danh sách)"
        scrollingFrame.Visible = true
    elseif currentMode == 2 then
        modeBtn.Text = "Chế độ: 2 (Textbox nhận diện)"
        scrollingFrame.Visible = false
    elseif currentMode == 3 then
        modeBtn.Text = "Chế độ: 3 (Random người chơi)"
        scrollingFrame.Visible = false
    elseif currentMode == 4 then
        modeBtn.Text = "Chế độ: 4 (Người ít máu nhất)"
        scrollingFrame.Visible = false
    end
end)

-- Kiểm tra Blacklist
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

-- Tìm mục tiêu theo Chế độ 2
local function findTargetByText(query)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and not isBlacklisted(p.Name) and (p.DisplayName and string.lower(p.DisplayName):sub(1, #query) == string.lower(query) or string.lower(p.Name):sub(1, #query) == string.lower(query)) then
            return p
        end
    end
    return nil
end

-- Chế độ 3: Random người chơi sống
local function getRandomPlayer()
    local validList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and not isBlacklisted(p.Name) and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum.Health > 0 then
                table.insert(validList, p)
            end
        end
    end
    if #validList > 0 then
        return validList[math.random(1, #validList)]
    end
    return nil
end

-- Chế độ 4: Người ít máu nhất còn sống
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

-- Vòng lặp bám dính liên tục (Tự động đổi mục tiêu ngay lập tức sang người khác khi người cũ chết)
RunService.RenderStepped:Connect(function()
    if not isEnabled or not isFollowing then return end
    
    local isTargetDead = false
    if targetPlayer and targetPlayer.Character then
        local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            isTargetDead = true
        end
    else
        isTargetDead = true
    end
    
    if currentMode == 2 then
        local query = nameBox.Text
        if query ~= "" then targetPlayer = findTargetByText(query) end
    elseif currentMode == 3 then
        if not targetPlayer or isTargetDead then
            targetPlayer = getRandomPlayer() -- Chết -> Đổi random người mới ngay lập tức
        end
    elseif currentMode == 4 then
        if not targetPlayer or isTargetDead then
            targetPlayer = getLowestHealthPlayer() -- Chết -> Đổi sang người ít máu tiếp theo ngay lập tức
        end
    end
    
    if not targetPlayer or not targetPlayer.Parent or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        targetPlayer = nil
        return
    end
    
    local char = player.Character
    local targetChar = targetPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local targetHRP = targetChar.HumanoidRootPart
        
        local offset = targetHRP.CFrame * CFrame.new(0, 0, distanceOffset)
        hrp.CFrame = CFrame.new(offset.Position, targetHRP.Position)
        hrp.Velocity = Vector3.new(0, 0, 0)
    end
end)

-- Nút đặc biệt: Lướt ra sau lưng tất cả người chơi siêu nhanh tức thì (0.1s/người) rồi ra Void đứng chờ chết (Tổng 4s)
local isVoidLooping = false
voidLoopBtn.MouseButton1Click:Connect(function()
    if isVoidLooping then return end
    isVoidLooping = true
    voidLoopBtn.Text = "Loop"
    
    task.spawn(function()
        local list = Players:GetPlayers()
        
        -- Lướt cực nhanh ra sau lưng từng người (0.1 giây mỗi người)
        for _, p in ipairs(list) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = p.Character.HumanoidRootPart
                    local offset = targetHRP.CFrame * CFrame.new(0, 0, distanceOffset)
                    char.HumanoidRootPart.CFrame = CFrame.new(offset.Position, targetHRP.Position)
                    task.wait(0.1) -- Tốc độ lướt qua mỗi người
                end
            end
        end
        
        -- Dịch chuyển ra vùng Void của map TSB để chết và đứng chờ ở ngoài đó
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, -50000, 0)
        end
        
        task.wait(2) -- Chờ ở Void để hoàn thành đủ chu kỳ 4 giây tổng cộng
        voidLoopBtn.Text = "Void Loop"
        isVoidLooping = false
    end)
end)

-- Cập nhật danh sách (Chế độ 1)
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
                isEnabled = true
                powerBtn.Text = "Trạng thái: ON"
                powerBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
                isFollowing = true
            end)
        end
    end
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiLayout.AbsoluteContentSize.Y + 5)
end

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible and currentMode == 1 then updateList() end
end)

print("Advanced Mobile Menu v6 (TSB) Loaded Successfully!")
