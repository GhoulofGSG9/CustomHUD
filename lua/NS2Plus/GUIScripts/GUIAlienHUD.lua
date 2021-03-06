PrecacheAsset("ui/oma_alien_hud_health.dds")
PrecacheAsset("ui/rant_alien_hud_health.dds")

Class_AddMethod( "GUIAlienHUD", "CHUDRepositionGUI",
	function(self)
		local mingui = not CHUDGetOption("mingui")
		local showcomm = CHUDGetOption("showcomm")
		local gametime = CHUDGetOption("gametime")
		local biomass = ClientUI.GetScript("GUIBioMassDisplay")
		local location = ClientUI.GetScript("GUINotifications")
		
		if gametime and self.gameTime then
			self.gameTime:SetFontName(GUIMarineHUD.kTextFontName)
			self.gameTime:SetScale(GetScaledVector()*1.15)
			self.gameTime:SetPosition(Vector(20, self.resourceDisplay.teamText:GetPosition().y+25, 0))
			GUIMakeFontScale(self.gameTime)
		end
		
		local biomassTexture = ConditionalValue(mingui, "ui/biomass_bar.dds", "ui/transparent.dds")
		
		biomass.smokeyBackground:SetIsVisible(mingui)
		biomass.background:SetTexture(biomassTexture)
	end)

Class_AddMethod( "GUIAlienHUD", "OnLocalPlayerChanged",
	function(self, newPlayer)
	
		if Client.GetIsControllingPlayer() then
			Client.GetLocalPlayer():SetDarkVision(CHUDGetOption("avstate"))
		end
	
	end)

