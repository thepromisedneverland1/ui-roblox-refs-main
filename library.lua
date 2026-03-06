local Wave = {}
Wave.__index = Wave

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function tween(obj, props, duration, style, direction)
	style = style or Enum.EasingStyle.Quart
	direction = direction or Enum.EasingDirection.Out
	local ti = TweenInfo.new(duration or 0.2, style, direction)
	TweenService:Create(obj, ti, props):Play()
end

local function create(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	for _, child in pairs(children or {}) do
		child.Parent = obj
	end
	return obj
end

local function makeDraggable(frame, handle)
	handle = handle or frame
	local dragging, dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local THEME = {
	Background    = Color3.fromRGB(14, 16, 21),
	Topbar        = Color3.fromRGB(18, 21, 28),
	TabBar        = Color3.fromRGB(16, 18, 24),
	TabSelected   = Color3.fromRGB(0, 160, 220),
	TabUnselected = Color3.fromRGB(22, 26, 34),
	Element       = Color3.fromRGB(20, 24, 32),
	ElementHover  = Color3.fromRGB(26, 30, 42),
	Stroke        = Color3.fromRGB(38, 44, 58),
	Accent        = Color3.fromRGB(0, 170, 230),
	AccentDark    = Color3.fromRGB(0, 120, 170),
	Text          = Color3.fromRGB(240, 242, 248),
	SubText       = Color3.fromRGB(130, 140, 165),
	Disabled      = Color3.fromRGB(55, 62, 80),
	Success       = Color3.fromRGB(50, 210, 130),
	Warning       = Color3.fromRGB(230, 170, 50),
	Danger        = Color3.fromRGB(220, 70, 80),
	ToggleOff     = Color3.fromRGB(45, 52, 68),
	ToggleOn      = Color3.fromRGB(0, 170, 230),
}

function Wave:CreateWindow(config)
	config = config or {}
	local windowName = config.Name or "Wave"
	local subtitle   = config.Subtitle or ""

	local ScreenGui = create("ScreenGui", {
		Name = "WaveUI_" .. windowName,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		DisplayOrder = 999,
	})

	if syn and syn.protect_gui then
		syn.protect_gui(ScreenGui)
		ScreenGui.Parent = game.CoreGui
	elseif gethui then
		ScreenGui.Parent = gethui()
	else
		ScreenGui.Parent = game.CoreGui
	end

	local MainFrame = create("Frame", {
		Name = "Main",
		Size = UDim2.new(0, 700, 0, 460),
		Position = UDim2.new(0.5, -350, 0.5, -230),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = ScreenGui,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 10) }),
		create("UIStroke", { Color = THEME.Stroke, Thickness = 1.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
	})

	local TopBar = create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = THEME.Topbar,
		BorderSizePixel = 0,
		Parent = MainFrame,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 10) }),
		create("Frame", {
			Size = UDim2.new(1, 0, 0.5, 0),
			Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundColor3 = THEME.Topbar,
			BorderSizePixel = 0,
		}),
	})

	local TitleLabel = create("TextLabel", {
		Text = windowName,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = THEME.Text,
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TopBar,
	})

	if subtitle ~= "" then
		TitleLabel.Text = windowName .. "  •  " .. subtitle
		TitleLabel.TextColor3 = THEME.SubText
		local bold = create("TextLabel", {
			Text = windowName,
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			TextColor3 = THEME.Text,
			Size = UDim2.new(0, 200, 1, 0),
			Position = UDim2.new(0, 16, 0, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = TopBar,
		})
	end

	local CloseBtn = create("TextButton", {
		Text = "✕",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = THEME.SubText,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -38, 0.5, -15),
		BackgroundColor3 = THEME.Element,
		BorderSizePixel = 0,
		Parent = TopBar,
	}, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })

	CloseBtn.MouseButton1Click:Connect(function()
		tween(MainFrame, { Position = UDim2.new(0.5, -350, 1.5, 0) }, 0.35)
		task.wait(0.4)
		ScreenGui:Destroy()
	end)

	CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, { BackgroundColor3 = THEME.Danger }, 0.15) end)
	CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, { BackgroundColor3 = THEME.Element }, 0.15) end)

	local MinBtn = create("TextButton", {
		Text = "─",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = THEME.SubText,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -72, 0.5, -15),
		BackgroundColor3 = THEME.Element,
		BorderSizePixel = 0,
		Parent = TopBar,
	}, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })

	local minimized = false
	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			tween(MainFrame, { Size = UDim2.new(0, 700, 0, 44) }, 0.3)
		else
			tween(MainFrame, { Size = UDim2.new(0, 700, 0, 460) }, 0.3)
		end
	end)

	MinBtn.MouseEnter:Connect(function() tween(MinBtn, { BackgroundColor3 = THEME.AccentDark }, 0.15) end)
	MinBtn.MouseLeave:Connect(function() tween(MinBtn, { BackgroundColor3 = THEME.Element }, 0.15) end)

	makeDraggable(MainFrame, TopBar)

	local TabBar = create("Frame", {
		Name = "TabBar",
		Size = UDim2.new(0, 148, 1, -44),
		Position = UDim2.new(0, 0, 0, 44),
		BackgroundColor3 = THEME.TabBar,
		BorderSizePixel = 0,
		Parent = MainFrame,
	}, {
		create("UIStroke", { Color = THEME.Stroke, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
	})

	local TabList = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -10),
		Position = UDim2.new(0, 0, 0, 8),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = TabBar,
	}, {
		create("UIListLayout", {
			Padding = UDim.new(0, 4),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
	})

	local ContentArea = create("Frame", {
		Name = "ContentArea",
		Size = UDim2.new(1, -148, 1, -44),
		Position = UDim2.new(0, 148, 0, 44),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = MainFrame,
	})

	tween(MainFrame, { Position = UDim2.new(0.5, -350, 0.5, -230) }, 0.4, Enum.EasingStyle.Back)

	local Window = { _tabs = {}, _activeTab = nil, _gui = ScreenGui, _main = MainFrame }

	function Window:CreateTab(name, icon)
		local Tab = { _elements = {}, _name = name }

		local TabBtn = create("TextButton", {
			Text = "",
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = THEME.TabUnselected,
			BorderSizePixel = 0,
			Parent = TabList,
		}, {
			create("UICorner", { CornerRadius = UDim.new(0, 8) }),
			create("UIStroke", { Color = THEME.Stroke, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
		})

		local TabIcon
		if icon then
			TabIcon = create("ImageLabel", {
				Image = "rbxassetid://" .. tostring(icon),
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(0, 10, 0.5, -9),
				BackgroundTransparency = 1,
				ImageColor3 = THEME.SubText,
				Parent = TabBtn,
			})
		end

		local TabLabel = create("TextLabel", {
			Text = name,
			Font = Enum.Font.GothamSemibold,
			TextSize = 13,
			TextColor3 = THEME.SubText,
			Size = UDim2.new(1, icon and -36 or -16, 1, 0),
			Position = UDim2.new(0, icon and 34 or 10, 0, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = TabBtn,
		})

		local TabContent = create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = THEME.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			Parent = ContentArea,
		}, {
			create("UIListLayout", {
				Padding = UDim.new(0, 6),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),
			create("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
		})

		local function selectTab()
			for _, t in pairs(Window._tabs) do
				tween(t._btn, { BackgroundColor3 = THEME.TabUnselected }, 0.15)
				tween(t._label, { TextColor3 = THEME.SubText }, 0.15)
				if t._icon then tween(t._icon, { ImageColor3 = THEME.SubText }, 0.15) end
				t._content.Visible = false
			end
			tween(TabBtn, { BackgroundColor3 = THEME.TabSelected }, 0.15)
			tween(TabLabel, { TextColor3 = THEME.Text }, 0.15)
			if TabIcon then tween(TabIcon, { ImageColor3 = THEME.Text }, 0.15) end
			TabContent.Visible = true
			Window._activeTab = Tab
		end

		TabBtn.MouseButton1Click:Connect(selectTab)
		TabBtn.MouseEnter:Connect(function()
			if Window._activeTab ~= Tab then
				tween(TabBtn, { BackgroundColor3 = THEME.ElementHover }, 0.12)
			end
		end)
		TabBtn.MouseLeave:Connect(function()
			if Window._activeTab ~= Tab then
				tween(TabBtn, { BackgroundColor3 = THEME.TabUnselected }, 0.12)
			end
		end)

		Tab._btn = TabBtn
		Tab._label = TabLabel
		Tab._icon = TabIcon
		Tab._content = TabContent
		table.insert(Window._tabs, Tab)

		if #Window._tabs == 1 then selectTab() end

		local function makeElement(size)
			return create("Frame", {
				Size = size or UDim2.new(1, 0, 0, 44),
				BackgroundColor3 = THEME.Element,
				BorderSizePixel = 0,
				Parent = TabContent,
			}, {
				create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				create("UIStroke", { Color = THEME.Stroke, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
			})
		end

		local function makeLabel(parent, text, font, size, color, xalign, pos, elSize)
			return create("TextLabel", {
				Text = text,
				Font = font or Enum.Font.GothamSemibold,
				TextSize = size or 13,
				TextColor3 = color or THEME.Text,
				BackgroundTransparency = 1,
				Size = elSize or UDim2.new(1, -16, 1, 0),
				Position = pos or UDim2.new(0, 12, 0, 0),
				TextXAlignment = xalign or Enum.TextXAlignment.Left,
				TextWrapped = true,
				Parent = parent,
			})
		end

		function Tab:CreateSection(name)
			local sec = create("Frame", {
				Size = UDim2.new(1, 0, 0, 26),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = TabContent,
			})
			local line = create("Frame", {
				Size = UDim2.new(0.42, 0, 0, 1),
				Position = UDim2.new(0, 0, 0.5, 0),
				BackgroundColor3 = THEME.Stroke,
				BorderSizePixel = 0,
				Parent = sec,
			})
			local line2 = create("Frame", {
				Size = UDim2.new(0.42, 0, 0, 1),
				Position = UDim2.new(0.58, 0, 0.5, 0),
				BackgroundColor3 = THEME.Stroke,
				BorderSizePixel = 0,
				Parent = sec,
			})
			create("TextLabel", {
				Text = string.upper(name),
				Font = Enum.Font.GothamBold,
				TextSize = 10,
				TextColor3 = THEME.SubText,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.16, 0, 1, 0),
				Position = UDim2.new(0.42, 0, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = sec,
			})
		end

		function Tab:CreateParagraph(config)
			config = config or {}
			local el = makeElement(UDim2.new(1, 0, 0, 0))
			el.AutomaticSize = Enum.AutomaticSize.Y
			create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, )
				.Parent = el
			local layout = create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
			layout.Parent = el
			create("TextLabel", {
				Text = config.Title or "",
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextColor3 = THEME.Text,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18),
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 1,
				Parent = el,
			})
			create("TextLabel", {
				Text = config.Content or "",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = THEME.SubText,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				LayoutOrder = 2,
				Parent = el,
			})
		end

		function Tab:CreateButton(config)
			config = config or {}
			local el = makeElement()
			el.BackgroundColor3 = THEME.Element

			local accent = create("Frame", {
				Size = UDim2.new(0, 3, 0.6, 0),
				Position = UDim2.new(0, 0, 0.2, 0),
				BackgroundColor3 = THEME.Accent,
				BorderSizePixel = 0,
				Parent = el,
			}, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

			makeLabel(el, config.Name or "Button")

			if config.Description then
				makeLabel(el, config.Description, Enum.Font.Gotham, 11, THEME.SubText, nil,
					UDim2.new(0, 12, 0.5, 0), UDim2.new(1, -16, 0.5, 0))
			end

			local btn = create("TextButton", {
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Parent = el,
			})

			btn.MouseEnter:Connect(function() tween(el, { BackgroundColor3 = THEME.ElementHover }, 0.12) end)
			btn.MouseLeave:Connect(function() tween(el, { BackgroundColor3 = THEME.Element }, 0.12) end)
			btn.MouseButton1Click:Connect(function()
				tween(accent, { BackgroundColor3 = THEME.Success }, 0.1)
				task.delay(0.3, function() tween(accent, { BackgroundColor3 = THEME.Accent }, 0.2) end)
				if config.Callback then
					task.spawn(config.Callback)
				end
			end)
		end

		function Tab:CreateToggle(config)
			config = config or {}
			local el = makeElement()
			local value = config.CurrentValue or false

			local accent = create("Frame", {
				Size = UDim2.new(0, 3, 0.6, 0),
				Position = UDim2.new(0, 0, 0.2, 0),
				BackgroundColor3 = value and THEME.Accent or THEME.Disabled,
				BorderSizePixel = 0,
				Parent = el,
			}, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

			makeLabel(el, config.Name or "Toggle")
			if config.Description then
				makeLabel(el, config.Description, Enum.Font.Gotham, 11, THEME.SubText, nil,
					UDim2.new(0, 12, 0.5, 0), UDim2.new(0.6, -16, 0.5, 0))
			end

			local track = create("Frame", {
				Size = UDim2.new(0, 40, 0, 22),
				Position = UDim2.new(1, -52, 0.5, -11),
				BackgroundColor3 = value and THEME.ToggleOn or THEME.ToggleOff,
				BorderSizePixel = 0,
				Parent = el,
			}, {
				create("UICorner", { CornerRadius = UDim.new(1, 0) }),
				create("UIStroke", { Color = THEME.Stroke, Thickness = 1 }),
			})

			local knob = create("Frame", {
				Size = UDim2.new(0, 16, 0, 16),
				Position = value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Parent = track,
			}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

			local btn = create("TextButton", {
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Parent = el,
			})

			local Toggle = { Value = value }

			local function update(v)
				Toggle.Value = v
				tween(track, { BackgroundColor3 = v and THEME.ToggleOn or THEME.ToggleOff }, 0.2)
				tween(knob, { Position = v and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) }, 0.2)
				tween(accent, { BackgroundColor3 = v and THEME.Accent or THEME.Disabled }, 0.2)
				if config.Callback then task.spawn(config.Callback, v) end
				if config.Flag then getgenv()[config.Flag] = v end
			end

			btn.MouseButton1Click:Connect(function() update(not Toggle.Value) end)
			btn.MouseEnter:Connect(function() tween(el, { BackgroundColor3 = THEME.ElementHover }, 0.12) end)
			btn.MouseLeave:Connect(function() tween(el, { BackgroundColor3 = THEME.Element }, 0.12) end)

			if config.Flag then getgenv()[config.Flag] = value end
			return Toggle
		end

		function Tab:CreateSlider(config)
			config = config or {}
			local min = config.Range and config.Range[1] or 0
			local max = config.Range and config.Range[2] or 100
			local increment = config.Increment or 1
			local value = config.CurrentValue or min

			local el = makeElement(UDim2.new(1, 0, 0, 58))

			local accent = create("Frame", {
				Size = UDim2.new(0, 3, 0.5, 0),
				Position = UDim2.new(0, 0, 0.1, 0),
				BackgroundColor3 = THEME.Accent,
				BorderSizePixel = 0,
				Parent = el,
			}, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

			makeLabel(el, config.Name or "Slider", nil, nil, nil, nil, UDim2.new(0, 12, 0, 6), UDim2.new(0.7, -12, 0, 18))

			local valLabel = create("TextLabel", {
				Text = tostring(value),
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextColor3 = THEME.Accent,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 60, 0, 18),
				Position = UDim2.new(1, -68, 0, 6),
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = el,
			})

			local track = create("Frame", {
				Size = UDim2.new(1, -24, 0, 6),
				Position = UDim2.new(0, 12, 0, 34),
				BackgroundColor3 = THEME.ToggleOff,
				BorderSizePixel = 0,
				Parent = el,
			}, {
				create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			})

			local fill = create("Frame", {
				Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
				BackgroundColor3 = THEME.Accent,
				BorderSizePixel = 0,
				Parent = track,
			}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

			local knob = create("Frame", {
				Size = UDim2.new(0, 14, 0, 14),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Parent = track,
			}, {
				create("UICorner", { CornerRadius = UDim.new(1, 0) }),
				create("UIStroke", { Color = THEME.AccentDark, Thickness = 2 }),
			})

			local Slider = { Value = value }
			local sliding = false

			local function setValue(v)
				v = math.clamp(math.round(v / increment) * increment, min, max)
				Slider.Value = v
				local pct = (v - min) / (max - min)
				tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.05)
				tween(knob, { Position = UDim2.new(pct, 0, 0.5, 0) }, 0.05)
				valLabel.Text = tostring(v)
				if config.Callback then task.spawn(config.Callback, v) end
				if config.Flag then getgenv()[config.Flag] = v end
			end

			local btn = create("TextButton", {
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Parent = el,
			})

			btn.MouseButton1Down:Connect(function()
				sliding = true
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
			end)
			RunService.RenderStepped:Connect(function()
				if sliding then
					local abs = track.AbsolutePosition
					local sz = track.AbsoluteSize
					local mx = UserInputService:GetMouseLocation().X
					local pct = math.clamp((mx - abs.X) / sz.X, 0, 1)
					setValue(min + pct * (max - min))
				end
			end)

			btn.MouseEnter:Connect(function() tween(el, { BackgroundColor3 = THEME.ElementHover }, 0.12) end)
			btn.MouseLeave:Connect(function() tween(el, { BackgroundColor3 = THEME.Element }, 0.12) end)

			if config.Flag then getgenv()[config.Flag] = value end
			setValue(value)
			return Slider
		end

		function Tab:CreateDropdown(config)
			config = config or {}
			local options = config.Options or {}
			local selected = config.CurrentOption and config.CurrentOption[1] or options[1] or ""
			local opened = false

			local el = makeElement(UDim2.new(1, 0, 0, 44))

			local accent = create("Frame", {
				Size = UDim2.new(0, 3, 0.6, 0),
				Position = UDim2.new(0, 0, 0.2, 0),
				BackgroundColor3 = THEME.Accent,
				BorderSizePixel = 0,
				Parent = el,
			}, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

			makeLabel(el, config.Name or "Dropdown", nil, nil, nil, nil, nil, UDim2.new(0.5, -12, 1, 0))

			local selLabel = create("TextLabel", {
				Text = selected,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = THEME.Accent,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.45, -36, 1, 0),
				Position = UDim2.new(0.5, 0, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = el,
			})

			local arrow = create("TextLabel", {
				Text = "▾",
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				TextColor3 = THEME.SubText,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 24, 1, 0),
				Position = UDim2.new(1, -28, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = el,
			})

			local dropFrame = create("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 1, 4),
				BackgroundColor3 = THEME.Topbar,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				ZIndex = 10,
				Parent = el,
			}, {
				create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				create("UIStroke", { Color = THEME.Stroke, Thickness = 1 }),
			})

			local dropList = create("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Parent = dropFrame,
			}, {
				create("UIListLayout", { Padding = UDim.new(0, 2), HorizontalAlignment = Enum.HorizontalAlignment.Center }),
				create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }),
			})

			local Dropdown = { Value = selected }

			local function setVal(v)
				Dropdown.Value = v
				selLabel.Text = v
				if config.Callback then task.spawn(config.Callback, { v }) end
				if config.Flag then getgenv()[config.Flag] = v end
			end

			local function toggleDrop()
				opened = not opened
				local targetH = opened and math.min(#options * 34 + 8, 180) or 0
				tween(dropFrame, { Size = UDim2.new(1, 0, 0, targetH) }, 0.2)
				tween(arrow, { Rotation = opened and 180 or 0 }, 0.2)
			end

			for _, opt in ipairs(options) do
				local optBtn = create("TextButton", {
					Text = opt,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = opt == selected and THEME.Accent or THEME.Text,
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundColor3 = THEME.Element,
					BorderSizePixel = 0,
					ZIndex = 11,
					Parent = dropList,
				}, {
					create("UICorner", { CornerRadius = UDim.new(0, 6) }),
				})
				optBtn.MouseButton1Click:Connect(function()
					setVal(opt)
					for _, b in ipairs(dropList:GetChildren()) do
						if b:IsA("TextButton") then
							tween(b, { TextColor3 = b.Text == opt and THEME.Accent or THEME.Text }, 0.1)
						end
					end
					toggleDrop()
				end)
				optBtn.MouseEnter:Connect(function() tween(optBtn, { BackgroundColor3 = THEME.ElementHover }, 0.1) end)
				optBtn.MouseLeave:Connect(function() tween(optBtn, { BackgroundColor3 = THEME.Element }, 0.1) end)
			end

			local btn = create("TextButton", {
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ZIndex = 5,
				Parent = el,
			})
			btn.MouseButton1Click:Connect(toggleDrop)
			btn.MouseEnter:Connect(function() tween(el, { BackgroundColor3 = THEME.ElementHover }, 0.12) end)
			btn.MouseLeave:Connect(function() tween(el, { BackgroundColor3 = THEME.Element }, 0.12) end)

			if config.Flag then getgenv()[config.Flag] = selected end
			return Dropdown
		end

		function Tab:CreateInput(config)
			config = config or {}
			local el = makeElement()

			local accent = create("Frame", {
				Size = UDim2.new(0, 3, 0.6, 0),
				Position = UDim2.new(0, 0, 0.2, 0),
				BackgroundColor3 = THEME.Accent,
				BorderSizePixel = 0,
				Parent = el,
			}, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

			makeLabel(el, config.Name or "Input", nil, nil, nil, nil, nil, UDim2.new(0.45, -12, 1, 0))

			local box = create("TextBox", {
				Text = config.CurrentValue or "",
				PlaceholderText = config.PlaceholderText or "Enter value...",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = THEME.Text,
				PlaceholderColor3 = THEME.SubText,
				BackgroundColor3 = THEME.TabBar,
				BorderSizePixel = 0,
				Size = UDim2.new(0.5, -12, 0, 28),
				Position = UDim2.new(0.5, 4, 0.5, -14),
				ClearTextOnFocus = config.ClearTextOnFocus ~= false,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = el,
			}, {
				create("UICorner", { CornerRadius = UDim.new(0, 6) }),
				create("UIStroke", { Color = THEME.Stroke, Thickness = 1 }),
				create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
			})

			local Input = { Value = box.Text }

			box.FocusLost:Connect(function(enter)
				Input.Value = box.Text
				tween(box, { UIStroke = nil }, 0)
				if config.Callback then task.spawn(config.Callback, box.Text) end
				if config.Flag then getgenv()[config.Flag] = box.Text end
			end)
			box.Focused:Connect(function()
				tween(box, { BackgroundColor3 = THEME.ElementHover }, 0.1)
			end)
			box.FocusLost:Connect(function()
				tween(box, { BackgroundColor3 = THEME.TabBar }, 0.1)
			end)

			if config.Flag then getgenv()[config.Flag] = box.Text end
			return Input
		end

		function Tab:CreateColorPicker(config)
			config = config or {}
			local color = config.Color or Color3.fromRGB(255, 255, 255)
			local opened = false

			local el = makeElement()

			local accent = create("Frame", {
				Size = UDim2.new(0, 3, 0.6, 0),
				Position = UDim2.new(0, 0, 0.2, 0),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				Parent = el,
			}, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

			makeLabel(el, config.Name or "Color Picker")

			local preview = create("Frame", {
				Size = UDim2.new(0, 24, 0, 24),
				Position = UDim2.new(1, -36, 0.5, -12),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				Parent = el,
			}, {
				create("UICorner", { CornerRadius = UDim.new(0, 6) }),
				create("UIStroke", { Color = THEME.Stroke, Thickness = 1.5 }),
			})

			local pickerFrame = create("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 1, 4),
				BackgroundColor3 = THEME.Topbar,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				ZIndex = 10,
				Parent = el,
			}, {
				create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				create("UIStroke", { Color = THEME.Stroke, Thickness = 1 }),
			})

			local H, S, V = Color3.toHSV(color)
			local ColorPicker = { Value = color }

			local function buildPicker()
				local pad = create("UIPadding", { PaddingAll = UDim.new(0, 10) })
				pad.Parent = pickerFrame

				local svBox = create("ImageLabel", {
					Size = UDim2.new(1, 0, 0, 120),
					BackgroundColor3 = Color3.fromHSV(H, 1, 1),
					BorderSizePixel = 0,
					Image = "rbxassetid://4155801252",
					ScaleType = Enum.ScaleType.Stretch,
					ZIndex = 11,
					Parent = pickerFrame,
				}, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })

				local svKnob = create("Frame", {
					Size = UDim2.new(0, 10, 0, 10),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(S, 0, 1 - V, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					ZIndex = 12,
					Parent = svBox,
				}, {
					create("UICorner", { CornerRadius = UDim.new(1, 0) }),
					create("UIStroke", { Color = Color3.fromRGB(0,0,0), Thickness = 1.5 }),
				})

				local hueBar = create("ImageLabel", {
					Size = UDim2.new(1, 0, 0, 16),
					Position = UDim2.new(0, 0, 0, 130),
					BorderSizePixel = 0,
					Image = "rbxassetid://698052001",
					ScaleType = Enum.ScaleType.Stretch,
					ZIndex = 11,
					Parent = pickerFrame,
				}, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

				local hueKnob = create("Frame", {
					Size = UDim2.new(0, 8, 1, 2),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(H, 0, 0.5, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					ZIndex = 12,
					Parent = hueBar,
				}, {
					create("UICorner", { CornerRadius = UDim.new(0, 3) }),
					create("UIStroke", { Color = Color3.fromRGB(0,0,0), Thickness = 1 }),
				})

				local hexBox = create("TextBox", {
					Text = string.format("%02X%02X%02X", math.round(color.R*255), math.round(color.G*255), math.round(color.B*255)),
					Font = Enum.Font.Code,
					TextSize = 12,
					TextColor3 = THEME.Text,
					PlaceholderColor3 = THEME.SubText,
					BackgroundColor3 = THEME.Element,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 28),
					Position = UDim2.new(0, 0, 0, 154),
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 11,
					Parent = pickerFrame,
				}, {
					create("UICorner", { CornerRadius = UDim.new(0, 6) }),
					create("UIStroke", { Color = THEME.Stroke, Thickness = 1 }),
				})

				local function updateColor()
					local c = Color3.fromHSV(H, S, V)
					ColorPicker.Value = c
					preview.BackgroundColor3 = c
					accent.BackgroundColor3 = c
					svBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
					svKnob.Position = UDim2.new(S, 0, 1 - V, 0)
					hueKnob.Position = UDim2.new(H, 0, 0.5, 0)
					hexBox.Text = string.format("%02X%02X%02X", math.round(c.R*255), math.round(c.G*255), math.round(c.B*255))
					if config.Callback then task.spawn(config.Callback, c) end
					if config.Flag then getgenv()[config.Flag] = c end
				end

				local svDrag, hueDrag = false, false

				local svBtn = create("TextButton", { Text="", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ZIndex=13, Parent=svBox })
				svBtn.MouseButton1Down:Connect(function() svDrag = true end)
				UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag=false hueDrag=false end end)

				local hueBtn = create("TextButton", { Text="", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ZIndex=13, Parent=hueBar })
				hueBtn.MouseButton1Down:Connect(function() hueDrag = true end)

				RunService.RenderStepped:Connect(function()
					local mp = UserInputService:GetMouseLocation()
					if svDrag then
						local abs = svBox.AbsolutePosition
						local sz = svBox.AbsoluteSize
						S = math.clamp((mp.X - abs.X) / sz.X, 0, 1)
						V = 1 - math.clamp((mp.Y - abs.Y) / sz.Y, 0, 1)
						updateColor()
					elseif hueDrag then
						local abs = hueBar.AbsolutePosition
						local sz = hueBar.AbsoluteSize
						H = math.clamp((mp.X - abs.X) / sz.X, 0, 1)
						updateColor()
					end
				end)

				hexBox.FocusLost:Connect(function()
					local hex = hexBox.Text:gsub("#","")
					if #hex == 6 then
						local r = tonumber(hex:sub(1,2), 16)
						local g = tonumber(hex:sub(3,4), 16)
						local b = tonumber(hex:sub(5,6), 16)
						if r and g and b then
							local c = Color3.fromRGB(r, g, b)
							H, S, V = Color3.toHSV(c)
							updateColor()
						end
					end
				end)
			end

			local btn = create("TextButton", {
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ZIndex = 5,
				Parent = el,
			})

			btn.MouseButton1Click:Connect(function()
				opened = not opened
				if opened then
					buildPicker()
					tween(pickerFrame, { Size = UDim2.new(1, 0, 0, 192) }, 0.2)
				else
					tween(pickerFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
					task.delay(0.2, function()
						for _, c in ipairs(pickerFrame:GetChildren()) do
							if not c:IsA("UICorner") and not c:IsA("UIStroke") then c:Destroy() end
						end
					end)
				end
			end)

			btn.MouseEnter:Connect(function() tween(el, { BackgroundColor3 = THEME.ElementHover }, 0.12) end)
			btn.MouseLeave:Connect(function() tween(el, { BackgroundColor3 = THEME.Element }, 0.12) end)

			if config.Flag then getgenv()[config.Flag] = color end
			return ColorPicker
		end

		return Tab
	end

	function Window:Notify(config)
		config = config or {}
		local notifGui = create("ScreenGui", {
			Name = "WaveNotif",
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			ResetOnSpawn = false,
			DisplayOrder = 9999,
		})
		if syn and syn.protect_gui then
			syn.protect_gui(notifGui)
			notifGui.Parent = game.CoreGui
		elseif gethui then
			notifGui.Parent = gethui()
		else
			notifGui.Parent = game.CoreGui
		end

		local nFrame = create("Frame", {
			Size = UDim2.new(0, 280, 0, 70),
			Position = UDim2.new(1, 10, 1, -80),
			AnchorPoint = Vector2.new(1, 1),
			BackgroundColor3 = THEME.Topbar,
			BorderSizePixel = 0,
			Parent = notifGui,
		}, {
			create("UICorner", { CornerRadius = UDim.new(0, 10) }),
			create("UIStroke", { Color = THEME.Stroke, Thickness = 1 }),
		})

		local bar = create("Frame", {
			Size = UDim2.new(0, 3, 0.7, 0),
			Position = UDim2.new(0, 0, 0.15, 0),
			BackgroundColor3 = THEME.Accent,
			BorderSizePixel = 0,
			Parent = nFrame,
		}, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

		create("TextLabel", {
			Text = config.Title or "Wave",
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextColor3 = THEME.Text,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 22),
			Position = UDim2.new(0, 14, 0, 8),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = nFrame,
		})
		create("TextLabel", {
			Text = config.Content or "",
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = THEME.SubText,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 22),
			Position = UDim2.new(0, 14, 0, 32),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Parent = nFrame,
		})

		tween(nFrame, { Position = UDim2.new(1, -10, 1, -80) }, 0.3, Enum.EasingStyle.Back)
		task.delay(config.Duration or 3, function()
			tween(nFrame, { Position = UDim2.new(1, 300, 1, -80) }, 0.3)
			task.wait(0.35)
			notifGui:Destroy()
		end)
	end

	function Window:Destroy()
		ScreenGui:Destroy()
	end

	return Window
end

return Wave
