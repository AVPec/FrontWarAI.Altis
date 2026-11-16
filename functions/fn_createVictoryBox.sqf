params ["_position","_numA","_numB"];

	_arrBox=[];
	_boxType = switch (selectRandomWeighted ["AAF",8,"NATO",8,"AaN",5]) do 
	{
		case "AAF":
		{
			["Box_IND_Support_F",50,"Box_IND_Ammo_F",100,"Box_IND_Grenades_F",40,"Box_IND_AmmoOrd_F",30,"Box_IND_WpsSpecial_F",20,"Box_IND_WpsLaunch_F",40,"Box_IND_Wps_F",70]
		};		
		case "NATO":
		{
			["Box_NATO_Support_F",30,"Box_NATO_Ammo_F",100,"Box_NATO_Grenades_F",40,"Box_NATO_AmmoOrd_F",30,"Box_NATO_WpsSpecial_F",20,"Box_NATO_WpsLaunch_F",40,"Box_NATO_Wps_F",70]
		};
		case "AaN":
		{
			["Box_IND_Support_F",50,"Box_IND_Ammo_F",100,"Box_IND_Grenades_F",40,"Box_IND_AmmoOrd_F",30,"Box_IND_WpsSpecial_F",20,"Box_IND_WpsLaunch_F",40,"Box_IND_Wps_F",70,"Box_NATO_Support_F",30,"Box_NATO_Ammo_F",100,"Box_NATO_Grenades_F",40,"Box_NATO_AmmoOrd_F",30,"Box_NATO_WpsSpecial_F",20,"Box_NATO_WpsLaunch_F",40,"Box_NATO_Wps_F",70]
		};
	};

	for "_i" from 1 to _numA do
	{	
		_type = selectRandomWeighted _boxType;
		_create = createVehicle [_type,[(_position select 0),(_position select 1),2], [], .5, "CAN_COLLIDE"];
		_create	allowDamage false;
		_create setDir (random 360);
		_arrBox pushBack _create;
		sleep .5;

		clearWeaponCargoGlobal _create;
		clearMagazineCargoGlobal _create;
		clearBackpackCargoGlobal _create;
		clearItemCargoGlobal _create;

		switch _type do 
		{
			case "Box_IND_Support_F":
			{
				_create addMagazineCargoGlobal ["Laserbatteries",(2+floor(random 11))];
				_create addItemCargoGlobal ["FirstAidKit",(6+floor(random 23))];
				for "_i" from 1 to _numB do 
				{ 
					_create addItemCargoGlobal 
					(switch (selectRandomWeighted ["item",40,"backpack",60,"vest",100]) do 
					{
						case "item": {[selectRandomWeighted["ItemGPS",50,"NVGoggles_INDEP",30,"Medikit",20,"ToolKit",40,"Binocular",50,"Rangefinder",10],(1+floor(random 3))]};
						case "backpack": {[selectRandomWeighted["B_TacticalPack_blk",30,"B_TacticalPack_oli",30,"B_FieldPack_oli",100,"B_LegStrapBag_black_F",15,"B_LegStrapBag_olive_F",15],(1+floor(random 2))]};
						case "vest": {[selectRandomWeighted["V_BandollierB_blk",35,"V_Pocketed_olive_F",12,"V_Pocketed_black_F",12,"V_Rangemaster_belt",70,"V_BandollierB_oli",50,"V_TacVest_oli",100,"V_PlateCarrierIA1_dgtl",80,"V_PlateCarrierIA2_dgtl",80,"V_RebreatherIA",5,"V_TacChestrig_oli_F",40],(1+floor(random 3))]};
					})
				} 
			}; 		 
		
			case "Box_IND_Ammo_F":
			{ 
				for "_i" from 1 to _numB do 
				{	
					_create addMagazineCargoGlobal 
					(switch (selectRandomWeighted ["belts",30,"stanag",100]) do 
					{
						case "belts": {[selectRandomWeighted["100Rnd_580x42_Mag_F",60,"150Rnd_762x54_Box",130,"200Rnd_556x45_Box_Tracer_F",120,"200Rnd_65x39_cased_Box",150,"150Rnd_93x64_Mag",50,"75Rnd_762x39_Mag_F",20,"75rnd_762x39_AK12_Mag_F",10],(2+floor(random 8))]};
						case "stanag": {[selectRandomWeighted["20Rnd_556x45_UW_mag",60,"30Rnd_580x42_Mag_F",140,"30Rnd_556x45_Stanag",140,"30Rnd_545x39_Mag_Tracer_F",140,"30Rnd_762x39_Mag_Tracer_F",130,"30Rnd_9x21_Mag_SMG_02",150,"10Rnd_127x54_Mag",30,"10Rnd_762x54_Mag",60,"10Rnd_93x64_DMR_05_Mag",30,"20Rnd_650x39_Cased_Mag_F",100,"20Rnd_762x51_Mag",80,"50Rnd_570x28_SMG_03",80,"30Rnd_762x39_AK12_Mag_F",60,"10Rnd_50BW_Mag_F",35,"30Rnd_65x39_caseless_msbs_mag",70,"6Rnd_12Gauge_Pellets",15,"6Rnd_12Gauge_Slug",15,"2Rnd_12Gauge_Pellets",15,"2Rnd_12Gauge_Slug",15,"5Rnd_127x108_Mag",12,"5Rnd_127x108_APDS_Mag",5],(4+floor(random 21))]};
					})
				} 
			};  
			
			case "Box_IND_Grenades_F":
			{ 
				for "_i" from 1 to _numB do 
				{ 
					_create addMagazineCargoGlobal 
					(switch (selectRandomWeighted ["handGrenade",50,"rocketGrenade",100]) do 
					{
						case "handGrenade": {[selectRandomWeighted["HandGrenade",200,"1Rnd_HE_Grenade_shell",180,"UGL_FlareWhite_F",20,"UGL_FlareGreen_F",20,"UGL_FlareRed_F",20,"UGL_FlareYellow_F",20,"UGL_FlareCIR_F",20,"1Rnd_Smoke_Grenade_shell",10,"1Rnd_SmokeRed_Grenade_shell",10,"1Rnd_SmokeGreen_Grenade_shell",10,"1Rnd_SmokeYellow_Grenade_shell",10,"1Rnd_SmokePurple_Grenade_shell",10,"1Rnd_SmokeBlue_Grenade_shell",10,"1Rnd_SmokeOrange_Grenade_shell",10,"3Rnd_HE_Grenade_shell",120,"3Rnd_UGL_FlareWhite_F",15,"3Rnd_UGL_FlareGreen_F",16,"3Rnd_UGL_FlareRed_F",15,"3Rnd_UGL_FlareYellow_F",15,"3Rnd_UGL_FlareCIR_F",15,"3Rnd_Smoke_Grenade_shell",5,"3Rnd_SmokeRed_Grenade_shell",5,"3Rnd_SmokeGreen_Grenade_shell",5,"3Rnd_SmokeYellow_Grenade_shell",5,"3Rnd_SmokePurple_Grenade_shell",5,"3Rnd_SmokeBlue_Grenade_shell",5,"3Rnd_SmokeOrange_Grenade_shell",5,"MiniGrenade",200,"I_IR_Grenade",50],(3+floor(random 10))]};
						case "rocketGrenade": {[selectRandomWeighted["RPG7_F",100,"RPG32_F",45,"RPG32_HE_F",35,"Titan_AA",20,"Titan_AT",15,"Titan_AP",10,"Vorona_HEAT",35,"Vorona_HE",30],(2+floor(random 7))]};
					})
				}
			}; 

			case "Box_IND_AmmoOrd_F":
			{ 
				for "_i" from 1 to _numB do 
				{ 
					_create addMagazineCargoGlobal 
					[selectRandomWeighted["DemoCharge_Remote_Mag",100,"SatchelCharge_Remote_Mag",40,"APERSBoundingMine_Range_Mag",35,"APERSTripMine_Wire_Mag",80,"TrainingMine_Mag",5,"ATMine_Range_Mag",20],(2+floor(random 5))]; 
				} 
			}; 

			case "Box_IND_WpsSpecial_F":
			{ 
				for "_i" from 1 to _numB do 
				{ 
					_create addWeaponCargoGlobal 
					(switch (selectRandomWeighted ["rifle",40,"machineGun",100]) do 
					{
						case "rifle": {[selectRandomWeighted["srifle_DMR_04_F",80,"srifle_DMR_04_ACO_F",70,"srifle_DMR_04_MRCO_F",60,"srifle_DMR_04_SOS_F",40,"srifle_DMR_04_DMS_F",50,"srifle_DMR_04_ARCO_F",60,"srifle_DMR_04_NS_LP_F",30,"srifle_DMR_05_blk_F",70,"srifle_DMR_05_ACO_F",60,"srifle_DMR_05_MRCO_F",50,"srifle_DMR_05_SOS_F",30,"srifle_DMR_05_DMS_F",40,"srifle_DMR_05_KHS_LP_F",40,"srifle_DMR_05_DMS_snds_F",30,"srifle_DMR_05_ARCO_F",50,"srifle_DMR_07_blk_F",150,"srifle_DMR_07_blk_DMS_F",130,"srifle_DMR_07_blk_DMS_Snds_F",110,"srifle_DMR_07_blk_F_arco_flash_F",140,"srifle_DMR_04_DMS_weathered_Kir_F_F",50,"srifle_GM6_F",70,"srifle_GM6_SOS_F",40,"srifle_GM6_LRPS_F",30,"srifle_DMR_01_F",100,"srifle_DMR_01_ACO_F",90,"srifle_DMR_01_MRCO_F",80,"srifle_DMR_01_SOS_F",50,"srifle_DMR_01_DMS_F",70,"srifle_DMR_01_DMS_snds_F",50,"srifle_DMR_01_ARCO_F",80,"srifle_EBR_F",100,"srifle_EBR_ACO_F",90,"srifle_EBR_MRCO_pointer_F",80,"srifle_EBR_ARCO_pointer_F",80,"srifle_EBR_SOS_F",50,"srifle_EBR_ARCO_pointer_snds_F",60,"srifle_EBR_DMS_F",70,"srifle_EBR_Hamr_pointer_F",80,"srifle_EBR_DMS_pointer_snds_F",50,"srifle_DMR_01_DMS_BI_F",70,"srifle_DMR_01_DMS_snds_BI_F",50,"srifle_EBR_MRCO_LP_BI_F",80,"B_Patrol_Soldier_Marksman_weapon_F",50],(1+floor(random 2))]};
						case "machineGun": {[selectRandomWeighted["LMG_Mk200_F",100,"LMG_Mk200_MRCO_F",80,"LMG_Mk200_pointer_F",100,"LMG_Zafir_F",110,"LMG_Zafir_pointer_F",110,"LMG_Zafir_ARCO_F",90,"LMG_Mk200_LP_BI_F",100,"LMG_Mk200_BI_F",100,"MMG_01_tan_F",150,"LMG_03_F",160,"LMG_03_Vehicle_F",160,"B_Patrol_Soldier_MachineGunner_weapon_F",60,"B_Patrol_Soldier_HeavyGunner_weapon_F",90],(1+floor(random 3))]};
					})
				}
			}; 
			
			case "Box_IND_WpsLaunch_F":
			{ 
				for "_i" from 1 to _numB do 
				{ 
					_create addWeaponCargoGlobal 
					[selectRandomWeighted["launch_O_Vorona_green_F",60,"launch_I_Titan_short_F",25,"launch_RPG7_F",130,"launch_MRAWS_green_rail_F",90,"launch_RPG32_green_F",80,"launch_B_Titan_olive_F",25],(1+floor(random 2))]; 
				} 
			}; 

			case "Box_IND_Wps_F":
			{ 
				for "_i" from 1 to _numB do 
				{ 
					_create addWeaponCargoGlobal 
					[selectRandomWeighted["arifle_Katiba_F",60,"arifle_Katiba_C_F",60,"arifle_Katiba_GL_F",50,"arifle_Katiba_C_ACO_pointer_F",50,"arifle_Katiba_C_ACO_F",50,"arifle_Katiba_ACO_F",50,"arifle_Katiba_pointer_F",60,"arifle_Katiba_ACO_pointer_F",50,"arifle_Katiba_ARCO_F",40,"arifle_Katiba_ARCO_pointer_F",40,"arifle_Katiba_GL_ACO_F",40,"arifle_Katiba_GL_ARCO_pointer_F",40,"arifle_Katiba_GL_ACO_pointer_F",40,"arifle_Katiba_GL_Nstalker_pointer_F",5,"arifle_Katiba_GL_ACO_pointer_snds_F",30,"arifle_Katiba_C_ACO_pointer_snds_F",30,"arifle_Katiba_ACO_pointer_snds_F",30,"arifle_Katiba_ARCO_pointer_snds_F",20,"arifle_Mk20_F",240,"arifle_Mk20_plain_F",200,"arifle_Mk20C_F",240,"arifle_Mk20C_plain_F",200,"arifle_Mk20_GL_F",230,"arifle_Mk20_GL_plain_F",190,"arifle_Mk20C_ACO_F",230,"arifle_Mk20C_ACO_pointer_F",230,"arifle_Mk20_pointer_F",230,"arifle_Mk20_Holo_F",230,"arifle_Mk20_ACO_F",230,"arifle_Mk20_ACO_pointer_F",230,"arifle_Mk20_MRCO_F",220,"arifle_Mk20_MRCO_plain_F",180,"arifle_Mk20_MRCO_pointer_F",220,"arifle_Mk20_GL_MRCO_pointer_F",210,"arifle_Mk20_GL_ACO_F",220,"arifle_SDAR_F",80,"arifle_TRG21_F",170,"arifle_TRG20_F",170,"arifle_TRG21_GL_F",160,"arifle_TRG20_Holo_F",160,"arifle_TRG20_ACO_pointer_F",160,"arifle_TRG20_ACO_Flash_F",160,"arifle_TRG20_ACO_F",160,"arifle_TRG21_ACO_pointer_F",160,"arifle_TRG21_ARCO_pointer_F",150,"arifle_TRG21_MRCO_F",150,"arifle_TRG21_GL_MRCO_F",140,"arifle_TRG21_GL_ACO_pointer_F",150,"arifle_AK12_F",220,"arifle_AK12_GL_F",200,"arifle_AKM_F",250,"arifle_AKS_F",250,"arifle_CTAR_blk_F",40,"arifle_CTAR_GL_blk_F",30,"arifle_CTAR_blk_ACO_Pointer_F",30,"arifle_CTAR_blk_Pointer_F",40,"arifle_CTAR_blk_ACO_F",30,"arifle_CTAR_GL_blk_ACO_F",20,"arifle_CTAR_GL_blk_ARCO_Pointer_F",10,"arifle_CTAR_blk_ARCO_Pointer_F",20,"arifle_CTAR_blk_ACO_Pointer_Snds_F",10,"arifle_CTAR_GL_blk_ACO_Pointer_Snds_F",5,"arifle_CTAR_blk_ARCO_Pointer_Snds_F",5,"arifle_CTAR_blk_ARCO_F",20,"arifle_CTARS_blk_F",30,"arifle_CTARS_blk_Pointer_F",30,"arifle_CTAR_blk_flash_F",40,"arifle_CTAR_blk_aco_flash_F",30,"arifle_CTAR_blk_arco_flash_F",20,"arifle_CTARS_blk_flash_F",30,"arifle_CTAR_GL_blk_aco_flash_F",20,"arifle_CTAR_GL_blk_arco_flash_F",10,"sgun_HunterShotgun_01_F",60,"sgun_HunterShotgun_01_sawedoff_F",60],(1+floor(random 3))]; 
				} 
			}; 

			case "Box_NATO_Support_F":
			{
				_create addItemCargoGlobal ["Laserbatteries",(2+floor(random 11))];
				_create addItemCargoGlobal ["FirstAidKit",(6+floor(random 23))];
				for "_i" from 1 to _numB do 
				{
					_create addItemCargoGlobal 
					(switch (selectRandomWeighted ["item",40,"backpack",60,"vest",100]) do 
					{
						case "item": {[selectRandomWeighted["ItemGPS",50,"NVGoggles_OPFOR",30,"Medikit",20,"ToolKit",40,"Binocular",50,"Rangefinder",10],(1+floor(random 3))]};
						case "backpack": {[selectRandomWeighted["B_AssaultPack_khk",60,"B_AssaultPack_rgr",60,"B_AssaultPack_blk",40,"B_Kitbag_rgr",100,"B_Messenger_Olive_F",20,"B_Messenger_Black_F",20],(1+floor(random 2))]};
						case "vest": {[selectRandomWeighted["V_Chestrig_blk",45,"V_LegStrapBag_olive_F",12,"V_LegStrapBag_black_F",12,"V_PlateCarrier2_blk",25,"V_PlateCarrier1_blk",25,"V_TacVestIR_blk",50,"V_RebreatherB",5,"V_Chestrig_oli",50,"V_TacVest_blk",70,"V_TacVest_blk_POLICE",70,"V_TacChestrig_grn_F",35],(1+floor(random 3))]};
					})
				}
			};

			case "Box_NATO_Ammo_F":
			{ 
				for "_i" from 1 to _numB do 
				{	
					_create addMagazineCargoGlobal 
					(switch (selectRandomWeighted ["belts",30,"stanag",60]) do 
					{
						case "belts": {[selectRandomWeighted["200Rnd_556x45_Box_Tracer_F",120,"150Rnd_556x45_Drum_Mag_F",20,"100Rnd_65x39_caseless_mag",150,"100Rnd_65x39_caseless_black_mag",80,"130Rnd_338_Mag",50,"75Rnd_762x39_Mag_F",20,"75rnd_762x39_AK12_Mag_F",10],(2+floor(random 7))]};
						case "stanag": {[selectRandomWeighted["20Rnd_556x45_UW_mag",60,"30Rnd_45ACP_Mag_SMG_01",70,"30Rnd_556x45_Stanag",140,"30Rnd_545x39_Mag_Tracer_F",140,"30Rnd_762x39_Mag_Tracer_F",130,"30Rnd_9x21_Mag_SMG_02",150,"10Rnd_338_Mag",10,"20Rnd_762x51_Mag",80,"30Rnd_65x39_caseless_mag",170,"30Rnd_65x39_caseless_black_mag",100,"50Rnd_570x28_SMG_03",80,"30Rnd_762x39_AK12_Mag_F",60,"30Rnd_65x39_caseless_msbs_mag",70,"6Rnd_12Gauge_Pellets",15,"6Rnd_12Gauge_Slug",15,"2Rnd_12Gauge_Pellets",15,"2Rnd_12Gauge_Slug",15,"10Rnd_Mk14_762x51_Mag",60,"7Rnd_408_Mag",8],(4+floor(random 21))]};
					})
				} 
			}; 

			case "Box_NATO_Grenades_F":
			{ 
				for "_i" from 1 to _numB do 
				{ 
					_create addMagazineCargoGlobal 
					(switch (selectRandomWeighted ["handGrenade",50,"rocketGrenade",100]) do 
					{
						case "handGrenade": {[selectRandomWeighted["HandGrenade",200,"1Rnd_HE_Grenade_shell",180,"UGL_FlareWhite_F",20,"UGL_FlareGreen_F",20,"UGL_FlareRed_F",20,"UGL_FlareYellow_F",20,"UGL_FlareCIR_F",20,"1Rnd_Smoke_Grenade_shell",10,"1Rnd_SmokeRed_Grenade_shell",10,"1Rnd_SmokeGreen_Grenade_shell",10,"1Rnd_SmokeYellow_Grenade_shell",10,"1Rnd_SmokePurple_Grenade_shell",10,"1Rnd_SmokeBlue_Grenade_shell",10,"1Rnd_SmokeOrange_Grenade_shell",10,"3Rnd_HE_Grenade_shell",120,"3Rnd_UGL_FlareWhite_F",15,"3Rnd_UGL_FlareGreen_F",16,"3Rnd_UGL_FlareRed_F",15,"3Rnd_UGL_FlareYellow_F",15,"3Rnd_UGL_FlareCIR_F",15,"3Rnd_Smoke_Grenade_shell",5,"3Rnd_SmokeRed_Grenade_shell",5,"3Rnd_SmokeGreen_Grenade_shell",5,"3Rnd_SmokeYellow_Grenade_shell",5,"3Rnd_SmokePurple_Grenade_shell",5,"3Rnd_SmokeBlue_Grenade_shell",5,"3Rnd_SmokeOrange_Grenade_shell",5,"MiniGrenade",200,"B_IR_Grenade",50,"I_IR_Grenade",1],(3+floor(random 10))]};
						case "rocketGrenade": {[selectRandomWeighted["RPG7_F",100,"NLAW_F",50,"Titan_AA",20,"Titan_AT",15,"Titan_AP",10,"MRAWS_HEAT_F",25,"MRAWS_HE_F",15,"MRAWS_HEAT55_F",25],(2+floor(random 7))]};
					})
				}
			}; 
			
			case "Box_NATO_AmmoOrd_F":
			{ 
				for "_i" from 1 to _numB do 
				{ 
					_create addMagazineCargoGlobal 
					[selectRandomWeighted["DemoCharge_Remote_Mag",100,"SatchelCharge_Remote_Mag",40,"ClaymoreDirectionalMine_Remote_Mag",40,"APERSMine_Range_Mag",50,"TrainingMine_Mag",5,"SLAMDirectionalMine_Wire_Mag",20],(2+floor(random 5))]; 
				} 
			};

			case "Box_NATO_WpsSpecial_F":
			{ 
				for "_i" from 1 to _numB do 
				{ 
					_create addWeaponCargoGlobal 
					(switch (selectRandomWeighted ["rifle",20,"machineGun",100]) do 
					{
						case "rifle": {[selectRandomWeighted["srifle_LRR_F",100,"srifle_LRR_SOS_F",80,"srifle_LRR_LRPS_F",70,"srifle_DMR_02_F",90,"srifle_DMR_02_ACO_F",80,"srifle_DMR_02_MRCO_F",70,"srifle_DMR_02_SOS_F",50,"srifle_DMR_02_DMS_F",60,"srifle_DMR_02_ARCO_F",70,"srifle_DMR_03_F",100,"srifle_DMR_03_ACO_F",90,"srifle_DMR_03_MRCO_F",80,"srifle_DMR_03_SOS_F",60,"srifle_DMR_03_DMS_F",70,"srifle_DMR_03_DMS_snds_F",60,"srifle_DMR_03_ARCO_F",80,"srifle_DMR_03_AMS_F",70,"srifle_DMR_06_olive_F",260,"arifle_SPAR_03_blk_F",450,"srifle_DMR_06_hunter_F",260],(1+floor(random 2))]};
						case "machineGun": {[selectRandomWeighted["arifle_MX_SW_F",120,"arifle_MX_SW_pointer_F",120,"arifle_MX_SW_Hamr_pointer_F",100,"arifle_MX_SW_Black_F",110,"arifle_MX_SW_Black_Hamr_pointer_F",90,"MMG_02_black_F",30,"MMG_02_black_RCO_BI_F",60,"LMG_03_F",140,"LMG_03_Vehicle_F",140,"arifle_SPAR_02_blk_F",220,"B_Patrol_Soldier_Autorifleman_weapon_F",90,"arifle_MX_SW_Black_Pointer_F",110],(1+floor(random 3))]};
					})
				}
			}; 	

			case "Box_NATO_WpsLaunch_F":
			{ 
				for "_i" from 1 to _numB do 
				{ 
					_create addWeaponCargoGlobal 
					[selectRandomWeighted["launch_NLAW_F",60,"launch_B_Titan_F",25,"launch_B_Titan_short_F",25,"launch_RPG7_F",120,"launch_MRAWS_green_rail_F",80],(1+floor(random 2))]; 
				} 
			}; 
			
			case "Box_NATO_Wps_F":
			{ 
				for "_i" from 1 to _numB do 
				{ 
					_create addWeaponCargoGlobal 
					[selectRandomWeighted["arifle_MXC_F",150,"arifle_MX_F",150,"arifle_MX_GL_F",100,"arifle_MXM_F",80,"arifle_MX_pointer_F",150,"arifle_MX_Holo_pointer_F",140,"arifle_MX_Hamr_pointer_F",130,"arifle_MX_ACO_pointer_F",140,"arifle_MX_ACO_F",140,"arifle_MX_GL_ACO_F",90,"arifle_MX_GL_ACO_pointer_F",90,"arifle_MX_GL_Hamr_pointer_F",80,"arifle_MXC_Holo_F",140,"arifle_MXC_Holo_pointer_F",140,"arifle_MXM_Hamr_pointer_F",60,"arifle_MXC_ACO_F",140,"arifle_MXC_Holo_pointer_snds_F",120,"arifle_MXC_SOS_point_snds_F",90,"arifle_MXC_ACO_pointer_snds_F",120,"arifle_MXC_ACO_pointer_F",140,"arifle_MX_ACO_pointer_snds_F",120,"arifle_MX_RCO_pointer_snds_F",110,"arifle_MX_GL_Holo_pointer_snds_F",70,"arifle_MXM_SOS_pointer_F",20,"arifle_MXM_RCO_pointer_snds_F",40,"arifle_MXM_DMS_F",40,"arifle_MXC_Black_F",140,"arifle_MX_Black_F",140,"arifle_MX_GL_Black_F",90,"arifle_MXM_Black_F",70,"arifle_MX_GL_Black_Hamr_pointer_F",70,"arifle_MX_Black_Hamr_pointer_F",120,"arifle_SDAR_F",30,"arifle_TRG21_F",90,"arifle_TRG20_F",90,"arifle_TRG21_GL_F",80,"arifle_TRG20_Holo_F",80,"arifle_TRG20_ACO_pointer_F",80,"arifle_TRG20_ACO_Flash_F",80,"arifle_TRG20_ACO_F",80,"arifle_TRG21_ACO_pointer_F",80,"arifle_TRG21_ARCO_pointer_F",70,"arifle_TRG21_MRCO_F",70,"arifle_TRG21_GL_MRCO_F",60,"arifle_TRG21_GL_ACO_pointer_F",70,"arifle_MXM_DMS_LP_BI_snds_F",30,"arifle_MXM_Hamr_LP_BI_F",60,"arifle_AKM_F",150,"arifle_AKS_F",150,"arifle_SPAR_01_blk_F",60,"arifle_SPAR_01_GL_blk_F",50,"B_Patrol_Soldier_Leader_weapon_F",70,"B_Patrol_Soldier_Operator_weapon_F",120,"B_Patrol_Soldier_Medic_weapon_F",120,"B_Patrol_Soldier_Carrier_weapon_F",120,"B_Patrol_Soldier_Specialist_weapon_F",120,"arifle_MX_Black_ACO_Pointer_F",130,"arifle_MX_Black_ACO_FL_F",130,"arifle_MX_Black_Holo_Pointer_F",130,"arifle_MX_Black_Hamr_Pointer_Snds_F",110,"arifle_MX_Black_Pointer_F",140,"arifle_MX_Black_ACO_Pointer_Snds_F",110,"arifle_MX_GL_Black_ACO_F",80,"arifle_MX_GL_Black_Holo_Pointer_Snds_F",60,"arifle_MXC_Black_Holo_Pointer_F",130,"arifle_MXC_Black_Holo_FL_F",130,"arifle_MXC_Black_ACO_F",130,"arifle_MXC_Black_ACO_Pointer_Snds_F",110,"arifle_MXM_Black_MOS_Pointer_Bipod_F",10,"arifle_MXM_Black_MOS_Pointer_Bipod_Snds_F",5,"sgun_HunterShotgun_01_F",60,"sgun_HunterShotgun_01_sawedoff_F",60],(1+floor(random 3))]; 
				} 
			};
		};
	};

	{if ((_position distance2D (getPos _x))>1) then {deleteVehicle _x}else{_x allowDamage true}} foreach _arrBox;

	_mkrLoot = createMarker[format["_mkrLoot_%1",str _position],_position];
	_mkrLoot setMarkerType "Mil_dot";
	_mkrLoot setMarkercolor "Color4_FD_F";
	_mkrLoot setMarkerText "loot";