local originalAlienInit
originalAlienInit = Class_ReplaceMethod( "GUIAlienHUD", "Initialize",
	function(self)
		local mingui = not CHUDGetOption("mingui")
		local aliencircles = CHUDGetOption("aliencircles")
	
		originalAlienInit(self)
		
		self.gameTime = self:CreateAnimatedTextItem()
		self.gameTime:SetFontName(GUIMarineHUD.kTextFontName)
		self.gameTime:SetFontIsBold(true)
		self.gameTime:SetLayer(kGUILayerPlayerHUDForeground2)
		self.gameTime:SetColor(kAlienTeamColorFloat)
		
		local kTextureNameCHUD = CHUDGetOptionAssocVal("aliencircles")
		local kBackgroundCHUD = ConditionalValue(mingui, PrecacheAsset("ui/alien_commander_bg_smoke.dds"), PrecacheAsset("ui/transparent.dds"))
		
		// Backgrounds of health/energy
		self.healthBall.dialBackground:SetAdditionalTexture("noise", kBackgroundCHUD)
		self.energyBall.dialBackground:SetAdditionalTexture("noise", kBackgroundCHUD)
		self.secondaryAbilityBackground:SetAdditionalTexture("noise", kBackgroundCHUD)
		
		// Alien bars
		self.healthBall:SetForegroundTexture(kTextureNameCHUD)
		self.armorBall:SetForegroundTexture(kTextureNameCHUD)
		self.energyBall:SetForegroundTexture(kTextureNameCHUD)
		self.adrenalineEnergy:SetForegroundTexture(kTextureNameCHUD)
		
		local healthColor = ConditionalValue(aliencircles == 2, Color(1, 1, 1, 1), Color(230/255, 171/255, 46/255, 1))
		local armorColor = ConditionalValue(aliencircles == 2, Color(1, 1, 1, 1), Color(1, 121/255, 12/255, 1))
		local adrenalineColor = ConditionalValue(aliencircles == 2, Color(1, 1, 1, 1), Color(1, 121/255, 12/255, 1))
		
		self.healthBall:GetLeftSide():SetColor(healthColor)
		self.healthBall:GetRightSide():SetColor(healthColor)
		
		self.armorBall:GetLeftSide():SetColor(armorColor)
		self.armorBall:GetRightSide():SetColor(armorColor)
		
		self.adrenalineEnergy:GetLeftSide():SetColor(adrenalineColor)
		self.adrenalineEnergy:GetRightSide():SetColor(adrenalineColor)
		
		if aliencircles == 2 then
			self.armorBall:GetLeftSide():SetTexturePixelCoordinates(0, 0, 64, 128)
			self.armorBall:GetRightSide():SetTexturePixelCoordinates(64, 0, 128, 128)
			
			self.energyBall:GetLeftSide():SetTexturePixelCoordinates(128, 128, 192, 256)
			self.energyBall:GetRightSide():SetTexturePixelCoordinates(192, 128, 256, 256)
			
			self.adrenalineEnergy:GetLeftSide():SetTexturePixelCoordinates(128, 0, 192, 128)
			self.adrenalineEnergy:GetRightSide():SetTexturePixelCoordinates(192, 0, 256, 128)
		end

		if CHUDGetOption("mingui") then
			self.resourceDisplay.background:SetColor(Color(1,1,1,0))
		else
			self.resourceDisplay.background:SetColor(Color(1,1,1,1))
		end
				
		Client.DestroyScreenEffect(Player.screenEffects.darkVision)
		Client.DestroyScreenEffect(HiveVision_screenEffect)
		Client.DestroyScreenEffect(HiveVisionExtra_screenEffect)
		HiveVision_screenEffect = Client.CreateScreenEffect("shaders/HiveVision.screenfx")
		HiveVisionExtra_screenEffect = Client.CreateScreenEffect("shaders/HiveVisionExtra.screenfx")
		Player.screenEffects.darkVision = Client.CreateScreenEffect(CHUDGetOptionAssocVal("av"))
		
		if CHUDGetOption("hudbars_a") > 0 then
			if CHUDGetOption("hudbars_a") == 2 then
				self.resourceDisplay.background:SetPosition(Vector(-440, -100, 0))
			end
			
			local healthBall = self.healthBall:GetBackground()
			local energyBall = self.energyBall:GetBackground()
			local healthBallPos = healthBall:GetPosition()
			local energyBallPos = energyBall:GetPosition()
			self.healthBall.leftSide:SetIsVisible(false)
			self.healthBall.rightSide:SetIsVisible(false)
			self.energyBall.leftSide:SetIsVisible(false)
			self.energyBall.rightSide:SetIsVisible(false)
			self.adrenalineEnergy:SetIsVisible(false)
			if CHUDGetOption("hudbars_a") == 2 then
				healthBall:SetPosition(Vector(healthBallPos.x+50, healthBallPos.y, 0))
				energyBall:SetPosition(Vector(energyBallPos.x-50, energyBallPos.y, 0))
				self.secondaryAbilityBackground:SetPosition(Vector(-50, -125, 0))
			end
		end
		
		self.gorgeBuiltText = GUIManager:CreateTextItem()
		self.gorgeBuiltText:SetFontName(Fonts.kStamp_Large)
		self.gorgeBuiltText:SetScale(GetScaledVector())
		self.gorgeBuiltText:SetAnchor(GUIItem.Middle, GUIItem.Center)
		self.gorgeBuiltText:SetTextAlignmentX(GUIItem.Align_Center)
		self.gorgeBuiltText:SetTextAlignmentY(GUIItem.Align_Center)
		self.gorgeBuiltText:SetColor(kAlienFontColor)
		self.gorgeBuiltText:SetInheritsParentAlpha(true)
		self.gorgeBuiltText:SetIsVisible(false)
		
		self.energyBall:GetBackground():AddChild(self.gorgeBuiltText)
		
		self:CHUDRepositionGUI()
	end)

