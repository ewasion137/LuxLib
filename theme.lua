-- ==============================================================================
-- LUXLIB V2 // BRUTAL ACRYLIC MONOLITH ENGINE
-- Full-Spectrum Spectrum UI / Zero Memory Leaks / Hyper-Responsive
-- ==============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LuxLib = {}
LuxLib.__index = LuxLib

-- [ EASINGS & TIMINGS ]
local TWEEN_SNAP   = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_FAST   = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_SMOOTH = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_BOUNCE = TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- [ BRUTAL MONOCHROME + ACCENT SYSTEM ]
local Theme = {
	Void            = Color3.fromRGB(7, 7, 10),
	Surface         = Color3.fromRGB(12, 12, 16),
	Card            = Color3.fromRGB(16, 17, 23),
	CardHover       = Color3.fromRGB(24, 25, 34),
	CardActive      = Color3.fromRGB(30, 32, 44),
	Border          = Color3.fromRGB(34, 35, 46),
	BorderLight     = Color3.fromRGB(68, 70, 90),
	BorderHighlight = Color3.fromRGB(255, 255, 255),
	Text            = Color3.fromRGB(245, 245, 250),
	TextMuted       = Color3.fromRGB(120, 122, 140),
	Accent          = Color3.fromRGB(255, 255, 255),
	AccentDim       = Color3.fromRGB(180, 180, 195),
	Success         = Color3.fromRGB(50, 220, 130),
	Warn            = Color3.fromRGB(255, 190, 40),
	Error           = Color3.fromRGB(255, 65, 80)
}

-- [ UTILITIES ]
local function getGuiHost()
	local ok, target = pcall(function() return CoreGui end)
	if ok and target then return target end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function applyFont(label, weight)
	local ok, font = pcall(function()
		return Font.fromName("Montserrat", weight or Enum.FontWeight.Medium)
	end)
	if ok and font then
		label.FontFace = font
	else
		label.Font = Enum.Font.GothamMedium
	end
end

local function tween(object, info, props)
	local anim = TweenService:Create(object, info, props)
	anim:Play()
	return anim
end

-- Безопасный драггер БЕЗ утечек событий
local function makeDraggable(handle, target)
	local dragging = false
	local dragStart, startPos
	local moveConn, endConn

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position

			if moveConn then moveConn:Disconnect() end
			if endConn then endConn:Disconnect() end

			moveConn = UserInputService.InputChanged:Connect(function(moveInput)
				if dragging and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
					local delta = moveInput.Position - dragStart
					tween(target, TWEEN_SNAP, {
						Position = UDim2.new(
							startPos.X.Scale,
							startPos.X.Offset + delta.X,
							startPos.Y.Scale,
							startPos.Y.Offset + delta.Y
						)
					})
				end
			end)

			endConn = UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
					dragging = false
					if moveConn then moveConn:Disconnect() moveConn = nil end
					if endConn then endConn:Disconnect() endConn = nil end
				end
			end)
		end
	end)
end

