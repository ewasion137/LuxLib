-- LuxLib: Brutalist acrylic UI engine for Roblox
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LuxLib = {}
LuxLib.__index = LuxLib

local TWEEN_FAST = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SMOOTH = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local Theme = {
	Void = Color3.fromRGB(8, 8, 10),
	Surface = Color3.fromRGB(14, 14, 18),
	Element = Color3.fromRGB(20, 20, 26),
	ElementHover = Color3.fromRGB(28, 28, 36),
	Border = Color3.fromRGB(38, 38, 48),
	BorderLight = Color3.fromRGB(60, 60, 75),
	Text = Color3.fromRGB(245, 245, 250),
	TextMuted = Color3.fromRGB(130, 130, 145),
	Accent = Color3.fromRGB(255, 255, 255),
	AccentGlow = Color3.fromRGB(59, 130, 246),
	Danger = Color3.fromRGB(244, 63, 94)
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
			targetFrame.Position = UDim2.new(
				framePos.X.Scale,
				framePos.X.Offset + delta.X,
				framePos.Y.Scale,
				framePos.Y.Offset + delta.Y
			)
		end
	end)
end

function LuxLib:CreateWindow(config)
	config = config or {}
	local titleText = config.Title or "LUX // BRUTAL"
	local subText = config.Subtitle or "SYSTEM INTERFACE"
	local size = config.Size or UDim2.new(0, 680, 0, 440)

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LuxLib_" .. math.random(1000, 9999)
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = getGuiHost()

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = size
	main.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
	main.BackgroundColor3 = Theme.Void
	main.BackgroundTransparency = 0.08
	main.BorderSizePixel = 0
	main.ClipsDescendants = false
	main.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = main

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Border
	stroke.Thickness = 1
	stroke.Parent = main

	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.Size = UDim2.new(1, 0, 0, 48)
	topbar.BackgroundColor3 = Theme.Surface
	topbar.BackgroundTransparency = 0.2
	topbar.BorderSizePixel = 0
	topbar.Parent = main

	local topbarCorner = Instance.new("UICorner")
	topbarCorner.CornerRadius = UDim.new(0, 4)
	topbarCorner.Parent = topbar

	local topbarStroke = Instance.new("UIStroke")
	topbarStroke.Color = Theme.Border
	topbarStroke.Thickness = 1
	topbarStroke.Parent = topbar

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(0, 200, 1, 0)
	title.Position = UDim2.new(0, 16, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = string.upper(titleText)
	title.TextColor3 = Theme.Text
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	applyFont(title, Enum.FontWeight.Bold)
	title.Parent = topbar

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Size = UDim2.new(0, 200, 1, 0)
	subtitle.Position = UDim2.new(0, 16 + title.TextBounds.X + 12, 0, 0)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = string.upper(subText)
	subtitle.TextColor3 = Theme.TextMuted
	subtitle.TextSize = 11
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	applyFont(subtitle, Enum.FontWeight.Medium)
	subtitle.Parent = topbar

	makeDraggable(topbar, main)

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 180, 1, -56)
	sidebar.Position = UDim2.new(0, 8, 0, 52)
	sidebar.BackgroundColor3 = Theme.Surface
	sidebar.BackgroundTransparency = 0.3
	sidebar.BorderSizePixel = 0
	sidebar.Parent = main

	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.CornerRadius = UDim.new(0, 4)
	sidebarCorner.Parent = sidebar

	local sidebarStroke = Instance.new("UIStroke")
	sidebarStroke.Color = Theme.Border
	sidebarStroke.Thickness = 1
	sidebarStroke.Parent = sidebar

	local tabScroll = Instance.new("ScrollingFrame")
	tabScroll.Name = "TabScroll"
	tabScroll.Size = UDim2.new(1, -12, 1, -12)
	tabScroll.Position = UDim2.new(0, 6, 0, 6)
	tabScroll.BackgroundTransparency = 1
	tabScroll.BorderSizePixel = 0
	tabScroll.ScrollBarThickness = 2
	tabScroll.ScrollBarImageColor3 = Theme.BorderLight
	tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabScroll.Parent = sidebar

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabScroll

	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, -204, 1, -56)
	contentArea.Position = UDim2.new(0, 196, 0, 52)
	contentArea.BackgroundColor3 = Theme.Surface
	contentArea.BackgroundTransparency = 0.3
	contentArea.BorderSizePixel = 0
	contentArea.Parent = main

	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = UDim.new(0, 4)
	contentCorner.Parent = contentArea

	local contentStroke = Instance.new("UIStroke")
	contentStroke.Color = Theme.Border
	contentStroke.Thickness = 1
	contentStroke.Parent = contentArea

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

	local windowObj = {
		ScreenGui = screenGui,
		Main = main,
		Tabs = {},
		ActiveTab = nil,
		NotifContainer = notifContainer
	}

	function windowObj:Notify(data)
		data = data or {}
		local nTitle = data.Title or "ALERT"
		local nDesc = data.Description or ""
		local duration = data.Duration or 3

		local item = Instance.new("Frame")
		item.Size = UDim2.new(1, 0, 0, 54)
		item.BackgroundColor3 = Theme.Void
		item.BackgroundTransparency = 0.05
		item.BorderSizePixel = 0
		item.Position = UDim2.new(0, 0, 0, 30)
		item.Parent = notifContainer

		local itemCorner = Instance.new("UICorner")
		itemCorner.CornerRadius = UDim.new(0, 4)
		itemCorner.Parent = item

		local itemStroke = Instance.new("UIStroke")
		itemStroke.Color = Theme.BorderLight
		itemStroke.Thickness = 1
		itemStroke.Parent = item

		local head = Instance.new("TextLabel")
		head.Size = UDim2.new(1, -20, 0, 18)
		head.Position = UDim2.new(0, 10, 0, 8)
		head.BackgroundTransparency = 1
		head.Text = string.upper(nTitle)
		head.TextColor3 = Theme.Accent
		head.TextSize = 12
		head.TextXAlignment = Enum.TextXAlignment.Left
		applyFont(head, Enum.FontWeight.Bold)
		head.Parent = item

		local desc = Instance.new("TextLabel")
		desc.Size = UDim2.new(1, -20, 0, 16)
		desc.Position = UDim2.new(0, 10, 0, 26)
		desc.BackgroundTransparency = 1
		desc.Text = nDesc
		desc.TextColor3 = Theme.TextMuted
		desc.TextSize = 11
		desc.TextXAlignment = Enum.TextXAlignment.Left
		applyFont(desc, Enum.FontWeight.Regular)
		desc.Parent = item

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, 0, 0, 2)
		bar.Position = UDim2.new(0, 0, 1, -2)
		bar.BackgroundColor3 = Theme.Accent
		bar.BorderSizePixel = 0
		bar.Parent = item

		tween(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })

		task.delay(duration, function()
			local fade = tween(item, TWEEN_FAST, { BackgroundTransparency = 1 })
			tween(itemStroke, TWEEN_FAST, { Transparency = 1 })
			tween(head, TWEEN_FAST, { TextTransparency = 1 })
			tween(desc, TWEEN_FAST, { TextTransparency = 1 })
			fade.Completed:Connect(function()
				item:Destroy()
			end)
		end)
	end

	function windowObj:CreateTab(name)
		local tabButton = Instance.new("TextButton")
		tabButton.Name = name .. "_Button"
		tabButton.Size = UDim2.new(1, 0, 0, 36)
		tabButton.BackgroundColor3 = Theme.Element
		tabButton.BackgroundTransparency = 1
		tabButton.BorderSizePixel = 0
		tabButton.Text = "  " .. string.upper(name)
		tabButton.TextColor3 = Theme.TextMuted
		tabButton.TextSize = 12
		tabButton.TextXAlignment = Enum.TextXAlignment.Left
		applyFont(tabButton, Enum.FontWeight.Medium)
		tabButton.Parent = tabScroll

		local tabBtnCorner = Instance.new("UICorner")
		tabBtnCorner.CornerRadius = UDim.new(0, 4)
		tabBtnCorner.Parent = tabButton

		local tabBtnStroke = Instance.new("UIStroke")
		tabBtnStroke.Color = Theme.Border
		tabBtnStroke.Transparency = 1
		tabBtnStroke.Thickness = 1
		tabBtnStroke.Parent = tabButton

		local page = Instance.new("ScrollingFrame")
		page.Name = name .. "_Page"
		page.Size = UDim2.new(1, -16, 1, -16)
		page.Position = UDim2.new(0, 8, 0, 8)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 2
		page.ScrollBarImageColor3 = Theme.BorderLight
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.Parent = contentArea

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Padding = UDim.new(0, 8)
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Parent = page

		local tabData = {
			Button = tabButton,
			Page = page,
			Stroke = tabBtnStroke
		}

		local function activate()
			for _, other in pairs(windowObj.Tabs) do
				other.Page.Visible = false
				tween(other.Button, TWEEN_FAST, {
					TextColor3 = Theme.TextMuted,
					BackgroundTransparency = 1
				})
				tween(other.Stroke, TWEEN_FAST, { Transparency = 1 })
			end
			page.Visible = true
			tween(tabButton, TWEEN_FAST, {
				TextColor3 = Theme.Text,
				BackgroundTransparency = 0
			})
			tween(tabBtnStroke, TWEEN_FAST, { Transparency = 0 })
			windowObj.ActiveTab = tabData
		end

		tabButton.MouseButton1Click:Connect(activate)

		if not windowObj.ActiveTab then
			activate()
		end

		table.insert(windowObj.Tabs, tabData)

		local tabElements = {}

		function tabElements:CreateButton(text, callback)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 36)
			btn.BackgroundColor3 = Theme.Element
			btn.BorderSizePixel = 0
			btn.AutoButtonColor = false
			btn.Text = string.upper(text)
			btn.TextColor3 = Theme.Text
			btn.TextSize = 12
			applyFont(btn, Enum.FontWeight.Medium)
			btn.Parent = page

			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 4)
			bCorner.Parent = btn

			local bStroke = Instance.new("UIStroke")
			bStroke.Color = Theme.Border
			bStroke.Thickness = 1
			bStroke.Parent = btn

			btn.MouseEnter:Connect(function()
				tween(btn, TWEEN_FAST, { BackgroundColor3 = Theme.ElementHover })
				tween(bStroke, TWEEN_FAST, { Color = Theme.BorderLight })
			end)
			btn.MouseLeave:Connect(function()
				tween(btn, TWEEN_FAST, { BackgroundColor3 = Theme.Element })
				tween(bStroke, TWEEN_FAST, { Color = Theme.Border })
			end)
			btn.MouseButton1Down:Connect(function()
				tween(btn, TWEEN_FAST, { BackgroundColor3 = Theme.Void })
			end)
			btn.MouseButton1Up:Connect(function()
				tween(btn, TWEEN_FAST, { BackgroundColor3 = Theme.ElementHover })
			end)
			btn.MouseButton1Click:Connect(function()
				if callback then
					callback()
				end
			end)
			return btn
		end

		function tabElements:CreateToggle(text, defaultState, callback)
			local state = defaultState or false

			local frame = Instance.new("TextButton")
			frame.Size = UDim2.new(1, 0, 0, 36)
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
			label.Size = UDim2.new(1, -60, 1, 0)
			label.Position = UDim2.new(0, 12, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = frame

			local switch = Instance.new("Frame")
			switch.Size = UDim2.new(0, 36, 0, 18)
			switch.Position = UDim2.new(1, -48, 0.5, -9)
			switch.BackgroundColor3 = state and Theme.Accent or Theme.Void
			switch.BorderSizePixel = 0
			switch.Parent = frame

			local swCorner = Instance.new("UICorner")
			swCorner.CornerRadius = UDim.new(1, 0)
			swCorner.Parent = switch

			local swStroke = Instance.new("UIStroke")
			swStroke.Color = Theme.BorderLight
			swStroke.Thickness = 1
			swStroke.Parent = switch

			local dot = Instance.new("Frame")
			dot.Size = UDim2.new(0, 12, 0, 12)
			dot.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
			dot.BackgroundColor3 = state and Theme.Void or Theme.TextMuted
			dot.BorderSizePixel = 0
			dot.Parent = switch

			local dotCorner = Instance.new("UICorner")
			dotCorner.CornerRadius = UDim.new(1, 0)
			dotCorner.Parent = dot

			local function set(val)
				state = val
				if state then
					tween(switch, TWEEN_FAST, { BackgroundColor3 = Theme.Accent })
					tween(dot, TWEEN_FAST, {
						Position = UDim2.new(1, -15, 0.5, -6),
						BackgroundColor3 = Theme.Void
					})
				else
					tween(switch, TWEEN_FAST, { BackgroundColor3 = Theme.Void })
					tween(dot, TWEEN_FAST, {
						Position = UDim2.new(0, 3, 0.5, -6),
						BackgroundColor3 = Theme.TextMuted
					})
				end
				if callback then
					callback(state)
				end
			end

			frame.MouseButton1Click:Connect(function()
				set(not state)
			end)

			return {
				Set = set,
				GetValue = function() return state end
			}
		end

		function tabElements:CreateSlider(text, min, max, defaultVal, step, callback)
			min = min or 0
			max = max or 100
			step = step or 1
			local value = math.clamp(defaultVal or min, min, max)

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 48)
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
			label.Size = UDim2.new(0.6, 0, 0, 20)
			label.Position = UDim2.new(0, 12, 0, 6)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = frame

			local readout = Instance.new("TextLabel")
			readout.Size = UDim2.new(0.4, -24, 0, 20)
			readout.Position = UDim2.new(0.6, 0, 0, 6)
			readout.BackgroundTransparency = 1
			readout.Text = tostring(value)
			readout.TextColor3 = Theme.TextMuted
			readout.TextSize = 12
			readout.TextXAlignment = Enum.TextXAlignment.Right
			applyFont(readout, Enum.FontWeight.Medium)
			readout.Parent = frame

			local track = Instance.new("TextButton")
			track.Name = "Track"
			track.Size = UDim2.new(1, -24, 0, 4)
			track.Position = UDim2.new(0, 12, 1, -12)
			track.BackgroundColor3 = Theme.Void
			track.BorderSizePixel = 0
			track.Text = ""
			track.AutoButtonColor = false
			track.Parent = frame

			local trackCorner = Instance.new("UICorner")
			trackCorner.CornerRadius = UDim.new(1, 0)
			trackCorner.Parent = track

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
				fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
				if callback then
					callback(value)
				end
			end

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					isDragging = true
					updateFromInput(input)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					isDragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateFromInput(input)
				end
			end)

			return {
				SetValue = function(v)
					value = math.clamp(v, min, max)
					readout.Text = tostring(value)
					fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
					if callback then
						callback(value)
					end
				end,
				GetValue = function() return value end
			}
		end

		function tabElements:CreateInput(text, placeholder, callback)
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 36)
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
			label.Position = UDim2.new(0, 12, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = frame

			local box = Instance.new("TextBox")
			box.Size = UDim2.new(0.6, -20, 0, 24)
			box.Position = UDim2.new(0.4, 8, 0.5, -12)
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
				tween(bStroke, TWEEN_FAST, { Color = Theme.BorderLight })
			end)
			box.FocusLost:Connect(function(enterPressed)
				tween(bStroke, TWEEN_FAST, { Color = Theme.Border })
				if callback then
					callback(box.Text, enterPressed)
				end
			end)

			return {
				GetText = function() return box.Text end,
				SetText = function(val) box.Text = tostring(val) end
			}
		end

		function tabElements:CreateDropdown(text, list, defaultIndex, callback)
			list = list or {}
			local current = list[defaultIndex or 1] or "SELECT..."
			local isOpen = false

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 36)
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
			headBtn.Size = UDim2.new(1, 0, 0, 36)
			headBtn.BackgroundTransparency = 1
			headBtn.Text = ""
			headBtn.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.5, 0, 0, 36)
			label.Position = UDim2.new(0, 12, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = headBtn

			local valueDisplay = Instance.new("TextLabel")
			valueDisplay.Size = UDim2.new(0.5, -36, 0, 36)
			valueDisplay.Position = UDim2.new(0.5, 0, 0, 0)
			valueDisplay.BackgroundTransparency = 1
			valueDisplay.Text = string.upper(tostring(current))
			valueDisplay.TextColor3 = Theme.TextMuted
			valueDisplay.TextSize = 12
			valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
			applyFont(valueDisplay, Enum.FontWeight.Medium)
			valueDisplay.Parent = headBtn

			local arrow = Instance.new("TextLabel")
			arrow.Size = UDim2.new(0, 20, 0, 36)
			arrow.Position = UDim2.new(1, -28, 0, 0)
			arrow.BackgroundTransparency = 1
			arrow.Text = "v"
			arrow.TextColor3 = Theme.TextMuted
			arrow.TextSize = 10
			applyFont(arrow, Enum.FontWeight.Bold)
			arrow.Parent = headBtn

			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, -16, 0, #list * 28)
			container.Position = UDim2.new(0, 8, 0, 38)
			container.BackgroundTransparency = 1
			container.Parent = frame

			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 2)
			layout.Parent = container

			local function toggle()
				isOpen = not isOpen
				local targetHeight = isOpen and (38 + (#list * 28) + 6) or 36
				tween(frame, TWEEN_SMOOTH, { Size = UDim2.new(1, 0, 0, targetHeight) })
				tween(arrow, TWEEN_FAST, { Rotation = isOpen and 180 or 0 })
			end

			headBtn.MouseButton1Click:Connect(toggle)

			for _, opt in ipairs(list) do
				local optBtn = Instance.new("TextButton")
				optBtn.Size = UDim2.new(1, 0, 0, 26)
				optBtn.BackgroundColor3 = Theme.Void
				optBtn.BorderSizePixel = 0
				optBtn.AutoButtonColor = false
				optBtn.Text = "  " .. string.upper(tostring(opt))
				optBtn.TextColor3 = (opt == current) and Theme.Accent or Theme.TextMuted
				optBtn.TextSize = 11
				optBtn.TextXAlignment = Enum.TextXAlignment.Left
				applyFont(optBtn, Enum.FontWeight.Medium)
				optBtn.Parent = container

				local optCorner = Instance.new("UICorner")
				optCorner.CornerRadius = UDim.new(0, 3)
				optCorner.Parent = optBtn

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

		function tabElements:CreateRadioGroup(text, options, defaultIndex, callback)
			options = options or {}
			local selected = options[defaultIndex or 1]

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 24 + (#options * 28))
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
			label.Size = UDim2.new(1, -24, 0, 24)
			label.Position = UDim2.new(0, 12, 0, 2)
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
				optBtn.Size = UDim2.new(1, -24, 0, 24)
				optBtn.Position = UDim2.new(0, 12, 0, 24 + (i - 1) * 26)
				optBtn.BackgroundTransparency = 1
				optBtn.Text = ""
				optBtn.Parent = frame

				local dotFrame = Instance.new("Frame")
				dotFrame.Size = UDim2.new(0, 14, 0, 14)
				dotFrame.Position = UDim2.new(0, 0, 0.5, -7)
				dotFrame.BackgroundColor3 = Theme.Void
				dotFrame.BorderSizePixel = 0
				dotFrame.Parent = optBtn

				local dfCorner = Instance.new("UICorner")
				dfCorner.CornerRadius = UDim.new(1, 0)
				dfCorner.Parent = dotFrame

				local dfStroke = Instance.new("UIStroke")
				dfStroke.Color = Theme.BorderLight
				dfStroke.Thickness = 1
				dfStroke.Parent = dotFrame

				local inner = Instance.new("Frame")
				inner.Size = UDim2.new(0, 8, 0, 8)
				inner.Position = UDim2.new(0.5, -4, 0.5, -4)
				inner.BackgroundColor3 = Theme.Accent
				inner.BorderSizePixel = 0
				inner.Visible = (opt == selected)
				inner.Parent = dotFrame

				local inCorner = Instance.new("UICorner")
				inCorner.CornerRadius = UDim.new(1, 0)
				inCorner.Parent = inner

				local optLabel = Instance.new("TextLabel")
				optLabel.Size = UDim2.new(1, -24, 1, 0)
				optLabel.Position = UDim2.new(0, 22, 0, 0)
				optLabel.BackgroundTransparency = 1
				optLabel.Text = string.upper(tostring(opt))
				optLabel.TextColor3 = (opt == selected) and Theme.Text or Theme.TextMuted
				optLabel.TextSize = 11
				optLabel.TextXAlignment = Enum.TextXAlignment.Left
				applyFont(optLabel, Enum.FontWeight.Medium)
				optLabel.Parent = optBtn

				buttons[opt] = { Dot = inner, Label = optLabel }

				optBtn.MouseButton1Click:Connect(function()
					selected = opt
					for key, val in pairs(buttons) do
						val.Dot.Visible = (key == selected)
						val.Label.TextColor3 = (key == selected) and Theme.Text or Theme.TextMuted
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

		function tabElements:CreateColorPicker(text, defaultColor, callback)
			local color = defaultColor or Color3.fromRGB(255, 255, 255)
			local isOpen = false

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 36)
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
			headBtn.Size = UDim2.new(1, 0, 0, 36)
			headBtn.BackgroundTransparency = 1
			headBtn.Text = ""
			headBtn.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.6, 0, 1, 0)
			label.Position = UDim2.new(0, 12, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = headBtn

			local swatch = Instance.new("Frame")
			swatch.Size = UDim2.new(0, 24, 0, 16)
			swatch.Position = UDim2.new(1, -36, 0.5, -8)
			swatch.BackgroundColor3 = color
			swatch.BorderSizePixel = 0
			swatch.Parent = headBtn

			local swCorner = Instance.new("UICorner")
			swCorner.CornerRadius = UDim.new(0, 2)
			swCorner.Parent = swatch

			local swStroke = Instance.new("UIStroke")
			swStroke.Color = Theme.BorderLight
			swStroke.Thickness = 1
			swStroke.Parent = swatch

			local palette = Instance.new("Frame")
			palette.Size = UDim2.new(1, -24, 0, 60)
			palette.Position = UDim2.new(0, 12, 0, 40)
			palette.BackgroundTransparency = 1
			palette.Parent = frame

			local colors = {
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(244, 63, 94),
				Color3.fromRGB(249, 115, 22),
				Color3.fromRGB(234, 179, 8),
				Color3.fromRGB(34, 197, 94),
				Color3.fromRGB(59, 130, 246),
				Color3.fromRGB(168, 85, 247),
				Color3.fromRGB(30, 30, 35)
			}

			local grid = Instance.new("UIGridLayout")
			grid.CellSize = UDim2.new(0, 24, 0, 24)
			grid.CellPadding = UDim2.new(0, 8, 0, 8)
			grid.Parent = palette

			for _, c in ipairs(colors) do
				local cBtn = Instance.new("TextButton")
				cBtn.Size = UDim2.new(0, 24, 0, 24)
				cBtn.BackgroundColor3 = c
				cBtn.BorderSizePixel = 0
				cBtn.Text = ""
				cBtn.Parent = palette

				local cCorner = Instance.new("UICorner")
				cCorner.CornerRadius = UDim.new(0, 3)
				cCorner.Parent = cBtn

				cBtn.MouseButton1Click:Connect(function()
					color = c
					swatch.BackgroundColor3 = color
					if callback then
						callback(color)
					end
				end)
			end

			headBtn.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				local targetHeight = isOpen and 108 or 36
				tween(frame, TWEEN_SMOOTH, { Size = UDim2.new(1, 0, 0, targetHeight) })
			end)

			return {
				GetColor = function() return color end
			}
		end

		function tabElements:CreateContextMenu(text, actions)
			actions = actions or {}
			local isOpen = false

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 36)
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
			headBtn.Size = UDim2.new(1, 0, 0, 36)
			headBtn.BackgroundTransparency = 1
			headBtn.Text = ""
			headBtn.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -40, 1, 0)
			label.Position = UDim2.new(0, 12, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = string.upper(text)
			label.TextColor3 = Theme.Text
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			applyFont(label, Enum.FontWeight.Medium)
			label.Parent = headBtn

			local dots = Instance.new("TextLabel")
			dots.Size = UDim2.new(0, 24, 0, 36)
			dots.Position = UDim2.new(1, -32, 0, 0)
			dots.BackgroundTransparency = 1
			dots.Text = ":::"
			dots.TextColor3 = Theme.TextMuted
			dots.TextSize = 14
			dots.Parent = headBtn

			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, -24, 0, #actions * 26)
			container.Position = UDim2.new(0, 12, 0, 38)
			container.BackgroundTransparency = 1
			container.Parent = frame

			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 2)
			layout.Parent = container

			for _, act in ipairs(actions) do
				local actBtn = Instance.new("TextButton")
				actBtn.Size = UDim2.new(1, 0, 0, 24)
				actBtn.BackgroundColor3 = Theme.Void
				actBtn.BorderSizePixel = 0
				actBtn.Text = "  " .. string.upper(act.Name or "ACTION")
				actBtn.TextColor3 = Theme.TextMuted
				actBtn.TextSize = 11
				actBtn.TextXAlignment = Enum.TextXAlignment.Left
				applyFont(actBtn, Enum.FontWeight.Medium)
				actBtn.Parent = container

				local actCorner = Instance.new("UICorner")
				actCorner.CornerRadius = UDim.new(0, 3)
				actCorner.Parent = actBtn

				actBtn.MouseEnter:Connect(function()
					actBtn.TextColor3 = Theme.Text
				end)
				actBtn.MouseLeave:Connect(function()
					actBtn.TextColor3 = Theme.TextMuted
				end)
				actBtn.MouseButton1Click:Connect(function()
					if act.Callback then
						act.Callback()
					end
				end)
			end

			headBtn.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				local targetHeight = isOpen and (38 + (#actions * 26) + 8) or 36
				tween(frame, TWEEN_SMOOTH, { Size = UDim2.new(1, 0, 0, targetHeight) })
			end)
		end

		return tabElements
	end

	return windowObj
end

return LuxLib