Class_AddMethod( "GUIAlienHUD", "CHUDUpdateHealthBall",
	function(self, deltaTime)
		local healthBarPercentageGoal = PlayerUI_GetPlayerHealth() / PlayerUI_GetPlayerMaxHealth()
		self.healthBarPercentage = healthBarPercentageGoal

		local maxArmor = PlayerUI_GetPlayerMaxArmor()

		if not (maxArmor == 0) then
			local armorBarPercentageGoal = PlayerUI_GetPlayerArmor() / maxArmor
			self.armorBarPercentage = armorBarPercentageGoal
		end

		// don't use more than 60% for armor in case armor value is bigger than health
		// for skulk use 10 / 70 = 14% as armor and 86% as health
		local armorUseFraction = Clamp( PlayerUI_GetPlayerMaxArmor() / PlayerUI_GetPlayerMaxHealth(), 0, 0.6)
		local healthUseFraction = 1 - armorUseFraction

		// set global rotation to snap to the health ring
		self.armorBall:SetRotation( - 2 * math.pi * self.healthBarPercentage * healthUseFraction )

		self.healthBall:SetPercentage(self.healthBarPercentage * healthUseFraction)
		self.armorBall:SetPercentage(self.armorBarPercentage * armorUseFraction)

		self:UpdateFading(self.healthBall:GetBackground(), self.healthBarPercentage * self.armorBarPercentage, deltaTime)
	end)

