params ["_spawnPos","_attckPos","_side","_grpSize"];

_untType = if (_side == Independent) then {"I_soldier_F"} else {"O_Soldier_F"};
_grp=createGroup _side;
_spawnPos = [0,0];
for "_i" from 0 to 6 do 
{	
	_dist = random 600;
	_dir = random 360;
	_spawnPos = [(_spawnPos#0 + (_dist * sin _dir)),(_spawnPos#1 + (_dist * cos _dir)),0];};
for "_i" from 1 to _grpSize do 
{	
	_unit = _grp createUnit [_untType, _spawnPos, [], 20, "CAN_COLLIDE"];
};
for "_i" from 0 to 1 do
{ 
	_wp = _grp addWaypoint [_attckPos, 500]; 
	_wp setWaypointType "SAD";
}; 
[_grp, 0] setWaypointPosition [_attckPos, 500]; 
_wp = _grp addWaypoint [_attckPos, 0]; 
_wp setWaypointType "CYCLE";
_grp