params ["_slctdSquarePos"];

_spawnPosGroup = [];
for "_i" from 1 to 6 do 
{	
	_dist = random 600;
	_dir = random 360;
	_spawnPosGroup = [(_slctdSquarePos#0 + (_dist * sin _dir)),(_slctdSquarePos#1 + (_dist * cos _dir)),0];
	if !(surfaceIsWater _spawnPosGroup) exitWith {};
};
_spawnPosGroup