local originalAlienUpdate
originalAlienUpdate = Class_ReplaceMethod( "GUIAlienHUD", "Update",
	function(self, deltaTime)
		originalAlienUpdate(self, deltaTime)
		
		local mingui = not CHUDGetOption("mingui")
		local rtcount = CHUDGetOption("rtcount")
		local gametime = CHUDGetOption("gametime")
		local showcomm = CHUDGetOption("showcomm")
		local instanthealth = CHUDGetOption("instantalienhealth")

		if instanthealth then
			self:CHUDUpdateHealthBall(deltaTime)
		end
			
		if not rtcount then
			self.resourceDisplay.rtCount:SetIsVisible(false)
			self.resourceDisplay.pResDescription:SetText(string.format("%s (%d %s)",
				Locale.ResolveString("RESOURCES"),
				CommanderUI_GetTeamHarvesterCount(),
				ConditionalValue(CommanderUI_GetTeamHarvesterCount() == 1, "RT", "RTs")))
		else
			self.resourceDisplay.rtCount:SetIsVisible(CommanderUI_GetTeamHarvesterCount() > 0)
			self.resourceDisplay.pResDescription:SetText(Locale.ResolveString("RESOURCES"))
		end
		
		if self.gameTime then
			self.gameTime:SetText(CHUDGetGameTime())
			self.gameTime:SetIsVisible(gametime)
		end
		
		self.resourceDisplay.teamText:SetIsVisible(showcomm)
		
		local aliencircles = CHUDGetOption("aliencircles")
		local energyColor = Color(1, 1, 1, 1)
		
		if aliencircles == 2 and self.energyBall:GetBackground():GetColor() ~= Color(0.6, 0, 0, 1) then
			self.energyBall:GetLeftSide():SetColor(energyColor)
			self.energyBall:GetRightSide():SetColor(energyColor)
		end
		
		self.armorBall:SetIsVisible(self.healthBall:GetBackground():GetIsVisible() and CHUDGetOption("hudbars_a") == 0)
		
		local player = Client.GetLocalPlayer()
		local shieldFraction = player:GetShieldPercentage()
		local hasShield = PlayerUI_GetHasMucousShield()
		
		if self.mucousText then
			self.mucousText:SetIsVisible(CHUDGetOption("hudbars_a") > 0 and PlayerUI_GetHasMucousShield())
		end
		
		if not self.mucousBall and CHUDGetOption("hudbars_a") == 0 then
			local mucousBallSettings = { }
			mucousBallSettings.BackgroundWidth = GUIScale(192)
			mucousBallSettings.BackgroundHeight = GUIScale(192)
			mucousBallSettings.BackgroundAnchorX = GUIItem.Left
			mucousBallSettings.BackgroundAnchorY = GUIItem.Bottom
			mucousBallSettings.BackgroundOffset = Vector(15, -35, 0) * GUIScale(1)
			mucousBallSettings.BackgroundTextureName = nil
			mucousBallSettings.BackgroundTextureX1 = 0
			mucousBallSettings.BackgroundTextureY1 = 0
			mucousBallSettings.BackgroundTextureX2 = 0
			mucousBallSettings.BackgroundTextureY2 = 0
			mucousBallSettings.ForegroundTextureName = CHUDGetOptionAssocVal("aliencircles")
			mucousBallSettings.ForegroundTextureWidth = 128
			mucousBallSettings.ForegroundTextureHeight = 128
			mucousBallSettings.ForegroundTextureX1 = 128
			mucousBallSettings.ForegroundTextureY1 = 0
			mucousBallSettings.ForegroundTextureX2 = 256
			mucousBallSettings.ForegroundTextureY2 = 128
			mucousBallSettings.InheritParentAlpha = false
			self.mucousBall = GUIDial()
			self.mucousBall:Initialize(mucousBallSettings)
			
			self.mucousBall:GetLeftSide():SetColor(Color(0, 1, 0, 1))
			self.mucousBall:GetRightSide():SetColor(Color(0, 1, 0, 1))
		end
		if self.mucousBall then
			self.mucousBall:SetIsVisible(shieldFraction and shieldFraction > 0 and CHUDGetOption("hudbars_a") == 0)
			self.mucousBall:SetPercentage(shieldFraction)
			self.mucousBall:Update()
		end
		
		local player = Client.GetLocalPlayer()
		local gorgeBuiltTextVisible = false
		if player and player:isa("Gorge") then
			local activeWeapon = player:GetActiveWeapon()
			if activeWeapon and activeWeapon:isa("DropStructureAbility") then
				local dropStructureAbility = player:GetWeapon(DropStructureAbility.kMapName)
				if dropStructureAbility then
					local structure = dropStructureAbility:GetActiveStructure()
					local structureId = structure and structure:GetDropStructureId() or -1
					local maxStructures = GorgeBuild_GetMaxNumStructure(structureId)
					local numBuilt = dropStructureAbility:GetNumStructuresBuilt(structureId)
					
					gorgeBuiltTextVisible = structureId ~= -1
					if gorgeBuiltTextVisible then
						self.gorgeBuiltText:SetText(numBuilt .. "/" .. maxStructures)
						self.gorgeBuiltText:SetColor(GorgeBuild_GetCanAffordAbility(structureId) and kAlienFontColor or kRed)
					end
				end
			end
		end
		self.gorgeBuiltText:SetIsVisible(gorgeBuiltTextVisible)
		self.activeAbilityIcon:SetIsVisible(not gorgeBuiltTextVisible)
	end)
	
local originalAlienReset
originalAlienReset = Class_ReplaceMethod( "GUIAlienHUD", "Reset",
function(self)
	originalAlienReset(self)

	self:CHUDRepositionGUI()
end)

local originalAlienUninit
originalAlienUninit = Class_ReplaceMethod( "GUIAlienHUD", "Uninitialize",
function(self)
	originalAlienUninit(self)

	GUI.DestroyItem(self.gameTime)
	self.gameTime = nil
	
	if self.mucousText then
		GUI.DestroyItem(self.mucousText)
		self.mucousText = nil
	end
	
	if self.mucousBall then
		self.mucousBall:Uninitialize()
		self.mucousBall = nil
	end
end)
	
Script.Load("lua/GUIAlienTeamMessage.lua")
local originalAlienMessage
originalAlienMessage = Class_ReplaceMethod( "GUIAlienTeamMessage", "SetTeamMessage",
	function(self, message)
		originalAlienMessage(self, message)
		if not CHUDGetOption("banners") then
			self.background:SetIsVisible(false)
		end
		if CHUDGetOption("mingui") then
			self.background:DestroyAnimations()
		end
	end)