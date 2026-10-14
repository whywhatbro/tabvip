-- Mobile Menu Script - Teleport Behind Player
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Xóa UI cũ nếu có tránh bị trùng lặp
if CoreGui:FindFirstChild("MobileTPMenu") then
    CoreGui.MobileTPMenu:Destroy()
end

-- Tạo ScreenGui chính
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileTPMenu"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 1. Nút Bật/Tắt Menu (Tròn, nhỏ gọn ở góc màn hình)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Parent = screenGui
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.BorderSizePixel = 0
toggleBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Font = Enum.Font.SourceSansBold
text_color = Color3.fromRGB(255, 255, 255)
toggleBtn.TextColor3 = text_color
toggleBtn.TextSize = 14
toggleBtn.Text = "Menu"

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(1, 0)
corner1.Parent = toggleBtn

-- 2. Khung Menu Danh Sách Người Chơi
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.02, 0, 0.23, 0)
mainFrame.Size = UDim2.new(0, 200, 0, 250)
mainFrame.Visible = false -- Mặc định ẩn

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 8)
corner2.Parent = mainFrame

-- Tiêu đề Menu
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleLabel.BorderSizePixel = 0
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Text = "Chọn Người Chơi"

local corner3 = Instance.new("UICorner")
corner3.CornerRadius = UDim.new(0, 8)
corner3.Parent = titleLabel

-- ScrollingFrame chứa danh sách
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Parent = mainFrame
scrollingFrame.Active = true
scrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.Position = UDim2.new(0, 0, 0, 40)
scrollingFrame.Size = UDim2.new(1, 0, 1, -40)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 4

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollingFrame
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 5)

-- Hàm thực hiện Bay ra sau lưng
local function teleportBehind(targetPlayer)
    local character = player.Character
    local targetChar = targetPlayer.Character
    
    if character and character:FindFirstChild("HumanoidRootPart") and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local targetHRP = targetChar.HumanoidRootPart
        
        -- Tính toán vị trí phía sau lưng và hướng mặt về phía họ
        local offset = targetHRP.CFrame * CFrame.new(0, 0, 4)
        local lookAtTarget = CFrame.new(offset.Position, targetHRP.Position)
        
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = lookAtTarget})
        tween:Play()
    end
end

-- Cập nhật danh sách người chơi
local function updatePlayerList()
    -- Xóa các nút cũ
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Tạo nút mới cho từng người chơi trong server
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton")
            btn.Parent = scrollingFrame
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.BorderSizePixel = 0
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.Position = UDim2.new(0, 5, 0, 0)
            btn.Font = Enum.Font.SourceSans
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 13
            btn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = btn
            
            -- Khi bấm vào tên ai -> thực hiện bay ra sau lưng người đó
            btn.MouseButton1Click:Connect(function()
                teleportBehind(p)
            end)
        end
    end
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
end

-- Sự kiện bật/tắt giao diện
toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible then
        updatePlayerList()
    end
end)

-- Tự động cập nhật lại danh sách khi có người vào/rời game
Players.PlayerAdded:Connect(function() if mainFrame.Visible then updatePlayerList() end end)
Players.PlayerRemoving:Connect(function() if mainFrame.Visible then updatePlayerList() end end)

print("Mobile Menu Loaded!")
