---@type string
local AddonName = ...
---@class Data
local Data = select(2, ...)
---@class BattleGroundEnemies
local BattleGroundEnemies = BattleGroundEnemies
local LSM = LibStub("LibSharedMedia-3.0")
local L = Data.L

local PowerBarColor = PowerBarColor --table
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local math_random = math.random

local generalDefaults = {
	Texture = 'Blizzard Raid Bar',
	Background = {0, 0, 0, 0.66},
	OnlyShowForHealers = false
}

local defaultSettings = {
	Enabled = true,
	Parent = "Button",
	Height = 5,
	ActivePoints = 2,
	Points = {
		{
			Point = "BOTTOMLEFT",
			RelativeFrame = "Button",
			RelativePoint = "BOTTOMLEFT",
		},
		{
			Point = "BOTTOMRIGHT",
			RelativeFrame = "Button",
			RelativePoint = "BOTTOMRIGHT",
		}
	}
}



local options = function (location)
	return {
		Height = {
			type = "range",
			name = L.Height,
			min = 1,
			max = 50,
			step = 1,
			order = 1
		},
	}
end

local generalOptions = function(location)
	return {
		Texture = {
			type = "select",
			name = L.BarTexture,
			desc = L.HealthBar_Texture_Desc,
			dialogControl = 'LSM30_Statusbar',
			values = AceGUIWidgetLSMlists.statusbar,
			width = "normal",
			order = 1
		},
		Background = {
			type = "color",
			name = L.BarBackground,
			desc = L.PowerBar_Background_Desc,
			hasAlpha = true,
			width = "normal",
			order = 2
		},
		OnlyShowForHealers = {
			type = "toggle",
			name = L.OnlyShowForHealers,
			desc = L.PowerBar_OnlyShowForHealers_Desc,
			width = 'normal',
			order = 3
		},
	}
end

local flags = {
	SetZeroHeightWhenDisabled = true,
	FixedPosition = true
}

local power = BattleGroundEnemies:NewButtonModule({
	moduleName = "Power",
	localizedModuleName = L.PowerBar,
	flags = flags,
	defaultSettings = defaultSettings,
	generalDefaults = generalDefaults,
	options = options,
	generalOptions = generalOptions,
	events = {"UnitIdUpdate", "UpdatePower"},
	enabledInThisExpansion = true,
	attachSettingsToButton = true
})

function power:AttachToPlayerButton(playerButton)
	playerButton.Power = CreateFrame('StatusBar', nil, playerButton)
	playerButton.Power:SetMinMaxValues(0, 1)
	playerButton.Power.maxValue = 1


	--playerButton.Power.Background = playerButton.Power:CreateTexture(nil, 'BACKGROUND', nil, 2)
	playerButton.Power.Background = playerButton.Power:CreateTexture(nil, 'BACKGROUND', nil, 2)
	playerButton.Power.Background:SetAllPoints()
	playerButton.Power.Background:SetTexture("Interface/Buttons/WHITE8X8")


	function playerButton.Power:UpdateMinMaxValues(max)
		if max and max ~= self.maxValue then
			self:SetMinMaxValues(0, max)
			self.maxValue = max
		end
	end

	function playerButton.Power:CheckForNewPowerColor(powerToken)
		--self:Debug("CheckForNewPowerColor", powerToken)

		if self.powerToken ~= powerToken then
			local color = PowerBarColor[powerToken]
			if color then
				self:SetStatusBarColor(color.r, color.g, color.b)
				self.powerToken = powerToken
			end
		end
	end

	function playerButton.Power:UnitIdUpdate(unitID)
		if unitID then
			local powerType, powerToken, altR, altG, altB = UnitPowerType(unitID)

			self:CheckForNewPowerColor(powerToken)
			self:UpdatePower(unitID)
		end
	end


	function playerButton.Power:UpdatePower(unitID)
		--self:Debug("UpdatePower", unitID, powerToken)
		if unitID then
			self:UpdateMinMaxValues(UnitPowerMax(unitID))
			self:SetValue(UnitPower(unitID))
		else
			--for testmode
			self:SetValue(math_random(0, 100)/100)
		end
	end


	function playerButton.Power:ApplyAllSettings()
		if not self.config then return end
		-- power
		self:SetHeight(self.config.Height or 0.01)

		self:SetStatusBarTexture(LSM:Fetch("statusbar", self.config.Texture))--self.healthBar:SetStatusBarTexture(137012)
		self.Background:SetVertexColor(unpack(self.config.Background))
		local playerDetails = playerButton.PlayerDetails
		if not playerDetails then return end
		if not playerDetails.PlayerClass then return end
		if not playerDetails.PlayerRole then return end

		if playerDetails.PlayerRole == "HEALER" or not self.config.OnlyShowForHealers then
			self:SetHeight(self.config.Height or 0.01)
		else
			self:SetHeight(0.01)
		end

		local powerToken
		if playerDetails.PlayerClass then
			local t = Data.Classes[playerDetails.PlayerClass]
			if t then
				if playerDetails.PlayerSpecName then
					t = t[playerDetails.PlayerSpecName]
				end
			end
			if t then powerToken = t.Ressource end
		end

		self:CheckForNewPowerColor(powerToken)
	end
	return playerButton.Power
end