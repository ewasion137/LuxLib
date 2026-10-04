-- LuxLib: Brutalist acrylic UI engine with full-spectrum color picker and dynamic blur
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LuxLib = {}
LuxLib.__index = LuxLib

local TWEEN_SNAP = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_FAST = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_SMOOTH = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_BOUNCE = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local Theme = {
	Void = Color3.fromRGB(6, 6, 8),
	Surface = Color3.fromRGB(12, 12, 16),
	Element = Color3.fromRGB(18, 18, 24),
	ElementHover = Color3.fromRGB(26, 26, 34),
	ElementActive = Color3.fromRGB(32, 32, 42),
	Border = Color3.fromRGB(36, 36, 46),
	BorderLight = Color3.fromRGB(70, 70, 88),
	BorderHighlight = Color3.fromRGB(255, 255, 255),
	Text = Color3.fromRGB(245, 245, 250),
	TextMuted = Color3.fromRGB(125, 125, 140),
	Accent = Color3.fromRGB(255, 255, 255),
	AccentDim = Color3.fromRGB(180, 180, 195)
}

local function getGuiHost()
	local ok, target = pcall(function()
		return CoreGui
	end)
	if ok and target then
		return target
	end
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

local function makeDraggable(dragHandle, targetFrame)
	local dragging = false
	local dragInput, mousePos, framePos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			mousePos = input.Position
			framePos = targetFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			tween(targetFrame, TWEEN_SNAP, {
				Position = UDim2.new(
					framePos.X.Scale,
					framePos.X.Offset + delta.X,
					framePos.Y.Scale,
					framePos.Y.Offset + delta.Y
				)
			})
		end
	end)
end

