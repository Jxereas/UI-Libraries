_G.JxereasExistingHooks = _G.JxereasExistingHooks or {}
if not _G.JxereasExistingHooks.GuiDetectionBypass then
    local CoreGui = game.CoreGui
    local ContentProvider = game.ContentProvider
    local RobloxGuis = {"RobloxGui", "TeleportGui", "RobloxPromptGui", "RobloxLoadingGui", "PlayerList", "RobloxNetworkPauseNotification", "PurchasePrompt", "HeadsetDisconnectedDialog", "ThemeProvider", "DevConsoleMaster"}
    
    local function FilterTable(tbl)
        local context = syn_context_get()
        syn_context_set(7)
        local new = {}
        for i,v in ipairs(tbl) do --roblox iterates the array part
            if typeof(v) ~= "Instance" then
                table.insert(new, v)
            else
                if v == CoreGui or v == game then
                    --insert only the default roblox guis
                    for i,v in pairs(RobloxGuis) do
                        local gui = CoreGui:FindFirstChild(v)
                        if gui then
                            table.insert(new, gui)
                        end
                    end
    
                    if v == game then
                        for i,v in pairs(game:GetChildren()) do
                            if v ~= CoreGui then
                                table.insert(new, v)
                            end
                        end
                    end
                else
                    if not CoreGui:IsAncestorOf(v) then
                        table.insert(new, v)
                    else
                        --don't insert it if it's a descendant of a different gui than default roblox guis
                        for j,k in pairs(RobloxGuis) do
                            local gui = CoreGui:FindFirstChild(k)
                            if gui then
                                if v == gui or gui:IsAncestorOf(v) then
                                    table.insert(new, v)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        syn_context_set(context)
        return new
    end
    
    local old
    old = hookfunc(ContentProvider.PreloadAsync, function(self, tbl, cb)
        if self ~= ContentProvider or type(tbl) ~= "table" or type(cb) ~= "function" then --note: callback can be nil but in that case it's useless anyways
            return old(self, tbl, cb)
        end
    
        --check for any errors that I might've missed (such as table being {[2] = "something"} which causes "Unable to cast to Array")
        local err
        task.spawn(function() --TIL pcalling a C yield function inside a C yield function is a bad idea ("cannot resume non-suspended coroutine")
            local s,e = pcall(old, self, tbl)
            if not s and e then
                err = e
            end
        end)
       
        if err then
            return old(self, tbl) --don't pass the callback, just in case
        end
    
        tbl = FilterTable(tbl)
        return old(self, tbl, cb)
    end)
    
    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if self == ContentProvider and (method == "PreloadAsync" or method == "preloadAsync") then
            local args = {...}
            if type(args[1]) ~= "table" or type(args[2]) ~= "function" then
                return old(self, ...)
            end
    
            local err
            task.spawn(function()
                setnamecallmethod(method) --different thread, different namecall method
                local s,e = pcall(old, self, args[1])
                if not s and e then
                    err = e
                end
            end)
    
            if err then
                return old(self, args[1])
            end
    
            args[1] = FilterTable(args[1])
            setnamecallmethod(method)
            return old(self, args[1], args[2])
        end
        return old(self, ...)
    end)
    
    _G.JxereasExistingHooks.GuiDetectionBypass = true
end

local library = {}

local players = game:GetService("Players")
local player = players.LocalPlayer

for _, connection in pairs(getconnections(player.Idled)) do
	if connection.Enabled then
    	connection:Disable()
    end
end

