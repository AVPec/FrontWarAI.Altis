params ["_managedGroup","_spawnPos","_unitSpecialization","_side","_groupSize"];

if (_side == independent) then {
	switch (_unitSpecialization) do {
		case "infantry": {
			_untType = ["I_G_Soldier_A_F","I_G_Soldier_AR_F","I_G_medic_F","I_G_engineer_F","I_G_Soldier_exp_F","I_G_Soldier_GL_F","I_G_Soldier_GL_F","I_G_Soldier_M_F","I_G_officer_F","I_G_Soldier_F","I_G_Soldier_LAT_F","I_G_Soldier_LAT2_F","I_G_Soldier_lite_F","I_G_Sharpshooter_F","I_G_Soldier_SL_F","I_G_Soldier_TL_F"]
		};
		case "crew": { }
	};
} else {
	switch (_unitSpecialization) do {
		case "infantry": {
			_untType = ["O_Soldier_A_F","O_Soldier_AAR_F","O_HeavyGunner_F","O_soldier_M_F","O_Soldier_AHAT_F","O_Soldier_AAA_F","O_Soldier_AAT_F","O_Soldier_AR_F","O_medic_F","O_soldier_exp_F","O_engineer_F","O_Soldier_GL_F","O_soldier_mine_F","O_Soldier_AA_F","O_Soldier_AT_F","O_officer_F","O_soldier_repair_F","O_Soldier_F","O_Soldier_LAT_F","O_Soldier_HAT_F","O_Soldier_lite_F","O_Sharpshooter_F","O_Soldier_SL_F","O_Soldier_TL_F","O_soldierU_A_F","O_soldierU_AAR_F","O_soldierU_AAA_F","O_soldierU_AAT_F","O_soldierU_AR_F","O_soldierU_medic_F","O_engineer_U_F","O_soldierU_exp_F","O_SoldierU_GL_F","O_Urban_HeavyGunner_F","O_soldierU_M_F","O_soldierU_AA_F","O_soldierU_repair_F","O_soldierU_F","O_soldierU_LAT_F","O_Urban_Sharpshooter_F","O_SoldierU_SL_F","O_soldierU_TL_F"]
		};
		case "crew": { }
	};	
};

for "_i" from 1 to _groupSize do {	
	_unit = _managedGroup createUnit [(selectRandom _untType), _spawnPos, [], 20, "CAN_COLLIDE"];
};