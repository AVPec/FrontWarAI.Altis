params ["_side"];

_data = if (_side == east) then 
{
	["APeast","ColorEAST","RedPos",["O_Soldier_F","O_Soldier_F","O_Soldier_F"]]
}else{
	["APguerilla","ColorGUER","GreenPos",["I_soldier_F","I_soldier_F","I_soldier_F"]]
};
_data params ["_pointsSide","_colorSide","_variableFriendlyPos","_untType"];

_calculateCommandPoints = {
	_commandPoints = 0;
	{
		if (side _x == _side) then {
			_commandPoints = _commandPoints + 5;
		}
	} forEach allunits;
	_commandPoints
};

sleep 5;

_assaultGroups = [];
while {true} do 
{
	if ((call _calculateCommandPoints) < 250) then {
		_availablePoints = missionNamespace getVariable _pointsSide;
		//systemChat str _availablePoints;
		_frontPositions = missionNamespace getVariable "frontPos";
		_percentageForSelection = switch true do {
			case (_availablePoints<251): {[50,40,10,0]};
			case ((_availablePoints>250) && (_availablePoints<750)): {[10,20,50,20]};
			case (_availablePoints>749): {[0,20,30,50]};
		};
		//systemChat str _percentageForSelection;

		_strengthOfReinforcements = ["none","minor","normal","high"] selectRandomWeighted _percentageForSelection;

		_spawnSquarePos = "";
		_attackSquarePos = ["findFrontLineSquarePos"] call FW_fnc_findPos;
		_conditionForAssault = if (typeName _attackSquarePos == "ARRAY") then {
			_spawnSquarePos = ["findSafeSquarePos",_attackSquarePos,_side] call FW_fnc_findPos;
			if (typeName _spawnSquarePos == "ARRAY") then {true} else {false};
		} else {false};
		_operatedGroups = [_strengthOfReinforcements,_spawnSquarePos,_side] call FW_fnc_createGroups;
		if (count _operatedGroups > 0) then {
			[_operatedGroups, _attackSquarePos] spawn FW_fnc_operateGroups;
			_assaultGroups pushBack _operatedGroups;
		};
	};
	sleep 20;
}


