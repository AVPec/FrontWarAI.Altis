/*
  SHK_patrol

  Based on BIN_taskPatrol by Binesi
  
  Version 0.22
  Author: Shuko (shuko@quakenet, miika@miikajarvinen.fi)
  http://forums.bistudio.com/showthread.php?163496-SHK_Patrol
	Modified for EOS by Bangabob
	
Requires SHK_POS.sqf
  Required Parameters:
    0 Object or Group     The patrolling unit
	1 Marker Name
*/
params ["_grp","_position","_PatrolDist","_waterBool",["_waterCoef",1],["_posBis",false]];
_numOfUntsInGrp = count (units _grp);

  if (_numOfUntsInGrp > 5) then 
  {
    _reGrp = createGroup west;
    _reNumOfUntsInGrp = [2,3,4,5] selectRandomWeighted [40,30,20,10];
    _unitsArray = (units _grp) select [_reNumOfUntsInGrp,(_numOfUntsInGrp-1)];
    _unitsArray join _reGrp;
    [_reGrp,_position,_PatrolDist,_waterBool,_waterCoef,_posBis] call EOS_fnc_SHK_taskPatrol;
  };

  _grp setBehaviour "AWARE";
  _grp setSpeedMode "NORMAL";
  _grp setCombatMode "YELLOW";
  _grp setFormation (selectRandom ["STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "DIAMOND"]);
  
  _wpPos=[];
  _wpNum = 3 + (floor (_PatrolDist*.03));
  if (_wpNum > 10) then {_wpNum = 6+(floor(random 5))};
  _wpRadius = 5+_PatrolDist*.1;

  for "_i" from 1 to _wpNum do 
  {
    _wpPos = if (_posBis) then
      {
        [_position,0,_PatrolDist,0,_waterCoef] call BIS_fnc_findSafePos;
      }else{
        [_position,0,[0,_PatrolDist],_waterBool,_waterCoef] call EOS_fnc_SHK_pos;
      };

      _wp = _grp addWaypoint [_wpPos, 0];
      _wp setWaypointType "MOVE";
      _wp setWaypointCompletionRadius _wpRadius;
      [_grp,_i] setWaypointTimeout [0,2,16];
  };

  _wp = _grp addWaypoint [_wpPos, 0];
  _wp setWaypointType "CYCLE";
  _wp setWaypointCompletionRadius _wpRadius;