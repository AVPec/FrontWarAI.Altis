	
["FlatArea","FlatAreaCity","FlatAreaCitySmall","CityCenter","Airport","NameMarine","NameCityCapital","NameCity","NameVillage","NameLocal","Hill","ViewPoint","RockArea","BorderCrossing","VegetationBroadleaf","VegetationFir","VegetationPalm","VegetationVineyard","fakeTown","Area","Flag","b_unknown","o_unknown","n_unknown","b_inf","o_inf","n_inf","b_motor_inf","o_motor_inf","n_motor_inf","b_mech_inf","o_mech_inf","n_mech_inf","b_armor","o_armor","n_armor","b_recon","o_recon","n_recon","b_air","o_air","n_air","b_plane","o_plane","n_plane","b_uav","o_uav","n_uav","b_naval","o_naval","n_naval","b_med","o_med","n_med","b_art","o_art","n_art","b_mortar","o_mortar","n_mortar","b_hq","o_hq","n_hq","b_support","o_support","n_support","b_maint","o_maint","n_maint","b_service","o_service","n_service","b_installation","o_installation","n_installation","u_installation","b_antiair","o_antiair","n_antiair","c_unknown","c_car","c_ship","c_air","c_plane","group_0","group_1","group_2","group_3","group_4","group_5","group_6","group_7","group_8","group_9","group_10","group_11","respawn_unknown","respawn_inf","respawn_motor","respawn_armor","respawn_air","respawn_plane","respawn_naval","respawn_para","Invisible","HistoricalSite","CivilDefense","CulturalProperty","DangerousForces","SafetyZone","HandDrawnCamp"]



private _allLocationTypes = [];
"_allLocationTypes pushBack configName _x" configClasses (configFile >> "CfgLocationTypes");
{
	systemChat format [
		"%1 (%2) - %3m",
		_x,
		text _x,
		position player distance _x
	];
} forEach nearestLocations [player, ["NameCity"], 3000];

(position player) distance2D ((nearestLocations [player, ["NameCity"], 6000]) select 0)


// name of location that can be used
["Mount","NameMarine","NameCityCapital","NameCity","NameVillage","NameLocal","Hill"]

[] spawn
{
	_markerTypes = ["flag_Altis","flag_AltisColonial","flag_AAF","flag_Astra","flag_Belgium","flag_Canada","flag_Croatia","flag_CSAT","flag_CTRG","flag_CzechRepublic","flag_Denmark","flag_EU","flag_FIA","flag_France","flag_TanoaGendarmerie","flag_Georgia","flag_Germany","flag_Greece","flag_Hungary","flag_Iceland","flag_IDAP","flag_Italy","flag_Enoch","flag_EAF","flag_EnochLooters","flag_Luxembourg","flag_NATO","flag_Netherlands","flag_Norway","flag_Portugal","RedCrystal","flag_Russia","flag_Slovakia","flag_Slovenia","flag_Spain","flag_Spetsnaz","flag_Syndicat","flag_Tanoa","flag_UK","flag_UN","flag_USA","flag_Viper","White"];

	_array = ["Mount","NameMarine","NameCityCapital","NameCity","NameVillage","NameLocal","Hill"];
	for [{_i = 0}, {_i < count _array}, {_i = _i + 1}] do 
	{
		_selectedFilter = _array select _i;
		systemChat _selectedFilter;
		_markerType = selectRandom _markerTypes;
		_markerTypes deleteAt (_array find _markerType);		
		{
			_position = locationPosition  _x;
			_position params ["_xPos","_yPos"];
			_mkr = createMarker ["marker_" + (str (random 100)),[_xPos,_yPos]];
			_mkr setMarkerTypeLocal _markerType;
			_mkr setMarkerAlpha .5;
		} forEach nearestLocations [player, [_selectedFilter], 30000];
		sleep 3;
	}
}

		{
			_position = locationPosition  _x;
			_position params ["_xPos","_yPos"];
			_mkr = createMarker ["marker_" + (str (random 100)),[_xPos,_yPos]];
			_mkr setMarkerTypeLocal "flag_CSAT";
			_mkr setMarkerAlpha .5;
		} forEach nearestLocations [player, ["NameCityCapital"], 30000];

			_mkr = createMarker ["marker_" + (str (random 100)),[_xPos - 300 + (random 600),_yPos - 300 + (random 600)]];
