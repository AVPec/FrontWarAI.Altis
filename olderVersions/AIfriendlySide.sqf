//////////////////// marker on screen ////////////////////
[] spawn 
{
	disableSerialization;  
	("iconFriendly" call BIS_fnc_rscLayer) cutRsc ["RscDynamicText", "PLAIN"];  
	_display = uiNamespace getVariable "BIS_dynamicText";  
	_icon = _display displayCtrl 9999;  
	_text = parseText format ["<t size = '3' color='#007f00'> <img image='a3\missions_f_tank\data\img\intros\t02\t02_intro_05\t_intro_02_05_fog.paa'/></t> "];  
	_icon ctrlSetStructuredText _text;  
	_icon ctrlSetPosition [-.6, -.45, 1, 1];  
	_icon ctrlCommit 0;  


	("pointsFriendly" call BIS_fnc_rscLayer) cutRsc ["RscDynamicText", "PLAIN"];  
	_display = uiNamespace getVariable "BIS_dynamicText";  
	_textTrader = _display displayCtrl 9999;
	_textTrader ctrlSetPosition [-.6, -.4, 1, 1];  
	_textTrader ctrlCommit 0; 

	_accrualPoints = 10;
	missionNamespace setVariable ["AvailablePointsFriendly", 0];		
	_stackPoints = 0;

	while {true} do 
	{
		_availablePoints = missionNamespace getVariable "AvailablePointsFriendly";
		_availablePoints = _availablePoints + _accrualPoints;
		_text = parseText format ["<t shadow = '1.8' size = '.8' font='PuristaBold'>   " + str _availablePoints + "</t>"];  
		_textTrader ctrlSetStructuredText _text;
		missionNamespace setVariable ["AvailablePointsFriendly", _availablePoints];		
		sleep 20;
	};
};