-- ==============================================================================
-- [ WINDOW ENGINE ]
-- ==============================================================================
function LuxLib:CreateWindow(config)
	config = config or {}
	local titleText = config.Title or "LUX // MONOLITH"
	local subText = config.Subtitle or "BRUTAL ACRYLIC ENGINE"
	local size = config.Size or UDim2.new(0, 740, 0, 490)
	local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
	local accentColor = config.Accent or Theme.Accent
	Theme.Accent = accentColor

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LuxLib_" .. math.random(10000, 99999)
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = getGuiHost()

	-- Dynamic Acrylic Blur
	local blurInstance = Lighting:FindFirstChild("LuxLib_Blur")
	if not blurInstance then
		blurInstance = Instance.new("BlurEffect")
		blurInstance.Name = "LuxLib_Blur"
		blurInstance.Size = 0
		blurInstance.Parent = Lighting
	end
	tween(blurInstance, TWEEN_SMOOTH, { Size = 20 })

	-- Darkened Acrylic Backdrop
	local backdrop = Instance.new("TextButton")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.new(1, 0, 1, 0)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 1
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.Parent = screenGui
	tween(backdrop, TWEEN_SMOOTH, { BackgroundTransparency = 0.45 })

	-- Main Chassis
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = size
	main.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
	main.BackgroundColor3 = Theme.Void
	main.BackgroundTransparency = 0.08
	main.BorderSizePixel = 0
	main.ClipsDescendants = false
	main.Parent = screenGui

	local mainScale = Instance.new("UIScale")
	mainScale.Scale = 0.94
	mainScale.Parent = main
	tween(mainScale, TWEEN_BOUNCE, { Scale = 1 })

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 8)
	mainCorner.Parent = main

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Theme.Border
	mainStroke.Thickness = 1.2
	mainStroke.Parent = main

	local strokeGradient = Instance.new("UIGradient")
	strokeGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.35, Color3.fromRGB(100, 102, 125)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 32, 42))
	})
	strokeGradient.Rotation = 45
	strokeGradient.Parent = mainStroke

	-- Industrial Topbar
	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.Size = UDim2.new(1, 0, 0, 52)
	topbar.BackgroundColor3 = Theme.Surface
	topbar.BackgroundTransparency = 0.2
	topbar.BorderSizePixel = 0
	topbar.Parent = main

	local topbarCorner = Instance.new("UICorner")
	topbarCorner.CornerRadius = UDim.new(0, 8)
	topbarCorner.Parent = topbar

	local topbarDivider = Instance.new("Frame")
	topbarDivider.Size = UDim2.new(1, 0, 0, 1)
	topbarDivider.Position = UDim2.new(0, 0, 1, -1)
	topbarDivider.BackgroundColor3 = Theme.Border
	topbarDivider.BorderSizePixel = 0
	topbarDivider.Parent = topbar

	local titleBox = Instance.new("Frame")
	titleBox.Size = UDim2.new(0, 320, 1, 0)
	titleBox.Position = UDim2.new(0, 18, 0, 0)
	titleBox.BackgroundTransparency = 1
	titleBox.Parent = topbar

	local titleLayout = Instance.new("UIListLayout")
	titleLayout.FillDirection = Enum.FillDirection.Horizontal
	titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	titleLayout.Padding = UDim.new(0, 10)
	titleLayout.Parent = titleBox

	local titleLabel = Instance.new("TextLabel")
	titleLabel.AutomaticSize = Enum.AutomaticSize.X
	titleLabel.Size = UDim2.new(0, 0, 1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = string.upper(titleText)
	titleLabel.TextColor3 = Theme.Text
	titleLabel.TextSize = 13
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	applyFont(titleLabel, Enum.FontWeight.Bold)
	titleLabel.Parent = titleBox

	local subLabel = Instance.new("TextLabel")
	subLabel.AutomaticSize = Enum.AutomaticSize.X
	subLabel.Size = UDim2.new(0, 0, 1, 0)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = "// " .. string.upper(subText)
	subLabel.TextColor3 = Theme.TextMuted
	subLabel.TextSize = 11
	subLabel.TextXAlignment = Enum.TextXAlignment.Left
	applyFont(subLabel, Enum.FontWeight.Medium)
	subLabel.Parent = titleBox

	-- Performance Stats Monitor
	local statsLabel = Instance.new("TextLabel")
	statsLabel.Size = UDim2.new(0, 140, 1, 0)
	statsLabel.Position = UDim2.new(1, -210, 0, 0)
	statsLabel.BackgroundTransparency = 1
	statsLabel.Text = "FPS: -- | PING: --"
	statsLabel.TextColor3 = Theme.TextMuted
	statsLabel.TextSize = 10
	statsLabel.TextXAlignment = Enum.TextXAlignment.Right
	applyFont(statsLabel, Enum.FontWeight.Medium)
	statsLabel.Parent = topbar

	local frameCount = 0
	local lastTime = os.clock()
	RunService.RenderStepped:Connect(function()
		frameCount = frameCount + 1
		local now = os.clock()
		if now - lastTime >= 0.5 then
			local fps = math.floor(frameCount / (now - lastTime))
			local ping = math.floor(Players.LocalPlayer:GetNetworkPing() * 1000)
			statsLabel.Text = string.format("FPS: %d | %d MS", fps, ping)
			frameCount = 0
			lastTime = now
		end
	end)

	-- Controls (Minimize/Close)
	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 30, 0, 30)
	minBtn.Position = UDim2.new(1, -40, 0.5, -15)
	minBtn.BackgroundColor3 = Theme.Card
	minBtn.BorderSizePixel = 0
	minBtn.Text = "–"
	minBtn.TextColor3 = Theme.TextMuted
	minBtn.TextSize = 14
	minBtn.AutoButtonColor = false
	applyFont(minBtn, Enum.FontWeight.Bold)
	minBtn.Parent = topbar

	local minCorner = Instance.new("UICorner")
	minCorner.CornerRadius = UDim.new(0, 4)
	minCorner.Parent = minBtn

	local minStroke = Instance.new("UIStroke")
	minStroke.Color = Theme.Border
	minStroke.Thickness = 1
	minStroke.Parent = minBtn

	minBtn.MouseEnter:Connect(function()
		tween(minBtn, TWEEN_SNAP, { BackgroundColor3 = Theme.CardHover, TextColor3 = Theme.Text })
	end)
	minBtn.MouseLeave:Connect(function()
		tween(minBtn, TWEEN_SNAP, { BackgroundColor3 = Theme.Card, TextColor3 = Theme.TextMuted })
	end)

	makeDraggable(topbar, main)

	-- Sidebar Layout
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 190, 1, -66)
	sidebar.Position = UDim2.new(0, 12, 0, 58)
	sidebar.BackgroundColor3 = Theme.Surface
	sidebar.BackgroundTransparency = 0.35
	sidebar.BorderSizePixel = 0
	sidebar.Parent = main

	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.CornerRadius = UDim.new(0, 6)
	sidebarCorner.Parent = sidebar

	local sidebarStroke = Instance.new("UIStroke")
	sidebarStroke.Color = Theme.Border
	sidebarStroke.Thickness = 1
	sidebarStroke.Parent = sidebar

	local activePill = Instance.new("Frame")
	activePill.Name = "ActivePill"
	activePill.Size = UDim2.new(0, 3, 0, 20)
	activePill.Position = UDim2.new(0, 5, 0, 10)
	activePill.BackgroundColor3 = Theme.Accent
	activePill.BorderSizePixel = 0
	activePill.Visible = false
	activePill.ZIndex = 4
	activePill.Parent = sidebar

	local pillCorner = Instance.new("UICorner")
	pillCorner.CornerRadius = UDim.new(1, 0)
	pillCorner.Parent = activePill

	local tabScroll = Instance.new("ScrollingFrame")
	tabScroll.Size = UDim2.new(1, -10, 1, -12)
	tabScroll.Position = UDim2.new(0, 5, 0, 6)
	tabScroll.BackgroundTransparency = 1
	tabScroll.BorderSizePixel = 0
	tabScroll.ScrollBarThickness = 0
	tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabScroll.Parent = sidebar

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabScroll

	-- Content Area
	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "ContentContainer"
	contentContainer.Size = UDim2.new(1, -226, 1, -66)
	contentContainer.Position = UDim2.new(0, 214, 0, 58)
	contentContainer.BackgroundColor3 = Theme.Surface
	contentContainer.BackgroundTransparency = 0.35
	contentContainer.BorderSizePixel = 0
	contentContainer.Parent = main

	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = UDim.new(0, 6)
	contentCorner.Parent = contentContainer

	local contentStroke = Instance.new("UIStroke")
	contentStroke.Color = Theme.Border
	contentStroke.Thickness = 1
	contentStroke.Parent = contentContainer

	-- Notification Stack Center
	local notifContainer = Instance.new("Frame")
	notifContainer.Name = "Notifications"
	notifContainer.Size = UDim2.new(0, 340, 1, -50)
	notifContainer.Position = UDim2.new(1, -360, 0, 25)
	notifContainer.BackgroundTransparency = 1
	notifContainer.Parent = screenGui

	local notifLayout = Instance.new("UIListLayout")
	notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	notifLayout.Padding = UDim.new(0, 8)
	notifLayout.Parent = notifContainer

	-- Open / Close Toggle Controller
	local isVisible = true
	local function toggleVisibility()
		isVisible = not isVisible
		if isVisible then
			main.Visible = true
			tween(blurInstance, TWEEN_SMOOTH, { Size = 20 })
			tween(backdrop, TWEEN_SMOOTH, { BackgroundTransparency = 0.45 })
			tween(mainScale, TWEEN_BOUNCE, { Scale = 1 })
		else
			tween(blurInstance, TWEEN_FAST, { Size = 0 })
			tween(backdrop, TWEEN_FAST, { BackgroundTransparency = 1 })
			local anim = tween(mainScale, TWEEN_FAST, { Scale = 0.92 })
			anim.Completed:Connect(function()
				if not isVisible then main.Visible = false end
			end)
		end
	end

	minBtn.MouseButton1Click:Connect(toggleVisibility)
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == toggleKey then
			toggleVisibility()
		end
	end)

	local windowObj = {
		ScreenGui = screenGui,
		Main = main,
		Tabs = {},
		ActiveTab = nil,
		Blur = blurInstance
	}

	-- ==============================================================================
	-- [ NOTIFICATIONS 2.0 (TYPE-AWARE) ]
	-- ==============================================================================
	function windowObj:Notify(data)
		data = data or {}
		local nTitle = data.Title or "SYSTEM NOTICE"
		local nDesc = data.Description or ""
		local duration = data.Duration or 3.5
		local nType = data.Type or "Info" -- Info | Success | Warn | Error

		local accentMap = {
			Info = Theme.Accent,
			Success = Theme.Success,
			Warn = Theme.Warn,
			Error = Theme.Error
		}
		local notifColor = accentMap[nType] or Theme.Accent

		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 58)
		card.Position = UDim2.new(1, 350, 0, 0)
		card.BackgroundColor3 = Theme.Void
		card.BackgroundTransparency = 0.05
		card.BorderSizePixel = 0
		card.ClipsDescendants = true
		card.Parent = notifContainer

		local cCorner = Instance.new("UICorner")
		cCorner.CornerRadius = UDim.new(0, 6)
		cCorner.Parent = card

		local cStroke = Instance.new("UIStroke")
		cStroke.Color = Theme.Border
		cStroke.Thickness = 1
		cStroke.Parent = card

		local badge = Instance.new("Frame")
		badge.Size = UDim2.new(0, 3, 1, 0)
		badge.BackgroundColor3 = notifColor
		badge.BorderSizePixel = 0
		badge.Parent = card

		local tLabel = Instance.new("TextLabel")
		tLabel.Size = UDim2.new(1, -26, 0, 18)
		tLabel.Position = UDim2.new(0, 14, 0, 10)
		tLabel.BackgroundTransparency = 1
		tLabel.Text = string.upper(nTitle)
		tLabel.TextColor3 = Theme.Text
		tLabel.TextSize = 12
		tLabel.TextXAlignment = Enum.TextXAlignment.Left
		applyFont(tLabel, Enum.FontWeight.Bold)
		tLabel.Parent = card

		local dLabel = Instance.new("TextLabel")
		dLabel.Size = UDim2.new(1, -26, 0, 18)
		dLabel.Position = UDim2.new(0, 14, 0, 28)
		dLabel.BackgroundTransparency = 1
		dLabel.Text = nDesc
		dLabel.TextColor3 = Theme.TextMuted
		dLabel.TextSize = 11
		dLabel.TextXAlignment = Enum.TextXAlignment.Left
		applyFont(dLabel, Enum.FontWeight.Medium)
		dLabel.Parent = card

		local prog = Instance.new("Frame")
		prog.Size = UDim2.new(1, 0, 0, 2)
		prog.Position = UDim2.new(0, 0, 1, -2)
		prog.BackgroundColor3 = notifColor
		prog.BorderSizePixel = 0
		prog.Parent = card

		tween(card, TWEEN_BOUNCE, { Position = UDim2.new(0, 0, 0, 0) })
		local barAnim = tween(prog, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })

		card.MouseEnter:Connect(function()
			barAnim:Pause()
			tween(cStroke, TWEEN_SNAP, { Color = Theme.BorderHighlight })
		end)
		card.MouseLeave:Connect(function()
			barAnim:Play()
			tween(cStroke, TWEEN_SNAP, { Color = Theme.Border })
		end)

		barAnim.Completed:Connect(function()
			local out = tween(card, TWEEN_FAST, { Position = UDim2.new(1, 350, 0, 0), BackgroundTransparency = 1 })
			out.Completed:Connect(function() card:Destroy() end)
		end)
	end

	-- ==============================================================================
	-- [ TAB ARCHITECTURE ]
	-- ==============================================================================
	function windowObj:CreateTab(name)
		local tabBtn = Instance.new("TextButton")
		tabBtn.Size = UDim2.new(1, 0, 0, 36)
		tabBtn.BackgroundColor3 = Theme.Card
		tabBtn.BackgroundTransparency = 1
		tabBtn.BorderSizePixel = 0
		tabBtn.Text = "    " .. string.upper(name)
		tabBtn.TextColor3 = Theme.TextMuted
		tabBtn.TextSize = 12
		tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		tabBtn.AutoButtonColor = false
		applyFont(tabBtn, Enum.FontWeight.Medium)
		tabBtn.Parent = tabScroll

		local tabBtnCorner = Instance.new("UICorner")
		tabBtnCorner.CornerRadius = UDim.new(0, 5)
		tabBtnCorner.Parent = tabBtn

		local page = Instance.new("ScrollingFrame")
		page.Size = UDim2.new(1, -24, 1, -24)
		page.Position = UDim2.new(0, 12, 0, 12)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 2
		page.ScrollBarImageColor3 = Theme.BorderLight
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.Parent = contentContainer

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Padding = UDim.new(0, 8)
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Parent = page

		local tabData = {
			Button = tabBtn,
			Page = page
		}

		local function selectTab()
			for _, other in pairs(windowObj.Tabs) do
				if other ~= tabData and other.Page.Visible then
					local oldPage = other.Page
					local fade = tween(oldPage, TWEEN_FAST, { Position = UDim2.new(0, -10, 0, 12) })
					fade.Completed:Connect(function() oldPage.Visible = false end)
					tween(other.Button, TWEEN_FAST, {
						TextColor3 = Theme.TextMuted,
						BackgroundTransparency = 1
					})
				end
			end

			page.Visible = true
			page.Position = UDim2.new(0, 20, 0, 12)
			tween(page, TWEEN_SMOOTH, { Position = UDim2.new(0, 12, 0, 12) })
			tween(tabBtn, TWEEN_FAST, {
				TextColor3 = Theme.Text,
				BackgroundTransparency = 0.6
			})

			-- Корректный расчет координаты без багов скролла
			activePill.Visible = true
			local targetY = tabBtn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y
			tween(activePill, TWEEN_BOUNCE, {
				Position = UDim2.new(0, 5, 0, targetY + 8),
				Size = UDim2.new(0, 3, 0, 20)
			})

			windowObj.ActiveTab = tabData
		end

		tabBtn.MouseEnter:Connect(function()
			if windowObj.ActiveTab ~= tabData then
				tween(tabBtn, TWEEN_SNAP, { TextColor3 = Theme.Text, BackgroundTransparency = 0.85 })
			end
		end)
		tabBtn.MouseLeave:Connect(function()
			if windowObj.ActiveTab ~= tabData then
				tween(tabBtn, TWEEN_SNAP, { TextColor3 = Theme.TextMuted, BackgroundTransparency = 1 })
			end
		end)
		tabBtn.MouseButton1Click:Connect(selectTab)

		if not windowObj.ActiveTab then
			selectTab()
		end

		table.insert(windowObj.Tabs, tabData)

		local elements = {}

		-- ==========================================================================
		-- [ 1. SECTION HEADER ]
		-- ==========================================================================
		function elements:CreateSection(text)
			local sec = Instance.new("Frame")
			sec.Size = UDim2.new(1, 0, 0, 28)
			sec.BackgroundTransparency = 1
			sec.Parent = page

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = "// " .. string.upper(text)
			label.TextColor3 = Theme.AccentDim
			label.TextSize = 11
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Bold)
			label.Parent = sec

			local line = Instance.new("Frame")
			line.Size = UDim2.new(1, -(label.TextBounds.X + 24), 0, 1)
			line.Position = UDim2.new(0, label.TextBounds.X + 20, 0.5, 0)
			line.BackgroundColor3 = Theme.Border
			line.BorderSizePixel = 0
			line.Parent = sec
		end

		-- ==========================================================================
		-- [ 2. BUTTON ]
		-- ==========================================================================
		function elements:CreateButton(text, callback)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 40)
			btn.BackgroundColor3 = Theme.Card
			btn.BorderSizePixel = 0
			btn.AutoButtonColor = false
			btn.Text = ""
			btn.Parent = page

			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 5)
			bCorner.Parent = btn

			local bStroke = Instance.new("UIStroke")
			bStroke.Color = Theme.Border
			bStroke.Thickness = 1
			bStroke.Parent = btn

			local bLabel = Instance.new("TextLabel")
			bLabel.Size = UDim2.new(1, -24, 1, 0)
			bLabel.Position = UDim2.new(0, 14, 0, 0)
			bLabel.BackgroundTransparency = 1
			bLabel.Text = string.upper(text)
			bLabel.TextColor3 = Theme.Text
			bLabel.TextSize = 12
			bLabel.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(bLabel, Enum.FontWeight.Medium)
			bLabel.Parent = btn

			local iconArrow = Instance.new("TextLabel")
			iconArrow.Size = UDim2.new(0, 20, 1, 0)
			iconArrow.Position = UDim2.new(1, -30, 0, 0)
			iconArrow.BackgroundTransparency = 1
			iconArrow.Text = "→"
			iconArrow.TextColor3 = Theme.TextMuted
			iconArrow.TextSize = 13
			applyFont(iconArrow, Enum.FontWeight.Bold)
			iconArrow.Parent = btn

			btn.MouseEnter:Connect(function()
				tween(btn, TWEEN_SNAP, { BackgroundColor3 = Theme.CardHover })
				tween(bStroke, TWEEN_SNAP, { Color = Theme.BorderLight })
				tween(iconArrow, TWEEN_SNAP, { Position = UDim2.new(1, -26, 0, 0), TextColor3 = Theme.Text })
			end)
			btn.MouseLeave:Connect(function()
				tween(btn, TWEEN_SNAP, { BackgroundColor3 = Theme.Card })
				tween(bStroke, TWEEN_SNAP, { Color = Theme.Border })
				tween(iconArrow, TWEEN_SNAP, { Position = UDim2.new(1, -30, 0, 0), TextColor3 = Theme.TextMuted })
			end)
			btn.MouseButton1Down:Connect(function()
				tween(btn, TWEEN_SNAP, { BackgroundColor3 = Theme.CardActive })
			end)
			btn.MouseButton1Up:Connect(function()
				tween(btn, TWEEN_SNAP, { BackgroundColor3 = Theme.CardHover })
			end)
			btn.MouseButton1Click:Connect(function()
				if callback then callback() end
			end)

			return {
				SetText = function(nt) bLabel.Text = string.upper(nt) end
			}
		end

		-- ==========================================================================
		-- [ 3. TOGGLE ]
		-- ==========================================================================
		function elements:CreateToggle(text, defaultState, callback)
			local state = defaultState or false

			local frame = Instance.new("TextButton")
			frame.Size = UDim2.new(1, 0, 0, 40)
			frame.BackgroundColor3 = Theme.Card
			frame.BorderSizePixel = 0
			frame.AutoButtonColor = false
			frame.Text = ""
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 5)
			fCorner.Parent = frame

			local fStroke = Instance.new("UIStroke")
			fStroke.Color = Theme.Border
			fStroke.Thickness = 1
			fStroke.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -70, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = frame

			local switch = Instance.new("Frame")
			switch.Size = UDim2.new(0, 40, 0, 20)
			switch.Position = UDim2.new(1, -54, 0.5, -10)
			switch.BackgroundColor3 = state and Theme.Accent or Theme.Void
			switch.BorderSizePixel = 0
			switch.Parent = frame

			local swCorner = Instance.new("UICorner")
			swCorner.CornerRadius = UDim.new(1, 0)
			swCorner.Parent = switch

			local swStroke = Instance.new("UIStroke")
			swStroke.Color = state and Theme.BorderHighlight or Theme.BorderLight
			swStroke.Thickness = 1
			swStroke.Parent = switch

			local thumb = Instance.new("Frame")
			thumb.Size = UDim2.new(0, 14, 0, 14)
			thumb.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
			thumb.BackgroundColor3 = state and Theme.Void or Theme.TextMuted
			thumb.BorderSizePixel = 0
			thumb.Parent = switch

			local thCorner = Instance.new("UICorner")
			thCorner.CornerRadius = UDim.new(1, 0)
			thCorner.Parent = thumb

			local function set(val)
				state = val
				if state then
					tween(switch, TWEEN_FAST, { BackgroundColor3 = Theme.Accent })
					tween(swStroke, TWEEN_FAST, { Color = Theme.BorderHighlight })
					tween(thumb, TWEEN_FAST, { Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = Theme.Void })
				else
					tween(switch, TWEEN_FAST, { BackgroundColor3 = Theme.Void })
					tween(swStroke, TWEEN_FAST, { Color = Theme.BorderLight })
					tween(thumb, TWEEN_FAST, { Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.TextMuted })
				end
				if callback then callback(state) end
			end

			frame.MouseEnter:Connect(function()
				tween(frame, TWEEN_SNAP, { BackgroundColor3 = Theme.CardHover })
				tween(fStroke, TWEEN_SNAP, { Color = Theme.BorderLight })
			end)
			frame.MouseLeave:Connect(function()
				tween(frame, TWEEN_SNAP, { BackgroundColor3 = Theme.Card })
				tween(fStroke, TWEEN_SNAP, { Color = Theme.Border })
			end)
			frame.MouseButton1Click:Connect(function() set(not state) end)

			return {
				Set = set,
				GetValue = function() return state end
			}
		end

		-- ==========================================================================
		-- [ 4. SLIDER (MANUAL INPUT + FLOAT PRECISION) ]
		-- ==========================================================================
		function elements:CreateSlider(text, min, max, defaultVal, step, callback)
			min = min or 0
			max = max or 100
			step = step or 1
			local value = math.clamp(defaultVal or min, min, max)

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 54)
			frame.BackgroundColor3 = Theme.Card
			frame.BorderSizePixel = 0
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 5)
			fCorner.Parent = frame

			local fStroke = Instance.new("UIStroke")
			fStroke.Color = Theme.Border
			fStroke.Thickness = 1
			fStroke.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.6, 0, 0, 24)
			label.Position = UDim2.new(0, 14, 0, 6)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = frame

			-- Интерактивный TextBox вместо мертвого Label
			local inputVal = Instance.new("TextBox")
			inputVal.Size = UDim2.new(0.35, -14, 0, 20)
			inputVal.Position = UDim2.new(0.65, 0, 0, 8)
			inputVal.BackgroundTransparency = 1
			inputVal.Text = tostring(value)
			inputVal.TextColor3 = Theme.TextMuted
			inputVal.TextSize = 12
			inputVal.TextXAlignment = Enum.TextXAlignment.Right
			inputVal.ClearTextOnFocus = false
			applyFont(inputVal, Enum.FontWeight.Bold)
			inputVal.Parent = frame

			local track = Instance.new("TextButton")
			track.Size = UDim2.new(1, -28, 0, 5)
			track.Position = UDim2.new(0, 14, 1, -14)
			track.BackgroundColor3 = Theme.Void
			track.BorderSizePixel = 0
			track.Text = ""
			track.AutoButtonColor = false
			track.Parent = frame

			local trCorner = Instance.new("UICorner")
			trCorner.CornerRadius = UDim.new(1, 0)
			trCorner.Parent = track

			local fill = Instance.new("Frame")
			fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
			fill.BackgroundColor3 = Theme.Accent
			fill.BorderSizePixel = 0
			fill.Parent = track

			local fillCorner = Instance.new("UICorner")
			fillCorner.CornerRadius = UDim.new(1, 0)
			fillCorner.Parent = fill

			local function updateSlider(newVal, emit)
				newVal = math.clamp(newVal, min, max)
				local factor = 1 / step
				newVal = math.floor(newVal * factor + 0.5) / factor
				value = newVal
				inputVal.Text = tostring(value)
				tween(fill, TWEEN_SNAP, { Size = UDim2.new((value - min) / (max - min), 0, 1, 0) })
				if emit and callback then callback(value) end
			end

			-- Глобальный скраббер мыши без потери фокуса
			local isDragging = false
			local moveConn, endConn

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					isDragging = true
					local function process(pos)
						local ratio = math.clamp((pos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
						updateSlider(min + (max - min) * ratio, true)
					end
					process(input.Position)

					if moveConn then moveConn:Disconnect() end
					if endConn then endConn:Disconnect() end

					moveConn = UserInputService.InputChanged:Connect(function(mInput)
						if isDragging and (mInput.UserInputType == Enum.UserInputType.MouseMovement or mInput.UserInputType == Enum.UserInputType.Touch) then
							process(mInput.Position)
						end
					end)

					endConn = UserInputService.InputEnded:Connect(function(eInput)
						if eInput.UserInputType == Enum.UserInputType.MouseButton1 or eInput.UserInputType == Enum.UserInputType.Touch then
							isDragging = false
							if moveConn then moveConn:Disconnect() moveConn = nil end
							if endConn then endConn:Disconnect() endConn = nil end
						end
					end)
				end
			end)

			inputVal.FocusLost:Connect(function()
				local n = tonumber(inputVal.Text)
				if n then updateSlider(n, true) else inputVal.Text = tostring(value) end
			end)

			return {
				SetValue = function(v) updateSlider(v, true) end,
				GetValue = function() return value end
			}
		end

		-- ==========================================================================
		-- [ 5. DROPDOWN (SEARCHABLE + ZERO CLIPPING) ]
		-- ==========================================================================
		function elements:CreateDropdown(text, list, defaultIndex, callback)
			list = list or {}
			local current = list[defaultIndex or 1] or "SELECT..."
			local isOpen = false

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 42)
			frame.BackgroundColor3 = Theme.Card
			frame.BorderSizePixel = 0
			frame.ClipsDescendants = true
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 5)
			fCorner.Parent = frame

			local fStroke = Instance.new("UIStroke")
			fStroke.Color = Theme.Border
			fStroke.Thickness = 1
			fStroke.Parent = frame

			local headBtn = Instance.new("TextButton")
			headBtn.Size = UDim2.new(1, 0, 0, 42)
			headBtn.BackgroundTransparency = 1
			headBtn.Text = ""
			headBtn.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.5, 0, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = headBtn

			local valueDisplay = Instance.new("TextLabel")
			valueDisplay.Size = UDim2.new(0.5, -44, 1, 0)
			valueDisplay.Position = UDim2.new(0.5, 0, 0, 0)
			valueDisplay.BackgroundTransparency = 1
			valueDisplay.Text = string.upper(tostring(current))
			valueDisplay.TextColor3 = Theme.AccentDim
			valueDisplay.TextSize = 11
			valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
			applyFont(valueDisplay, Enum.FontWeight.Medium)
			valueDisplay.Parent = headBtn

			local arrow = Instance.new("TextLabel")
			arrow.Size = UDim2.new(0, 24, 1, 0)
			arrow.Position = UDim2.new(1, -30, 0, 0)
			arrow.BackgroundTransparency = 1
			arrow.Text = "↓"
			arrow.TextColor3 = Theme.TextMuted
			arrow.TextSize = 12
			applyFont(arrow, Enum.FontWeight.Bold)
			arrow.Parent = headBtn

			-- Search Box
			local searchBox = Instance.new("TextBox")
			searchBox.Size = UDim2.new(1, -28, 0, 28)
			searchBox.Position = UDim2.new(0, 14, 0, 48)
			searchBox.BackgroundColor3 = Theme.Void
			searchBox.BorderSizePixel = 0
			searchBox.PlaceholderText = "SEARCH ITEMS..."
			searchBox.PlaceholderColor3 = Theme.TextMuted
			searchBox.TextColor3 = Theme.Text
			searchBox.TextSize = 11
			applyFont(searchBox, Enum.FontWeight.Medium)
			searchBox.Parent = frame

			local sCorner = Instance.new("UICorner")
			sCorner.CornerRadius = UDim.new(0, 4)
			sCorner.Parent = searchBox

			local itemHolder = Instance.new("ScrollingFrame")
			itemHolder.Size = UDim2.new(1, -28, 0, 120)
			itemHolder.Position = UDim2.new(0, 14, 0, 82)
			itemHolder.BackgroundTransparency = 1
			itemHolder.BorderSizePixel = 0
			itemHolder.ScrollBarThickness = 2
			itemHolder.ScrollBarImageColor3 = Theme.BorderLight
			itemHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
			itemHolder.Parent = frame

			local listLayout = Instance.new("UIListLayout")
			listLayout.Padding = UDim.new(0, 3)
			listLayout.Parent = itemHolder

			local itemButtons = {}

			local function refreshView()
				local targetHeight = isOpen and 215 or 42
				tween(frame, TWEEN_SMOOTH, { Size = UDim2.new(1, 0, 0, targetHeight) })
				tween(arrow, TWEEN_FAST, { Rotation = isOpen and 180 or 0 })
			end

			headBtn.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				refreshView()
			end)

			local function renderItems(filter)
				for _, b in ipairs(itemButtons) do b:Destroy() end
				table.clear(itemButtons)

				filter = (filter or ""):lower()

				for _, opt in ipairs(list) do
					local str = tostring(opt)
					if filter == "" or str:lower():find(filter) then
						local b = Instance.new("TextButton")
						b.Size = UDim2.new(1, 0, 0, 28)
						b.BackgroundColor3 = (opt == current) and Theme.CardActive or Theme.Void
						b.BorderSizePixel = 0
						b.Text = "  " .. string.upper(str)
						b.TextColor3 = (opt == current) and Theme.Text or Theme.TextMuted
						b.TextSize = 11
						b.TextXAlignment = Enum.TextXAlignment.Left
						applyFont(b, Enum.FontWeight.Medium)
						b.Parent = itemHolder

						local bCorner = Instance.new("UICorner")
						bCorner.CornerRadius = UDim.new(0, 3)
						bCorner.Parent = b

						b.MouseButton1Click:Connect(function()
							current = opt
							valueDisplay.Text = string.upper(str)
							isOpen = false
							refreshView()
							if callback then callback(current) end
						end)

						table.insert(itemButtons, b)
					end
				end
			end

			searchBox:GetPropertyChangedSignal("Text"):Connect(function()
				renderItems(searchBox.Text)
			end)

			renderItems("")

			return {
				GetSelected = function() return current end,
				Refresh = function(newList)
					list = newList or {}
					renderItems("")
				end
			}
		end

		-- ==========================================================================
		-- [ 6. COLOR PICKER (HSV MATRIX + CLIPBOARD + ZERO LOSS DRAG) ]
		-- ==========================================================================
		function elements:CreateColorPicker(text, defaultColor, defaultAlpha, callback)
			local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)
			local currentAlpha = defaultAlpha or 1
			local curH, curS, curV = Color3.toHSV(currentColor)
			local isOpen = false

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 42)
			frame.BackgroundColor3 = Theme.Card
			frame.BorderSizePixel = 0
			frame.ClipsDescendants = true
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 5)
			fCorner.Parent = frame

			local fStroke = Instance.new("UIStroke")
			fStroke.Color = Theme.Border
			fStroke.Thickness = 1
			fStroke.Parent = frame

			local headBtn = Instance.new("TextButton")
			headBtn.Size = UDim2.new(1, 0, 0, 42)
			headBtn.BackgroundTransparency = 1
			headBtn.Text = ""
			headBtn.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.6, 0, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = headBtn

			local swatch = Instance.new("Frame")
			swatch.Size = UDim2.new(0, 36, 0, 20)
			swatch.Position = UDim2.new(1, -48, 0.5, -10)
			swatch.BackgroundColor3 = currentColor
			swatch.BorderSizePixel = 0
			swatch.Parent = headBtn

			local swCorner = Instance.new("UICorner")
			swCorner.CornerRadius = UDim.new(0, 4)
			swCorner.Parent = swatch

			local swStroke = Instance.new("UIStroke")
			swStroke.Color = Theme.BorderLight
			swStroke.Thickness = 1
			swStroke.Parent = swatch

			-- Canvas Area
			local pickerArea = Instance.new("Frame")
			pickerArea.Size = UDim2.new(1, -28, 0, 195)
			pickerArea.Position = UDim2.new(0, 14, 0, 48)
			pickerArea.BackgroundTransparency = 1
			pickerArea.Parent = frame

			local svBox = Instance.new("TextButton")
			svBox.Size = UDim2.new(1, 0, 0, 105)
			svBox.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
			svBox.BorderSizePixel = 0
			svBox.Text = ""
			svBox.AutoButtonColor = false
			svBox.Parent = pickerArea

			local svCorner = Instance.new("UICorner")
			svCorner.CornerRadius = UDim.new(0, 4)
			svCorner.Parent = svBox

			local satGradFrame = Instance.new("Frame")
			satGradFrame.Size = UDim2.new(1, 0, 1, 0)
			satGradFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			satGradFrame.BorderSizePixel = 0
			satGradFrame.Parent = svBox

			local satGrad = Instance.new("UIGradient")
			satGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
			satGrad.Parent = satGradFrame

			local valGradFrame = Instance.new("Frame")
			valGradFrame.Size = UDim2.new(1, 0, 1, 0)
			valGradFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			valGradFrame.BorderSizePixel = 0
			valGradFrame.Parent = svBox

			local valGrad = Instance.new("UIGradient")
			valGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
			valGrad.Rotation = 90
			valGrad.Parent = valGradFrame

			local svCursor = Instance.new("Frame")
			svCursor.Size = UDim2.new(0, 10, 0, 10)
			svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
			svCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
			svCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			svCursor.BorderSizePixel = 0
			svCursor.Parent = svBox

			local curStroke = Instance.new("UIStroke")
			curStroke.Color = Color3.fromRGB(0, 0, 0)
			curStroke.Thickness = 1.5
			curStroke.Parent = svCursor

			-- Hue Bar
			local hueBar = Instance.new("TextButton")
			hueBar.Size = UDim2.new(1, 0, 0, 14)
			hueBar.Position = UDim2.new(0, 0, 0, 114)
			hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			hueBar.BorderSizePixel = 0
			hueBar.Text = ""
			hueBar.AutoButtonColor = false
			hueBar.Parent = pickerArea

			local hbCorner = Instance.new("UICorner")
			hbCorner.CornerRadius = UDim.new(1, 0)
			hbCorner.Parent = hueBar

			local hueGrad = Instance.new("UIGradient")
			hueGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
			})
			hueGrad.Parent = hueBar

			local hueThumb = Instance.new("Frame")
			hueThumb.Size = UDim2.new(0, 8, 1, 4)
			hueThumb.AnchorPoint = Vector2.new(0.5, 0.5)
			hueThumb.Position = UDim2.new(curH, 0, 0.5, 0)
			hueThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			hueThumb.BorderSizePixel = 0
			hueThumb.Parent = hueBar

			local htStroke = Instance.new("UIStroke")
			htStroke.Color = Color3.fromRGB(0, 0, 0)
			htStroke.Thickness = 1.5
			htStroke.Parent = hueThumb

			-- Alpha Bar
			local alphaBar = Instance.new("TextButton")
			alphaBar.Size = UDim2.new(1, 0, 0, 14)
			alphaBar.Position = UDim2.new(0, 0, 0, 136)
			alphaBar.BackgroundColor3 = Theme.Void
			alphaBar.BorderSizePixel = 0
			alphaBar.Text = ""
			alphaBar.AutoButtonColor = false
			alphaBar.Parent = pickerArea

			local abCorner = Instance.new("UICorner")
			abCorner.CornerRadius = UDim.new(1, 0)
			abCorner.Parent = alphaBar

			local alphaFill = Instance.new("Frame")
			alphaFill.Size = UDim2.new(1, 0, 1, 0)
			alphaFill.BackgroundColor3 = currentColor
			alphaFill.BorderSizePixel = 0
			alphaFill.Parent = alphaBar

			local afGrad = Instance.new("UIGradient")
			afGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
			afGrad.Parent = alphaFill

			local alphaThumb = Instance.new("Frame")
			alphaThumb.Size = UDim2.new(0, 8, 1, 4)
			alphaThumb.AnchorPoint = Vector2.new(0.5, 0.5)
			alphaThumb.Position = UDim2.new(currentAlpha, 0, 0.5, 0)
			alphaThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			alphaThumb.BorderSizePixel = 0
			alphaThumb.Parent = alphaBar

			local atStroke = Instance.new("UIStroke")
			atStroke.Color = Color3.fromRGB(0, 0, 0)
			atStroke.Thickness = 1.5
			atStroke.Parent = alphaThumb

			-- Readout Row
			local infoBar = Instance.new("Frame")
			infoBar.Size = UDim2.new(1, 0, 0, 26)
			infoBar.Position = UDim2.new(0, 0, 0, 158)
			infoBar.BackgroundTransparency = 1
			infoBar.Parent = pickerArea

			local hexBox = Instance.new("TextBox")
			hexBox.Size = UDim2.new(0.45, 0, 1, 0)
			hexBox.BackgroundColor3 = Theme.Void
			hexBox.BorderSizePixel = 0
			hexBox.TextColor3 = Theme.Text
			hexBox.TextSize = 11
			hexBox.ClearTextOnFocus = false
			applyFont(hexBox, Enum.FontWeight.Medium)
			hexBox.Parent = infoBar

			local hexCorner = Instance.new("UICorner")
			hexCorner.CornerRadius = UDim.new(0, 4)
			hexCorner.Parent = hexBox

			local hexStroke = Instance.new("UIStroke")
			hexStroke.Color = Theme.Border
			hexStroke.Thickness = 1
			hexStroke.Parent = hexBox

			local copyBtn = Instance.new("TextButton")
			copyBtn.Size = UDim2.new(0.2, 0, 1, 0)
			copyBtn.Position = UDim2.new(0.48, 0, 0, 0)
			copyBtn.BackgroundColor3 = Theme.CardActive
			copyBtn.BorderSizePixel = 0
			copyBtn.Text = "COPY"
			copyBtn.TextColor3 = Theme.Text
			copyBtn.TextSize = 10
			applyFont(copyBtn, Enum.FontWeight.Bold)
			copyBtn.Parent = infoBar

			local copyCorner = Instance.new("UICorner")
			copyCorner.CornerRadius = UDim.new(0, 4)
			copyCorner.Parent = copyBtn

			local rgbaDisplay = Instance.new("TextLabel")
			rgbaDisplay.Size = UDim2.new(0.32, 0, 1, 0)
			rgbaDisplay.Position = UDim2.new(0.68, 0, 0, 0)
			rgbaDisplay.BackgroundTransparency = 1
			rgbaDisplay.TextColor3 = Theme.TextMuted
			rgbaDisplay.TextSize = 10
			rgbaDisplay.TextXAlignment = Enum.TextXAlignment.Right
			applyFont(rgbaDisplay, Enum.FontWeight.Medium)
			rgbaDisplay.Parent = infoBar

			local function emitChange()
				currentColor = Color3.fromHSV(curH, curS, curV)
				svBox.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
				alphaFill.BackgroundColor3 = currentColor
				swatch.BackgroundColor3 = currentColor
				swatch.BackgroundTransparency = 1 - currentAlpha

				local rInt = math.floor(currentColor.R * 255 + 0.5)
				local gInt = math.floor(currentColor.G * 255 + 0.5)
				local bInt = math.floor(currentColor.B * 255 + 0.5)
				local hex = string.format("#%02X%02X%02X", rInt, gInt, bInt)
				hexBox.Text = hex
				rgbaDisplay.Text = string.format("%d,%d,%d", rInt, gInt, bInt)

				if callback then callback(currentColor, currentAlpha, hex) end
			end

			-- Safe Global Dragging Engine for Color Matrix
			local function attachScrubber(sensor, onMove)
				local active = false
				local mConn, eConn

				sensor.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						active = true
						onMove(input.Position)

						if mConn then mConn:Disconnect() end
						if eConn then eConn:Disconnect() end

						mConn = UserInputService.InputChanged:Connect(function(mInput)
							if active and (mInput.UserInputType == Enum.UserInputType.MouseMovement or mInput.UserInputType == Enum.UserInputType.Touch) then
								onMove(mInput.Position)
							end
						end)

						eConn = UserInputService.InputEnded:Connect(function(eInput)
							if eInput.UserInputType == Enum.UserInputType.MouseButton1 or eInput.UserInputType == Enum.UserInputType.Touch then
								active = false
								if mConn then mConn:Disconnect() mConn = nil end
								if eConn then eConn:Disconnect() eConn = nil end
							end
						end)
					end
				end)
			end

			attachScrubber(svBox, function(pos)
				curS = math.clamp((pos.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
				curV = 1 - math.clamp((pos.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
				svCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
				emitChange()
			end)

			attachScrubber(hueBar, function(pos)
				curH = math.clamp((pos.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
				hueThumb.Position = UDim2.new(curH, 0, 0.5, 0)
				emitChange()
			end)

			attachScrubber(alphaBar, function(pos)
				currentAlpha = math.clamp((pos.X - alphaBar.AbsolutePosition.X) / alphaBar.AbsoluteSize.X, 0, 1)
				alphaThumb.Position = UDim2.new(currentAlpha, 0, 0.5, 0)
				emitChange()
			end)

			copyBtn.MouseButton1Click:Connect(function()
				if setclipboard then
					pcall(setclipboard, hexBox.Text)
					windowObj:Notify({ Title = "COLOR COPIED", Description = hexBox.Text, Type = "Success" })
				end
			end)

			hexBox.FocusLost:Connect(function()
				local clean = hexBox.Text:gsub("#", "")
				local num = tonumber(clean, 16)
				if num and #clean == 6 then
					local r = math.floor(num / 65536) % 256 / 255
					local g = math.floor(num / 256) % 256 / 255
					local b = num % 256 / 255
					currentColor = Color3.new(r, g, b)
					curH, curS, curV = Color3.toHSV(currentColor)
					svCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
					hueThumb.Position = UDim2.new(curH, 0, 0.5, 0)
				end
				emitChange()
			end)

			headBtn.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				local targetHeight = isOpen and 255 or 42
				tween(frame, TWEEN_SMOOTH, { Size = UDim2.new(1, 0, 0, targetHeight) })
			end)

			emitChange()

			return {
				SetColor = function(c, a)
					currentColor = c or currentColor
					currentAlpha = a or currentAlpha
					curH, curS, curV = Color3.toHSV(currentColor)
					svCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
					hueThumb.Position = UDim2.new(curH, 0, 0.5, 0)
					alphaThumb.Position = UDim2.new(currentAlpha, 0, 0.5, 0)
					emitChange()
				end,
				GetColor = function() return currentColor, currentAlpha end
			}
		end

		-- ==========================================================================
		-- [ 7. KEYBIND COMPONENT ]
		-- ==========================================================================
		function elements:CreateKeybind(text, defaultKey, callback)
			local boundKey = defaultKey or Enum.KeyCode.E
			local listening = false

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 40)
			frame.BackgroundColor3 = Theme.Card
			frame.BorderSizePixel = 0
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 5)
			fCorner.Parent = frame

			local fStroke = Instance.new("UIStroke")
			fStroke.Color = Theme.Border
			fStroke.Thickness = 1
			fStroke.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.6, 0, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = frame

			local bindBtn = Instance.new("TextButton")
			bindBtn.Size = UDim2.new(0, 80, 0, 24)
			bindBtn.Position = UDim2.new(1, -94, 0.5, -12)
			bindBtn.BackgroundColor3 = Theme.Void
			bindBtn.BorderSizePixel = 0
			bindBtn.Text = boundKey.Name
			bindBtn.TextColor3 = Theme.Accent
			bindBtn.TextSize = 11
			applyFont(bindBtn, Enum.FontWeight.Bold)
			bindBtn.Parent = frame

			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 4)
			bCorner.Parent = bindBtn

			local bStroke = Instance.new("UIStroke")
			bStroke.Color = Theme.Border
			bStroke.Thickness = 1
			bStroke.Parent = bindBtn

			bindBtn.MouseButton1Click:Connect(function()
				listening = true
				bindBtn.Text = "..."
				tween(bStroke, TWEEN_SNAP, { Color = Theme.BorderHighlight })
			end)

			UserInputService.InputBegan:Connect(function(input, processed)
				if listening and input.UserInputType == Enum.UserInputType.Keyboard then
					if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= Enum.KeyCode.Escape then
						boundKey = input.KeyCode
						bindBtn.Text = boundKey.Name
					end
					listening = false
					tween(bStroke, TWEEN_SNAP, { Color = Theme.Border })
				elseif not processed and input.KeyCode == boundKey then
					if callback then callback(boundKey) end
				end
			end)

			return {
				GetKey = function() return boundKey end,
				SetKey = function(key) boundKey = key bindBtn.Text = key.Name end
			}
		end

		-- ==========================================================================
		-- [ 8. TEXT INPUT ]
		-- ==========================================================================
		function elements:CreateInput(text, placeholder, callback)
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 40)
			frame.BackgroundColor3 = Theme.Card
			frame.BorderSizePixel = 0
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 5)
			fCorner.Parent = frame

			local fStroke = Instance.new("UIStroke")
			fStroke.Color = Theme.Border
			fStroke.Thickness = 1
			fStroke.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.4, 0, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = frame

			local box = Instance.new("TextBox")
			box.Size = UDim2.new(0.6, -24, 0, 26)
			box.Position = UDim2.new(0.4, 10, 0.5, -13)
			box.BackgroundColor3 = Theme.Void
			box.BorderSizePixel = 0
			box.Text = ""
			box.PlaceholderText = placeholder or "TYPE HERE..."
			box.TextColor3 = Theme.Text
			box.PlaceholderColor3 = Theme.TextMuted
			box.TextSize = 11
			box.ClearTextOnFocus = false
			applyFont(box, Enum.FontWeight.Medium)
			box.Parent = frame

			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 4)
			bCorner.Parent = box

			local bStroke = Instance.new("UIStroke")
			bStroke.Color = Theme.Border
			bStroke.Thickness = 1
			bStroke.Parent = box

			box.Focused:Connect(function()
				tween(bStroke, TWEEN_FAST, { Color = Theme.BorderHighlight })
			end)
			box.FocusLost:Connect(function(enter)
				tween(bStroke, TWEEN_FAST, { Color = Theme.Border })
				if callback then callback(box.Text, enter) end
			end)

			return {
				GetText = function() return box.Text end,
				SetText = function(str) box.Text = tostring(str) end
			}
		end

		-- ==========================================================================
		-- [ 9. PARAGRAPH (INFO CALLOUT CARD) ]
		-- ==========================================================================
		function elements:CreateParagraph(header, body)
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 60)
			frame.BackgroundColor3 = Theme.Card
			frame.BorderSizePixel = 0
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 5)
			fCorner.Parent = frame

			local fStroke = Instance.new("UIStroke")
			fStroke.Color = Theme.Border
			fStroke.Thickness = 1
			fStroke.Parent = frame

			local hLabel = Instance.new("TextLabel")
			hLabel.Size = UDim2.new(1, -28, 0, 18)
			hLabel.Position = UDim2.new(0, 14, 0, 10)
			hLabel.BackgroundTransparency = 1
			hLabel.Text = string.upper(header or "INFO")
			hLabel.TextColor3 = Theme.Text
			hLabel.TextSize = 11
			hLabel.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(hLabel, Enum.FontWeight.Bold)
			hLabel.Parent = frame

			local bLabel = Instance.new("TextLabel")
			bLabel.Size = UDim2.new(1, -28, 0, 24)
			bLabel.Position = UDim2.new(0, 14, 0, 28)
			bLabel.BackgroundTransparency = 1
			bLabel.Text = body or ""
			bLabel.TextColor3 = Theme.TextMuted
			bLabel.TextSize = 11
			bLabel.TextWrapped = true
			bLabel.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(bLabel, Enum.FontWeight.Medium)
			bLabel.Parent = frame

			return {
				SetText = function(nh, nb)
					hLabel.Text = string.upper(nh or hLabel.Text)
					bLabel.Text = nb or bLabel.Text
				end
			}
		end

		return elements
	end

	return windowObj
end

return LuxLib
