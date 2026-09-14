local Core = ...
local NoxLib = Core.NoxLib
local Players = Core.Players
local RunService = Core.RunService
local UserInputService = Core.UserInputService
local ReplicatedStorage = Core.ReplicatedStorage
local Lighting = Core.Lighting
local GuiService = Core.GuiService
local player = Core.player
local NetManaged = Core.NetManaged
local GameEvents = Core.GameEvents
local RemoteList = Core.RemoteList
local Shared = Core.Shared
local FontMap = Core.FontMap
local getColor = Core.getColor
local getNumber = Core.getNumber
local getBool = Core.getBool
local getSwordWeapon = Core.getSwordWeapon
local hasItem = Core.hasItem
local getCharacterRoot = Core.getCharacterRoot
local getCharacterHumanoid = Core.getCharacterHumanoid
local isHumanoidAlive = Core.isHumanoidAlive
local isEnemyPlayer = Core.isEnemyPlayer
local getEntityRoot = Core.getEntityRoot
local getKnitController = Core.getKnitController
local getSwordController = Core.getSwordController
local getSprintController = Core.getSprintController
local getMoveInput = Core.getMoveInput
local collectAllEntities = Core.collectAllEntities
local getClosestTarget = Core.getClosestTarget
local findBed = Core.findBed

