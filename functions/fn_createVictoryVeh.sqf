params ["_position","_type"];

	_vehType = if (surfaceIsWater _position) then 
	{
		switch _type do 
		{
			case "1": 
			{
				selectRandomWeighted [(selectRandom ["I_MRAP_03_F","I_MRAP_03_gmg_F","I_MRAP_03_hmg_F"]),100,(selectRandomWeighted ["C_Boat_Civil_01_F",100,"C_Boat_Civil_01_police_F",40,"C_Boat_Civil_01_rescue_F",60]),80,"I_C_Boat_Transport_02_F",50,"C_Scooter_Transport_01_F",40]
			};
			case "2": 
			{
				selectRandomWeighted ["I_APC_Wheeled_03_cannon_F",100,(selectRandom ["I_Boat_Armed_01_minigun_F","O_Boat_Armed_01_hmg_F"]),60,"I_SDV_01_F",20]
			};
			case "3": 
			{
				selectRandomWeighted ["I_SDV_01_F",100,(selectRandom ["I_Boat_Armed_01_minigun_F","O_Boat_Armed_01_hmg_F"]),40,"I_APC_Wheeled_03_cannon_F",20]
			};
		};
	}else{
		switch _type do 
		{
			case "1": 
			{
				selectRandomWeighted [(selectRandom ["C_Offroad_01_F","I_G_Offroad_01_armed_F","I_G_Offroad_01_AT_F"]),100,(selectRandom ["I_MRAP_03_F","I_MRAP_03_gmg_F","I_MRAP_03_hmg_F"]),100,(selectRandom ["O_LSV_02_unarmed_F","O_LSV_02_armed_F","O_LSV_02_AT_F"]),40,(selectRandom ["B_LSV_01_unarmed_F","B_LSV_01_armed_F","B_LSV_01_AT_F"]),30,(selectRandom ["C_Offroad_02_unarmed_F","I_C_Offroad_02_LMG_F","I_C_Offroad_02_AT_F"]),20,"C_Truck_02_box_F",20]
			};
			case "2": 
			{
				selectRandomWeighted ["I_APC_Wheeled_03_cannon_F",100,(selectRandom ["I_LT_01_cannon_F","I_LT_01_AT_F","I_LT_01_AA_F"]),25,"I_APC_tracked_03_cannon_F",15]
			};
			case "3": 
			{
				selectRandomWeighted ["I_MBT_03_cannon_F",100,"I_Truck_02_box_F",60,"I_UGV_01_rcws_F",30,(selectRandom ["O_MBT_04_cannon_F","O_MBT_04_command_F"]),20,"I_Truck_02_MRL_F",10]
			};
		};
	};

	_vehicle = _vehType createVehicle _position;
	if (_vehType == "C_Scooter_Transport_01_F") then {"C_Scooter_Transport_01_F" createVehicle (_position findEmptyPosition [3, 20, "C_Scooter_Transport_01_F"])};

	switch _vehType do 
	{
		case "C_Offroad_01_F": 
		{
			_comp = selectRandomWeighted [0,8,1,2];		
			[_vehicle,["Beige",16,"Green",22,"Guerilla_01",2,"Guerilla_02",2,"Guerilla_03",2,"Guerilla_04",2,"Guerilla_05",2,"Guerilla_06",2,"Guerilla_07",2,"Guerilla_08",2,"Guerilla_09",2,"Guerilla_10",2,"Guerilla_11",2,"Guerilla_12",2],["HideDoor1",_comp,"HideDoor2",_comp,"HideDoor3",0.8,"HideBackpacks",0.6,"HideBumper1",0.7,"HideBumper2",0.7,"HideConstruction",0.3,"hidePolice",1,"HideServices",1,"BeaconsStart",0,"BeaconsServicesStart",0]] call bis_fnc_initVehicle;	
		};
		case "I_G_Offroad_01_armed_F": 
		{
			_comp = selectRandomWeighted [0,2,1,8];		
			[_vehicle,["Green",6,"Guerilla_01",2,"Guerilla_02",2,"Guerilla_03",2,"Guerilla_04",2,"Guerilla_05",2,"Guerilla_06",2,"Guerilla_07",2,"Guerilla_08",2,"Guerilla_09",2,"Guerilla_10",2,"Guerilla_11",2,"Guerilla_12",2],["Hide_Shield",0.4,"Hide_Rail",0.2,"HideDoor1",_comp,"HideDoor2",_comp,"HideDoor3",0.8,"HideBackpacks",0.4,"HideBumper1",0.6,"HideBumper2",0.6,"HideConstruction",0.2]] call bis_fnc_initVehicle;
		};
		case "I_G_Offroad_01_AT_F": 
		{
			_comp = selectRandomWeighted [0,2,1,8];		
			[_vehicle,["Green",6,"Guerilla_01",2,"Guerilla_02",2,"Guerilla_03",2,"Guerilla_04",2,"Guerilla_05",2,"Guerilla_06",2,"Guerilla_07",2,"Guerilla_08",2,"Guerilla_09",2,"Guerilla_10",2,"Guerilla_11",2,"Guerilla_12",2],["HideDoor1",_comp,"HideDoor2",_comp,"HideDoor3",0.8,"HideBackpacks",0.4,"HideBumper1",0.6,"HideBumper2",0.6,"HideConstruction",0.2]] call bis_fnc_initVehicle;
		};
		
		case "O_LSV_02_unarmed_F":{[_vehicle,"Black",["Unarmed_Doors_Hide",0.7]] call bis_fnc_initVehicle};
		case "O_LSV_02_armed_F":{[_vehicle,"Black",["Unarmed_Doors_Hide",0.7]] call bis_fnc_initVehicle};
		case "O_LSV_02_AT_F":{[_vehicle,"Black",["Unarmed_Doors_Hide",0.7]] call bis_fnc_initVehicle};

		case "B_LSV_01_unarmed_F": 
		{
			_comp = floor(random 2);
			[_vehicle,"Black",["HideDoor1",_comp,"HideDoor2",_comp,"HideDoor3",_comp,"HideDoor4",_comp]] call bis_fnc_initVehicle;
		};
		case "B_LSV_01_armed_F": 
		{
			_comp = floor(random 2);
			[_vehicle,"Black",["HideDoor1",_comp,"HideDoor2",_comp,"HideDoor3",_comp,"HideDoor4",_comp]] call bis_fnc_initVehicle;
		};
		case "B_LSV_01_AT_F": 
		{
			_comp = floor(random 2);
			[_vehicle,"Black",["HideDoor1",_comp,"HideDoor2",_comp,"HideDoor3",_comp,"HideDoor4",_comp]] call bis_fnc_initVehicle;
		};

		case "C_Offroad_02_unarmed_F": 
		{
			_comp = selectRandomWeighted [0,8,1,2];		
			[_vehicle,["Black",0.8,"Green",0.6,"Olive",1,"Brown",1],["hideLeftDoor",_comp,"hideRightDoor",_comp,"hideRearDoor",0.1,"hideBullbar",0.4,"hideFenders",0.3,"hideHeadSupportRear",0.5,"hideHeadSupportFront",0.5,"hideRollcage",0.9,"hideSeatsRear",0,"hideSpareWheel",0.5]] call bis_fnc_initVehicle;
		};
		case "I_C_Offroad_02_LMG_F": 
		{
			_comp = selectRandomWeighted [0,2,1,8];		
			[_vehicle,["Black",0.6,"Green",0.2,"Olive",1,"Brown",1],["hideLeftDoor",_comp,"hideRightDoor",_comp,"hideRearDoor",0.3,"hideFenders",0.6,"hideHeadSupportFront",0.8,"hideSpareWheel",0.5,"hideBullbar",0]] call bis_fnc_initVehicle;
		};
		case "I_C_Offroad_02_AT_F": 
		{
			_comp = selectRandomWeighted [0,2,1,8];		
			[_vehicle,["Black",0.6,"Green",0.2,"Olive",1,"Brown",1],["hideLeftDoor",_comp,"hideRightDoor",_comp,"hideRearDoor",0.3,"hideFenders",0.6,"hideHeadSupportFront",0.8,"hideSpareWheel",0.5,"hideBullbar",0]] call bis_fnc_initVehicle;
		};

		case "C_Truck_02_box_F":{[_vehicle,["BlueGreen",1,"BlueOrange",0.8,"OrangeGreen",0.6,"OrangeOrange",0.4]] call bis_fnc_initVehicle};

		case "I_APC_Wheeled_03_cannon_F": 
		{
			[_vehicle,["Indep",1,"Guerilla_01",1,"Guerilla_02",1,"Guerilla_03",1],["showCamonetHull",0.3,"showBags",0.4,"showBags2",0.4,"showTools",0.3,"showSLATHull",0.05]] call bis_fnc_initVehicle;
		};

		case "I_LT_01_cannon_F": 
		{
			[_vehicle,["Indep_01",3,"Indep_02",0.1,"Indep_03",0.1,"Indep_Olive",0.3],["showTools",0.3,"showCamonetHull",0.3,"showBags",0.4,"showSLATHull",0.02]] call bis_fnc_initVehicle;
		};
		case "I_LT_01_AT_F": 
		{
			[_vehicle,["Indep_01",3,"Indep_02",0.1,"Indep_03",0.1,"Indep_Olive",0.3],["showTools",0.3,"showCamonetHull",0.3,"showBags",0.4,"showSLATHull",0.02]] call bis_fnc_initVehicle;
		};
		case "I_LT_01_AA_F": 
		{
			[_vehicle,["Indep_01",3,"Indep_02",0.1,"Indep_03",0.1,"Indep_Olive",0.3],["showTools",0.3,"showCamonetHull",0.3,"showBags",0.4,"showSLATHull",0.02]] call bis_fnc_initVehicle;
		};

		case "I_APC_tracked_03_cannon_F": 
		{
			_comp = selectRandomWeighted [0,1,1,0.5];		
			[_vehicle,["Indep_01",3,"Indep_02",0.1,"Indep_03",0.1],["showBags",0.4,"showBags2",0.4,"showCamonetHull",_comp,"showCamonetTurret",(if(_comp == 1)then{0.4}else{0}),"showTools",0.3,"showSLATHull",0.02,"showSLATTurret",0.1]] call bis_fnc_initVehicle;
		};

		case "I_MBT_03_cannon_F": 
		{
			_comp = selectRandomWeighted [0,1,1,0.5];		
			[_vehicle,["Indep_01",3,"Indep_02",0.1,"Indep_03",0.1],["HideTurret",0.5,"HideHull",0.5,"showCamonetHull",_comp,"showCamonetTurret",(if(_comp == 1)then{0.3}else{0})]] call bis_fnc_initVehicle;
		};

		case "I_Truck_02_box_F": 
		{
			_vehicle setObjectTexture [1,(["a3\soft_f_beta\truck_02\data\truck_02_repair_indp_co.paa","a3\soft_f_beta\truck_02\data\truck_02_repair_green_co.paa","a3\soft_f_beta\truck_02\data\truck_02_repair_co.paa"] selectRandomWeighted [2,3,1])];
		};

		case "O_MBT_04_cannon_F": 
		{
			_comp = selectRandomWeighted [0,1,1,0.6];		
			[_vehicle,["Grey",1,"Jungle",0.3],["showCamonetHull",1,"showCamonetTurret",(if(_comp == 1)then{0.3}else{0})]] call bis_fnc_initVehicle;
		};
		case "O_MBT_04_command_F": 
		{
			_comp = selectRandomWeighted [0,1,1,0.6];		
			[_vehicle,["Grey",1,"Jungle",0.3],["showCamonetHull",1,"showCamonetTurret",(if(_comp == 1)then{0.3}else{0})]] call bis_fnc_initVehicle;
		};

		case "I_Truck_02_MRL_F": 
		{
			_vehicle setObjectTexture [2,(["a3\soft_f_gamma\truck_02\data\truck_02_mrl_co.paa","a3\soft_f_gamma\truck_02\data\truck_02_mrl_opfor_co.paa","a3\soft_f_enoch\truck_02\data\truck_02_mrl_eaf_co.paa"] selectRandomWeighted [8,1,6])];
		};

		case "O_Boat_Armed_01_hmg_F": 
		{
			_vehicle setObjectTexture [0,"a3\boat_f_beta\boat_armed_01\data\boat_armed_01_ext_indp_co.paa"];
			_vehicle setObjectTexture [1,"a3\boat_f_beta\boat_armed_01\data\boat_armed_01_int_indp_co.paa"];
			_vehicle setObjectTexture [2,"a3\boat_f_beta\boat_armed_01\data\boat_armed_01_crows_indp_co.paa"];
		};
	};

	_mkrLoot = createMarker[format["_mkrLoot_%1",str _position],_position];
	_mkrLoot setMarkerType "Mil_dot";
	_mkrLoot setMarkercolor "Color4_FD_F";
	_mkrLoot setMarkerText "loot";

