params ["_type","_rngPrcntg"];
_tempArray=[];

	_infPool = ["B_Soldier_lite_F","B_engineer_F","B_soldier_AAT_F","B_soldier_AAA_F","B_Soldier_F","B_soldier_repair_F","B_Soldier_A_F","B_soldier_LAT2_F","B_soldier_AR_F","B_soldier_LAT_F","B_soldier_AA_F","B_soldier_AT_F","B_soldier_M_F","B_medic_F","B_Soldier_SL_F","B_soldier_exp_F","B_Soldier_GL_F","B_Soldier_TL_F","B_soldier_mine_F","B_soldier_AAR_F","B_HeavyGunner_F","B_Sharpshooter_F","B_support_AMG_F","B_support_MG_F","B_support_GMG_F","B_support_AMort_F","B_support_Mort_F"];	
	_diverPool = ["B_diver_exp_F","B_diver_F","B_diver_TL_F","B_diver_TL_F","B_diver_TL_F"];
	_crewPool = ["B_crew_F","B_Soldier_lite_F","B_engineer_F","B_Soldier_F","B_soldier_repair_F","B_soldier_AR_F","B_soldier_M_F","B_Soldier_SL_F","B_Soldier_GL_F","B_support_AMG_F","B_support_MG_F","B_support_GMG_F"];

	_lightVehPool = ["B_LSV_01_armed_F","B_LSV_01_AT_F","B_MRAP_01_gmg_F","B_MRAP_01_hmg_F"];
	_cargoVehPool = ["B_LSV_01_unarmed_F","B_MRAP_01_F","B_Truck_01_transport_F","B_Truck_01_covered_F","B_Truck_01_medical_F"];
	_armVehPool = ["B_APC_Tracked_01_rcws_F","B_APC_Tracked_01_CRV_F","B_APC_Wheeled_01_cannon_F","B_AFV_Wheeled_01_cannon_F","B_AFV_Wheeled_01_up_cannon_F","B_APC_Tracked_01_AA_F","B_MBT_01_cannon_F","B_MBT_01_TUSK_F"];
	_attckHeliPool = ["B_Heli_Light_01_dynamicLoadout_F","B_Heli_Attack_01_dynamicLoadout_F"];
	_vtolPool = ["B_T_VTOL_01_infantry_F","B_T_VTOL_01_infantry_blue_F"];
	_cargoHeliPool = ["B_Heli_Transport_03_unarmed_F","B_Heli_Transport_03_F"];
	_uavPool = ["B_UAV_01_F","B_UAV_01_CAS_F","B_UGV_01_rcws_F"];
	_sttcGunPool = ["B_HMG_01_F","B_GMG_01_F","B_HMG_01_high_F","B_GMG_01_high_F","B_HMG_01_A_F","B_GMG_01_A_F","B_static_AA_F","B_static_AT_F","B_Mortar_01_F"];
	_attckShipPool = ["B_Boat_Armed_01_minigun_F","O_Boat_Armed_01_hmg_F","I_Boat_Armed_01_minigun_F"];
	
	_minePool = ["APERSMineDispenser_Mine_F","APERSMine","APERSBoundingMine","APERSBoundingMine","APERSBoundingMine"];	
	_mineWPool = ["UnderwaterMine","UnderwaterMinePDM","UnderwaterMinePDM","UnderwaterMinePDM"];
