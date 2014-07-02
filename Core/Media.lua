 --[[

	s:UI Media-related Stuff

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

function S:RemoveArtwork(f)
	f:DestroyAllPixies();
	f:SetSprite(nil);
end

function S:ApplyDebugBackdrop(f)
	f:SetSprite("UI_BK3_Holo_InsetSimple");
	f:SetStyle("Picture", 1);
end

-----------------------------------------------------------------------------
-- Guessed Spell Icons
-- Credits: Quickblink (Interruptor Addon)
-- http://www.curse.com/ws-addons/wildstar/220057-interruptor
-----------------------------------------------------------------------------

local tSpellIconSprites = {
	"ClientSprites:Icon_SkillMisc_UI_misc_knkdwn","ClientSprites:Icon_SkillMisc_UI_ss_sglfire","ClientSprites:Icon_SkillMisc_UI_ss_sglrcvry","ClientSprites:Icon_SkillMisc_UI_ss_sglpain","ClientSprites:Icon_SkillMind_UI_espr_mndstb","ClientSprites:Icon_SkillMind_UI_espr_phnstmlarmor","ClientSprites:Icon_SkillPhysical_UI_wr_rcklsswngs","ClientSprites:Icon_SkillEngineer_Anomaly_Launcher","ClientSprites:Icon_SkillEngineer_Electrocute","ClientSprites:Icon_SkillSpellslinger_cone_of_frost","ClientSprites:Icon_SkillMedic_paralyticsurge","ClientSprites:Icon_SkillWarrior_Polarity_Field","ClientSprites:Icon_SkillMedic_magneticlockdown",
	"ClientSprites:Icon_SkillStalker_Stance_Antagonistic","ClientSprites:Icon_SkillMisc_UI_m_enrgypls","ClientSprites:Icon_SkillSpellslinger_Trueshot","ClientSprites:Icon_SkillMisc_UI_ss_infusefire","ClientSprites:Icon_SkillSpellslinger_arcane_infusion","ClientSprites:Icon_SkillSpellslinger_power_torrent","ClientSprites:Icon_SkillShadow_UI_stlkr_stealth","ClientSprites:Icon_SkillMisc_UI_misc_vlnrbl","ClientSprites:Icon_SkillMedic_gammarays","ClientSprites:Icon_SkillMedic_MedicIconTreatWounds","ClientSprites:Icon_SkillMedic_sheildsurge","ClientSprites:Icon_SkillWarrior_Unstoppable_Force",
	"ClientSprites:Icon_SkillMisc_UI_ss_infuseice","ClientSprites:Icon_SkillEsper_Mind_Over_Body","ClientSprites:Icon_SkillMisc_UI_srcr_frecho","ClientSprites:Icon_SkillShadow_UI_stlkr_pounce","ClientSprites:Icon_SkillMisc_UI_srcr_coldecho","ClientSprites:Icon_SkillSpellslinger_flame_burst","ClientSprites:Icon_SkillShadow_UI_SM_envelop","ClientSprites:Icon_SkillWarrior_Plasma_Blast","ClientSprites:Icon_SkillWarrior_Plasma_Pulse","ClientSprites:Icon_SkillEngineer_BioShell","ClientSprites:Icon_SkillMisc_UI_srcr_elctrcecho","ClientSprites:Icon_SkillFire_UI_srcr_frblt","ClientSprites:Icon_SkillEngineer_Target_Acquistion",
	"ClientSprites:Icon_SkillEngineer_Shock_Wave","ClientSprites:Icon_SkillEsper_Awaken","ClientSprites:Icon_SkillEsper_Blade_Dance","ClientSprites:Icon_SkillEsper_Fade_Out","ClientSprites:Icon_SkillEsper_Soothe","ClientSprites:Icon_SkillEsper_Mental_Boon","ClientSprites:Icon_SkillMedic_recharge","ClientSprites:Icon_SkillEsper_Awaken_Alt","ClientSprites:Icon_SkillEnergy_UI_ss_offblnblst","ClientSprites:Icon_SkillEsper_Sudden_Quiet","ClientSprites:Icon_SkillEsper_Mirage","ClientSprites:Icon_SkillEsper_Warden","ClientSprites:Icon_SkillEnergy_UI_ss_gate","ClientSprites:Icon_SkillSpellslinger_healing_salve",
	"ClientSprites:Icon_SkillEngineer_Recursive_Matrix","ClientSprites:Icon_SkillPetCommand_Combat_Pet_Attack","ClientSprites:Icon_SkillEngineer_Mortar_Strike","ClientSprites:Icon_SkillSpellslinger_void_pact","ClientSprites:Icon_SkillEsper_Soothe_Alt","ClientSprites:Icon_SkillStalker_Nano_Dart","ClientSprites:Icon_SkillMisc_UI_m_flsh","ClientSprites:Icon_SkillEngineer_Urgent_Withdrawal","ClientSprites:Icon_SkillEngineer_Zap","ClientSprites:Icon_SkillWarrior_Explusion","ClientSprites:Icon_SkillMind_UI_espr_phbmve","ClientSprites:Icon_SkillWarrior_Juggernaut","ClientSprites:Icon_SkillStalker_Amplifide_Spike",
	"ClientSprites:Icon_SkillWarrior_Plasma_Shield","ClientSprites:Icon_SkillMedic_particlecollider","ClientSprites:Icon_SkillPhysical_UI_wr_smsh","ClientSprites:Icon_SkillEsper_Geist","ClientSprites:Icon_SkillEngineer_Pet_Ability_Shield_Restore","ClientSprites:Icon_SkillPhysical_DeathWarrant","ClientSprites:Icon_SkillEsper_Spectral_Frenzy","ClientSprites:Icon_SkillMind_UI_espr_rpls","ClientSprites:Icon_SkillStalker_Whiplash","ClientSprites:Icon_SkillSpellslinger_magic_missile","ClientSprites:Icon_SkillWarrior_Tremor_Strike","ClientSprites:Icon_SkillEsper_Projected_Spirit","ClientSprites:Icon_SkillShadow_UI_SM_mkrsmrk",
	"ClientSprites:Icon_SkillEngineer_Hyper_Wave","ClientSprites:Icon_SkillEngineer_Flak_Cannon","ClientSprites:Icon_SkillStalker_overload","ClientSprites:Icon_SkillPhysical_UI_wr_stall","ClientSprites:Icon_SkillEngineer_Bolt_Caster","ClientSprites:Icon_SkillPetCommand_Combat_Pet_Stay","ClientSprites:Icon_SkillSpellslinger_runic_healing","ClientSprites:Icon_SkillMedic_fieldsurgeon","ClientSprites:Icon_SkillEsper_Dislodge_Essence","ClientSprites:Icon_SkillMedic_fieldprobes1","ClientSprites:Icon_SkillMedic_empowerprobe","ClientSprites:Icon_SkillEngineer_Pulse_Blast","ClientSprites:Icon_SkillMedic_restraintgrind",
	"ClientSprites:Icon_SkillPetCommand_Combat_Pet_Despawn","ClientSprites:Icon_SkillSpellslinger_regenerative_pulse","ClientSprites:Icon_SkillWarrior_Plasma_Wall","ClientSprites:Icon_SkillStalker_Analyze_Weakness","ClientSprites:Icon_SkillStalker_Cripple","ClientSprites:Icon_SkillStalker_Neutralize","ClientSprites:Icon_SkillStalker_Phlebotomizing_Missile","ClientSprites:Icon_SkillStalker_Nano_Field","ClientSprites:Icon_SkillStalker_Razor_Disk","ClientSprites:Icon_SkillStalker_Nano_Virus","ClientSprites:Icon_SkillStalker_Reaver","ClientSprites:Icon_SkillStalker_Combat_Stealth","ClientSprites:Icon_SkillStalker_Blood_Thirst",
	"ClientSprites:Icon_SkillEngineer_Feedback","ClientSprites:Icon_SkillStalker_Augment_Drone","ClientSprites:Icon_SkillStalker_Concussive_Kicks","ClientSprites:Icon_SkillPetCommand_Combat_Pet_Go_To_Location","ClientSprites:Icon_SkillSpellslinger_healing_torrent","ClientSprites:Icon_SkillFire_UI_srcr_frybrrg","ClientSprites:Icon_SkillMisc_UI_srcr_airecho","ClientSprites:Icon_SkillMisc_UI_m_slvo","ClientSprites:Icon_SkillMedic_repairstation","ClientSprites:Icon_SkillPhysical_UI_wr_whip","ClientSprites:Icon_SkillMisc_UI_misc_root","ClientSprites:Icon_SkillWarrior_Cannon_Volley_Alt",
	"ClientSprites:Icon_SkillEngineer_Disruptive_Mod","ClientSprites:Icon_SkillMedic_discharge","ClientSprites:Icon_SkillMedic_repairprobes1","ClientSprites:Icon_SkillMedic_Barrier","ClientSprites:Icon_SkillMind_UI_espr_slp","ClientSprites:Icon_SkillMedic_protectionprobe1","ClientSprites:Icon_SkillMedic_suture","ClientSprites:Icon_SkillEngineer_Ricochet","ClientSprites:Icon_SkillMedic_devastatorprobes1","ClientSprites:Icon_SkillEngineer_Quick_Burst","ClientSprites:Icon_SkillMedic_atomize","ClientSprites:Icon_SkillEngineer_Survival_Mode","ClientSprites:Icon_SkillMedic_urgency","ClientSprites:Icon_SkillMedic_energize",
	"ClientSprites:Icon_SkillMedic_Calm","ClientSprites:Icon_SkillMedic_annihilation","ClientSprites:Icon_SkillEnergy_UI_srcr_shckcntrp","ClientSprites:Icon_SkillShadow_UI_SM_undrwrlddrms","ClientSprites:Icon_SkillEngineer_Volatile_Injection","ClientSprites:Icon_SkillMedic_Fissure","ClientSprites:Icon_SkillMedic_quantumcascade","ClientSprites:Icon_SkillMisc_UI_ss_crpplngblst","ClientSprites:Icon_SkillMedic_healingnova","ClientSprites:Icon_SkillMind_UI_espr_mdlsh","ClientSprites:Icon_SkillMedic_extricate","ClientSprites:Icon_SkillMind_UI_espr_cnfs","ClientSprites:Icon_SkillMedic_fieldprobes2","ClientSprites:Icon_SkillEngineer_Shock_Pulse",
	"ClientSprites:Icon_SkillMind_UI_espr_bldstrm","ClientSprites:Icon_SkillEngineer_Shatter_Impairment","ClientSprites:Icon_SkillEngineer_Repair_Bot","ClientSprites:Icon_SkillShadow_UI_stlkr_onslaught","ClientSprites:Icon_SkillMind_UI_espr_crush","ClientSprites:Icon_SkillShadow_UI_SM_crrptngprsnc","ClientSprites:Icon_SkillFire_UI_srcr_twncst","ClientSprites:Icon_SkillMind_UI_espr_rsrgnc","ClientSprites:Icon_SkillShadow_UI_SM_rprrsh","ClientSprites:Icon_SkillMind_UI_espr_mndlsh","ClientSprites:Icon_SkillMisc_UI_m_trnsfsenrgy","ClientSprites:Icon_SkillMind_UI_espr_bolster",
	"ClientSprites:Icon_SkillShadow_UI_stlkr_shredarmor","ClientSprites:Icon_SkillMind_UI_espr_mdt","ClientSprites:Icon_SkillEnergy_UI_ss_spacialshift","ClientSprites:Icon_SkillEsper_Illusionary_Blades","ClientSprites:Icon_SkillStalker_Tether_Mine","ClientSprites:Icon_SkillSpellslinger_arcane_shock","ClientSprites:Icon_SkillWarrior_Detonate","ClientSprites:Icon_SkillEngineer_Thresher","ClientSprites:Icon_SkillShadow_UI_stlkr_shadowdash","ClientSprites:Icon_SkillMisc_UI_ss_srsht","ClientSprites:Icon_SkillPhysical_UI_wr_leap","ClientSprites:Icon_SkillEngineer_Personal_Defense_Unit","ClientSprites:Icon_SkillEnergy_UI_srcr_getouttadodge",
	"ClientSprites:Icon_SkillShadow_UI_SM_sacrstrk","ClientSprites:Icon_SkillEnergy_UI_srcr_thebigguns","ClientSprites:Icon_SkillFire_UI_ss_srngblst","ClientSprites:Icon_SkillPhysical_UI_wr_slap","ClientSprites:Icon_SkillMind_UI_espr_moverb","ClientSprites:Icon_SkillShadow_UI_SM_eye","ClientSprites:Icon_SkillStalker_Stance_Offensive","ClientSprites:Icon_SkillStalker_Stance_Defensive","ClientSprites:Icon_SkillPhysical_UI_wr_offblnc","ClientSprites:Icon_SkillEnergy_UI_srcr_surgeengine","ClientSprites:Icon_SkillMisc_UI_ss_gate","ClientSprites:Icon_SkillPhysical_UI_wr_grenade",
	"ClientSprites:Icon_SkillMisc_UI_ss_sglprot","ClientSprites:Icon_SkillEnergy_UI_srcr_elctrcshck","ClientSprites:Icon_SkillPhysical_UI_wr_wrlwnd","ClientSprites:Icon_SkillPhysical_ThickSkull","ClientSprites:Icon_SkillPhysical_UI_wr_vrtx","ClientSprites:Icon_SkillMisc_UI_ss_knckdwnsgl","ClientSprites:Icon_SkillMisc_UI_ss_infuselng","ClientSprites:Icon_SkillPhysical_UI_wr_fume","ClientSprites:Icon_SkillMisc_UI_ss_clldshtlg","ClientSprites:Icon_SkillPetCommand_Combat_Pet_Passive","ClientSprites:Icon_SkillEnergy_UI_ss_plsmasht","ClientSprites:Icon_SkillMisc_UI_ss_recharge","ClientSprites:Icon_SkillPhysical_UI_wr_bludgeon",
	"ClientSprites:Icon_SkillShadow_UI_stlkr_partialcamo","ClientSprites:Icon_SkillEnergy_UI_ss_plasmabrge","ClientSprites:Icon_SkillMisc_UI_ss_sglstop","ClientSprites:Icon_SkillShadow_UI_SM_ghstshft","ClientSprites:Icon_SkillEngineer_Code_Red","ClientSprites:Icon_SkillMisc_UI_srcr_spatialdistortion","ClientSprites:Icon_SkillMind_UI_espr_shockwave","ClientSprites:Icon_SkillShadow_UI_SM_cnsmgprsnc","ClientSprites:Icon_SkillMisc_UI_srcr_enhncesns","ClientSprites:Icon_SkillMisc_UI_m_enrgybrst","ClientSprites:Icon_SkillMedic_paddleshock","ClientSprites:Icon_SkillSpellslinger_phase_shift","ClientSprites:Icon_SkillStalker_Destructive_Sweep",
	"ClientSprites:Icon_SkillShadow_UI_stlkr_emergencystealth","ClientSprites:Icon_SkillPhysical_Vulnerable","ClientSprites:Icon_SkillStalker_Punish","ClientSprites:Icon_SkillMisc_UI_m_dschrgshld","ClientSprites:Icon_SkillWarrior_Tether_Anchor","ClientSprites:Icon_SkillEngineer_Give_Em_Gas","ClientSprites:Icon_SkillStalker_Preparation","ClientSprites:Icon_SkillWarrior_Plasma_Pulse_Alt","ClientSprites:Icon_SkillMind_UI_espr_fltr","ClientSprites:Icon_SkillPetCommand_Combat_Pet_Assist","ClientSprites:Icon_SkillPhysical_UI_wr_lng","ClientSprites:Icon_SkillSpellslinger_vitality_burst",
	"ClientSprites:Icon_SkillShadow_UI_stlkr_concealedslash","ClientSprites:Icon_SkillMisc_UI_m_jolt","ClientSprites:Icon_SkillShadow_UI_SM_bldbnd","ClientSprites:Icon_SkillWarrior_Power_Link","ClientSprites:Icon_SkillShadow_UI_stlkr_ragingslash","ClientSprites:Icon_SkillShadow_UI_SM_maul","ClientSprites:Icon_SkillWarrior_Shield_Burst","ClientSprites:Icon_SkillShadow_UI_SM_rip","ClientSprites:Icon_SkillEsper_Catharsis_Alt","ClientSprites:Icon_SkillPhysical_FountainOfBlood","ClientSprites:Icon_SkillShadow_UI_SM_reprisal","ClientSprites:Icon_SkillMedic_Emission","ClientSprites:Icon_SkillMedic_nullifyfield",
	"ClientSprites:Icon_SkillPhysical_UI_wr_saw","ClientSprites:Icon_SkillMisc_Scientist_CreatePortal_HomeCity_Thayd","ClientSprites:Icon_SkillMisc_Scientist_CreatePortal_HomeCity_Illium","ClientSprites:Icon_SkillPhysical_UI_wr_punt","ClientSprites:Icon_SkillWarrior_Guarded_Strikes","ClientSprites:Icon_SkillPetCommand_Combat_Pet_Aggressive","ClientSprites:Icon_SkillEngineer_Eradication_Mode","ClientSprites:Icon_SkillEsper_Catharsis","ClientSprites:Icon_SkillEsper_Replicate","ClientSprites:Icon_SkillSpellslinger_charged_shot","ClientSprites:Icon_SkillMedic_repairprobes2","ClientSprites:Icon_SkillWarrior_Cannon_Volley",
	"ClientSprites:Icon_SkillSpellslinger_frozen_bolt","ClientSprites:Icon_SkillMisc_UI_m_chnltng","ClientSprites:Icon_SkillEsper_Catharsis_Alt_Yellow","ClientSprites:Icon_SkillSpellslinger_aura","ClientSprites:Icon_SkillEsper_Catharsis_Alt_Blue","ClientSprites:Icon_SkillEsper_Catharsis_Alt_Red","ClientSprites:Icon_SkillEsper_Catharsis_Alt_Orange","ClientSprites:Icon_SkillSpellslinger_call_the_void","IconSprites:Icon_SkillIce_UI_srcr_avlnch","IconSprites:Icon_SkillIce_UI_srcr_iceshrds","IconSprites:Icon_SkillNature_UI_srcr_dstdvl","IconSprites:Icon_SkillNature_UI_srcr_wndwlk"
};

local tRandomMap = { 98,  6, 85,150, 36, 23,112,164,135,207,169,  5, 26, 64,165,219,
       61, 20, 68, 89,130, 63, 52,102, 24,229,132,245, 80,216,195,115,
       90,168,156,203,177,120,  2,190,188,  7,100,185,174,243,162, 10,
      237, 18,253,225,  8,208,172,244,255,126,101, 79,145,235,228,121,
      123,251, 67,250,161,  0,107, 97,241,111,181, 82,249, 33, 69, 55,
       59,153, 29,  9,213,167, 84, 93, 30, 46, 94, 75,151,114, 73,222,
      197, 96,210, 45, 16,227,248,202, 51,152,252,125, 81,206,215,186,
       39,158,178,187,131,136,  1, 49, 50, 17,141, 91, 47,129, 60, 99,
      154, 35, 86,171,105, 34, 38,200,147, 58, 77,118,173,246, 76,254,
      133,232,196,144,198,124, 53,  4,108, 74,223,234,134,230,157,139,
      189,205,199,128,176, 19,211,236,127,192,231, 70,233, 88,146, 44,
      183,201, 22, 83, 13,214,116,109,159, 32, 95,226,140,220, 57, 12,
      221, 31,209,182,143, 92,149,184,148, 62,113, 65, 37, 27,106,166,
        3, 14,204, 72, 21, 41, 56, 66, 28,193, 40,217, 25, 54,179,117,
      238, 87,240,155,180,170,242,212,191,163, 78,218,137,194,175,110,
       43,119,224, 71,122,142, 42,160,104, 48,247,103, 15, 11,138,239 
};

function S:GetSpellIcon(strSpellName)
	local h = 0;

	for i = 1, #strSpellName do
		local char = strSpellName:sub(i,i);
		local nvalue = string.byte(char);
		local index = bit32.bxor(h, nvalue);
		h = tRandomMap[index + 1];
	end

	return tSpellIconSprites[h + 1];
end