function LuxLib:CreateWindow(config)
	config = config or {}
	local titleText = config.Title or "LUX // SYSTEM"
	local subText = config.Subtitle or "BRUTAL INTERFACE"
	local size = config.Size or UDim2.new(0, 720, 0, 480)
	local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LuxLib_" .. math.random(1000, 9999)
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = getGuiHost()

	local blurInstance = Lighting:FindFirstChild("LuxLib_Blur")
	if not blurInstance then
		blurInstance = Instance.new("BlurEffect")
		blurInstance.Name = "LuxLib_Blur"
		blurInstance.Size = 0
		blurInstance.Parent = Lighting
	end
	tween(blurInstance, TWEEN_SMOOTH, { Size = 24 })

	local backdrop = Instance.new("TextButton")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.new(1, 0, 1, 0)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 1
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.Parent = screenGui
	tween(backdrop, TWEEN_SMOOTH, { BackgroundTransparency = 0.5 })

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = size
	main.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
	main.BackgroundColor3 = Theme.Void
	main.BackgroundTransparency = 0.15
	main.BorderSizePixel = 0
	main.ClipsDescendants = false
	main.Parent = screenGui

	local mainScale = Instance.new("UIScale")
	mainScale.Scale = 0.95
	mainScale.Parent = main
	tween(mainScale, TWEEN_BOUNCE, { Scale = 1 })

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 6)
	mainCorner.Parent = main

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Theme.Border
	mainStroke.Thickness = 1.2
	mainStroke.Parent = main

	local strokeGradient = Instance.new("UIGradient")
	strokeGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(80, 80, 100)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 40))
	})
	strokeGradient.Rotation = 45
	strokeGradient.Parent = mainStroke

	local glassSheen = Instance.new("Frame")
	glassSheen.Name = "Sheen"
	glassSheen.Size = UDim2.new(1, 0, 0, 120)
	glassSheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	glassSheen.BackgroundTransparency = 1
	glassSheen.BorderSizePixel = 0
	glassSheen.Parent = main

	local sheenCorner = Instance.new("UICorner")
	sheenCorner.CornerRadius = UDim.new(0, 6)
	sheenCorner.Parent = glassSheen

	local sheenGradient = Instance.new("UIGradient")
	sheenGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	sheenGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.95),
		NumberSequenceKeypoint.new(1, 1)
	})
	sheenGradient.Rotation = 90
	sheenGradient.Parent = glassSheen

	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.Size = UDim2.new(1, 0, 0, 50)
	topbar.BackgroundColor3 = Theme.Surface
	topbar.BackgroundTransparency = 0.3
	topbar.BorderSizePixel = 0
	topbar.Parent = main

	local topbarCorner = Instance.new("UICorner")
	topbarCorner.CornerRadius = UDim.new(0, 6)
	topbarCorner.Parent = topbar

	local topbarDivider = Instance.new("Frame")
	topbarDivider.Size = UDim2.new(1, 0, 0, 1)
	topbarDivider.Position = UDim2.new(0, 0, 1, -1)
	topbarDivider.BackgroundColor3 = Theme.Border
	topbarDivider.BorderSizePixel = 0
	topbarDivider.Parent = topbar

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0, 220, 1, 0)
	titleLabel.Position = UDim2.new(0, 18, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = string.upper(titleText)
	titleLabel.TextColor3 = Theme.Text
	titleLabel.TextSize = 13
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	applyFont(titleLabel, Enum.FontWeight.Bold)
	titleLabel.Parent = topbar

	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(0, 220, 1, 0)
	subLabel.Position = UDim2.new(0, 18 + titleLabel.TextBounds.X + 16, 0, 0)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = string.upper(subText)
	subLabel.TextColor3 = Theme.TextMuted
	subLabel.TextSize = 11
	subLabel.TextXAlignment = Enum.TextXAlignment.Left
	applyFont(subLabel, Enum.FontWeight.Medium)
	subLabel.Parent = topbar

	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 28, 0, 28)
	minBtn.Position = UDim2.new(1, -38, 0.5, -14)
	minBtn.BackgroundColor3 = Theme.Element
	minBtn.BorderSizePixel = 0
	minBtn.Text = "-"
	minBtn.TextColor3 = Theme.TextMuted
	minBtn.TextSize = 14
	applyFont(minBtn, Enum.FontWeight.Bold)
	minBtn.Parent = topbar

	local minCorner = Instance.new("UICorner")
	minCorner.CornerRadius = UDim.new(0, 4)
	minCorner.Parent = minBtn

	makeDraggable(topbar, main)

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 190, 1, -62)
	sidebar.Position = UDim2.new(0, 10, 0, 56)
	sidebar.BackgroundColor3 = Theme.Surface
	sidebar.BackgroundTransparency = 0.35
	sidebar.BorderSizePixel = 0
	sidebar.Parent = main

	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.CornerRadius = UDim.new(0, 5)
	sidebarCorner.Parent = sidebar

	local sidebarStroke = Instance.new("UIStroke")
	sidebarStroke.Color = Theme.Border
	sidebarStroke.Thickness = 1
	sidebarStroke.Parent = sidebar

	local activePill = Instance.new("Frame")
	activePill.Name = "ActivePill"
	activePill.Size = UDim2.new(0, 3, 0, 20)
	activePill.Position = UDim2.new(0, 6, 0, 0)
	activePill.BackgroundColor3 = Theme.Accent
	activePill.BorderSizePixel = 0
	activePill.Visible = false
	activePill.ZIndex = 5
	activePill.Parent = sidebar

	local activePillCorner = Instance.new("UICorner")
	activePillCorner.CornerRadius = UDim.new(1, 0)
	activePillCorner.Parent = activePill

	local tabScroll = Instance.new("ScrollingFrame")
	tabScroll.Size = UDim2.new(1, -12, 1, -12)
	tabScroll.Position = UDim2.new(0, 6, 0, 6)
	tabScroll.BackgroundTransparency = 1
	tabScroll.BorderSizePixel = 0
	tabScroll.ScrollBarThickness = 0
	tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabScroll.Parent = sidebar

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabScroll

	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "ContentContainer"
	contentContainer.Size = UDim2.new(1, -220, 1, -62)
	contentContainer.Position = UDim2.new(0, 210, 0, 56)
	contentContainer.BackgroundColor3 = Theme.Surface
	contentContainer.BackgroundTransparency = 0.35
	contentContainer.BorderSizePixel = 0
	contentContainer.Parent = main

	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = UDim.new(0, 5)
	contentCorner.Parent = contentContainer

	local contentStroke = Instance.new("UIStroke")
	contentStroke.Color = Theme.Border
	contentStroke.Thickness = 1
	contentStroke.Parent = contentContainer

	local notifContainer = Instance.new("Frame")
	notifContainer.Name = "Notifications"
	notifContainer.Size = UDim2.new(0, 320, 1, -40)
	notifContainer.Position = UDim2.new(0.5, -160, 0, 20)
	notifContainer.BackgroundTransparency = 1
	notifContainer.Parent = screenGui

	local notifLayout = Instance.new("UIListLayout")
	notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	notifLayout.Padding = UDim.new(0, 8)
	notifLayout.Parent = notifContainer

	local isVisible = true
	local function toggleVisibility()
		isVisible = not isVisible
		if isVisible then
			main.Visible = true
			tween(blurInstance, TWEEN_SMOOTH, { Size = 24 })
			tween(backdrop, TWEEN_SMOOTH, { BackgroundTransparency = 0.5 })
			tween(mainScale, TWEEN_BOUNCE, { Scale = 1 })
		else
			tween(blurInstance, TWEEN_FAST, { Size = 0 })
			tween(backdrop, TWEEN_FAST, { BackgroundTransparency = 1 })
			local anim = tween(mainScale, TWEEN_FAST, { Scale = 0.92 })
			anim.Completed:Connect(function()
				if not isVisible then
					main.Visible = false
				end
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

	function windowObj:Notify(data)
		data = data or {}
		local nTitle = data.Title or "NOTIFICATION"
		local nDesc = data.Description or ""
		local duration = data.Duration or 3.5

		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 56)
		card.Position = UDim2.new(0, 0, 1, 40)
		card.BackgroundColor3 = Theme.Void
		card.BackgroundTransparency = 0.1
		card.BorderSizePixel = 0
		card.ClipsDescendants = true
		card.Parent = notifContainer

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 5)
		cardCorner.Parent = card

		local cardStroke = Instance.new("UIStroke")
		cardStroke.Color = Theme.BorderLight
		cardStroke.Thickness = 1
		cardStroke.Parent = card

		local titleTxt = Instance.new("TextLabel")
		titleTxt.Size = UDim2.new(1, -24, 0, 18)
		titleTxt.Position = UDim2.new(0, 14, 0, 9)
		titleTxt.BackgroundTransparency = 1
		titleTxt.Text = string.upper(nTitle)
		titleTxt.TextColor3 = Theme.Text
		titleTxt.TextSize = 12
		titleTxt.TextXAlignment = Enum.TextXAlignment.Left
		applyFont(titleTxt, Enum.FontWeight.Bold)
		titleTxt.Parent = card

		local descTxt = Instance.new("TextLabel")
		descTxt.Size = UDim2.new(1, -24, 0, 18)
		descTxt.Position = UDim2.new(0, 14, 0, 27)
		descTxt.BackgroundTransparency = 1
		descTxt.Text = nDesc
		descTxt.TextColor3 = Theme.TextMuted
		descTxt.TextSize = 11
		descTxt.TextXAlignment = Enum.TextXAlignment.Left
		applyFont(descTxt, Enum.FontWeight.Medium)
		descTxt.Parent = card

		local timerBar = Instance.new("Frame")
		timerBar.Size = UDim2.new(1, 0, 0, 2)
		timerBar.Position = UDim2.new(0, 0, 1, -2)
		timerBar.BackgroundColor3 = Theme.Accent
		timerBar.BorderSizePixel = 0
		timerBar.Parent = card

		tween(card, TWEEN_BOUNCE, { Position = UDim2.new(0, 0, 0, 0) })
		local barAnim = tween(timerBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })

		card.MouseEnter:Connect(function()
			barAnim:Pause()
			tween(cardStroke, TWEEN_SNAP, { Color = Theme.BorderHighlight })
		end)
		card.MouseLeave:Connect(function()
			barAnim:Play()
			tween(cardStroke, TWEEN_SNAP, { Color = Theme.BorderLight })
		end)

		barAnim.Completed:Connect(function()
			local close = tween(card, TWEEN_FAST, {
				Position = UDim2.new(0, 0, 1, 40),
				BackgroundTransparency = 1
			})
			tween(cardStroke, TWEEN_FAST, { Transparency = 1 })
			tween(titleTxt, TWEEN_FAST, { TextTransparency = 1 })
			tween(descTxt, TWEEN_FAST, { TextTransparency = 1 })
			close.Completed:Connect(function()
				card:Destroy()
			end)
		end)
	end

	function windowObj:CreateTab(name)
		local tabBtn = Instance.new("TextButton")
		tabBtn.Size = UDim2.new(1, 0, 0, 36)
		tabBtn.BackgroundColor3 = Theme.Element
		tabBtn.BackgroundTransparency = 1
		tabBtn.BorderSizePixel = 0
		tabBtn.Text = "   " .. string.upper(name)
		tabBtn.TextColor3 = Theme.TextMuted
		tabBtn.TextSize = 12
		tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		tabBtn.AutoButtonColor = false
		applyFont(tabBtn, Enum.FontWeight.Medium)
		tabBtn.Parent = tabScroll

		local tabBtnCorner = Instance.new("UICorner")
		tabBtnCorner.CornerRadius = UDim.new(0, 4)
		tabBtnCorner.Parent = tabBtn

		local page = Instance.new("ScrollingFrame")
		page.Size = UDim2.new(1, -20, 1, -20)
		page.Position = UDim2.new(0, 10, 0, 10)
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
					local fade = tween(oldPage, TWEEN_FAST, { Position = UDim2.new(0, -10, 0, 10) })
					fade.Completed:Connect(function()
						oldPage.Visible = false
					end)
					tween(other.Button, TWEEN_FAST, {
						TextColor3 = Theme.TextMuted,
						BackgroundTransparency = 1
					})
				end
			end

			page.Visible = true
			page.Position = UDim2.new(0, 20, 0, 10)
			tween(page, TWEEN_SMOOTH, { Position = UDim2.new(0, 10, 0, 10) })
			tween(tabBtn, TWEEN_FAST, {
				TextColor3 = Theme.Text,
				BackgroundTransparency = 0.5
			})

			activePill.Visible = true
			tween(activePill, TWEEN_BOUNCE, {
				Position = UDim2.new(0, 4, 0, tabBtn.Position.Y.Offset + (tabBtn.AbsolutePosition.Y - tabScroll.AbsolutePosition.Y) + 8)
			})
			windowObj.ActiveTab = tabData
		end

		tabBtn.MouseEnter:Connect(function()
			if windowObj.ActiveTab ~= tabData then
				tween(tabBtn, TWEEN_SNAP, {
					TextColor3 = Theme.Text,
					BackgroundTransparency = 0.8
				})
			end
		end)
		tabBtn.MouseLeave:Connect(function()
			if windowObj.ActiveTab ~= tabData then
				tween(tabBtn, TWEEN_SNAP, {
					TextColor3 = Theme.TextMuted,
					BackgroundTransparency = 1
				})
			end
		end)
		tabBtn.MouseButton1Click:Connect(selectTab)

		if not windowObj.ActiveTab then
			selectTab()
		end

		table.insert(windowObj.Tabs, tabData)

		local elements = {}

		function elements:CreateButton(text, callback)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 38)
			btn.BackgroundColor3 = Theme.Element
			btn.BorderSizePixel = 0
			btn.AutoButtonColor = false
			btn.Text = ""
			btn.Parent = page

			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 4)
			bCorner.Parent = btn

			local bStroke = Instance.new("UIStroke")
			bStroke.Color = Theme.Border
			bStroke.Thickness = 1
			bStroke.Parent = btn

			local bLabel = Instance.new("TextLabel")
			bLabel.Size = UDim2.new(1, -24, 1, 0)
			bLabel.Position = UDim2.new(0, 12, 0, 0)
			bLabel.BackgroundTransparency = 1
			bLabel.Text = string.upper(text)
			bLabel.TextColor3 = Theme.Text
			bLabel.TextSize = 12
			applyFont(bLabel, Enum.FontWeight.Medium)
			bLabel.Parent = btn

			btn.MouseEnter:Connect(function()
				tween(btn, TWEEN_SNAP, { BackgroundColor3 = Theme.ElementHover })
				tween(bStroke, TWEEN_SNAP, { Color = Theme.BorderLight })
				tween(bLabel, TWEEN_SNAP, { Position = UDim2.new(0, 16, 0, 0) })
			end)
			btn.MouseLeave:Connect(function()
				tween(btn, TWEEN_SNAP, { BackgroundColor3 = Theme.Element })
				tween(bStroke, TWEEN_SNAP, { Color = Theme.Border })
				tween(bLabel, TWEEN_SNAP, { Position = UDim2.new(0, 12, 0, 0) })
			end)
			btn.MouseButton1Down:Connect(function()
				tween(btn, TWEEN_SNAP, { BackgroundColor3 = Theme.ElementActive })
				tween(bLabel, TWEEN_SNAP, { TextColor3 = Theme.AccentDim })
			end)
			btn.MouseButton1Up:Connect(function()
				tween(btn, TWEEN_SNAP, { BackgroundColor3 = Theme.ElementHover })
				tween(bLabel, TWEEN_SNAP, { TextColor3 = Theme.Text })
			end)
			btn.MouseButton1Click:Connect(function()
				if callback then
					callback()
				end
			end)

			return btn
		end

		function elements:CreateToggle(text, defaultState, callback)
			local state = defaultState or false

			local frame = Instance.new("TextButton")
			frame.Size = UDim2.new(1, 0, 0, 38)
			frame.BackgroundColor3 = Theme.Element
			frame.BorderSizePixel = 0
			frame.AutoButtonColor = false
			frame.Text = ""
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 4)
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
			switch.Position = UDim2.new(1, -52, 0.5, -10)
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
					tween(thumb, TWEEN_SNAP, { Size = UDim2.new(0, 18, 0, 14) })
					local slide = tween(thumb, TWEEN_FAST, {
						Position = UDim2.new(1, -17, 0.5, -7),
						BackgroundColor3 = Theme.Void
					})
					slide.Completed:Connect(function()
						tween(thumb, TWEEN_SNAP, { Size = UDim2.new(0, 14, 0, 14) })
					end)
				else
					tween(switch, TWEEN_FAST, { BackgroundColor3 = Theme.Void })
					tween(swStroke, TWEEN_FAST, { Color = Theme.BorderLight })
					tween(thumb, TWEEN_SNAP, { Size = UDim2.new(0, 18, 0, 14) })
					local slide = tween(thumb, TWEEN_FAST, {
						Position = UDim2.new(0, 3, 0.5, -7),
						BackgroundColor3 = Theme.TextMuted
					})
					slide.Completed:Connect(function()
						tween(thumb, TWEEN_SNAP, { Size = UDim2.new(0, 14, 0, 14) })
					end)
				end
				if callback then
					callback(state)
				end
			end

			frame.MouseEnter:Connect(function()
				tween(frame, TWEEN_SNAP, { BackgroundColor3 = Theme.ElementHover })
				tween(fStroke, TWEEN_SNAP, { Color = Theme.BorderLight })
			end)
			frame.MouseLeave:Connect(function()
				tween(frame, TWEEN_SNAP, { BackgroundColor3 = Theme.Element })
				tween(fStroke, TWEEN_SNAP, { Color = Theme.Border })
			end)
			frame.MouseButton1Click:Connect(function()
				set(not state)
			end)

			return {
				Set = set,
				GetValue = function() return state end
			}
		end

		function elements:CreateSlider(text, min, max, defaultVal, step, callback)
			min = min or 0
			max = max or 100
			step = step or 1
			local value = math.clamp(defaultVal or min, min, max)

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 52)
			frame.BackgroundColor3 = Theme.Element
			frame.BorderSizePixel = 0
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 4)
			fCorner.Parent = frame

			local fStroke = Instance.new("UIStroke")
			fStroke.Color = Theme.Border
			fStroke.Thickness = 1
			fStroke.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.6, 0, 0, 22)
			label.Position = UDim2.new(0, 14, 0, 6)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = frame

			local readout = Instance.new("TextLabel")
			readout.Size = UDim2.new(0.4, -28, 0, 22)
			readout.Position = UDim2.new(0.6, 0, 0, 6)
			readout.BackgroundTransparency = 1
			readout.Text = tostring(value)
			readout.TextColor3 = Theme.TextMuted
			readout.TextSize = 12
			readout.TextXAlignment = Enum.TextXAlignment.Right
			applyFont(readout, Enum.FontWeight.Bold)
			readout.Parent = frame

			local track = Instance.new("TextButton")
			track.Size = UDim2.new(1, -28, 0, 4)
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
			local initRatio = (value - min) / (max - min)
			fill.Size = UDim2.new(initRatio, 0, 1, 0)
			fill.BackgroundColor3 = Theme.Accent
			fill.BorderSizePixel = 0
			fill.Parent = track

			local fillCorner = Instance.new("UICorner")
			fillCorner.CornerRadius = UDim.new(1, 0)
			fillCorner.Parent = fill

			local isDragging = false

			local function updateFromInput(input)
				local ratio = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				local raw = min + (max - min) * ratio
				local stepped = math.floor((raw / step) + 0.5) * step
				stepped = math.clamp(stepped, min, max)
				value = stepped
				readout.Text = tostring(value)
				tween(fill, TWEEN_SNAP, { Size = UDim2.new((value - min) / (max - min), 0, 1, 0) })
				if callback then
					callback(value)
				end
			end

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					isDragging = true
					tween(track, TWEEN_SNAP, { Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 1, -15) })
					tween(readout, TWEEN_SNAP, { TextColor3 = Theme.Text })
					updateFromInput(input)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if isDragging then
						isDragging = false
						tween(track, TWEEN_SNAP, { Size = UDim2.new(1, -28, 0, 4), Position = UDim2.new(0, 14, 1, -14) })
						tween(readout, TWEEN_SNAP, { TextColor3 = Theme.TextMuted })
					end
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateFromInput(input)
				end
			end)

			frame.MouseEnter:Connect(function()
				tween(fStroke, TWEEN_SNAP, { Color = Theme.BorderLight })
			end)
			frame.MouseLeave:Connect(function()
				tween(fStroke, TWEEN_SNAP, { Color = Theme.Border })
			end)

			return {
				SetValue = function(v)
					value = math.clamp(v, min, max)
					readout.Text = tostring(value)
					tween(fill, TWEEN_FAST, { Size = UDim2.new((value - min) / (max - min), 0, 1, 0) })
					if callback then
						callback(value)
					end
				end,
				GetValue = function() return value end
			}
		end

		function elements:CreateColorPicker(text, defaultColor, defaultAlpha, callback)
			local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)
			local currentAlpha = defaultAlpha or 1
			local curH, curS, curV = Color3.toHSV(currentColor)
			local isOpen = false

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 40)
			frame.BackgroundColor3 = Theme.Element
			frame.BorderSizePixel = 0
			frame.ClipsDescendants = true
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 4)
			fCorner.Parent = frame

			local fStroke = Instance.new("UIStroke")
			fStroke.Color = Theme.Border
			fStroke.Thickness = 1
			fStroke.Parent = frame

			local headBtn = Instance.new("TextButton")
			headBtn.Size = UDim2.new(1, 0, 0, 40)
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
			swatch.Size = UDim2.new(0, 32, 0, 18)
			swatch.Position = UDim2.new(1, -46, 0.5, -9)
			swatch.BackgroundColor3 = currentColor
			swatch.BorderSizePixel = 0
			swatch.Parent = headBtn

			local swCorner = Instance.new("UICorner")
			swCorner.CornerRadius = UDim.new(0, 3)
			swCorner.Parent = swatch

			local swStroke = Instance.new("UIStroke")
			swStroke.Color = Theme.BorderLight
			swStroke.Thickness = 1
			swStroke.Parent = swatch

			local pickerArea = Instance.new("Frame")
			pickerArea.Size = UDim2.new(1, -28, 0, 190)
			pickerArea.Position = UDim2.new(0, 14, 0, 46)
			pickerArea.BackgroundTransparency = 1
			pickerArea.Parent = frame

			local svBox = Instance.new("TextButton")
			svBox.Size = UDim2.new(1, 0, 0, 110)
			svBox.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
			svBox.BorderSizePixel = 0
			svBox.Text = ""
			svBox.AutoButtonColor = false
			svBox.ClipsDescendants = true
			svBox.Parent = pickerArea

			local svCorner = Instance.new("UICorner")
			svCorner.CornerRadius = UDim.new(0, 4)
			svCorner.Parent = svBox

			local satGradientFrame = Instance.new("Frame")
			satGradientFrame.Size = UDim2.new(1, 0, 1, 0)
			satGradientFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			satGradientFrame.BorderSizePixel = 0
			satGradientFrame.Parent = svBox

			local satGrad = Instance.new("UIGradient")
			satGrad.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1)
			})
			satGrad.Rotation = 0
			satGrad.Parent = satGradientFrame

			local valGradientFrame = Instance.new("Frame")
			valGradientFrame.Size = UDim2.new(1, 0, 1, 0)
			valGradientFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			valGradientFrame.BorderSizePixel = 0
			valGradientFrame.Parent = svBox

			local valGrad = Instance.new("UIGradient")
			valGrad.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0)
			})
			valGrad.Rotation = 90
			valGrad.Parent = valGradientFrame

			local svCursor = Instance.new("Frame")
			svCursor.Size = UDim2.new(0, 10, 0, 10)
			svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
			svCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
			svCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			svCursor.BorderSizePixel = 0
			svCursor.Parent = svBox

			local curCorner = Instance.new("UICorner")
			curCorner.CornerRadius = UDim.new(1, 0)
			curCorner.Parent = svCursor

			local curStroke = Instance.new("UIStroke")
			curStroke.Color = Color3.fromRGB(0, 0, 0)
			curStroke.Thickness = 1.5
			curStroke.Parent = svCursor

			local hueBar = Instance.new("TextButton")
			hueBar.Size = UDim2.new(1, 0, 0, 14)
			hueBar.Position = UDim2.new(0, 0, 0, 118)
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

			local htCorner = Instance.new("UICorner")
			htCorner.CornerRadius = UDim.new(1, 0)
			htCorner.Parent = hueThumb

			local htStroke = Instance.new("UIStroke")
			htStroke.Color = Color3.fromRGB(0, 0, 0)
			htStroke.Thickness = 1.5
			htStroke.Parent = hueThumb

			local alphaBar = Instance.new("TextButton")
			alphaBar.Size = UDim2.new(1, 0, 0, 14)
			alphaBar.Position = UDim2.new(0, 0, 0, 140)
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

			local afCorner = Instance.new("UICorner")
			afCorner.CornerRadius = UDim.new(1, 0)
			afCorner.Parent = alphaFill

			local alphaGrad = Instance.new("UIGradient")
			alphaGrad.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0)
			})
			alphaGrad.Parent = alphaFill

			local alphaThumb = Instance.new("Frame")
			alphaThumb.Size = UDim2.new(0, 8, 1, 4)
			alphaThumb.AnchorPoint = Vector2.new(0.5, 0.5)
			alphaThumb.Position = UDim2.new(currentAlpha, 0, 0.5, 0)
			alphaThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			alphaThumb.BorderSizePixel = 0
			alphaThumb.Parent = alphaBar

			local atCorner = Instance.new("UICorner")
			atCorner.CornerRadius = UDim.new(1, 0)
			atCorner.Parent = alphaThumb

			local atStroke = Instance.new("UIStroke")
			atStroke.Color = Color3.fromRGB(0, 0, 0)
			atStroke.Thickness = 1.5
			atStroke.Parent = alphaThumb

			local infoBar = Instance.new("Frame")
			infoBar.Size = UDim2.new(1, 0, 0, 24)
			infoBar.Position = UDim2.new(0, 0, 0, 162)
			infoBar.BackgroundTransparency = 1
			infoBar.Parent = pickerArea

			local hexBox = Instance.new("TextBox")
			hexBox.Size = UDim2.new(0.4, 0, 1, 0)
			hexBox.BackgroundColor3 = Theme.Void
			hexBox.BorderSizePixel = 0
			hexBox.TextColor3 = Theme.Text
			hexBox.TextSize = 11
			hexBox.ClearTextOnFocus = false
			applyFont(hexBox, Enum.FontWeight.Medium)
			hexBox.Parent = infoBar

			local hexCorner = Instance.new("UICorner")
			hexCorner.CornerRadius = UDim.new(0, 3)
			hexCorner.Parent = hexBox

			local hexStroke = Instance.new("UIStroke")
			hexStroke.Color = Theme.Border
			hexStroke.Thickness = 1
			hexStroke.Parent = hexBox

			local rgbaDisplay = Instance.new("TextLabel")
			rgbaDisplay.Size = UDim2.new(0.6, -10, 1, 0)
			rgbaDisplay.Position = UDim2.new(0.4, 10, 0, 0)
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
				rgbaDisplay.Text = string.format("R:%d G:%d B:%d A:%d%%", rInt, gInt, bInt, math.floor(currentAlpha * 100))

				if callback then
					callback(currentColor, currentAlpha, hex)
				end
			end

			local isDraggingSV = false
			local isDraggingHue = false
			local isDraggingAlpha = false

			local function updateSV(input)
				local relX = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
				local relY = math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
				curS = relX
				curV = 1 - relY
				svCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
				emitChange()
			end

			local function updateHue(input)
				curH = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
				hueThumb.Position = UDim2.new(curH, 0, 0.5, 0)
				emitChange()
			end

			local function updateAlpha(input)
				currentAlpha = math.clamp((input.Position.X - alphaBar.AbsolutePosition.X) / alphaBar.AbsoluteSize.X, 0, 1)
				alphaThumb.Position = UDim2.new(currentAlpha, 0, 0.5, 0)
				emitChange()
			end

			svBox.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					isDraggingSV = true
					updateSV(input)
				end
			end)

			hueBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					isDraggingHue = true
					updateHue(input)
				end
			end)

			alphaBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					isDraggingAlpha = true
					updateAlpha(input)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					isDraggingSV = false
					isDraggingHue = false
					isDraggingAlpha = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					if isDraggingSV then
						updateSV(input)
					elseif isDraggingHue then
						updateHue(input)
					elseif isDraggingAlpha then
						updateAlpha(input)
					end
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
					emitChange()
				else
					emitChange()
				end
			end)

			headBtn.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				local targetH = isOpen and 246 or 40
				tween(frame, TWEEN_SMOOTH, { Size = UDim2.new(1, 0, 0, targetH) })
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
				GetColor = function()
					return currentColor, currentAlpha
				end
			}
		end

		function elements:CreateDropdown(text, list, defaultIndex, callback)
			list = list or {}
			local current = list[defaultIndex or 1] or "SELECT..."
			local isOpen = false

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 38)
			frame.BackgroundColor3 = Theme.Element
			frame.BorderSizePixel = 0
			frame.ClipsDescendants = true
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 4)
			fCorner.Parent = frame

			local fStroke = Instance.new("UIStroke")
			fStroke.Color = Theme.Border
			fStroke.Thickness = 1
			fStroke.Parent = frame

			local headBtn = Instance.new("TextButton")
			headBtn.Size = UDim2.new(1, 0, 0, 38)
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
			valueDisplay.Size = UDim2.new(0.5, -42, 1, 0)
			valueDisplay.Position = UDim2.new(0.5, 0, 0, 0)
			valueDisplay.BackgroundTransparency = 1
			valueDisplay.Text = string.upper(tostring(current))
			valueDisplay.TextColor3 = Theme.TextMuted
			valueDisplay.TextSize = 12
			valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
			applyFont(valueDisplay, Enum.FontWeight.Medium)
			valueDisplay.Parent = headBtn

			local arrow = Instance.new("TextLabel")
			arrow.Size = UDim2.new(0, 24, 1, 0)
			arrow.Position = UDim2.new(1, -30, 0, 0)
			arrow.BackgroundTransparency = 1
			arrow.Text = "v"
			arrow.TextColor3 = Theme.TextMuted
			arrow.TextSize = 10
			applyFont(arrow, Enum.FontWeight.Bold)
			arrow.Parent = headBtn

			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, -20, 0, #list * 30)
			container.Position = UDim2.new(0, 10, 0, 42)
			container.BackgroundTransparency = 1
			container.Parent = frame

			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 3)
			layout.Parent = container

			local function toggle()
				isOpen = not isOpen
				local targetH = isOpen and (42 + (#list * 33) + 6) or 38
				tween(frame, TWEEN_SMOOTH, { Size = UDim2.new(1, 0, 0, targetH) })
				tween(arrow, TWEEN_FAST, { Rotation = isOpen and 180 or 0 })
			end

			headBtn.MouseButton1Click:Connect(toggle)

			for _, opt in ipairs(list) do
				local optBtn = Instance.new("TextButton")
				optBtn.Size = UDim2.new(1, 0, 0, 30)
				optBtn.BackgroundColor3 = Theme.Void
				optBtn.BorderSizePixel = 0
				optBtn.AutoButtonColor = false
				optBtn.Text = "   " .. string.upper(tostring(opt))
				optBtn.TextColor3 = (opt == current) and Theme.Accent or Theme.TextMuted
				optBtn.TextSize = 11
				optBtn.TextXAlignment = Enum.TextXAlignment.Left
				applyFont(optBtn, Enum.FontWeight.Medium)
				optBtn.Parent = container

				local optCorner = Instance.new("UICorner")
				optCorner.CornerRadius = UDim.new(0, 3)
				optCorner.Parent = optBtn

				optBtn.MouseEnter:Connect(function()
					tween(optBtn, TWEEN_SNAP, { BackgroundColor3 = Theme.ElementActive })
				end)
				optBtn.MouseLeave:Connect(function()
					tween(optBtn, TWEEN_SNAP, { BackgroundColor3 = Theme.Void })
				end)

				optBtn.MouseButton1Click:Connect(function()
					current = opt
					valueDisplay.Text = string.upper(tostring(current))
					for _, child in ipairs(container:GetChildren()) do
						if child:IsA("TextButton") then
							child.TextColor3 = Theme.TextMuted
						end
					end
					optBtn.TextColor3 = Theme.Accent
					toggle()
					if callback then
						callback(current)
					end
				end)
			end

			return {
				GetSelected = function() return current end
			}
		end

		function elements:CreateRadioGroup(text, options, defaultIndex, callback)
			options = options or {}
			local selected = options[defaultIndex or 1]

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 28 + (#options * 30))
			frame.BackgroundColor3 = Theme.Element
			frame.BorderSizePixel = 0
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 4)
			fCorner.Parent = frame

			local fStroke = Instance.new("UIStroke")
			fStroke.Color = Theme.Border
			fStroke.Thickness = 1
			fStroke.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -28, 0, 26)
			label.Position = UDim2.new(0, 14, 0, 4)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = frame

			local buttons = {}

			for i, opt in ipairs(options) do
				local optBtn = Instance.new("TextButton")
				optBtn.Size = UDim2.new(1, -28, 0, 26)
				optBtn.Position = UDim2.new(0, 14, 0, 28 + (i - 1) * 28)
				optBtn.BackgroundTransparency = 1
				optBtn.Text = ""
				optBtn.Parent = frame

				local ring = Instance.new("Frame")
				ring.Size = UDim2.new(0, 16, 0, 16)
				ring.Position = UDim2.new(0, 0, 0.5, -8)
				ring.BackgroundColor3 = Theme.Void
				ring.BorderSizePixel = 0
				ring.Parent = optBtn

				local rCorner = Instance.new("UICorner")
				rCorner.CornerRadius = UDim.new(1, 0)
				rCorner.Parent = ring

				local rStroke = Instance.new("UIStroke")
				rStroke.Color = (opt == selected) and Theme.BorderHighlight or Theme.BorderLight
				rStroke.Thickness = 1
				rStroke.Parent = ring

				local dot = Instance.new("Frame")
				dot.AnchorPoint = Vector2.new(0.5, 0.5)
				dot.Position = UDim2.new(0.5, 0, 0.5, 0)
				dot.Size = (opt == selected) and UDim2.new(0, 8, 0, 8) or UDim2.new(0, 0, 0, 0)
				dot.BackgroundColor3 = Theme.Accent
				dot.BorderSizePixel = 0
				dot.Parent = ring

				local dCorner = Instance.new("UICorner")
				dCorner.CornerRadius = UDim.new(1, 0)
				dCorner.Parent = dot

				local optLabel = Instance.new("TextLabel")
				optLabel.Size = UDim2.new(1, -26, 1, 0)
				optLabel.Position = UDim2.new(0, 26, 0, 0)
				optLabel.BackgroundTransparency = 1
				optLabel.Text = string.upper(tostring(opt))
				optLabel.TextColor3 = (opt == selected) and Theme.Text or Theme.TextMuted
				optLabel.TextSize = 11
				optLabel.TextXAlignment = Enum.TextXAlignment.Left
				applyFont(optLabel, Enum.FontWeight.Medium)
				optLabel.Parent = optBtn

				buttons[opt] = { Dot = dot, Label = optLabel, Stroke = rStroke }

				optBtn.MouseButton1Click:Connect(function()
					selected = opt
					for key, val in pairs(buttons) do
						if key == selected then
							tween(val.Dot, TWEEN_BOUNCE, { Size = UDim2.new(0, 8, 0, 8) })
							tween(val.Stroke, TWEEN_FAST, { Color = Theme.BorderHighlight })
							tween(val.Label, TWEEN_FAST, { TextColor3 = Theme.Text })
						else
							tween(val.Dot, TWEEN_FAST, { Size = UDim2.new(0, 0, 0, 0) })
							tween(val.Stroke, TWEEN_FAST, { Color = Theme.BorderLight })
							tween(val.Label, TWEEN_FAST, { TextColor3 = Theme.TextMuted })
						end
					end
					if callback then
						callback(selected)
					end
				end)
			end

			return {
				GetSelected = function() return selected end
			}
		end

		function elements:CreateInput(text, placeholder, callback)
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 38)
			frame.BackgroundColor3 = Theme.Element
			frame.BorderSizePixel = 0
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 4)
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
			box.PlaceholderText = placeholder or "ENTER TEXT..."
			box.TextColor3 = Theme.Text
			box.PlaceholderColor3 = Theme.TextMuted
			box.TextSize = 11
			box.ClearTextOnFocus = false
			applyFont(box, Enum.FontWeight.Medium)
			box.Parent = frame

			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 3)
			bCorner.Parent = box

			local bStroke = Instance.new("UIStroke")
			bStroke.Color = Theme.Border
			bStroke.Thickness = 1
			bStroke.Parent = box

			box.Focused:Connect(function()
				tween(bStroke, TWEEN_FAST, { Color = Theme.BorderHighlight })
				tween(box, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(4, 4, 6) })
			end)
			box.FocusLost:Connect(function(enterPressed)
				tween(bStroke, TWEEN_FAST, { Color = Theme.Border })
				tween(box, TWEEN_FAST, { BackgroundColor3 = Theme.Void })
				if callback then
					callback(box.Text, enterPressed)
				end
			end)

			return {
				GetText = function() return box.Text end,
				SetText = function(val) box.Text = tostring(val) end
			}
		end

		function elements:CreateContextMenu(text, actions)
			actions = actions or {}
			local isOpen = false

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 38)
			frame.BackgroundColor3 = Theme.Element
			frame.BorderSizePixel = 0
			frame.ClipsDescendants = true
			frame.Parent = page

			local fCorner = Instance.new("UICorner")
			fCorner.CornerRadius = UDim.new(0, 4)
			fCorner.Parent = frame

			local fStroke = Instance.new("UIStroke")
			fStroke.Color = Theme.Border
			fStroke.Thickness = 1
			fStroke.Parent = frame

			local headBtn = Instance.new("TextButton")
			headBtn.Size = UDim2.new(1, 0, 0, 38)
			headBtn.BackgroundTransparency = 1
			headBtn.Text = ""
			headBtn.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -50, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = headBtn

			local dots = Instance.new("TextLabel")
			dots.Size = UDim2.new(0, 30, 1, 0)
			dots.Position = UDim2.new(1, -38, 0, 0)
			dots.BackgroundTransparency = 1
			dots.Text = ":::"
			dots.TextColor3 = Theme.TextMuted
			dots.TextSize = 14
			applyFont(dots, Enum.FontWeight.Bold)
			dots.Parent = headBtn

			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, -24, 0, #actions * 28)
			container.Position = UDim2.new(0, 12, 0, 42)
			container.BackgroundTransparency = 1
			container.Parent = frame

			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 3)
			layout.Parent = container

			for _, act in ipairs(actions) do
				local actBtn = Instance.new("TextButton")
				actBtn.Size = UDim2.new(1, 0, 0, 26)
				actBtn.BackgroundColor3 = Theme.Void
				actBtn.BorderSizePixel = 0
				actBtn.Text = "   " .. string.upper(act.Name or "ACTION")
				actBtn.TextColor3 = Theme.TextMuted
				actBtn.TextSize = 11
				actBtn.TextXAlignment = Enum.TextXAlignment.Left
				applyFont(actBtn, Enum.FontWeight.Medium)
				actBtn.Parent = container

				local actCorner = Instance.new("UICorner")
				actCorner.CornerRadius = UDim.new(0, 3)
				actCorner.Parent = actBtn

				actBtn.MouseEnter:Connect(function()
					tween(actBtn, TWEEN_SNAP, { BackgroundColor3 = Theme.ElementHover, TextColor3 = Theme.Text })
				end)
				actBtn.MouseLeave:Connect(function()
					tween(actBtn, TWEEN_SNAP, { BackgroundColor3 = Theme.Void, TextColor3 = Theme.TextMuted })
				end)
				actBtn.MouseButton1Click:Connect(function()
					if act.Callback then
						act.Callback()
					end
				end)
			end

			headBtn.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				local targetH = isOpen and (44 + (#actions * 29) + 6) or 38
				tween(frame, TWEEN_SMOOTH, { Size = UDim2.new(1, 0, 0, targetH) })
			end)
		end

		return elements
	end

	return windowObj
end

return LuxLib