////////////////////////////////////////////////////////////////////

	switch _type do 
	{
	// (0)
		case "Infantry":
		{
			_weight = [65,(30+30*_rngPrcntg),(20+30*_rngPrcntg),(20+30*_rngPrcntg),(60+30*_rngPrcntg),(30+20*_rngPrcntg),(20+20*_rngPrcntg),(25+65*_rngPrcntg),(20+50*_rngPrcntg),(20+75*_rngPrcntg),(10+90*_rngPrcntg),(10+90*_rngPrcntg),(18+62*_rngPrcntg),(110*_rngPrcntg),(120*_rngPrcntg),(110*_rngPrcntg),(115*_rngPrcntg),(110*_rngPrcntg),(85*_rngPrcntg),(30*_rngPrcntg),(30*_rngPrcntg),(30*_rngPrcntg),(15+55*_rngPrcntg),(15+55*_rngPrcntg),(12+53*_rngPrcntg),(11+39*_rngPrcntg),(11+39*_rngPrcntg)];
			for "_i" from 0 to 5 do
			{
				_tempArray pushBack (_infPool selectRandomWeighted _weight);
			}
		};

	// (1)
		case "Divers":
		{					
			_tempArray=_diverPool;
		};
		
	// CREATE ARMORED & CREW (2)			
		case "ArmVehAndCrew":
		{
			_weight = [90,(50+40*_rngPrcntg),(100+30*_rngPrcntg),(70+40*_rngPrcntg),(45+75*_rngPrcntg),(175*_rngPrcntg),(170*_rngPrcntg),(170*_rngPrcntg)];		
			_temparray pushBack (_armVehPool selectRandomWeighted _weight);
			_temparray pushBack ["B_crew_F"];
		};

	// CREATE ATTACK CHOPPER & CREW	(3)
		case "AttackHei":
		{
			_temparray = _attckHeliPool selectRandomWeighted [50,(100*_rngPrcntg)];
		};

	// CREATE TRANSPORT CHOPPER & CREW (4)		
		case "CargoHeli":
		{
			_temparray = _cargoHeliPool selectRandomWeighted [50,(100*_rngPrcntg)];
		};
							
	// CREATE STATIC & CREW	(5)					
		case "SttcGunAndCrew":
		{
			_weight = [20,20,(10+90*_rngPrcntg),(10+90*_rngPrcntg),(40*_rngPrcntg),(40*_rngPrcntg),(60*_rngPrcntg),(40*_rngPrcntg),(50*_rngPrcntg)];
			_temparray pushBack (_sttcGunPool selectRandomWeighted _weight);
			_temparray pushBack [(selectRandom _crewPool)];
		};

	// (6)
		case "UAV":
		{	
			_tempArray = selectRandom _uavPool;
		};

	// CREATE LIGHT TRANSPORT & CREW (7)
		case "LightVehAndCrew":
		{	
			_weight = [(50+30*_rngPrcntg),(40+30*_rngPrcntg),(10+90*_rngPrcntg),(10+90*_rngPrcntg)];
			_temparray pushBack (_lightVehPool selectRandomWeighted _weight);
			_weight = [40,65,(30+30*_rngPrcntg),(60+30*_rngPrcntg),(30+20*_rngPrcntg),(20+50*_rngPrcntg),(18+62*_rngPrcntg),(120*_rngPrcntg),(115*_rngPrcntg),(15+55*_rngPrcntg),(15+55*_rngPrcntg),(12+53*_rngPrcntg)];
			_crewArray=[];
			for "_i" from 0 to 5 do
			{
				_crewArray pushBack (_crewPool selectRandomWeighted _weight);
			};
			_temparray pushBack _crewArray;
		};

	// CREATE BOAT & DIVER CREW (8)
		case "AttackBoatAndCrew":
		{	
			_temparray pushBack (selectRandom _attckShipPool);
			_weight = [40,65,(30+30*_rngPrcntg),(60+30*_rngPrcntg),(30+20*_rngPrcntg),(20+50*_rngPrcntg),(18+62*_rngPrcntg),(120*_rngPrcntg),(115*_rngPrcntg),(15+55*_rngPrcntg),(15+55*_rngPrcntg),(12+53*_rngPrcntg)];
			_crewArray=[];
			for "_i" from 0 to 5 do
			{
				_crewArray pushBack (_crewPool selectRandomWeighted _weight);
			};
			_temparray pushBack _crewArray;
		};
					
	// CREATE CARGO (9)
		case "CargoInfantry":
		{	
			_weight = [65,(30+30*_rngPrcntg),(20+30*_rngPrcntg),(20+30*_rngPrcntg),(60+30*_rngPrcntg),(30+20*_rngPrcntg),(20+20*_rngPrcntg),(25+65*_rngPrcntg),(20+50*_rngPrcntg),(20+75*_rngPrcntg),(10+90*_rngPrcntg),(10+90*_rngPrcntg),(18+62*_rngPrcntg),(110*_rngPrcntg),(120*_rngPrcntg),(110*_rngPrcntg),(115*_rngPrcntg),(110*_rngPrcntg),(85*_rngPrcntg),(30*_rngPrcntg),(30*_rngPrcntg),(30*_rngPrcntg),(15+55*_rngPrcntg),(15+55*_rngPrcntg),(12+53*_rngPrcntg),(11+39*_rngPrcntg),(11+39*_rngPrcntg)];
			for "_i" from 0 to 10 do
			{
				_tempArray pushBack (_infPool selectRandomWeighted _weight);
			}
		};

	// CREATE MINES (11)			
		case "Mines":
		{	
			_temparray pushBack (selectRandom _minePool);
		};

	// CREATE WATER MINES (12)						
		case "WaterMines":
		{	
			_temparray pushBack (selectRandom _mineWPool);
		};

	// CREATE TRANSPORT PARADROP CHOPPER & CREW	(14)
		case "CargoVtol":
		{	
			_temparray = (_vtolPool selectRandomWeighted [50,(100*_rngPrcntg)]);
		};

	// CREATE TRANSPORT VEHICLE & CREW (15)
		case "CargoVehAndCrew":
		{	
			_weight = [20,(40*_rngPrcntg),60,(40+(40*_rngPrcntg)),(10+(20*_rngPrcntg))];		
			_temparray pushBack (_cargoVehPool selectRandomWeighted _weight);
			_temparray pushBack (selectRandom _crewPool);
		};
	};

	_tempArray