sleep 5;
params ["_landArrPos"];
while {true} do 
{
	_deleteMarkers = []; //// debug ////
	_availablePoints = missionNamespace getVariable "AvailablePointsFriendly";
	_frontPositions = missionNamespace getVariable "FrontPositions";
	if (_availablePoints > _reinforcmntCndition) then 
	{
	//////////////////// chose an attak positions ////////////////////

		_frontPosWithWeight = [];
		_numlandArrPos = count _landArrPos;
		{
			_curFrontPos = _x;
			for [{_i = 0}, {_i < _numlandArrPos}, {_i = _i + 1}] do 
			{
				if ((_curFrontPos#0) == (((_landArrPos#_i)#0)#0)) then 
				{
					if ((_curFrontPos#1) == (((_landArrPos#_i)#0)#1)) then 
					{
						_frontPosWithWeight pushBack (_landArrPos#_i)#0;
						_frontPosWithWeight pushBack (_landArrPos#_i)#1;
						_i = _numlandArrPos;
					}
				}
			};
		} forEach _frontPositions;
		_selectdAttackPosition = selectRandomWeighted _frontPosWithWeight;
	//////////////////// DEBUG ////////////////////
		_deleteMarkers = [];
		if (true) then
		{
			_mkrDot = createMarker [str (random 10000),_selectdAttackPosition];
			_mkrDot setMarkerTypeLocal "mil_dot";
			_mkrDot setMarkerColor "colorGUER";
			_mkrDot setMarkerText "AttckPos";
			_deleteMarkers pushBack _mkrDot;
		};

	//////////////////// chose a spawn position ////////////////////
		_greenPositions = missionNamespace getVariable "GreenPositions";
		_numGreenPositions = count _greenPositions;
		_numLandArrPos = count _landArrPos;
		_reinforcementPosWithWeight = [];
		{
			_pos = (_selectdAttackPosition vectorAdd _x);
			for [{_i = 0}, {_i < _numGreenPositions}, {_i = _i + 1}] do 
			{
				if (_pos#0 == (_greenPositions#_i)#0) then 
				{
					if (_pos#1 == (_greenPositions#_i)#1) then 
					{
						for [{_j = 0}, {_j < _numLandArrPos}, {_j = _j + 1}] do 
						{
							if (_pos#0 == ((_landArrPos#_j)#0)#0) then 
							{
								if (_pos#1 == ((_landArrPos#_j)#0)#1) then 
								{
									_reinforcementPosWithWeight append _landArrPos#_j;
									_i = _numGreenPositions; _j = _numLandArrPos
								}
							}	
						}
					}
				}
			}
		} forEach [[0,1000],[1000,1000],[1000,0],[1000,-1000],[0,-1000],[-1000,-1000],[-1000,0],[-1000,1000],[-1000,2000],[0,2000],[1000,2000],[2000,1000],[2000,0],[2000,-1000],[-1000,-2000],[0,-2000],[1000,-2000],[-2000,1000],[-2000,0],[-2000,-1000]];
		_spawnPos =  selectRandomWeighted _reinforcementPosWithWeight;

	//////////////////// SPAWN UNITS ////////////////////
		while {_availablePoints > 29 } do 
		{
			_grpSize = (floor (random 5)) + 2;
			_availablePoints = _availablePoints - (_grpSize * 5);
			[_spawnPos,_selectdAttackPosition,Independent,_grpSize] call FWCore_fnc_createPatrolInf;
		};
		missionNamespace setVariable ["AvailablePointsFriendly", _availablePoints];
		_reinforcmntCndition = 30 + ((floor (random 13)) * 5);
	};

	//////////////////// CHECK GROUP WAYPOINTS ////////////////////
	_numFrontPos = count _frontPositions;
	{
		_group = _x;
		_curWp = currentWaypoint _group;
		_wPos = waypointPosition [_group, _curWp];

		_bool = true;
		for [{_i = 0}, {_i < _numFrontPos}, {_i = _i + 1}] do 
		{
			if ((_wPos distance2D _frontPositions#_i) < 500) then
			{_bool = false}
		};


		if (_bool) then 
		{
			_xStr = str (floor (_wPos#0));
			_numOfxStr = count _xStr;
			_xPos = floor (parseNumber ((_xStr select [0,_numOfxStr - 3]) + "500"));
			_yStr = str (floor (_wPos#1));
			_numOfyStr = count _yStr;
			_yPos = floor (parseNumber ((_yStr select [0,_numOfyStr - 3]) + "500"));

			_neighbrPos = [[_xPos,_yPos+1000],[_xPos+1000,_yPos+1000],[_xPos+1000,_yPos],[_xPos+1000,_yPos-1000],[_xPos,_yPos-1000],[_xPos-1000,_yPos-1000],[_xPos-1000,_yPos],[_xPos-1000,_yPos+1000]];
			_numNeighbrPos = count _neighbrPos;


		//////////////////// DEBUG ////////////////////
			for [{_i = 0}, {_i < _numNeighbrPos}, {_i = _i + 1}] do 
			{

				_mkrDot = createMarker [("debugQ21_" + str _i),_neighbrPos#_i];
				_mkrDot setMarkerTypeLocal "mil_dot";
				_mkrDot setMarkerColor "colorblue";
				_mkrDot setMarkerText "Q21";
			};

			_avlblFrontPos = [];
			for [{_i = 0}, {_i < _numNeighbrPos}, {_i = _i + 1}] do 
			{
				_curNeighbrPos =  _neighbrPos#_i;
				for [{_j = 0}, {_j < _numFrontPos}, {_j = _j + 1}] do 
				{
					_curFrontPos = _frontPositions#_i;
					if (_curNeighbrPos#0 == _curFrontPos#0) then 
					{
						if (_curNeighbrPos#1 == _curFrontPos#1) then 
						{
							_j = _numFrontPos;
							_avlblFrontPos pushBack _curFrontPos;
						}
					}
				}
			};
			_nextAttackPos = if (count _avlblFrontPos > 0) then 
			{
				selectRandom _avlblFrontPos
			}else{
				([_frontPositions, [], {_wPos distance _x }, "ASCEND"] call BIS_fnc_sortBy)#0
			};

			{deleteWaypoint _x} forEachReversed waypoints _group;
			for "_i" from 0 to 1 do  
			{ 
				_wp = _group addWaypoint [_nextAttackPos, 200]; 
				_wp setWaypointType "SAD"; 
			}; 
			[_group, 0] setWaypointPosition [_nextAttackPos, 200]; 
			_wp = _group addWaypoint [_nextAttackPos, 0]; 
			_wp setWaypointType "CYCLE";	
		}
	} forEach groups Independent;
	sleep 20;
	{deleteMarker _x} foreach _deleteMarkers; //debug
}