openMap true;

_calcPos = 
{
params ["_array","_i"];
_array params ["_posFrom","_posTo"];
	_posFrom vectorAdd ((_posTo vectorDiff _posFrom) vectorMultiply _i)
};

_offset = 
{
params ["_arrFrom","_arrTo"];
	_arrPosOffset = [];
	for [{_i = 0}, {_i < (count _arrFrom)}, {_i = _i + 1}] do 
	{
		_posFrom = _arrFrom#_i;
		if ((_arrTo findIf {_posFrom isEqualTo _x}) == -1) then 
		{
			_posLeft = [];
			for [{_k = _i - 1}, {_k > -1}, {_k = _k - 1}] do 
			{
				_posLeft = _arrFrom#_k;
				if ((_arrTo findIf {_posLeft isEqualTo _x}) != -1) exitWith {};
			};
			_posRight = [];
			for [{_k = _i + 1}, {_k < count _arrFrom}, {_k = _k + 1}] do 
			{
				_posRight = _arrFrom#_k;
				if ((_arrTo findIf {_posRight isEqualTo _x}) != -1) exitWith {};
			};
			_posTo = (_posLeft vectorAdd _posRight) vectorMultiply .5;
 			_arrPosOffset pushBack [_posFrom,_posTo];
		}else{
			_arrPosOffset pushBack _posFrom;
		}
	};
	_arrPosOffset
};


_outside = 
{
params ["_arrFrom","_arrTo"];
	_arrPosOutside = [];
	for [{_i = 0}, {_i < (count _arrTo)}, {_i = _i + 1}] do 
	{
		_posTo = _arrTo#_i;
		if ((_arrFrom findIf {_posTo isEqualTo _x}) == -1) then 
		{
			_posLeft = [];
			for [{_k = _i - 1}, {_k > -1}, {_k = _k - 1}] do 
			{
				_posLeft = _arrTo#_k;
				if ((_arrFrom findIf {_posLeft isEqualTo _x}) != -1) exitWith {};
			};
			_posRight = [];
			for [{_k = _i + 1}, {_k < count _arrTo}, {_k = _k + 1}] do 
			{
				_posRight = _arrTo#_k;
				if ((_arrFrom findIf {_posRight isEqualTo _x}) != -1) exitWith {};
			};
			_posFrom = (_posLeft vectorAdd _posRight) vectorMultiply .5;
 			_arrPosOutside pushBack [_posFrom,_posTo];
		}else{
			_arrPosOutside pushBack _posTo;
		}
	};
	_arrPosOutside
};



_arrFrom= [[21250,7750,0],[21250,7250,0],[21250,6750,0],[20750,6750,0],[20250,6750,0],[19750,6750,0],[19750,7250,0],[19750,7750,0],[19750,8250,0],[20250,8250,0],[20750,8250,0],[21250,8250,0],[21250,7750,0]];
_arrTo = [[21250,7750,0],[21250,7250,0],[21250,6750,0],[20750,6750,0],[20250,6750,0],[19750,6750,0],[19250,6750,0],[18750,6750,0],[18750,7250,0],[18750,7750,0],[18750,8250,0],[19250,8250,0],[19750,8250,0],[19750,8750,0],[19750,9250,0],[20250,9250,0],[20750,9250,0],[21250,9250,0],[21250,8750,0],[21250,8250,0],[21250,7750,0]];

//_arrTo = [[19250,8250,0],[19750,8250,0],[20250,8250,0],[20250,8750,0],[20750,8750,0],[20750,8250,0],[21250,8250,0],[21750,8250,0]];
//_arrFrom = [[19250,8250,0],[19750,8250,0],[20250,8250,0],[20750,8250,0],[21250,8250,0],[21750,8250,0]];


_arrOutside = [_arrFrom,_arrTo] call _outside;
_arroffset = [_arrFrom,_arrTo] call _offset;
copyToClipboard format ["%1,%2",_arrOutside,_arroffset];
[
	[21250,7750,0],[21250,7250,0],[21250,6750,0],[20750,6750,0],[20250,6750,0],[19750,6750,0],[[19750,7500,0],[19250,6750,0]],[[19750,7500,0],[18750,6750,0]],[[19750,7500,0],[18750,7250,0]],[[19750,7500,0],[18750,7750,0]],[[19750,7500,0],[18750,8250,0]],[[19750,7500,0],[19250,8250,0]],[19750,8250,0],[[20500,8250,0],[19750,8750,0]],[[20500,8250,0],[19750,9250,0]],[[20500,8250,0],[20250,9250,0]],[[20500,8250,0],[20750,9250,0]],[[20500,8250,0],[21250,9250,0]],[[20500,8250,0],[21250,8750,0]],[21250,8250,0],[21250,7750,0]
],[
	[21250,7750,0],[21250,7250,0],[21250,6750,0],[20750,6750,0],[20250,6750,0],[19750,6750,0],[[19750,7250,0],[19750,7500,0]],[[19750,7750,0],[19750,7500,0]],[19750,8250,0],[[20250,8250,0],[20500,8250,0]],[[20750,8250,0],[20500,8250,0]],[21250,8250,0],[21250,7750,0]
]




