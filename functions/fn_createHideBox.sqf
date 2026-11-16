	_position = _this select 0;_charge2 = "";
	_m = createMarker [format ["mkrIED%1",random 100000],_position];
    _m setMarkerShape "ICON";
    _m setMarkerColor "ColorRed";
    _m setMarkerType "mil_dot";

	_NofItems = [1,2,3,4,5] selectRandomWeighted [20,100,60,40,20];

	if (_NofItems < 3) then 
	{
		_charge1 = createMine ["DemoCharge_F", _position, [], 0];
		_charge1 setDir (random 360);		
		_create = createSimpleObject ["Box_Syndicate_Wps_F", _position];
		_create attachTo [_charge1, [0,0,0.07]];  
		_charge2 = createVehicle ["DemoCharge_F", _position, [], 0];
		_charge2 attachTo [_create, [0.022,0.204,0.012]];  
		_charge2 setVectorDirAndUp [[0,-2.8213e-007,-1],[0,1,-2.8213e-007]];
		_charge2 attachTo [_create, [0.022,0.204,0.012]]; 
	};

	if (_NofItems == 3) then 
	{
		_charge1 = createMine ["DemoCharge_F", _position, [], 0];
		_charge1 setDir (random 360);		
		_create = createSimpleObject ["Box_Syndicate_WpsLaunch_F", _position];
		_create attachTo [_charge1, [0,0,0.18]];  
		_charge2 = createVehicle ["DemoCharge_F", _position, [], 0];
		_charge2 attachTo [_create, [0.037,-0.161,0.066]];  
		_charge2 setVectorDirAndUp [[0,1.19249e-008,1],[0,-1,1.19249e-008]];
		_charge2 attachTo [_create, [0.037,-0.161,0.066]];  
	};

	if (_NofItems > 3) then 
	{
		_charge1 = createMine ["SatchelCharge_F", _position, [], 0];
		_charge1 setDir (random 360);		
		_create = createSimpleObject ["Box_Syndicate_Ammo_F", _position];
		_create attachTo [_charge1, [0,0,0.21]];  
		_charge2 = createVehicle ["SatchelCharge_F", _position, [], 0];
		_charge2 attachTo [_create, [0.006,0.212,0.045]];  
		_charge2 setVectorDirAndUp [[1,1.91069e-015,4.37114e-008],[0,1,-4.37114e-008]];
		_charge2 attachTo [_create, [0.006,0.212,0.045]]; 	 
	};
	
	_null = [_charge2,"easy"] execVM "IED\init_ied.sqf";