/*


_dfger = [];
{
	if (vehicleVarName _x != "") then 
	{
		_array = [];
		_comnd = "";
		_itms = getItemCargo _x;
		for "_i" from 0 to ((count (_itms select 0))-1) do 
		{
			_comnd = "addItemCargoGlobal";
			_array pushBack ((_itms select 0) select _i);
			_array pushBack ((_itms select 1) select _i); 
		};
		_itms = getMagazineCargo _x;
		for "_i" from 0 to ((count (_itms select 0))-1) do 
		{
			_comnd = "addMagazineCargoGlobal";
			_array pushBack ((_itms select 0) select _i);
			_array pushBack ((_itms select 1) select _i); 
		};
		_itms = getWeaponCargo _x;
		for "_i" from 0 to ((count (_itms select 0))-1) do 
		{
			_comnd = "addWeaponCargoGlobal";
			_array pushBack ((_itms select 0) select _i);
			_array pushBack ((_itms select 1) select _i); 
		};
		_afqwrqwe = (everyContainer _x);
		{
			_typeItem = (_x select 0);
			if !(_typeItem in _array) then 
			{
				_comnd = "addItemCargoGlobal";
				_array pushBack _typeItem;
				_array pushBack ({(_x select 0) == _typeItem} count _afqwrqwe);
			};
		} foreach _afqwrqwe;

		_dfger pushBack 
		(
format 
[
"
case '%1'
{
for '_i' from 1 to _numB do
{
_create %2
[selectRandomWeighted%3,%4];
}
};
",
typeof _x,
_comnd,
_array,
vehicleVarName _x
]
		);
	};	
} foreach (allMissionObjects "");
_dfger
