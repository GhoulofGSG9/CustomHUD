Script.Load("lua/CHUD_Shared.lua")
Server.AddTag("CHUD")

CHUDSendHiveStats = true

local originaldmgmixin = DamageMixin.DoDamage
function DamageMixin:DoDamage(damage, target, point, direction, surface, altMode, showtracer)
	if Server and GetGamerules():GetGameStarted() then
		if Shared.GetCheatsEnabled() then
			CHUDSendHiveStats = false
		end
	
		local weapon
	
		if self:isa("Player") then
			attacker = self
		elseif self:GetParent() and self:GetParent():isa("Player") then
			attacker = self:GetParent()
			weapon = self:GetTechId()
		elseif HasMixin(self, "Owner") and self:GetOwner() and self:GetOwner():isa("Player") then
			attacker = self:GetOwner()
			
			if self.techId ~= nil and self.techId > 1 then
				weapon = self:GetTechId()
			end

			// Map to their proper weapons so we don't need to perform voodoo magic
			local mapname = self:GetMapName()
			
			if mapname == Spit.kMapName then
				weapon = kTechId.Spit
			elseif mapname == Grenade.kMapName then
				weapon = kTechId.GrenadeLauncher
			elseif mapname == Flame.kMapName then
				weapon = kTechId.Flamethrower
			elseif mapname == ClusterGrenade.kMapName or mapname == ClusterFragment.kMapName then
				weapon = kTechId.ClusterGrenade
			elseif mapname == NerveGasCloud.kMapName then
				weapon = kTechId.GasGrenade
			elseif mapname == PulseGrenade.kMapName then
				weapon = kTechId.PulseGrenadeProjectile
			elseif mapname == SporeCloud.kMapName then
				weapon = kTechId.Spores
			elseif mapname == Shockwave.kMapName then
				weapon = kTechId.Stomp
			elseif mapname == DotMarker.kMapName then
				weapon = kTechId.BileBomb
			elseif mapname == WhipBomb.kMapName then
				weapon = kTechId.Whip
			elseif weapon == nil then
				weapon = 1
			end
			//Print(weapon .. " " .. self:GetMapName())
			
		else 
			// Don't be silly, if we return here something won't do damage (apparently ARCs :D)
			return originaldmgmixin(self, damage, target, point, direction, surface, altMode, showtracer)
		end
		
		// Secondary attack on alien weapons (lerk spikes, gorge healspray)
		if (self.secondaryAttacking or self.shootingSpikes) and attacker:isa("Alien") then
			weapon = attacker:GetActiveWeapon():GetSecondaryTechId()
		end
		
        local armorUsed = 0
        local healthUsed = 0
        local damageDone = 0
		
        local damageType = kDamageType.Normal
        if self.GetDamageType then
            damageType = self:GetDamageType()
        elseif HasMixin(self, "Tech") then
            damageType = LookupTechData(self:GetTechId(), kTechDataDamageType, kDamageType.Normal)
        end
		
		if target and HasMixin(target, "Live") and damage > 0 and GetAreEnemies(attacker, target) then
			
			damageDone, armorUsed, healthUsed = GetDamageByType(target, attacker, self, damage, damageType, point)

			local msg = { }
			msg.damage = healthUsed+(armorUsed)*2
			msg.targetId = (target and target:GetId()) or Entity.invalidId
			msg.isPlayer = target:isa("Player")
			msg.weapon = weapon
			Server.SendNetworkMessage(attacker, "CHUDStats", msg, false)
		end
	end
	// Now we send the actual damage message
	return originaldmgmixin(self, damage, target, point, direction, surface, altMode, showtracer)
end

local skulkJumpSounds = {
	"sound/NS2.fev/alien/skulk/jump_good",
	"sound/NS2.fev/alien/skulk/jump_best",
	"sound/NS2.fev/alien/skulk/jump"
}

function StartSoundEffectOnEntity(soundEffectName, onEntity, volume, predictor)
	if table.contains(skulkJumpSounds, soundEffectName) then
		volume = volume * 0.5
	end
	local soundEffectEntity = Server.CreateEntity(SoundEffect.kMapName)
	soundEffectEntity:SetParent(onEntity)
	soundEffectEntity:SetAsset(soundEffectName)
	soundEffectEntity:SetVolume(volume)
	soundEffectEntity:SetPredictor(predictor)
	soundEffectEntity:Start()
	
	return soundEffectEntity
	
end

// Thanks Shine!
local Gamemode
function ShineGetGamemode()
	if Gamemode then return Gamemode end

	local GameSetup = io.open( "game_setup.xml", "r" )

	if not GameSetup then
		Gamemode = "ns2"

		return "ns2"
	end

	local Data = GameSetup:read( "*all" )

	GameSetup:close()

	local Match = Data:match( "<name>(.+)</name>" )

	Gamemode = Match or "ns2"

	return Gamemode
end

originalPlayerBotName = Class_ReplaceMethod("PlayerBot", "UpdateNameAndGender",
	function(self)
		originalPlayerBotName(self)
		CHUDSendHiveStats = false
	end)

// Reenable Hive stats
// We check if cheats or bots have been used at any point to disable sending stats
Class_ReplaceMethod("PlayerRanking", "GetTrackServer",
	function(self)
		return CHUDSendHiveStats and ShineGetGamemode() == "ns2"
	end)
	
// Bugfix for skulk growl sounds
Class_ReplaceMethod("Player", "GetPlayIdleSound",
	function(self)
		if self:isa("Skulk") and self.movementModiferState then
			Print(self:GetVelocityLength() / (self:GetMaxSpeed()*2))
			return self:GetIsAlive() and (self:GetVelocityLength() / (self:GetMaxSpeed()*2)) > 0.65
		else
			return self:GetIsAlive() and (self:GetVelocityLength() / self:GetMaxSpeed()) > 0.65
		end
	end)