{
	_arrPosForMove = _x;
	systemChat str (_arrPosForMove findIf {count _x < 3});
	//if ((_arrPosForMove findIf {count _x < 3}) != -1) then {continue};
	for [{_i = 0.01}, {_i < 1}, {_i = _i + 0.01}] do 
	{
		_arrNewPath = [];
		for [{_j = 0}, {_j < (count _arrPosForMove)}, {_j = _j + 1}] do 
		{
			_slctdArr = _arrPosForMove#_j;
			if ((count _slctdArr) < 3) then 		
			{
				_arrNewPath pushBack ([_slctdArr,_i] call _calcPos);
			}else{
				_arrNewPath pushBack _slctdArr;
			}
		};
		[_arrNewPath, "colorRED"] call FW_fnc_drawLineTEST;
		sleep 0.1;
	};
} forEach [_arrOffset/*,_arrOutside*/];


/*
	openMap true;
	for [{_i = 0}, {_i < 10}, {_i = _i + 0.01}] do 
	{
		[[[20000,8000,0],[20300,(8000+_i*100),0],[20900,(8000+_i*100),0],[21000,8000,0]], "colorRED"] execVM "test.sqf";
		sleep 0.01;
	};


/*
	openMap true;

	_interpolatedPoints = [[[20000,8000,0],[20300,8500,0],[20900,8500,0],[21000,8000,0]], "colorRED"] call FW_fnc_drawLineTEST;

	_index1 = _interpolatedPoints findIf {_x isEqualTo [20300,8500,0]};
	_index2 = _interpolatedPoints findIf {_x isEqualTo [20900,8500,0]};
	_midleIndex = (_index1 + _index2)/2;
	_newPos = _interpolatedPoints select _midleIndex;

	sleep 5;

	_interpolatedPoints = [[[20000,8000,0],_newPos,[21000,8000,0]], "colorRED"] call FW_fnc_drawLineTEST;





/*	
	_searchPos = [20300,8000,0]; _index = -1;
	for [{_i = 0},{_i < ((count _polyline) - 1)},{_i = _i + 1}] do 
	{
		if ((_polyline#_i == _searchPos#0) && (_polyline#(_i+1) == _searchPos#1)) exitWith {_index = _i};
	};
	systemChat str _index;

/*
allMapMarkers apply {[(markerpos _x)#0,(markerpos _x)#1,0]}
[[[19614.6,7686.75,0],[20031.5,8087.28,0],[20533.3,7665.79,0],[20509.2,7091.77,0]], "colorRED"] execVM "test.sqf"


[] spawn 
{
	openMap true;
	for [{_i = 0}, {_i < 10}, {_i = _i + 0.01}] do 
	{
		[[[20000,8000,0],[20300,(8000+_i*100),0],[20900,(8000+_i*100),0],[21000,8000,0]], "colorRED"] execVM "test.sqf";
		sleep 0.01;
	};
};


*/
configFile >> "CfgLocationTypes"
getArray (configfile >> "CfgWorlds" >> "Altis" >> "Names");

angle = 0; // can be changed
demography = 'CIV'; // can be not present
name = 'Ifistiona'; // can be changed
position[] = {12787.19679.3} // can be changed 
radiusA = 500; // can be changed
radiusB = 176.64; // can be changed
type = 'NameVillage'; // can be changed



_createMkrPoint = 
{
params ["_pos","_mkrColor","_text"];
_pos params ["_xPos","_yPos"];

	_mkr = createMarker [_text + (str (random 100)),[_xPos,_yPos]];
	_mkr setMarkerTypeLocal "mil_dot";
	_mkr setMarkerColor _mkrColor;
	_mkr setMarkerText _text;

	_mkr
};


_position = getArray (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> _x >> "position"); 





