-- Servicios necesarios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Variables de estado
local aimbotEnabled = false
local selectedTargetCharacter = nil

-- Crear GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimbotPlayerListGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Botón principal: ON / OFF
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleBoton"
toggleButton.Size = UDim2.new(0, 160, 0, 45)
toggleButton.Position = UDim2.new(0, 20, 0, 80)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 16
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Text = "Aimbot: OFF"
toggleButton.Parent = screenGui

-- Contenedor de la lista de jugadores
local listFrame = Instance.new("ScrollingFrame")
listFrame.Name = "PlayerListFrame"
listFrame.Size = UDim2.new(0, 160, 0, 200)
listFrame.Position = UDim2.new(0, 20, 0, 135)
listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
listFrame.BackgroundTransparency = 0.3
listFrame.BorderSizePixel = 0
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.Parent = screenGui

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = listFrame
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Función para actualizar la lista de botones de jugadores
local function refreshPlayerList()
	-- Limpiar botones anteriores
	for _, child in ipairs(listFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	-- Crear un botón por cada jugador en la partida (excluyéndote a ti)
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			local pButton = Instance.new("TextButton")
			pButton.Size = UDim2.new(1, 0, 0, 35)
			pButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			pButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			pButton.TextSize = 14
			pButton.Font = Enum.Font.SourceSans
			pButton.Text = player.Name
			pButton.Parent = listFrame

			-- Al hacer clic en un jugador de la lista, se fija como objetivo
			pButton.MouseButton1Click:Connect(function()
				if player.Character and player.Character:FindFirstChild("Head") then
					selectedTargetCharacter = player.Character
					print("Objetivo fijado en: " .. player.Name)
					pButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
					task.wait(0.5)
					pButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				else
					print("El jugador no tiene personaje o cabeza válida.")
				end
			end)
		end
	end
	
	-- Ajustar tamaño del scroll automáticamente
	listFrame.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 35)
end

-- Actualizar lista cuando alguien entra o sale
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

-- Alternar Estado ON/OFF
toggleButton.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	if aimbotEnabled then
		toggleButton.Text = "Aimbot: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		refreshPlayerList() -- Refresca por si entró alguien nuevo
	else
		toggleButton.Text = "Aimbot: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		selectedTargetCharacter = nil
	end
end)

-- Bucle de seguimiento de cámara constante
RunService.RenderStepped:Connect(function()
	if not aimbotEnabled then return end
	
	if selectedTargetCharacter and selectedTargetCharacter:FindFirstChild("Head") then
		local head = selectedTargetCharacter.Head
		camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
	end
end)