function library:CreateWindow(windowName, inputedTheme)
	if game:GetService("CoreGui"):FindFirstChild("UILibrary") then
		game:GetService("CoreGui").UILibrary:Destroy()
	end

	local themeTable = {
		PageBackground = Color3.fromRGB(32, 34, 37),
		PageOutterBackground = Color3.fromRGB(54, 57, 63),
		ButtonBackground = Color3.fromRGB(52, 52, 52),
		HeaderButtons = Color3.fromRGB(255,255,255),
		TabBackground = Color3.fromRGB(47, 49, 54),
		TabColor = Color3.fromRGB(54, 57, 63),
		TabSelectedBackground = Color3.fromRGB(37, 39, 43),
		LabelColor = Color3.fromRGB(20, 20, 20),
		ButtonBoxColor = Color3.fromRGB(35, 35, 35),
		TextColor = Color3.fromRGB(255, 255, 255),
		PushedIconColor = Color3.fromRGB(60,60,60),
		SelectedIconColor = Color3.fromRGB(0,255,0),
		IconColor = Color3.fromRGB(255, 255, 255),
		ButtonBoxTextColor = Color3.fromRGB(255,255,255),
		TitleTextColor = Color3.fromRGB(114, 118, 125),
		TitleBackground = Color3.fromRGB(32, 34, 37)
	}
	
	inputedTheme = inputedTheme or {}
	for i, v in pairs(inputedTheme) do
		if themeTable[i] then
			themeTable[i] = v
		end
	end
	
	local offsetSizesTable = {}

	local mouse = player:GetMouse()

	local ts = game:GetService("TweenService")
	local uis = game:GetService("UserInputService")

	local UILibrary = Instance.new("ScreenGui")
	local MainWindow = Instance.new("Frame")
	local Background = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local Tabs = Instance.new("ScrollingFrame")
	local TabsElementListing = Instance.new("UIListLayout")
	local TabsPadding = Instance.new("UIPadding")
	local Pages = Instance.new("Frame")
	local PagesPadding = Instance.new("UIPadding")
	local pagesFolder = Instance.new("Folder")
	local Heading = Instance.new("Frame")
	local Title = Instance.new("TextLabel")
	local HeadingPadding = Instance.new("UIPadding")
	local CornerHiding = Instance.new("Frame")
	local CloseButton = Instance.new("ImageButton")
	local CloseAspect = Instance.new("UIAspectRatioConstraint")
	local MinimizeButton = Instance.new("ImageButton")
	local MinimizeAspect = Instance.new("UIAspectRatioConstraint")
	local MaximizeButton = Instance.new("ImageButton")
	local MaximizeAspect = Instance.new("UIAspectRatioConstraint")
	local Sample = Instance.new("ImageLabel")
	
	UILibrary.Name = "UILibrary"
	UILibrary.Parent = game:GetService("CoreGui")
	UILibrary.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	UILibrary.ResetOnSpawn = false

	MainWindow.Name = "MainWindow"
	MainWindow.Parent = UILibrary
	MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
	MainWindow.BackgroundColor3 = themeTable.TitleBackground
	MainWindow.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MainWindow.BorderSizePixel = 0
	MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainWindow.Size = UDim2.new(0.36, 0, 0.400000006, 0)

	Background.Name = "Background"
	Background.Parent = MainWindow
	Background.AnchorPoint = Vector2.new(1, 1)
	Background.BackgroundColor3 = themeTable.PageOutterBackground
	Background.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Background.BorderSizePixel = 0
	Background.Position = UDim2.new(1, 0, 1, 0)
	Background.Size = UDim2.new(0.949999988, 0, 0.949999988, 0)

	UICorner.Parent = Background

	Tabs.Name = "Tabs"
	Tabs.Parent = Background
	Tabs.Active = true
	Tabs.BackgroundColor3 = themeTable.TabBackground
	Tabs.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Tabs.BorderSizePixel = 0
	Tabs.Size = UDim2.new(0.25, 0, 1, 0)
	Tabs.ScrollBarThickness = 3

	TabsElementListing.Name = "TabsElementListing"
	TabsElementListing.Parent = Tabs
	TabsElementListing.SortOrder = Enum.SortOrder.LayoutOrder
	TabsElementListing.Padding = UDim.new(0, 2)

	TabsPadding.Name = "TabsPadding"
	TabsPadding.Parent = Tabs
	TabsPadding.PaddingBottom = UDim.new(0, 2)
	TabsPadding.PaddingLeft = UDim.new(0, 5)
	TabsPadding.PaddingRight = UDim.new(0, 5)
	TabsPadding.PaddingTop = UDim.new(0, 2)

	Pages.Name = "Pages"
	Pages.Parent = Background
	Pages.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Pages.BackgroundTransparency = 1.000
	Pages.BorderSizePixel = 0
	Pages.Position = UDim2.new(0.25, 0, 0, 0)
	Pages.Size = UDim2.new(0.75, 0, 1, 0)

	PagesPadding.Name = "PagesPadding"
	PagesPadding.Parent = Pages
	PagesPadding.PaddingBottom = UDim.new(0, 3)
	PagesPadding.PaddingLeft = UDim.new(0, 5)
	PagesPadding.PaddingRight = UDim.new(0, 5)
	PagesPadding.PaddingTop = UDim.new(0, 3)

	Heading.Name = "Heading"
	Heading.Parent = MainWindow
	Heading.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Heading.BackgroundTransparency = 1.000
	Heading.BorderSizePixel = 0
	Heading.Size = UDim2.new(1, 0, 0.0500000007, 0)

	Title.Name = "Title"
	Title.Parent = Heading
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title.BackgroundTransparency = 1.000
	Title.BorderSizePixel = 0
	Title.Size = UDim2.new(0.5, 0, 1, 0)
	Title.Font = Enum.Font.SourceSansBold
	Title.Text = windowName or "New Window"
	Title.TextColor3 = themeTable.TitleTextColor
	Title.TextScaled = true
	Title.TextSize = 14.000
	Title.TextWrapped = true
	Title.TextXAlignment = Enum.TextXAlignment.Left

	HeadingPadding.Name = "HeadingPadding"
	HeadingPadding.Parent = Heading
	HeadingPadding.PaddingLeft = UDim.new(0, 5)

	CloseButton.Name = "CloseButton"
	CloseButton.Parent = Heading
	CloseButton.AnchorPoint = Vector2.new(1, 0.5)
	CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.BackgroundTransparency = 1.000
	CloseButton.Position = UDim2.new(1, 0, 0.5, 0)
	CloseButton.Size = UDim2.new(1, 0, 1, 0)
	CloseButton.Image = "rbxassetid://3926305904"
	CloseButton.ImageColor3 = themeTable.HeaderButtons
	CloseButton.ImageRectOffset = Vector2.new(284, 4)
	CloseButton.ImageRectSize = Vector2.new(24, 24)
	CloseButton.ZIndex = 987

	CloseAspect.Name = "CloseAspect"
	CloseAspect.Parent = CloseButton

	MinimizeButton.Name = "MinimizeButton"
	MinimizeButton.Parent = Heading
	MinimizeButton.AnchorPoint = Vector2.new(1, 0.5)
	MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	MinimizeButton.BackgroundTransparency = 1.000
	MinimizeButton.BorderSizePixel = 0
	MinimizeButton.Position = UDim2.new(0.970000029, 0, 0.5, 0)
	MinimizeButton.Size = UDim2.new(1, 0, 1, 0)
	MinimizeButton.Image = "rbxassetid://3926305904"
	MinimizeButton.ImageColor3 = themeTable.HeaderButtons
	MinimizeButton.ImageRectOffset = Vector2.new(723, 280)
	MinimizeButton.ImageRectSize = Vector2.new(40, 40)
	MinimizeButton.ZIndex = 999

	MinimizeAspect.Name = "MinimizeAspect"
	MinimizeAspect.Parent = MinimizeButton

	MaximizeButton.Name = "MaximizeButton"
	MaximizeButton.Parent = Heading
	MaximizeButton.AnchorPoint = Vector2.new(1, 0.5)
	MaximizeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	MaximizeButton.BackgroundTransparency = 1
	MaximizeButton.Visible = false
	MaximizeButton.BorderSizePixel = 0
	MaximizeButton.Position = UDim2.new(0.925000012, 0, 0.5, 0)
	MaximizeButton.Size = UDim2.new(1, 0, 1, 0)
	MaximizeButton.Image = "rbxassetid://3926305904"
	MaximizeButton.ImageColor3 = themeTable.HeaderButtons
	MaximizeButton.ImageRectOffset = Vector2.new(962, 280)
	MaximizeButton.ImageRectSize = Vector2.new(40, 40)
	MaximizeButton.ImageTransparency = 0
	MaximizeButton.ZIndex = 998

	MaximizeAspect.Name = "MaximizeAspect"
	MaximizeAspect.Parent = MaximizeButton

	CornerHiding.Name = "CornerHiding"
	CornerHiding.Parent = MainWindow
	CornerHiding.AnchorPoint = Vector2.new(1, 1)
	CornerHiding.BackgroundColor3 = themeTable.PageOutterBackground
	CornerHiding.BorderColor3 = Color3.fromRGB(0, 0, 0)
	CornerHiding.BorderSizePixel = 0
	CornerHiding.Position = UDim2.new(1, 0, 1, 0)
	CornerHiding.Size = UDim2.new(0.949999988, 0, 0.100000001, 0)
	CornerHiding.ZIndex = 0

	Sample.Name = "Sample"
	Sample.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Sample.BackgroundTransparency = 1.000
	Sample.Image = "http://www.roblox.com/asset/?id=4560909609"
	Sample.ImageColor3 = Color3.fromRGB(0,0,0)
	Sample.ImageTransparency = 0.6

	pagesFolder.Name = "PagesFolder"
	pagesFolder.Parent = Pages

	--Get Middle Gui Tween Function
	local function getPositionOnGui(guiInstance, stringValue)
		local absPos = guiInstance.AbsolutePosition
		local absSize = guiInstance.AbsoluteSize

		local posClassifyTable = {
			["center"] = UDim2.new(0, absPos.X + absSize.X/2, 0, absPos.Y + absSize.Y/2);
			["topLeft"] = UDim2.new(0, absPos.X, 0, absPos.Y);
			["topMiddle"] = UDim2.new(0, absPos.X + absSize.X/2, 0, absPos.Y);
			["topRight"] = UDim2.new(0, absPos.X + absSize.X, 0, absPos.Y);
			["rightMiddle"] = UDim2.new(0, absPos.X + absSize.X, 0, absPos.Y + absSize.Y/2);
			["bottomRight"] = UDim2.new(0, absPos.X + absSize.X, 0, absPos.Y + absSize.Y);
			["bottomMiddle"] = UDim2.new(0, absPos.X + absSize.X/2, absPos.Y + absSize.Y);
			["bottomLeft"] = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y/2);
			["leftMiddle"] = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y/2);
		}

		for i, v in pairs(posClassifyTable) do
			if i == stringValue then
				return v
			end
		end
	end

	local function createButtonAnimation(instance)
		coroutine.wrap(function()
			local c = Sample:Clone()
			c.Parent = instance
			local x,y = (mouse.X - c.AbsolutePosition.X), (mouse.Y - c.AbsolutePosition.Y)

			c.Position = UDim2.new(0,x,0,y)
			local len,size = .35, nil
			if instance.AbsoluteSize.X >= instance.AbsoluteSize.Y then
				size = (instance.AbsoluteSize.X * 1.5)
			else
				size = (instance.AbsoluteSize.Y * 1.5)
			end

			c:TweenSizeAndPosition(UDim2.new(0, size,0,size), UDim2.new(.5,(-size/2),.5,(-size/2)), "In", "Linear", len, true)
			for _ = 1, 10 do
				c.ImageTransparency = c.ImageTransparency + .05
				wait(len / 12)
			end

			c:Destroy()
		end)()
	end

	--[[
	local function getPositionOnGuiVector(absPos, absSize,stringValue)
		local posClassifyTable = {
			["center"] = UDim2.new(0, absPos.X + absSize.X/2, 0, absPos.Y + absSize.Y/2);
			["topLeft"] = UDim2.new(0, absPos.X, 0, absPos.Y);
			["topMiddle"] = UDim2.new(0, absPos.X + absSize.X/2, 0, absPos.Y);
			["topRight"] = UDim2.new(0, absPos.X + absSize.X, 0, absPos.Y);
			["rightMiddle"] = UDim2.new(0, absPos.X + absSize.X, 0, absPos.Y + absSize.Y/2);
			["bottomRight"] = UDim2.new(0, absPos.X + absSize.X, 0, absPos.Y + absSize.Y);
			["bottomMiddle"] = UDim2.new(0, absPos.X + absSize.X/2, absPos.Y + absSize.Y);
			["bottomLeft"] = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y/2);
			["leftMiddle"] = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y/2);
		}

		for i, v in pairs(posClassifyTable) do
			if i == stringValue then
				return v
			end
		end
	end
	]]--NEVER USED

	--Drag Function
	local dragging
	local dragInput
	local dragStart
	local startPos	

	local function update(input)
		local viewport = workspace.CurrentCamera.ViewportSize
		local topLeft = MainWindow.AbsolutePosition
		local bottomRight = topLeft + MainWindow.AbsoluteSize
		local minOffsetX = MainWindow.Position.X.Offset + (0 - topLeft.X )
		local minOffsetY = MainWindow.Position.Y.Offset + (0 - topLeft.Y - 36)
		local maxOffsetX = MainWindow.Position.X.Offset + (viewport.X - bottomRight.X)
		local maxOffsetY = MainWindow.Position.Y.Offset + (viewport.Y - bottomRight.Y - 34)
		local delta = input.Position - dragStart
		local newPositionX = startPos.X.Offset + delta.X
		local newPositionY = startPos.Y.Offset + delta.Y
		if newPositionX < minOffsetX or newPositionX > maxOffsetX or newPositionY < minOffsetY or newPositionY > maxOffsetY then
			ts:Create(MainWindow, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Position = UDim2.new(startPos.X.Scale, math.clamp(startPos.X.Offset + delta.X, minOffsetX, maxOffsetX), startPos.Y.Scale, math.clamp(startPos.Y.Offset + delta.Y, minOffsetY, maxOffsetY))}):Play()
		else
			ts:Create(MainWindow, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
		end
	end

	Heading.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = MainWindow.Position
		end

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end)
	Heading.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	uis.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)

	--Close function
	CloseButton.MouseButton1Click:Connect(function()
		MainWindow:TweenSize(UDim2.new(0,0,0,0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, .2, false)
		wait(.2)
		UILibrary:Destroy()
	end)

	--Keybind Visible
	uis.InputBegan:Connect(function(input, isTyping)
		if input.KeyCode == Enum.KeyCode.RightControl and not isTyping then
			UILibrary.Enabled = not UILibrary.Enabled
		end
	end)

	local diffPositionHeading
	local diffPositionMainWindow
	local isClosed = false

	--Minimize Function
	MinimizeButton.MouseButton1Click:Connect(function()
		if isClosed == false then
			local headingPos, headingSize = Heading.AbsolutePosition, Heading.AbsoluteSize
			local changedPositionHeading = getPositionOnGui(Heading, "center")
			local changedPositionMainWindow = MainWindow.AbsolutePosition.Y + MainWindow.AbsoluteSize.Y/2

			MainWindow:TweenSizeAndPosition(UDim2.new(0.36, 0, 0.02, 0), getPositionOnGui(Heading, "center"), Enum.EasingDirection.In, Enum.EasingStyle.Linear, .2, true)
			Heading:TweenSize(UDim2.new(0,0,0,0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, .2, true)
			wait(.2)
			MinimizeButton.Visible = false
			MaximizeButton.Visible = true
			Background.Visible = false
			CornerHiding.Visible = false			

			diffPositionHeading = changedPositionHeading.X.Offset - MainWindow.AbsolutePosition.X
			diffPositionMainWindow = changedPositionMainWindow - MainWindow.AbsolutePosition.Y

			MainWindow:TweenSizeAndPosition(UDim2.new(0.15, 0,0.02, 0), UDim2.new(0, headingPos.X + headingSize.X * .208, 0, headingPos.Y + headingSize.Y/2), Enum.EasingDirection.In, Enum.EasingStyle.Linear, .2, true)
			Heading:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, .2, true)

			isClosed = true	
		end
	end)

	--Maxamize Function
	MaximizeButton.MouseButton1Click:Connect(function()
		if isClosed then
			MainWindow:TweenSizeAndPosition(UDim2.new(0.36, 0, 0.02, 0), UDim2.new(0, MainWindow.AbsolutePosition.X + diffPositionHeading, 0, MainWindow.AbsolutePosition.Y + MainWindow.AbsoluteSize.Y/2), Enum.EasingDirection.In, Enum.EasingStyle.Linear, .2, true)
			wait(.2)
			MaximizeButton.Visible = false
			MinimizeButton.Visible = true
			Background.Visible = true
			CornerHiding.Visible = true
			Heading.Size = UDim2.new(1, 0, 0.0500000007, 0)
			MainWindow:TweenSizeAndPosition(UDim2.new(0.36, 0, 0.400000006, 0), UDim2.new(0, MainWindow.AbsolutePosition.X + MainWindow.AbsoluteSize.X/2, 0, MainWindow.AbsolutePosition.Y + diffPositionMainWindow), Enum.EasingDirection.In, Enum.EasingStyle.Linear, .2, true)

			isClosed = false
		end
	end)

	local tabHandler = {}

	function tabHandler:CreateTab(tabName, imageInfo)
		local TabButton = Instance.new("TextButton")
		local TabButtonCorner = Instance.new("UICorner")

		local NewPage = Instance.new("Frame")
		local PageBackground = Instance.new("Frame")
		local PageBackgroundCorner = Instance.new("UICorner")
		local PageScrollFrame = Instance.new("ScrollingFrame")
		local PageElementListing = Instance.new("UIListLayout")
		local PagePadding = Instance.new("UIPadding")

		TabButton.Name = "TabButton"
		TabButton.Parent = Tabs
		TabButton.BackgroundColor3 = themeTable.TabColor
		TabButton.BorderSizePixel = 0
		TabButton.Size = UDim2.new(1, 0, 0.0500000007, 0)
		TabButton.ClipsDescendants = true
		TabButton.Text = tabName or "New Tab"
		TabButton.Font = Enum.Font.GothamBold
		TabButton.TextColor3 = themeTable.TextColor
		TabButton.TextSize = 16.000
		TabButton.Size = UDim2.new(0, TabButton.AbsoluteSize.X, 0, TabButton.AbsoluteSize.Y)

		TabButtonCorner.CornerRadius = UDim.new(0, 3)
		TabButtonCorner.Name = "TabButtonCorner"
		TabButtonCorner.Parent = TabButton

		NewPage.Name = "NewPage"
		NewPage.Parent = pagesFolder
		NewPage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		NewPage.BackgroundTransparency = 1.000
		NewPage.BorderSizePixel = 0
		NewPage.Size = UDim2.new(1, 0, 1, 0)
		NewPage.Visible = false

		PageBackground.Name = "PageBackground"
		PageBackground.Parent = NewPage
		PageBackground.BackgroundColor3 = themeTable.PageBackground
		PageBackground.Size = UDim2.new(1, 0, 1, 0)
		PageBackground.ZIndex = 0

		PageBackgroundCorner.CornerRadius = UDim.new(0, 5)
		PageBackgroundCorner.Name = "PageBackgroundCorner"
		PageBackgroundCorner.Parent = PageBackground

		PageScrollFrame.Name = "PageScrollFrame"
		PageScrollFrame.Parent = NewPage
		PageScrollFrame.Active = true
		PageScrollFrame.BackgroundColor3 = themeTable.PageBackground
		PageScrollFrame.BackgroundTransparency = 1.000
		PageScrollFrame.BorderSizePixel = 0
		PageScrollFrame.Size = UDim2.new(1, 0, 1, 0)
		PageScrollFrame.ScrollBarThickness = 0

		PageElementListing.Name = "PageElementListing"
		PageElementListing.Parent = PageScrollFrame
		PageElementListing.SortOrder = Enum.SortOrder.LayoutOrder
		PageElementListing.Padding = UDim.new(0, 3)

		PagePadding.Name = "PagePadding"
		PagePadding.Parent = PageScrollFrame
		PagePadding.PaddingBottom = UDim.new(0, 5)
		PagePadding.PaddingLeft = UDim.new(0, 5)
		PagePadding.PaddingRight = UDim.new(0, 5)
		PagePadding.PaddingTop = UDim.new(0, 5)

		if imageInfo then
			local tabImage = Instance.new("ImageLabel")
			tabImage.Size = UDim2.new(0, TabButton.AbsoluteSize.Y - 2.5, 1, -5)
			tabImage.Position = UDim2.fromOffset(2.5,2.5)
			tabImage.BackgroundTransparency = 1
			tabImage.ImageColor3 = imageInfo.ImageColor or themeTable.IconColor
			tabImage.Image = imageInfo.Id or "rbxasset://textures/ui/GuiImagePlaceholder.png"
			tabImage.Parent = TabButton
		end

		local testFrame = PageScrollFrame:Clone()
		testFrame.Size = UDim2.new(0, PageScrollFrame.AbsoluteSize.X, 0, PageScrollFrame.AbsoluteSize.Y)
		--\\ ADD DYNAMIC SCROLL BAR AND CONVERT OFFSETS
		local function findOffset(instance, scrollParent, isDropdown)
			if isDropdown then
				instance.Size = UDim2.fromOffset(325,29)
				return
			end
			if offsetSizesTable[tostring(instance.Name)] ~= nil then
				instance.Size = offsetSizesTable[tostring(instance.Name)]	
			else
				instance.Parent = testFrame
				instance.Size = UDim2.new(0,instance.AbsoluteSize.X,0,instance.AbsoluteSize.Y)
				offsetSizesTable[tostring(instance.Name)] = instance.Size
				instance.Parent = scrollParent
			end
		end

		findOffset(TabButton, Tabs)

		--\\ AUTO SCALE SCROLLING FRAME AND CONVERT TO OFFSET
		PageElementListing:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			PageScrollFrame.CanvasSize = UDim2.new(0,0,0, PageElementListing.AbsoluteContentSize.Y + PagePadding.PaddingBottom.Offset + PageElementListing.Padding.Offset)
		end)

		TabsElementListing:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Tabs.CanvasSize = UDim2.new(0,0,0, TabsElementListing.AbsoluteContentSize.Y + PagePadding.PaddingBottom.Offset + PageElementListing.Padding.Offset)
		end)

		TabButton.MouseButton1Click:Connect(function()
			coroutine.wrap(function()
				createButtonAnimation(TabButton)

				for _, tab in pairs(Tabs:GetChildren()) do
					if tab:IsA("TextButton") then
						tab.BackgroundColor3 = themeTable.TabColor
					end
				end

				TabButton.BackgroundColor3 = themeTable.TabSelectedBackground

				for _, v in pairs(pagesFolder:GetChildren()) do
					if v ~= NewPage and v.Visible == true then
						v:TweenSize(UDim2.fromScale(1,.0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, .25, true)
						task.wait(.25)
						v.Visible = false
					end
				end

				NewPage.Visible = true
				NewPage:TweenSize(UDim2.fromScale(1,1), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, .5, true)
			end)()
		end)

		NewPage.Size = UDim2.fromScale(1,0)
		pagesFolder:GetChildren()[1].Visible = true
		pagesFolder:GetChildren()[1].Size = UDim2.fromScale(1,1)
		Tabs:GetChildren()[3].BackgroundColor3 = themeTable.TabSelectedBackground

		local elementHandler = {}
		elementHandler.__index = elementHandler

		elementHandler.Parent = PageScrollFrame
		elementHandler.Size = UDim2.fromScale(1, 0.0500000007)
		elementHandler.isDropdown = false

		function elementHandler:RemoveUI(InstanceType, InstanceText)
			InstanceType = InstanceType or nil
			InstanceText = InstanceText or nil

			if InstanceType ~= nil then
				if InstanceType:lower() == "tab" then
					TabButton:Destroy()
					NewPage:Destroy()
				else
					for _, element in pairs(PageScrollFrame:GetDescendants()) do
						if element:IsA("Frame") and element.Name:lower():find("element") and element.Name:lower():find(InstanceType:lower()) then
							for _, textLabel in pairs(element:GetDescendants()) do
								if textLabel:IsA("TextLabel") and textLabel.Text:lower() == InstanceText:lower() then
									element:Destroy()
								end
							end
						end
					end
				end
			else
				warn("Add valid instanceType: argument 1")
			end	
		end

		function elementHandler:Button(buttonName, callback, imageInfo)						
			local ButtonElement = Instance.new("Frame")
			local Button = Instance.new("TextButton")
			local ButtonCorner = Instance.new("UICorner")
			local TouchImage = Instance.new("ImageLabel")
			local ButName = Instance.new("TextLabel")

			callback = callback or function() end

			ButtonElement.Name = "ButtonElement"
			ButtonElement.Parent = self.Parent
			ButtonElement.BackgroundColor3 = themeTable.ButtonBackground
			ButtonElement.BackgroundTransparency = 1.000
			ButtonElement.ClipsDescendants = true
			ButtonElement.Size = self.Size

			findOffset(ButtonElement, self.Parent, self.isDropdown)

			Button.Name = "Button"
			Button.Parent = ButtonElement
			Button.BackgroundColor3 = themeTable.ButtonBackground
			Button.Size = UDim2.new(1, 0, 1, 0)
			Button.Font = Enum.Font.SourceSansSemibold
			Button.Text = ""
			Button.TextColor3 = themeTable.TextColor
			Button.TextSize = 18.000

			ButtonCorner.CornerRadius = UDim.new(0, 5)
			ButtonCorner.Name = "ButtonCorner"
			ButtonCorner.Parent = Button

			TouchImage.Name = "TouchImage"
			TouchImage.AnchorPoint = Vector2.new(0,.5)
			TouchImage.Position = UDim2.new(0,3,.5,0)
			TouchImage.BackgroundColor3 = themeTable.IconColor
			TouchImage.BackgroundTransparency = 1.000
			TouchImage.BorderSizePixel = 0
			TouchImage.Size = UDim2.fromOffset(20, 20)
			TouchImage.ImageColor3 = imageInfo and imageInfo.ImageColor or themeTable.IconColor
			TouchImage.Image = imageInfo and imageInfo.Id or "rbxassetid://9322846658"
			TouchImage.Parent = Button

			ButName.Name = "ButName"
			ButName.Parent = Button
			ButName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ButName.BackgroundTransparency = 1.000
			ButName.Position = UDim2.new(0, 26, 0, 0)
			ButName.Size = UDim2.new(1, -26, 1, 0)
			ButName.Font = Enum.Font.GothamSemibold
			ButName.Text = buttonName or "New Button"
			ButName.TextColor3 = themeTable.TextColor
			ButName.TextSize = 18.000
			ButName.TextXAlignment = Enum.TextXAlignment.Left

			Button.MouseButton1Click:Connect(function()
				coroutine.wrap(function()
					createButtonAnimation(Button)

					local tweenEnable = ts:Create(TouchImage, TweenInfo.new(.1), {ImageColor3 = imageInfo and imageInfo.ImageColor or themeTable.PushedIconColor})
					tweenEnable:Play()
					tweenEnable.Completed:Wait()
					local tweenDisable = ts:Create(TouchImage, TweenInfo.new(.1), {ImageColor3 = imageInfo and imageInfo.ImageColor or themeTable.IconColor})
					tweenDisable:Play()
				end)()

				callback()
			end)
		end

		function elementHandler:Toggle(toggleName, callback, imageInfo)
			local ToggleElement = Instance.new("Frame")
			local Button = Instance.new("TextButton")
			local ButtonCorner = Instance.new("UICorner")
			local ToggleDisabled = Instance.new("ImageLabel")
			local ToggleEnabled = Instance.new("ImageLabel")
			local TogName = Instance.new("TextLabel")

			callback = callback or function() end

			ToggleElement.Name = "ToggleElement"
			ToggleElement.Parent = self.Parent
			ToggleElement.BackgroundColor3 = themeTable.ButtonBackground
			ToggleElement.BackgroundTransparency = 1
			ToggleElement.ClipsDescendants = true
			ToggleElement.Size = self.Size

			findOffset(ToggleElement, self.Parent, self.isDropdown)

			Button.Name = "Button"
			Button.Parent = ToggleElement
			Button.BackgroundColor3 = themeTable.ButtonBackground
			Button.BackgroundTransparency = 0
			Button.AutoButtonColor = true
			Button.BorderSizePixel = 0
			Button.Size = UDim2.new(1, 0, 1, 0)
			Button.Font = Enum.Font.SourceSans
			Button.Text = ""
			Button.TextColor3 = themeTable.TextColor
			Button.TextSize = 18.000

			ButtonCorner.CornerRadius = UDim.new(0, 5)
			ButtonCorner.Name = "ButtonCorner"
			ButtonCorner.Parent = Button

			ToggleDisabled.Name = "ToggleDisabled"
			ToggleDisabled.AnchorPoint = Vector2.new(0,.5)
			ToggleDisabled.Position = UDim2.new(0,3,.5,0)
			ToggleDisabled.BackgroundColor3 = themeTable.IconColor
			ToggleDisabled.BackgroundTransparency = 1.000
			ToggleDisabled.BorderSizePixel = 0
			ToggleDisabled.Size = UDim2.fromOffset(20,20)
			ToggleDisabled.ImageColor3 = themeTable.IconColor
			ToggleDisabled.Image = imageInfo and imageInfo.Id or "rbxassetid://9323553784"
			ToggleDisabled.Parent = Button

			ToggleEnabled.Name = "ToggleEnabled"
			ToggleEnabled.AnchorPoint = Vector2.new(0,.5)
			ToggleEnabled.Position = UDim2.new(0,3,.5,0)
			ToggleEnabled.BackgroundColor3 = themeTable.IconColor
			ToggleEnabled.BackgroundTransparency = 1.000
			ToggleEnabled.Size = UDim2.fromOffset(20,20)
			ToggleEnabled.Image = imageInfo and imageInfo.Id or "rbxassetid://9323551028"
			ToggleEnabled.ImageColor3 = imageInfo and imageInfo.ImageColor or themeTable.SelectedIconColor
			ToggleEnabled.ImageTransparency = 1.000
			ToggleEnabled.Parent = Button

			TogName.Name = "TogName"
			TogName.Parent = Button
			TogName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TogName.BackgroundTransparency = 1.000
			TogName.Position = UDim2.new(0, 26, 0, 0)
			TogName.Size = UDim2.new(1, -26, 1, 0)
			TogName.Font = Enum.Font.GothamSemibold
			TogName.Text = toggleName or "New Toggle"
			TogName.TextColor3 = themeTable.TextColor
			TogName.TextSize = 18.000
			TogName.TextXAlignment = Enum.TextXAlignment.Left

			local toggle = false

			Button.MouseButton1Click:Connect(function()
				toggle = not toggle
				createButtonAnimation(Button)
				coroutine.wrap(function()
					if toggle then
						local tweenEnable = ts:Create(ToggleEnabled, TweenInfo.new(.25), {ImageTransparency = 0})
						local tweenDisable = ts:Create(ToggleDisabled, TweenInfo.new(.05), {ImageTransparency = 1})
						tweenDisable:Play()
						tweenEnable:Play()
					else
						local tweenEnable = ts:Create(ToggleEnabled, TweenInfo.new(.05), {ImageTransparency = 1})
						local tweenDisable = ts:Create(ToggleDisabled, TweenInfo.new(.25), {ImageTransparency = 0})
						tweenEnable:Play()
						tweenDisable:Play()
					end
				end)()				

				callback(toggle)
			end)

			local toggleHandler = {}

			function toggleHandler:SetToggle(toggleSetBoolean)
				coroutine.wrap(function()
					toggle = toggleSetBoolean
					if toggle then
						local tweenEnable = ts:Create(ToggleEnabled, TweenInfo.new(.25), {ImageTransparency = 0})
						local tweenDisable = ts:Create(ToggleDisabled, TweenInfo.new(.05), {ImageTransparency = 1})
						tweenDisable:Play()
						tweenEnable:Play()
					else
						local tweenEnable = ts:Create(ToggleEnabled, TweenInfo.new(.05), {ImageTransparency = 1})
						local tweenDisable = ts:Create(ToggleDisabled, TweenInfo.new(.25), {ImageTransparency = 0})
						tweenEnable:Play()
						tweenDisable:Play()
					end
				end)()
			end

			return toggleHandler
		end

		function elementHandler:TextBox(boxName, callback, imageInfo)
			local TextBoxElement = Instance.new("Frame")
			local Button = Instance.new("TextButton")
			local PencilImage = Instance.new("ImageLabel")
			local ElementCorner = Instance.new("UICorner")
			local TextName = Instance.new("TextLabel")
			local TextBox = Instance.new("TextBox")
			local ElementCorner_2 = Instance.new("UICorner")

			callback = callback or function() end

			TextBoxElement.Name = "TextBoxElement"
			TextBoxElement.Parent = self.Parent
			TextBoxElement.BackgroundColor3 = themeTable.ButtonBackground
			TextBoxElement.ClipsDescendants = true
			TextBoxElement.Size = self.Size

			findOffset(TextBoxElement, self.Parent, self.isDropdown)			

			Button.Name = "Button"
			Button.Parent = TextBoxElement
			Button.BackgroundColor3 = themeTable.ButtonBackground
			Button.BackgroundTransparency = 1.000
			Button.Size = UDim2.new(1, 0, 1, 0)
			Button.ZIndex = 2
			Button.Font = Enum.Font.SourceSansSemibold
			Button.Text = ""
			Button.TextColor3 = themeTable.TextColor
			Button.TextSize = 18.000

			PencilImage.Name = "PencilImage"
			PencilImage.AnchorPoint = Vector2.new(0,.5)
			PencilImage.Position = UDim2.new(0,3,.5,0)
			PencilImage.AnchorPoint = Vector2.new(0, 0.5)
			PencilImage.BackgroundColor3 = themeTable.IconColor
			PencilImage.BackgroundTransparency = 1.000
			PencilImage.BorderSizePixel = 0
			PencilImage.Size = UDim2.new(0,20,0,20)
			PencilImage.ImageColor3 = imageInfo and imageInfo.ImageColor or themeTable.IconColor
			PencilImage.Image = imageInfo and imageInfo.Id or "rbxassetid://9323815021"
			PencilImage.Parent = TextBoxElement

			ElementCorner.CornerRadius = UDim.new(0, 5)
			ElementCorner.Name = "ElementCorner"
			ElementCorner.Parent = TextBoxElement

			TextName.Name = "TextName"
			TextName.Parent = TextBoxElement
			TextName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextName.BackgroundTransparency = 1.000
			TextName.Position = UDim2.new(0,26,0,0)
			TextName.Size = UDim2.new(0.7, -34, 1, 0)
			TextName.Font = Enum.Font.GothamSemibold
			TextName.Text = boxName or "New TextBox"
			TextName.TextColor3 = themeTable.TextColor
			TextName.TextSize = 18.000
			TextName.TextXAlignment = Enum.TextXAlignment.Left

			TextBox.Parent = TextBoxElement
			TextBox.AnchorPoint = Vector2.new(1, 0.5)
			TextBox.BackgroundColor3 = themeTable.ButtonBoxColor
			TextBox.BorderSizePixel = 0
			TextBox.Position = UDim2.new(1, -3, 0.5, 0)
			TextBox.PlaceholderColor3 = themeTable.ButtonBoxTextColor
			TextBox.PlaceholderText = "Type Here!"
			TextBox.Text = ""
			TextBox.ZIndex = 999
			TextBox.ClipsDescendants = true
			TextBox.ClearTextOnFocus = false
			TextBox.Size = UDim2.new(.3, 0, 0.9, 0)
			TextBox.Font = Enum.Font.GothamSemibold
			TextBox.TextColor3 = themeTable.TextColor
			TextBox.TextSize = 12.000

			ElementCorner_2.CornerRadius = UDim.new(0, 5)
			ElementCorner_2.Name = "ElementCorner"
			ElementCorner_2.Parent = TextBox

			TextBox.FocusLost:Connect(function(enterPressed)
				if enterPressed then
					local isNumber = tonumber(TextBox.Text)
					if isNumber then
						callback(tonumber(TextBox.Text))
						wait(.18)
						TextBox.Text = ""
					else
						callback(TextBox.Text)
						wait(.18)
						TextBox.Text = ""
					end
				else
					return
				end
			end)
		end

		function elementHandler:Label(description, tbl, imageInfo)
			local LabelElement = Instance.new("Frame")
			local ElementCorner = Instance.new("UICorner")
			local LabName = Instance.new("TextLabel")
			local LabelImage = Instance.new("ImageLabel")

			tbl = tbl or {}

			local bgColor = tbl.BgColor or themeTable.LabelColor
			local textSize = tbl.TextSize or 18
			local textColor = tbl.TextColor or themeTable.TextColor

			LabelElement.Name = "LabelElement"
			LabelElement.Parent = self.Parent
			LabelElement.ClipsDescendants = true
			LabelElement.BackgroundColor3 = bgColor
			LabelElement.Size = self.Size

			findOffset(LabelElement, self.Parent, self.isDropdown)

			ElementCorner.CornerRadius = UDim.new(0, 5)
			ElementCorner.Name = "ElementCorner"
			ElementCorner.Parent = LabelElement

			LabName.Name = "LabName"
			LabName.Parent = LabelElement
			LabName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			LabName.BackgroundTransparency = 1.000
			LabName.Position = UDim2.new(0, 26, 0, 0)
			LabName.Size = UDim2.new(1, -26, 1, 0)
			LabName.Font = Enum.Font.GothamSemibold
			LabName.Text = description or "New Label"
			LabName.TextColor3 = textColor
			LabName.TextSize = textSize
			LabName.TextXAlignment = Enum.TextXAlignment.Left

			LabelImage.Name = "LabelImage"
			LabelImage.AnchorPoint = Vector2.new(0,.5)
			LabelImage.Position = UDim2.new(0,3,.5,0)
			LabelImage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			LabelImage.BackgroundTransparency = 1.000
			LabelImage.BorderSizePixel = 0
			LabelImage.Size = UDim2.new(0, 20, 0, 20)
			LabelImage.ImageColor3 = imageInfo and imageInfo.ImageColor or themeTable.IconColor
			LabelImage.Image = imageInfo and imageInfo.Id or "rbxassetid://9323772603"
			LabelImage.Parent = LabelElement

			local labelHandler = {}
			function labelHandler:ChangeText(newTxt)
				LabName.Text = newTxt
			end

			return labelHandler
		end

		function elementHandler:Slider(sliderName, maxValue, callback, imageInfo)			
			local SliderElement = Instance.new("Frame")
			local ElementCorner = Instance.new("UICorner")
			local SliderName = Instance.new("TextLabel")
			local SliderImage = Instance.new("ImageLabel")
			local Max = Instance.new("TextButton")
			local Bar = Instance.new("Frame")
			local BarCorner = Instance.new("UICorner")
			local MaxCorner = Instance.new("UICorner")
			local TextBox = Instance.new("TextBox")
			local TextBoxCorner = Instance.new("UICorner")
			local Fire = Instance.new("BoolValue")

			callback = callback or function() end

			SliderElement.Name = "SliderElement"
			SliderElement.Parent = self.Parent
			SliderElement.BackgroundColor3 = themeTable.ButtonBackground
			SliderElement.ClipsDescendants = true
			SliderElement.Size = self.Size

			findOffset(SliderElement, self.Parent, self.isDropdown)

			ElementCorner.CornerRadius = UDim.new(0, 5)
			ElementCorner.Name = "ElementCorner"
			ElementCorner.Parent = SliderElement

			SliderName.Name = "SliderName"
			SliderName.Parent = SliderElement
			SliderName.ClipsDescendants = true
			SliderName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SliderName.BackgroundTransparency = 1.000
			SliderName.Position = UDim2.new(0, 26, 0, 0)
			SliderName.Size = UDim2.new(.475, -37, 1, 0)
			SliderName.Font = Enum.Font.GothamSemibold
			SliderName.Text = sliderName or "New Slider"
			SliderName.TextColor3 = themeTable.TextColor
			SliderName.TextSize = 18.000
			SliderName.TextXAlignment = Enum.TextXAlignment.Left

			SliderImage.Name = "SliderImage"
			SliderImage.AnchorPoint = Vector2.new(0,.5)
			SliderImage.Position = UDim2.new(0,3,.5,0)
			SliderImage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			SliderImage.BackgroundTransparency = 1.000
			SliderImage.BorderSizePixel = 0
			SliderImage.Size = UDim2.new(0,20,0,20)
			SliderImage.ImageColor3 = imageInfo and imageInfo.ImageColor or themeTable.IconColor
			SliderImage.Image = imageInfo and imageInfo.Id or "rbxassetid://9323139890"
			SliderImage.Parent = SliderElement

			Max.Name = "Max"
			Max.Parent = SliderElement
			Max.AnchorPoint = Vector2.new(1, 0.5)
			Max.BackgroundColor3 = themeTable.ButtonBoxColor
			Max.BorderSizePixel = 0
			Max.Position = UDim2.new(1, -3, 0.5, 0)
			Max.Size = UDim2.new(0.425, 0, 0.5, 0)
			Max.Font = Enum.Font.SourceSans
			Max.Text = ""
			Max.TextColor3 = themeTable.TextColor
			Max.TextSize = 14.000

			Bar.Name = "Bar"
			Bar.Parent = Max
			Bar.BackgroundColor3 = themeTable.SelectedIconColor
			Bar.BorderSizePixel = 0
			Bar.Size = UDim2.new(0, 0, 1, 0)

			BarCorner.CornerRadius = UDim.new(0, 5)
			BarCorner.Name = "BarCorner"
			BarCorner.Parent = Bar

			MaxCorner.CornerRadius = UDim.new(0, 5)
			MaxCorner.Name = "MaxCorner"
			MaxCorner.Parent = Max

			TextBox.Parent = SliderElement
			TextBox.AnchorPoint = Vector2.new(1, 0.5)
			TextBox.BackgroundColor3 = themeTable.ButtonBoxColor
			TextBox.ClipsDescendants = true
			TextBox.Position = UDim2.new(.575, -5, 0.5, 0)
			TextBox.Size = UDim2.new(0.100000001, 0, 0.800000012, 0)
			TextBox.Font = Enum.Font.GothamBold
			TextBox.Text = "0"
			TextBox.TextColor3 = themeTable.ButtonBoxTextColor
			TextBox.TextSize = 14.000

			TextBoxCorner.CornerRadius = UDim.new(0, 5)
			TextBoxCorner.Name = "TextBoxCorner"
			TextBoxCorner.Parent = TextBox

			Fire.Value = false

			--Slider Handler
			local as = Vector2.new(Max.AbsoluteSize.X, Max.AbsoluteSize.Y)
			local down = false

			Max.MouseButton1Down:Connect(function()
				local ap = Vector2.new(Max.AbsolutePosition.X, Max.AbsolutePosition.Y)
				Bar.Size = UDim2.new(0,(mouse.X - ap.X),1,0)
				Fire.Value = true
				down = true
			end)

			uis.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					down = false
					Fire.Value = false
				end
			end)

			mouse.Move:Connect(function()
				if down == true then
					local ap = Vector2.new(Max.AbsolutePosition.X, Max.AbsolutePosition.Y)
					Fire.Value = false
					Fire.Value = true

					if mouse.X < ap.X then
						Bar.Size = UDim2.new(0,0,1,0)
					elseif mouse.X > (ap.X + as.X) then
						Bar.Size = UDim2.new(0,as.X,1,0)
					else
						Bar.Size = UDim2.new(0,(mouse.X-ap.X),1,0)
					end
				end
			end)

			--Text Control Handler
			Fire.Changed:Connect(function()
				if Fire.Value == true then
					local maxSize = as.X
					local size = Bar.Size.X.Offset
					maxValue = maxValue or 100
					local num = maxValue * (size/maxSize)

					TextBox.Text = math.ceil(num)
					callback(math.ceil(num))
				end
			end)

			TextBox.FocusLost:Connect(function(hitEnter)
				if hitEnter then
					if type(tonumber(TextBox.Text)) == "number" then
						local num = tonumber(TextBox.Text)

						if num >= 0 and num <=100 then
							Bar.Size = UDim2.new(0,((num/100)*as.X),1,0)

							callback(num)
						else
							TextBox.Text = "INVALID"
						end
					else
						TextBox.Text = "INVALID"
					end
				end
			end)
		end

		function elementHandler:Dropdown(dropdownName, tbl, callback, showNone, imageInfo)
			local DropdownElement = Instance.new("Frame")
			local DropdownButton = Instance.new("TextButton")
			local ButtonCorner = Instance.new("UICorner")
			local DropdownImage = Instance.new("ImageLabel")
			local DropdownName = Instance.new("TextLabel")
			local DropdownList = Instance.new("UIListLayout")
			local OptionSelect = Instance.new("TextButton")
			local UICorner = Instance.new("UICorner")
			local UIPadding = Instance.new("UIPadding")
			local TextLabel = Instance.new("TextLabel")		

			tbl = tbl or {}
			callback = callback or function() end
			showNone = showNone or false

			DropdownElement.Name = "DropdownElement"
			DropdownElement.Parent = self.Parent
			DropdownElement.BackgroundColor3 = themeTable.ButtonBackground
			DropdownElement.BackgroundTransparency = 1.000
			DropdownElement.ClipsDescendants = true
			DropdownElement.Size = self.Size

			findOffset(DropdownElement, self.Parent, self.isDropdown)

			DropdownButton.Name = "DropdownButton"
			DropdownButton.Parent = DropdownElement
			DropdownButton.BackgroundColor3 = themeTable.ButtonBackground
			DropdownButton.Size = UDim2.new(1,0,1,0)
			DropdownButton.ZIndex = 2
			DropdownButton.Font = Enum.Font.SourceSansSemibold
			DropdownButton.ClipsDescendants = true
			DropdownButton.Text = ""
			DropdownButton.TextColor3 = themeTable.TextColor
			DropdownButton.TextSize = 18.000

			ButtonCorner.CornerRadius = UDim.new(0, 5)
			ButtonCorner.Name = "ButtonCorner"
			ButtonCorner.Parent = DropdownButton

			DropdownImage.Name = "DropdownImage"
			DropdownImage.AnchorPoint = Vector2.new(0,.5)
			DropdownImage.Position = UDim2.new(0,3,.5,0)
			DropdownImage.BackgroundColor3 = themeTable.IconColor
			DropdownImage.BackgroundTransparency = 1.000
			DropdownImage.BorderSizePixel = 0
			DropdownImage.Size = UDim2.new(0,20,0,20)
			DropdownImage.ImageColor3 = imageInfo and imageInfo.ImageColor or themeTable.IconColor
			DropdownImage.Image = imageInfo and imageInfo.Id or "rbxassetid://9324047489"
			DropdownImage.Parent = DropdownButton

			DropdownName.Name = "DropdownName"
			DropdownName.Parent = DropdownButton
			DropdownName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			DropdownName.BackgroundTransparency = 1.000
			DropdownName.Position = UDim2.new(0, 26, 0, 0)
			DropdownName.Size = UDim2.new(1, -26, 1, 0)
			DropdownName.Font = Enum.Font.GothamSemibold
			DropdownName.Text = dropdownName or "New Dropdown"
			DropdownName.TextColor3 = themeTable.TextColor
			DropdownName.TextSize = 18.000
			DropdownName.TextXAlignment = Enum.TextXAlignment.Left

			DropdownList.Name = "DropdownList"
			DropdownList.Parent = DropdownElement
			DropdownList.SortOrder = Enum.SortOrder.LayoutOrder
			DropdownList.Padding = UDim.new(0, 3)	

			for _, v in pairs(tbl) do
				local OptionSelect = Instance.new("TextButton")
				local UICorner = Instance.new("UICorner")
				local UIPadding = Instance.new("UIPadding")
				local TextLabel = Instance.new("TextLabel")

				OptionSelect.Name = "OptionSelect"
				OptionSelect.Parent = DropdownElement
				OptionSelect.BackgroundColor3 = themeTable.ButtonBackground
				OptionSelect.Size = UDim2.new(0, 325, 0, 29)
				OptionSelect.Font = Enum.Font.SourceSans
				OptionSelect.ClipsDescendants = true
				OptionSelect.Text = ""
				OptionSelect.TextColor3 = themeTable.TextColor
				OptionSelect.TextSize = 14.000

				UICorner.CornerRadius = UDim.new(0, 5)
				UICorner.Parent = OptionSelect

				UIPadding.Parent = OptionSelect
				UIPadding.PaddingLeft = UDim.new(0, 5)
				UIPadding.PaddingRight = UDim.new(0, 5)

				TextLabel.Parent = OptionSelect
				TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel.BackgroundTransparency = 1.000
				TextLabel.Size = UDim2.new(1, 0, 1, 0)
				TextLabel.Font = Enum.Font.GothamSemibold
				TextLabel.Text = tostring(v) or "Selection Name"
				TextLabel.TextColor3 = themeTable.TextColor
				TextLabel.TextSize = 18.000
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left

				OptionSelect.MouseButton1Click:Connect(function()
					createButtonAnimation(OptionSelect)
					DropdownName.Text = TextLabel.Text
					callback(v)
				end)
			end

			if showNone then
				OptionSelect.Name = "OptionSelect"
				OptionSelect.Parent = DropdownElement
				OptionSelect.BackgroundColor3 = themeTable.ButtonBackground
				OptionSelect.Size = UDim2.new(0, 325, 0, 29)
				OptionSelect.Font = Enum.Font.SourceSans
				OptionSelect.ClipsDescendants = true
				OptionSelect.Text = ""
				OptionSelect.TextColor3 = themeTable.TextColor
				OptionSelect.TextSize = 14.000

				UICorner.CornerRadius = UDim.new(0, 5)
				UICorner.Parent = OptionSelect

				UIPadding.Parent = OptionSelect
				UIPadding.PaddingLeft = UDim.new(0, 5)
				UIPadding.PaddingRight = UDim.new(0, 5)

				TextLabel.Parent = OptionSelect
				TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel.BackgroundTransparency = 1.000
				TextLabel.Size = UDim2.new(1, 0, 1, 0)
				TextLabel.Font = Enum.Font.GothamSemibold
				TextLabel.Text = "None"
				TextLabel.TextColor3 = themeTable.TextColor
				TextLabel.TextSize = 18.000
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left

				OptionSelect.MouseButton1Click:Connect(function()
					createButtonAnimation(OptionSelect)
					DropdownName.Text = dropdownName or "New Dropdown"
				end)
			end

			local isOpen = false
			local debounce = false

			DropdownButton.MouseButton1Click:Connect(function()
				if debounce == false then
					debounce = true

					createButtonAnimation(DropdownButton)
					local size = DropdownList.AbsoluteContentSize	

					if isOpen then                
						DropdownElement:TweenSize(offsetSizesTable[DropdownElement.Name],Enum.EasingDirection.In, Enum.EasingStyle.Sine, .2, true)
						wait(.2)
						DropdownButton:TweenSize(UDim2.new(1,0,1,0),Enum.EasingDirection.In, Enum.EasingStyle.Sine, .2, true)
					else
						DropdownButton:TweenSize(UDim2.new(0,407,0,29),Enum.EasingDirection.In, Enum.EasingStyle.Sine, .2, true)
						wait(.2)
						DropdownElement:TweenSize(UDim2.new(1,0,0,size.Y),Enum.EasingDirection.In, Enum.EasingStyle.Sine, .2, true)             
					end
					isOpen = not isOpen
					debounce = false
				end
			end)

			local dropdownElementHandler = setmetatable({}, elementHandler)

			dropdownElementHandler.Parent = DropdownElement
			dropdownElementHandler.Size = UDim2.fromOffset(325,29)
			dropdownElementHandler.isDropdown = true

			return dropdownElementHandler
		end

		function elementHandler:Keybind(keybindName, defaultKeybind, callback, imageInfo)
			local KeybindElement = Instance.new("Frame")
			local Button = Instance.new("TextButton")
			local KeybindName = Instance.new("TextLabel")
			local KeyboardImage = Instance.new("ImageLabel")
			local KeybindText = Instance.new("TextLabel")
			local ElementCorner = Instance.new("UICorner")

			callback = callback or function() end

			KeybindElement.Name = "KeybindElement"
			KeybindElement.Parent = self.Parent
			KeybindElement.BackgroundColor3 = themeTable.ButtonBackground
			KeybindElement.BackgroundTransparency = 1
			KeybindElement.ClipsDescendants = true
			KeybindElement.Size = self.Size

			findOffset(KeybindElement, self.Parent, self.isDropdown)

			Button.Name = "Button"
			Button.Parent = KeybindElement
			Button.BackgroundColor3 = themeTable.ButtonBackground
			Button.BackgroundTransparency = 0
			Button.Size = UDim2.new(1, 0, 1, 0)
			Button.AutoButtonColor = true
			Button.ZIndex = 1
			Button.Font = Enum.Font.SourceSansSemibold
			Button.Text = ""
			Button.TextColor3 = themeTable.TextColor
			Button.TextSize = 18.000

			KeybindName.Name = "KeybindName"
			KeybindName.Parent = Button
			KeybindName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			KeybindName.BackgroundTransparency = 1.000
			KeybindName.Position = UDim2.new(0, 26, 0, 0)
			KeybindName.Size = UDim2.new(.8, -32, 1, 0)
			KeybindName.Font = Enum.Font.GothamSemibold
			KeybindName.Text = keybindName or "New Keybind"
			KeybindName.TextColor3 = themeTable.TextColor
			KeybindName.TextSize = 18.000
			KeybindName.TextXAlignment = Enum.TextXAlignment.Left

			KeyboardImage.Name = "KeyboardImage"
			KeyboardImage.AnchorPoint = Vector2.new(0,.5)
			KeyboardImage.Position = UDim2.new(0,3,.5,0)
			KeyboardImage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			KeyboardImage.BackgroundTransparency = 1.000
			KeyboardImage.BorderSizePixel = 0
			KeyboardImage.Size = UDim2.new(0,20,0,20)
			KeyboardImage.ImageColor3 = imageInfo and imageInfo.ImageColor or themeTable.IconColor
			KeyboardImage.Image = imageInfo and imageInfo.Id or "rbxassetid://9323980256"
			KeyboardImage.Parent = Button

			KeybindText.Name = "KeybindText"
			KeybindText.Parent = Button
			KeybindText.AnchorPoint = Vector2.new(1, 0)
			KeybindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			KeybindText.BackgroundTransparency = 1.000
			KeybindText.ClipsDescendants = true
			KeybindText.Position = UDim2.new(1, -3, 0, 0)
			KeybindText.Size = UDim2.new(0.2, 0, 1, 0)
			KeybindText.Font = Enum.Font.GothamSemibold
			KeybindText.Text = defaultKeybind.Name or "F"
			KeybindText.TextColor3 = themeTable.TextColor
			KeybindText.TextSize = 18.000
			KeybindText.TextXAlignment = Enum.TextXAlignment.Right

			ElementCorner.CornerRadius = UDim.new(0, 5)
			ElementCorner.Name = "ElementCorner"
			ElementCorner.Parent = Button

			Button.MouseButton1Click:Connect(function()
				createButtonAnimation(Button)

				KeybindText.Text = "..."

				local input, _ = uis.InputBegan:Wait()

				if input.KeyCode.Name ~= "Unknown" then
					KeybindText.Text = input.KeyCode.Name
					defaultKeybind = input.KeyCode
				end
			end)

			uis.InputBegan:Connect(function(input, isTyping)
				if not isTyping and input.UserInputType == Enum.UserInputType.Keyboard then
					if input.KeyCode == defaultKeybind then
						callback()
					end
				end
			end)
		end
		
		function elementHandler:ColorWheel(colorWheelName, callback, imageInfo)
			local ColorWheelElement = Instance.new("Frame")
			local Button = Instance.new("TextButton")
			local ColorWheelName = Instance.new("TextLabel")
			local PaintbrushImage = Instance.new("ImageLabel")
			local ElementCorner = Instance.new("UICorner")
			local CornerHider = Instance.new("Frame")
			local ColorSelectionFrame = Instance.new("Frame")
			local Wheel = Instance.new("ImageButton")
			local Selector = Instance.new("ImageLabel")
			local ValueButton = Instance.new("TextButton")
			local UIGradient = Instance.new("UIGradient")
			local ValueSliderBar = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local ColorSampleFrame = Instance.new("Frame")
			local elementListLayout = Instance.new("UIListLayout")
			
			ColorWheelElement.Name = "ColorWheelElement"
			ColorWheelElement.Parent = self.Parent
			ColorWheelElement.BackgroundColor3 = themeTable.ButtonBackground
			ColorWheelElement.BackgroundTransparency = 1.000
			ColorWheelElement.ClipsDescendants = true
			ColorWheelElement.Size = self.Size
			
			findOffset(ColorWheelElement, self.Parent, self.isDropdown)
			
			Button.Name = "Button"
			Button.Parent = ColorWheelElement
			Button.BackgroundColor3 = themeTable.ButtonBackground
			Button.Size = UDim2.fromScale(1,1)
			Button.Font = Enum.Font.SourceSansSemibold
			Button.Text = ""
			Button.TextColor3 = themeTable.TextColor
			Button.TextSize = 18.000

			ColorWheelName.Name = "ColorWheelName"
			ColorWheelName.Parent = Button
			ColorWheelName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ColorWheelName.BackgroundTransparency = 1.000
			ColorWheelName.Position = UDim2.new(0, 26, 0, 0)
			ColorWheelName.Size = UDim2.new(1, -26, 1, 0)
			ColorWheelName.Font = Enum.Font.GothamSemibold
			ColorWheelName.Text = "Color Wheel Name"
			ColorWheelName.TextColor3 = themeTable.TextColor
			ColorWheelName.TextSize = 18.000
			ColorWheelName.TextXAlignment = Enum.TextXAlignment.Left

			PaintbrushImage.Name = "PaintbrushImage"
			PaintbrushImage.Parent = Button
			PaintbrushImage.AnchorPoint = Vector2.new(0, 0.5)
			PaintbrushImage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			PaintbrushImage.BackgroundTransparency = 1.000
			PaintbrushImage.BorderSizePixel = 0
			PaintbrushImage.Position = UDim2.new(0, 3, 0.5, 0)
			PaintbrushImage.ImageColor3 = imageInfo and imageInfo.ImageColor or themeTable.IconColor
			PaintbrushImage.Size = UDim2.new(0, 20, 0, 20)
			PaintbrushImage.Image = imageInfo and imageInfo.Id or "rbxassetid://9508785673"

			ElementCorner.CornerRadius = UDim.new(0, 5)
			ElementCorner.Name = "ElementCorner"
			ElementCorner.Parent = Button

			ColorSelectionFrame.Name = "ColorSelectionFrame"
			ColorSelectionFrame.Parent = ColorWheelElement
			ColorSelectionFrame.BackgroundColor3 = themeTable.ButtonBackground
			ColorSelectionFrame.BorderSizePixel = 0
			ColorSelectionFrame.ZIndex = 0
			ColorSelectionFrame.Size = UDim2.new(0.600000024, 0, 0, 170)

			CornerHider.Name = "CornerHider"
			CornerHider.Parent = ColorSelectionFrame
			CornerHider.AnchorPoint = Vector2.new(0, 0)
			CornerHider.BackgroundColor3 = themeTable.ButtonBackground
			CornerHider.BorderSizePixel = 0
			CornerHider.Position = UDim2.new(0, 0, 0, -7)
			CornerHider.Size = UDim2.new(0.0500000007, 0, 0.100000001, 0)
			CornerHider.Visible = false

			Wheel.Name = "Wheel"
			Wheel.Parent = ColorSelectionFrame
			Wheel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Wheel.BackgroundTransparency = 1.000
			Wheel.Position = UDim2.new(0, 3, 0, 0)
			Wheel.Size = UDim2.new(0, 125, 0, 125)
			Wheel.Image = "rbxassetid://2849458409"

			Selector.Name = "Selector"
			Selector.Parent = Wheel
			Selector.AnchorPoint = Vector2.new(0.5, 0.5)
			Selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Selector.BackgroundTransparency = 1.000
			Selector.Position = UDim2.new(0.5, 0, 0.5, 0)
			Selector.Size = UDim2.new(0, 10, 0, 10)
			Selector.Image = "rbxassetid://9476341235"

			ValueButton.Name = "ValueButton"
			ValueButton.Parent = ColorSelectionFrame
			ValueButton.AnchorPoint = Vector2.new(0, 1)
			ValueButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ValueButton.BorderSizePixel = 0
			ValueButton.Position = UDim2.new(0, 3, 1, -3)
			ValueButton.Size = UDim2.new(1, -6, 0.150000006, -3)
			ValueButton.Font = Enum.Font.SourceSans
			ValueButton.Text = ""
			ValueButton.TextColor3 = themeTable.TextColor
			ValueButton.TextSize = 14.000

			UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
			UIGradient.Parent = ValueButton
			
			ValueSliderBar.Name = "ValueSliderBar"
			ValueSliderBar.Parent = ValueButton
			ValueSliderBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ValueSliderBar.Size = UDim2.new(0, 5, 1, 0)

			UICorner.Parent = ValueSliderBar
			
			ColorSampleFrame.Name = "ColorSampleFrame"
			ColorSampleFrame.Parent = ColorSelectionFrame
			ColorSampleFrame.AnchorPoint = Vector2.new(1, 0)
			ColorSampleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ColorSampleFrame.BorderSizePixel = 0
			ColorSampleFrame.Position = UDim2.new(1, -3, 0, 3)
			ColorSampleFrame.Size = UDim2.new(0, 30, 0, 30)

			elementListLayout.Name = "elementListLayout"
			elementListLayout.Parent = ColorWheelElement
			elementListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			
			local wheelDown = false
			local sliderDown = false
			local hue, saturation, value = 0,0,0
			
			local isOpen = false
			local offsetOriginialSize = offsetSizesTable[ColorWheelElement.Name]
			local uisConnection
			
			Button.Size = UDim2.new(0,Button.AbsoluteSize.X,0,Button.AbsoluteSize.Y)
			Button.MouseButton1Click:Connect(function()
				createButtonAnimation(Button)
				if isOpen then
					if uisConnection then
						uisConnection:Disconnect()
					end
					CornerHider.Visible = false
					ts:Create(ColorWheelElement, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Size = offsetOriginialSize}):Play()
				else
					uisConnection = uis.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							if wheelDown or sliderDown then
								wheelDown = false
								sliderDown = false
							end
						end
					end)
					CornerHider.Visible = true
					ts:Create(ColorWheelElement, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Size = UDim2.new(0,offsetOriginialSize.X.Offset,0,offsetOriginialSize.Y.Offset + ColorSelectionFrame.Size.Y.Offset)}):Play()
				end
				isOpen = not isOpen
			end)
			
			local function toPolar(v)
				return v.Magnitude, math.atan2(v.Y, v.X)
			end

			local function radToDeg(x)
				return ((x + math.pi) / (2 * math.pi)) * 360
			end
			
			local function update()
				local color = Color3.fromHSV(hue, saturation, value)

				ColorSampleFrame.BackgroundColor3 = color
				Selector.ImageColor3 = color
				ValueSliderBar.BackgroundColor3 = Color3.fromHSV(0,0,-value)
				UIGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(0,0,0)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, saturation, 1))
				})
				callback(color)
			end
			
			local function updateSlider(input)
				local relativePos = input.X - ValueButton.AbsolutePosition.X
				local posOnFrame = math.clamp(relativePos, 0, ValueButton.AbsoluteSize.X - ValueSliderBar.AbsoluteSize.X)

				value = 0 + (posOnFrame / (ValueButton.AbsoluteSize.X - ValueSliderBar.AbsoluteSize.X))
				ValueSliderBar.Position = UDim2.fromOffset(posOnFrame, 0)
				update()
			end
			
			local function updateWheel(input)
				local r = Wheel.AbsoluteSize.X/2
				local d = Vector2.new(input.X, input.Y) - Wheel.AbsolutePosition - Wheel.AbsoluteSize/2

				if d:Dot(d) > r*r then
					d = d.Unit * r
				end

				Selector.Position = UDim2.new(.5,d.X,.5,d.Y)
				local len, phi = toPolar(d * Vector2.new(1, -1))
				hue, saturation = radToDeg(phi)/360, math.clamp(len / r,0,1)
				update()
			end
			
			ValueButton.MouseButton1Down:Connect(function()
				sliderDown = true
				updateSlider(mouse)
			end)
			
			ValueButton.MouseMoved:Connect(function()
				if sliderDown then
					updateSlider(mouse)
				end
			end)
			
			Wheel.MouseButton1Down:Connect(function()
				wheelDown = true
				updateWheel(mouse)
			end)

			Wheel.MouseMoved:Connect(function()
				if wheelDown then
					updateWheel(mouse)
				end
			end)
		end
		
		function elementHandler:SearchBar(searchBarFillerText, searchElementsTable, callback, imageInfo)
		    local SearchElement = Instance.new("Frame")
		    local ScrollingFrame = Instance.new("ScrollingFrame")
		    local ScrollingFrameUIListLayout = Instance.new("UIListLayout")
		    local ScrollingFrameUIPadding = Instance.new("UIPadding")
		    local SearchElementTemplate = Instance.new("TextButton")
		    local UIPadding = Instance.new("UIPadding")
		    local UICorner = Instance.new("UICorner")
		    local SearchElementBackground = Instance.new("Frame")
		    local SearchBox = Instance.new("TextBox")
		    local SearchImage = Instance.new("ImageLabel")
		    local SearchElementBackgroundCorner = Instance.new("UICorner")

		    callback = callback or function() end
		    searchElementsTable = searchElementsTable or {}

		    SearchElement.Name = "SearchElement"
		    SearchElement.Parent = self.Parent
		    SearchElement.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
		    SearchElement.BackgroundTransparency = 1.000
		    SearchElement.BorderSizePixel = 0
		    SearchElement.ClipsDescendants = true
		    SearchElement.Size = self.Size

		    findOffset(SearchElement, self.Parent, self.isDropdown)

		    ScrollingFrame.Parent = SearchElement
		    ScrollingFrame.Active = true
		    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
		    ScrollingFrame.BackgroundTransparency = 1.000
		    ScrollingFrame.BorderSizePixel = 0
		    ScrollingFrame.Position = UDim2.new(0, 0, 0, SearchElement.Size.Y.Offset)
		    ScrollingFrame.Size = UDim2.new(0.7, 0, 0, 233)
		    ScrollingFrame.ScrollBarThickness = 0

		    ScrollingFrameUIListLayout.Name = "ScrollingFrameUIListLayout"
		    ScrollingFrameUIListLayout.Parent = ScrollingFrame
		    ScrollingFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		    ScrollingFrameUIListLayout.Padding = UDim.new(0, 3)

		    ScrollingFrameUIPadding.Name = "ScrollingFrameUIPadding"
		    ScrollingFrameUIPadding.Parent = ScrollingFrame
		    ScrollingFrameUIPadding.PaddingBottom = UDim.new(0, 3)
		    ScrollingFrameUIPadding.PaddingRight = UDim.new(0, 3)
		    ScrollingFrameUIPadding.PaddingTop = UDim.new(0, 3)

		    SearchElementTemplate.Name = "SearchElementTemplate"
		    SearchElementTemplate.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
		    SearchElementTemplate.BorderSizePixel = 0
		    SearchElementTemplate.Size = UDim2.new(1, 0, 0, 20)
		    SearchElementTemplate.Font = Enum.Font.GothamMedium
		    SearchElementTemplate.Text = ""
		    SearchElementTemplate.TextColor3 = Color3.fromRGB(255, 255, 255)
		    SearchElementTemplate.TextSize = 16.000
		    SearchElementTemplate.TextXAlignment = Enum.TextXAlignment.Left
		    SearchElementTemplate.ClipsDescendants = true

		    UIPadding.Parent = SearchElementTemplate
		    UIPadding.PaddingLeft = UDim.new(0, 4)

		    UICorner.CornerRadius = UDim.new(0, 5)
		    UICorner.Parent = SearchElementTemplate

		    SearchElementBackground.Name = "SearchElementBackground"
		    SearchElementBackground.Parent = SearchElement
		    SearchElementBackground.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
		    SearchElementBackground.Size = SearchElement.Size

		    SearchBox.Name = "SearchBox"
		    SearchBox.Parent = SearchElementBackground
		    SearchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		    SearchBox.BackgroundTransparency = 1.000
		    SearchBox.BorderSizePixel = 0
		    SearchBox.Position = UDim2.new(0, 26, 0, 0)
		    SearchBox.Size = UDim2.new(1, -26, 0, 28)
		    SearchBox.Font = Enum.Font.GothamMedium
		    SearchBox.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
		    SearchBox.PlaceholderText = searchBarFillerText or "Click to search..."
		    SearchBox.Text = ""
		    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		    SearchBox.TextSize = 18.000
		    SearchBox.TextXAlignment = Enum.TextXAlignment.Left

		    SearchImage.Name = "SearchImage"
		    SearchImage.Parent = SearchElementBackground
		    SearchImage.AnchorPoint = Vector2.new(0, 0.5)
		    SearchImage.BackgroundColor3 = themeTable.IconColor
		    SearchImage.BackgroundTransparency = 1.000
		    SearchImage.BorderSizePixel = 0
		    SearchImage.Position = UDim2.new(0, 3, 0, 14)
		    SearchImage.Size = UDim2.new(0, 20, 0, 20)
		    SearchImage.ImageColor3 = imageInfo and imageInfo.ImageColor or themeTable.IconColor
		    SearchImage.Image = imageInfo and imageInfo.Id or "rbxassetid://10117636771"

		    SearchElementBackgroundCorner.CornerRadius = UDim.new(0, 5)
		    SearchElementBackgroundCorner.Name = "SearchElementBackgroundCorner"
		    SearchElementBackgroundCorner.Parent = SearchElementBackground

		    ScrollingFrameUIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if ScrollingFrame.AbsoluteCanvasSize.Y < (ScrollingFrameUIListLayout.AbsoluteContentSize.Y + ScrollingFrameUIPadding.PaddingTop.Offset + ScrollingFrameUIPadding.PaddingBottom.Offset) then
			    ScrollingFrame.CanvasSize = UDim2.fromOffset(0, ScrollingFrameUIListLayout.AbsoluteContentSize.Y + ScrollingFrameUIPadding.PaddingTop.Offset + ScrollingFrameUIPadding.PaddingBottom.Offset)
			end
		    end)

		    for _, elementText in ipairs(searchElementsTable) do
			local elementClone = SearchElementTemplate:Clone()
			elementClone.Text = elementText
			elementClone.Parent = ScrollingFrame

			elementClone.MouseButton1Click:Connect(function()
			    coroutine.wrap(function()
				createButtonAnimation(elementClone)
				callback(elementClone.Text)
			    end)()
			end)
		    end

		    local originialSearchElementSize = SearchElement.Size

		    SearchBox.Focused:Connect(function()
			local openScrollingFrameTween = ts:Create(SearchElement, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,ScrollingFrame.Size.Y.Offset + SearchElement.Size.Y.Offset)})
			openScrollingFrameTween:Play()
		    end)

		    SearchBox.FocusLost:Connect(function()
			if SearchBox.Text == "" then
			    task.wait(.1)
			    local closeScrollingFrameTween = ts:Create(SearchElement, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = originialSearchElementSize})
			    closeScrollingFrameTween:Play()
			end
		    end)

		    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
			for _, txtElement in pairs(ScrollingFrame:GetChildren()) do
			    if not txtElement:IsA("TextButton") then continue end
			    if txtElement.Text:lower():find(SearchBox.Text:lower(), 1, true) then
				if txtElement.Visible == false then
				    txtElement.Visible = true
				end
			    else
				if txtElement.Visible then
				    txtElement.Visible = false
				end
			    end
			end
		    end)
		end
		
		return elementHandler
	end
	return tabHandler
end

return library