{
	_angle = getNumber (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> _x >> "angle");
	_demography = getText (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> _x >> "demography");
	_name = getText (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> _x >> "name");
	_position = getArray (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> _x >> "position");
	_radiusA = getNumber (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> _x >> "radiusA");
	_radiusB = getNumber (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> _x >> "radiusB");
	_type = getText (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> _x >> "type");

	_mkr = createMarker [_name + (str (random 100)),_position];
	_mkr setMarkerShape "ELLIPSE";
	_mkr setMarkerSize [_radiusA, _radiusB];
	_mkr setMarkerDir _angle;
	_mkr setMarkerColor "colorGUER";
	_mkr setmarkerAlpha 0.5;

	_mkrText = createMarker [_name + (str (random 100)),_position];
	_mkrText setMarkerTypeLocal "mil_dot";
	_mkrText setMarkerText str [_angle,_demography,_name,_type];	
} forEach (configfile >> "CfgWorlds" >> "Altis" >> "Names");



{
	systemChat str "1";
} forEach [(configfile >> "CfgWorlds" >> "Altis" >> "Names")];

 if not(false) {systemChat str "1"}


("true" configclasses (configfile >> "CfgWorlds" >> "Altis" >> "Names")) apply 
{
		_angle = getNumber (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> configname  _x >> "angle");
	_demography = getText (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> configname  _x >> "demography");
	_name = getText (configfile >> "CfgWorlds" >> "Altis" >> "Names" >>configname  _x >> "name");
	_position = getArray (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> configname _x >> "position");
	_radiusA = getNumber (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> configname _x >> "radiusA");
	_radiusB = getNumber (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> configname _x >> "radiusB");
	_type = getText (configfile >> "CfgWorlds" >> "Altis" >> "Names" >>configname  _x >> "type");


	if ((_type == "NameLocal") && (_name == "military")) then 
	{
		_mkr = createMarker [_name + (str (random 100)),_position];
		_mkr setMarkerShape "ELLIPSE";
		_mkr setMarkerSize [_radiusA, _radiusB];
		_mkr setMarkerDir _angle;
		_mkr setMarkerColor "colorGUER";
		_mkr setmarkerAlpha 0.5;

		_mkrText = createMarker [_name + (str (random 100)),_position];
		_mkrText setMarkerTypeLocal "mil_dot";
		_mkrText setMarkerText str [_angle,_demography,_name,_type];
	};
};


["CityCenter","NameVillage","NameCity","NameCityCapital","NameLocal","Hill","NameMarine"]

_notCapturedVillages = [];
("true" configclasses (configfile >> "CfgWorlds" >> "Altis" >> "Names")) apply 
{
	_position = getArray (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> configname _x >> "position");
	_radiusA = getNumber (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> configname _x >> "radiusA");
	_radiusB = getNumber (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> configname _x >> "radiusB");

	_notCapturedVillages pushBack [_position,[_radiusA,_radiusB]];
	_mkr = createMarker [_radiusA + (str (random 100)),_position];
	_mkr setMarkerShape "ELLIPSE";
	_mkr setMarkerSize [_radiusA, _radiusB];
	_mkr setMarkerColor "colorGUER";
	_mkr setmarkerAlpha 0.5;	
};


("true" configclasses (configfile >> "CfgWorlds" >> "Altis" >> "Names")) apply 
{
		_angle = getNumber (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> configname  _x >> "angle");
	_demography = getText (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> configname  _x >> "demography");
	_name = getText (configfile >> "CfgWorlds" >> "Altis" >> "Names" >>configname  _x >> "name");
	_position = getArray (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> configname _x >> "position");
	_radiusA = getNumber (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> configname _x >> "radiusA");
	_radiusB = getNumber (configfile >> "CfgWorlds" >> "Altis" >> "Names" >> configname _x >> "radiusB");
	_type = getText (configfile >> "CfgWorlds" >> "Altis" >> "Names" >>configname  _x >> "type");


	if !((_type == "NameVillage")||(_type == "NameCity")||(_type == "NameCityCapital")||(_name == "military")) then 
	{
		_mkr = createMarker [_name + (str (random 100)),_position];
		_mkr setMarkerShape "ELLIPSE";
		_mkr setMarkerSize [_radiusA, _radiusB];
		_mkr setMarkerDir _angle;
		_mkr setMarkerColor "colorGUER";
		_mkr setmarkerAlpha 0.5;

		_mkrText = createMarker [_name + (str (random 100)),_position];
		_mkrText setMarkerTypeLocal "mil_dot";
		_mkrText setMarkerText str [_angle,_demography,_name,_type];
	};
};

_BuildToSq = ((count (nearestObjects [_mPos,["building"],_mkrSize]))/(3.14*_mkrSize^2)*1000000)/_mkrX;	


_frontPositions
_capturedPositions



crteate places 
selecet available places
spawn groups

select random