do
	local RainPart, RainEmitter, RainConn = nil, nil, nil
	local RAIN_SIZE, RAIN_RATE = 2000, 12000
	local function destroyRain()
		if RainEmitter then
			RainEmitter:Destroy();
			RainEmitter = nil
		end
		if RainPart then
			RainPart:Destroy();
			RainPart = nil
		end
		if RainConn then
			RainConn:Disconnect();
			RainConn = nil
		end
	end
	local function createRain(intensity)
		destroyRain()
		if not intensity or intensity <= 0 then
			return
		end
		RainPart = Instance.new("Part")
		RainPart.Name = "NoxRainPart"
		RainPart.Size = Vector3.new(RAIN_SIZE, 1, RAIN_SIZE)
		RainPart.Anchored = true
		RainPart.CanCollide = false
		RainPart.CanQuery = false
		RainPart.CanTouch = false
		RainPart.Transparency = 1
		RainPart.Parent = workspace
		RainEmitter = Instance.new("ParticleEmitter")
		RainEmitter.Texture = "rbxassetid://241876428"
		RainEmitter.Lifetime = NumberRange.new(0.6, 0.9)
		RainEmitter.Rate = RAIN_RATE * intensity
		RainEmitter.Speed = NumberRange.new(120, 160)
		RainEmitter.SpreadAngle = Vector2.new(3, 3)
		RainEmitter.Size = NumberSequence.new(0.45)
		RainEmitter.Transparency = NumberSequence.new(0.35)
		RainEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 215, 240))
		RainEmitter.EmissionDirection = Enum.NormalId.Bottom
		RainEmitter.VelocityInheritance = 0
		RainEmitter.Rotation = NumberRange.new(0, 0)
		RainEmitter.RotSpeed = NumberRange.new(0, 0)
		RainEmitter.Parent = RainPart
		RainConn = RunService.Heartbeat:Connect(function()
			local c = player.Character
			local r = c and c:FindFirstChild("HumanoidRootPart")
			if r and RainPart then
				RainPart.CFrame = CFrame.new(r.Position + Vector3.new(0, 70, 0))
			end
		end)
	end
	local ThemeRunning, ThemeConn, ThemeOrig, ThemeAtmo, ThemeSkyCreated = false, nil, nil, nil, false
	local Presets = {
		Day = {
			ClockTime = 14,
			Brightness = 3,
			ExposureCompensation = 0.2,
			Ambient = Color3.fromRGB(130, 130, 140),
			OutdoorAmbient = Color3.fromRGB(130, 130, 140),
			FogColor = Color3.fromRGB(200, 210, 230),
			FogStart = 0,
			FogEnd = 100000,
			EnvironmentDiffuseScale = 0.5,
			EnvironmentSpecularScale = 0.5,
			GlobalShadows = true,
			AtmoDensity = 0.30,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(215, 225, 245),
			AtmoDecay = Color3.fromRGB(110, 130, 160),
			AtmoGlare = 0,
			AtmoHaze = 0,
			Sky = "rbxassetid://102590176595275"
		},
		Sunset = {
			ClockTime = 18.2,
			Brightness = 2.2,
			ExposureCompensation = 0.15,
			Ambient = Color3.fromRGB(140, 100, 80),
			OutdoorAmbient = Color3.fromRGB(165, 110, 80),
			FogColor = Color3.fromRGB(255, 140, 90),
			FogStart = 0,
			FogEnd = 1200,
			EnvironmentDiffuseScale = 0.6,
			EnvironmentSpecularScale = 0.6,
			GlobalShadows = true,
			AtmoDensity = 0.42,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(255, 175, 120),
			AtmoDecay = Color3.fromRGB(120, 70, 60),
			AtmoGlare = 0.4,
			AtmoHaze = 2.2,
			Sky = "rbxassetid://102590176595275"
		},
		Dawn = {
			ClockTime = 5.8,
			Brightness = 2,
			ExposureCompensation = 0.1,
			Ambient = Color3.fromRGB(150, 120, 140),
			OutdoorAmbient = Color3.fromRGB(180, 130, 150),
			FogColor = Color3.fromRGB(230, 170, 190),
			FogStart = 0,
			FogEnd = 1500,
			EnvironmentDiffuseScale = 0.5,
			EnvironmentSpecularScale = 0.5,
			GlobalShadows = true,
			AtmoDensity = 0.38,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(230, 180, 210),
			AtmoDecay = Color3.fromRGB(110, 90, 120),
			AtmoGlare = 0.2,
			AtmoHaze = 1.5,
			Sky = "rbxassetid://102590176595275"
		},
		Night = {
			ClockTime = 0,
			Brightness = 1.2,
			ExposureCompensation = 0.1,
			Ambient = Color3.fromRGB(35, 40, 60),
			OutdoorAmbient = Color3.fromRGB(45, 50, 75),
			FogColor = Color3.fromRGB(20, 25, 45),
			FogStart = 0,
			FogEnd = 800,
			EnvironmentDiffuseScale = 0.35,
			EnvironmentSpecularScale = 0.35,
			GlobalShadows = true,
			AtmoDensity = 0.35,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(30, 40, 70),
			AtmoDecay = Color3.fromRGB(20, 25, 50),
			AtmoGlare = 0,
			AtmoHaze = 0.8,
			Sky = "rbxassetid://102590176595275",
			Rain = 0.5
		},
		Midnight = {
			ClockTime = 0,
			Brightness = 0.6,
			ExposureCompensation = 0.05,
			Ambient = Color3.fromRGB(18, 22, 35),
			OutdoorAmbient = Color3.fromRGB(22, 28, 45),
			FogColor = Color3.fromRGB(8, 10, 20),
			FogStart = 0,
			FogEnd = 350,
			EnvironmentDiffuseScale = 0.25,
			EnvironmentSpecularScale = 0.25,
			GlobalShadows = true,
			AtmoDensity = 0.42,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(15, 20, 40),
			AtmoDecay = Color3.fromRGB(10, 12, 25),
			AtmoGlare = 0,
			AtmoHaze = 1.2,
			Sky = "rbxassetid://102590176595275",
			Rain = 0.4
		},
		Stormy = {
			ClockTime = 11,
			Brightness = 0.9,
			ExposureCompensation = - 0.1,
			Ambient = Color3.fromRGB(80, 85, 95),
			OutdoorAmbient = Color3.fromRGB(90, 95, 105),
			FogColor = Color3.fromRGB(90, 95, 105),
			FogStart = 0,
			FogEnd = 250,
			EnvironmentDiffuseScale = 0.3,
			EnvironmentSpecularScale = 0.3,
			GlobalShadows = true,
			AtmoDensity = 0.48,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(120, 125, 135),
			AtmoDecay = Color3.fromRGB(70, 75, 85),
			AtmoGlare = 0,
			AtmoHaze = 3,
			Sky = "rbxassetid://102590176595275",
			Rain = 1.5
		},
		Foggy = {
			ClockTime = 8,
			Brightness = 1.5,
			ExposureCompensation = 0,
			Ambient = Color3.fromRGB(160, 165, 175),
			OutdoorAmbient = Color3.fromRGB(170, 175, 185),
			FogColor = Color3.fromRGB(200, 205, 215),
			FogStart = 0,
			FogEnd = 180,
			EnvironmentDiffuseScale = 0.4,
			EnvironmentSpecularScale = 0.4,
			GlobalShadows = true,
			AtmoDensity = 0.5,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(210, 215, 225),
			AtmoDecay = Color3.fromRGB(150, 155, 165),
			AtmoGlare = 0,
			AtmoHaze = 4,
			Sky = "rbxassetid://102590176595275",
			Rain = 0.35
		},
		Aurora = {
			ClockTime = 1,
			Brightness = 1.4,
			ExposureCompensation = 0.2,
			Ambient = Color3.fromRGB(40, 80, 90),
			OutdoorAmbient = Color3.fromRGB(60, 130, 140),
			FogColor = Color3.fromRGB(30, 90, 100),
			FogStart = 0,
			FogEnd = 900,
			EnvironmentDiffuseScale = 0.4,
			EnvironmentSpecularScale = 0.5,
			GlobalShadows = true,
			AtmoDensity = 0.35,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(80, 200, 180),
			AtmoDecay = Color3.fromRGB(40, 90, 110),
			AtmoGlare = 0.6,
			AtmoHaze = 1.2,
			Sky = "rbxassetid://102590176595275"
		},
		GoldenHour = {
			ClockTime = 17.4,
			Brightness = 2.6,
			ExposureCompensation = 0.25,
			Ambient = Color3.fromRGB(180, 130, 90),
			OutdoorAmbient = Color3.fromRGB(220, 160, 100),
			FogColor = Color3.fromRGB(255, 200, 130),
			FogStart = 0,
			FogEnd = 2200,
			EnvironmentDiffuseScale = 0.6,
			EnvironmentSpecularScale = 0.65,
			GlobalShadows = true,
			AtmoDensity = 0.4,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(255, 210, 150),
			AtmoDecay = Color3.fromRGB(160, 90, 60),
			AtmoGlare = 0.5,
			AtmoHaze = 2.4,
			Sky = "rbxassetid://102590176595275"
		},
		BloodMoon = {
			ClockTime = 0,
			Brightness = 0.9,
			ExposureCompensation = 0.1,
			Ambient = Color3.fromRGB(80, 15, 20),
			OutdoorAmbient = Color3.fromRGB(110, 20, 25),
			FogColor = Color3.fromRGB(60, 10, 12),
			FogStart = 0,
			FogEnd = 500,
			EnvironmentDiffuseScale = 0.4,
			EnvironmentSpecularScale = 0.4,
			GlobalShadows = true,
			AtmoDensity = 0.45,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(150, 30, 30),
			AtmoDecay = Color3.fromRGB(60, 10, 10),
			AtmoGlare = 0.3,
			AtmoHaze = 1.6,
			Sky = "rbxassetid://102590176595275"
		},
		Volcanic = {
			ClockTime = 12,
			Brightness = 1.1,
			ExposureCompensation = - 0.05,
			Ambient = Color3.fromRGB(70, 30, 25),
			OutdoorAmbient = Color3.fromRGB(95, 40, 25),
			FogColor = Color3.fromRGB(120, 45, 30),
			FogStart = 0,
			FogEnd = 400,
			EnvironmentDiffuseScale = 0.4,
			EnvironmentSpecularScale = 0.35,
			GlobalShadows = true,
			AtmoDensity = 0.55,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(160, 60, 30),
			AtmoDecay = Color3.fromRGB(70, 25, 20),
			AtmoGlare = 0.3,
			AtmoHaze = 3.5,
			Sky = "rbxassetid://102590176595275"
		},
		Arctic = {
			ClockTime = 10,
			Brightness = 2.8,
			ExposureCompensation = 0.15,
			Ambient = Color3.fromRGB(180, 200, 220),
			OutdoorAmbient = Color3.fromRGB(200, 220, 240),
			FogColor = Color3.fromRGB(230, 240, 255),
			FogStart = 0,
			FogEnd = 1200,
			EnvironmentDiffuseScale = 0.55,
			EnvironmentSpecularScale = 0.55,
			GlobalShadows = true,
			AtmoDensity = 0.3,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(230, 240, 255),
			AtmoDecay = Color3.fromRGB(150, 170, 200),
			AtmoGlare = 0,
			AtmoHaze = 1,
			Sky = "rbxassetid://102590176595275"
		},
		Tropical = {
			ClockTime = 15,
			Brightness = 3.2,
			ExposureCompensation = 0.25,
			Ambient = Color3.fromRGB(150, 190, 180),
			OutdoorAmbient = Color3.fromRGB(180, 220, 200),
			FogColor = Color3.fromRGB(200, 240, 220),
			FogStart = 0,
			FogEnd = 3000,
			EnvironmentDiffuseScale = 0.65,
			EnvironmentSpecularScale = 0.65,
			GlobalShadows = true,
			AtmoDensity = 0.28,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(200, 245, 225),
			AtmoDecay = Color3.fromRGB(100, 170, 130),
			AtmoGlare = 0,
			AtmoHaze = 0.6,
			Sky = "rbxassetid://102590176595275"
		},
		Desert = {
			ClockTime = 13,
			Brightness = 3.4,
			ExposureCompensation = 0.3,
			Ambient = Color3.fromRGB(210, 180, 130),
			OutdoorAmbient = Color3.fromRGB(240, 210, 160),
			FogColor = Color3.fromRGB(245, 220, 170),
			FogStart = 0,
			FogEnd = 4000,
			EnvironmentDiffuseScale = 0.6,
			EnvironmentSpecularScale = 0.6,
			GlobalShadows = true,
			AtmoDensity = 0.25,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(250, 230, 190),
			AtmoDecay = Color3.fromRGB(180, 130, 80),
			AtmoGlare = 0.2,
			AtmoHaze = 0.4,
			Sky = "rbxassetid://102590176595275"
		},
		Autumn = {
			ClockTime = 16,
			Brightness = 2.4,
			ExposureCompensation = 0.15,
			Ambient = Color3.fromRGB(170, 120, 80),
			OutdoorAmbient = Color3.fromRGB(200, 140, 90),
			FogColor = Color3.fromRGB(220, 160, 100),
			FogStart = 0,
			FogEnd = 1800,
			EnvironmentDiffuseScale = 0.55,
			EnvironmentSpecularScale = 0.55,
			GlobalShadows = true,
			AtmoDensity = 0.35,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(230, 170, 110),
			AtmoDecay = Color3.fromRGB(140, 80, 50),
			AtmoGlare = 0.2,
			AtmoHaze = 1.8,
			Sky = "rbxassetid://102590176595275"
		},
		Neon = {
			ClockTime = 1,
			Brightness = 1.6,
			ExposureCompensation = 0.35,
			Ambient = Color3.fromRGB(60, 20, 90),
			OutdoorAmbient = Color3.fromRGB(100, 30, 140),
			FogColor = Color3.fromRGB(50, 10, 90),
			FogStart = 0,
			FogEnd = 700,
			EnvironmentDiffuseScale = 0.5,
			EnvironmentSpecularScale = 0.7,
			GlobalShadows = true,
			AtmoDensity = 0.4,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(180, 60, 220),
			AtmoDecay = Color3.fromRGB(90, 20, 130),
			AtmoGlare = 0.5,
			AtmoHaze = 2,
			Sky = "rbxassetid://102590176595275",
			Rain = 0.3
		},
		PitchBlack = {
			ClockTime = 0,
			Brightness = 0.1,
			ExposureCompensation = - 0.2,
			Ambient = Color3.fromRGB(5, 5, 10),
			OutdoorAmbient = Color3.fromRGB(8, 8, 15),
			FogColor = Color3.fromRGB(0, 0, 0),
			FogStart = 0,
			FogEnd = 120,
			EnvironmentDiffuseScale = 0.15,
			EnvironmentSpecularScale = 0.15,
			GlobalShadows = true,
			AtmoDensity = 0.55,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(5, 5, 15),
			AtmoDecay = Color3.fromRGB(0, 0, 5),
			AtmoGlare = 0,
			AtmoHaze = 2,
			Sky = "rbxassetid://102590176595275"
		},
		Overcast = {
			ClockTime = 10,
			Brightness = 1.8,
			ExposureCompensation = 0.05,
			Ambient = Color3.fromRGB(140, 145, 155),
			OutdoorAmbient = Color3.fromRGB(160, 165, 175),
			FogColor = Color3.fromRGB(180, 185, 195),
			FogStart = 0,
			FogEnd = 1000,
			EnvironmentDiffuseScale = 0.45,
			EnvironmentSpecularScale = 0.45,
			GlobalShadows = true,
			AtmoDensity = 0.4,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(190, 195, 205),
			AtmoDecay = Color3.fromRGB(130, 135, 145),
			AtmoGlare = 0,
			AtmoHaze = 2.5,
			Sky = "rbxassetid://102590176595275",
			Rain = 0.6
		},
		Alien = {
			ClockTime = 22,
			Brightness = 1.5,
			ExposureCompensation = 0.3,
			Ambient = Color3.fromRGB(40, 100, 60),
			OutdoorAmbient = Color3.fromRGB(60, 160, 90),
			FogColor = Color3.fromRGB(30, 130, 70),
			FogStart = 0,
			FogEnd = 600,
			EnvironmentDiffuseScale = 0.5,
			EnvironmentSpecularScale = 0.6,
			GlobalShadows = true,
			AtmoDensity = 0.42,
			AtmoOffset = 0,
			AtmoColor = Color3.fromRGB(80, 220, 130),
			AtmoDecay = Color3.fromRGB(20, 90, 60),
			AtmoGlare = 0.4,
			AtmoHaze = 2.2,
			Sky = "rbxassetid://102590176595275"
		}
	}
	local ThemeOptions = {
		"None",
		"Day",
		"Dawn",
		"Sunset",
		"Night",
		"Midnight",
		"Stormy",
		"Foggy",
		"Aurora",
		"GoldenHour",
		"BloodMoon",
		"Volcanic",
		"Arctic",
		"Tropical",
		"Desert",
		"Autumn",
		"Neon",
		"PitchBlack",
		"Overcast",
		"Alien"
	}
	local function ensureAtmo()
		if ThemeAtmo and ThemeAtmo.Parent then
			return ThemeAtmo
		end
		local existing = Lighting:FindFirstChildOfClass("Atmosphere")
		ThemeAtmo = existing or Instance.new("Atmosphere")
		ThemeAtmo.Parent = Lighting
		return ThemeAtmo
	end
	local function captureOrig()
		if ThemeOrig then
			return
		end
		ThemeOrig = {
			ClockTime = Lighting.ClockTime,
			Brightness = Lighting.Brightness,
			ExposureCompensation = Lighting.ExposureCompensation,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			FogColor = Lighting.FogColor,
			FogStart = Lighting.FogStart,
			FogEnd = Lighting.FogEnd,
			EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
			EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
			GlobalShadows = Lighting.GlobalShadows,
			HadSky = false
		}
		local atmo = ensureAtmo()
		ThemeOrig.AtmoDensity = atmo.Density
		ThemeOrig.AtmoOffset = atmo.Offset
		ThemeOrig.AtmoColor = atmo.Color
		ThemeOrig.AtmoDecay = atmo.Decay
		ThemeOrig.AtmoGlare = atmo.Glare
		ThemeOrig.AtmoHaze = atmo.Haze
		local sky = Lighting:FindFirstChildOfClass("Sky")
		if sky then
			ThemeOrig.HadSky = true
			ThemeOrig.SkyBk = sky.SkyboxBk
			ThemeOrig.SkyDn = sky.SkyboxDn
			ThemeOrig.SkyFt = sky.SkyboxFt
			ThemeOrig.SkyLf = sky.SkyboxLf
			ThemeOrig.SkyRt = sky.SkyboxRt
			ThemeOrig.SkyUp = sky.SkyboxUp
			ThemeOrig.SunAngularSize = sky.SunAngularSize
			ThemeOrig.MoonAngularSize = sky.MoonAngularSize
			ThemeOrig.StarCount = sky.StarCount
		else
			ThemeOrig.SunAngularSize = 21
			ThemeOrig.MoonAngularSize = 11
			ThemeOrig.StarCount = 3000
		end
	end
	local function getSky()
		local sky = Lighting:FindFirstChildOfClass("Sky")
		if sky then
			return sky
		end
		sky = Instance.new("Sky")
		sky.Name = "NoxThemeSky"
		sky.Parent = Lighting
		ThemeSkyCreated = true
		return sky
	end
	local function cleanupSky()
		local sky = Lighting:FindFirstChildOfClass("Sky")
		if not sky then
			return
		end
		if ThemeSkyCreated and not (ThemeOrig and ThemeOrig.HadSky) then
			sky:Destroy()
			ThemeSkyCreated = false
		end
	end
	local function apply(preset)
		captureOrig()
		local atmo = ensureAtmo()
		if preset then
			local sky = getSky()
			Lighting.ClockTime = preset.ClockTime
			Lighting.Brightness = preset.Brightness
			Lighting.ExposureCompensation = preset.ExposureCompensation
			Lighting.Ambient = preset.Ambient
			Lighting.OutdoorAmbient = preset.OutdoorAmbient
			Lighting.FogColor = preset.FogColor
			Lighting.FogStart = preset.FogStart
			Lighting.FogEnd = preset.FogEnd
			Lighting.EnvironmentDiffuseScale = preset.EnvironmentDiffuseScale
			Lighting.EnvironmentSpecularScale = preset.EnvironmentSpecularScale
			Lighting.GlobalShadows = preset.GlobalShadows
			atmo.Density = preset.AtmoDensity
			atmo.Offset = preset.AtmoOffset
			atmo.Color = preset.AtmoColor
			atmo.Decay = preset.AtmoDecay
			atmo.Glare = preset.AtmoGlare
			atmo.Haze = preset.AtmoHaze
			if preset.Sky then
				sky.SkyboxBk = preset.Sky
				sky.SkyboxDn = preset.Sky
				sky.SkyboxFt = preset.Sky
				sky.SkyboxLf = preset.Sky
				sky.SkyboxRt = preset.Sky
				sky.SkyboxUp = preset.Sky
				sky.SunAngularSize = 21
				sky.MoonAngularSize = 11
				sky.StarCount = 3000
			end
		elseif ThemeOrig then
			Lighting.ClockTime = ThemeOrig.ClockTime
			Lighting.Brightness = ThemeOrig.Brightness
			Lighting.ExposureCompensation = ThemeOrig.ExposureCompensation
			Lighting.Ambient = ThemeOrig.Ambient
			Lighting.OutdoorAmbient = ThemeOrig.OutdoorAmbient
			Lighting.FogColor = ThemeOrig.FogColor
			Lighting.FogStart = ThemeOrig.FogStart
			Lighting.FogEnd = ThemeOrig.FogEnd
			Lighting.EnvironmentDiffuseScale = ThemeOrig.EnvironmentDiffuseScale
			Lighting.EnvironmentSpecularScale = ThemeOrig.EnvironmentSpecularScale
			Lighting.GlobalShadows = ThemeOrig.GlobalShadows
			if ThemeOrig.AtmoDensity ~= nil then
				atmo.Density = ThemeOrig.AtmoDensity
				atmo.Offset = ThemeOrig.AtmoOffset
				atmo.Color = ThemeOrig.AtmoColor
				atmo.Decay = ThemeOrig.AtmoDecay
				atmo.Glare = ThemeOrig.AtmoGlare
				atmo.Haze = ThemeOrig.AtmoHaze
			end
			local sky = Lighting:FindFirstChildOfClass("Sky")
			if sky and ThemeOrig.HadSky then
				sky.SkyboxBk = ThemeOrig.SkyBk
				sky.SkyboxDn = ThemeOrig.SkyDn
				sky.SkyboxFt = ThemeOrig.SkyFt
				sky.SkyboxLf = ThemeOrig.SkyLf
				sky.SkyboxRt = ThemeOrig.SkyRt
				sky.SkyboxUp = ThemeOrig.SkyUp
				sky.SunAngularSize = ThemeOrig.SunAngularSize
				sky.MoonAngularSize = ThemeOrig.MoonAngularSize
				sky.StarCount = ThemeOrig.StarCount
			end
			cleanupSky()
		end
		local scale = 1
		local ov = NoxLib.getSetting("Renderer", "World Theme", "rain", 1)
		if type(ov) == "number" then
			scale = ov
		end
		if preset and preset.Rain then
			createRain(preset.Rain * scale)
		else
			destroyRain()
		end
	end
	local function getName()
		local n = NoxLib.getSetting("Renderer", "World Theme", "theme", "None")
		return type(n) == "string" and n or "None"
	end
	NoxLib.addButton("Renderer", {
		name = "World Theme",
		toggle = true,
		description = "Applies an aesthetic day/night atmosphere to the world.",
		settings = {
			{
				type = "dropdown",
				name = "Theme",
				key = "theme",
				default = "Day",
				options = ThemeOptions,
				action = function()
					if ThemeRunning then
						apply(Presets[getName()])
					end
				end
			},
			{
				type = "slider",
				name = "Rain Intensity",
				key = "rain",
				default = 1,
				min = 0,
				max = 3,
				step = 0.1,
				action = function()
					if ThemeRunning then
						apply(Presets[getName()])
					end
				end
			}
		},
		action = function(enabled)
			ThemeRunning = enabled
			if ThemeConn then
				ThemeConn:Disconnect();
				ThemeConn = nil
			end
			if not enabled then
				destroyRain()
				apply(nil)
				return true
			end
			captureOrig()
			apply(Presets[getName()])
			ThemeConn = RunService.Heartbeat:Connect(function()
				if not ThemeRunning then
					return
				end
				local p = Presets[getName()]
				if not p then
					return
				end
				if Lighting.ClockTime ~= p.ClockTime then
					Lighting.ClockTime = p.ClockTime
				end
				if Lighting.Brightness ~= p.Brightness then
					Lighting.Brightness = p.Brightness
				end
			end)
			return true
		end
	})
end
return true
