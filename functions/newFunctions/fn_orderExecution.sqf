params ["_group","_order","_orderPos","_side"];
{ deleteWaypoint _x } forEachReversed waypoints _group;

//systemChat str _orderPos;
//systemChat str (missionNamespace getVariable _friendlyPos);

switch (_order) do {
	case "attack": {
		for "_j" from 1 to 2 do	{ 
			_wp = _group addWaypoint [_orderPos, 500]; 
			_wp setWaypointType "SAD";
		}; 
		[_group, 0] setWaypointPosition [_orderPos, 500]; 
		_wp = _group addWaypoint [_orderPos, 0]; 
		_wp setWaypointType "CYCLE";
	};
	case "retreat": {
		_retreatPos = [_group, _side] call FW_fnc_getClosestFriendlyPos;
		_wp = _group addWaypoint [_retreatPos, 500]; 
		_wp setWaypointType "MOVE";
	};
	case "defend": {};
	case "regroup": {};
	case "findEmptyVehicle": {};
}; 
