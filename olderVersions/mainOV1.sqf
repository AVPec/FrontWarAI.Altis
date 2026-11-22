enemySideFW = east;
enemyColorFW = ([enemySideFW, true] call BIS_fnc_sideColor);
friendlySideFW = resistance;
friendlyColorFW = ([friendlySideFW, true] call BIS_fnc_sideColor);

call FW_fnc_crteMainMkrs;

while {combatBehaviour groupRed != "COMBAT"} do {sleep 1};
_grpPos = getPos (leader groupRed);
_slctdMkr = ([allMapMarkers, [], {_grpPos distance2D (markerPos _x)}, "ASCEND", {((_grpPos distance2D (markerPos _x)) < 800)&&(markerShape _x == "RECTANGLE")&&(((markerSize _x) select 0) > 100)}] call BIS_fnc_sortBy) select 0;

[_slctdMkr] spawn FW_fnc_mkrDivision;