_createMkrRectangle = 
{
params ["_pos","_mkrColor"];
_pos params ["_xPos","_yPos"];

    _mkr = createMarker [(format["A_X%1Y%2R%3",_xPos,_yPos,(random 100)]),[_xPos,_yPos]];
    _mkr setMarkerShape "RECTANGLE";
    _mkr setMarkerSize [500, 500];
    _mkr setMarkerColor _mkrColor;
    _mkr setmarkerAlpha 0.5;

    _mkr
};
_redMarkerPositions = [[19500,9500],[20500,9500],[21500,9500],[22500,9500]];
_yellowMarkerPositions = [[19500,8500],[20500,8500],[21500,8500],[22500,8500]];
_greenMarkerPositions = [[19500,7500],[20500,7500],[21500,7500],[22500,7500]];
{([_x,"colorRed"] call _createMkrRectangle)} forEach _redMarkerPositions;
{([_x,"colorYellow"] call _createMkrRectangle)} forEach _yellowMarkerPositions;
{([_x,"colorGUER"] call _createMkrRectangle)} forEach _greenMarkerPositions;


[_redMarkerPositions,"colorRed"] call FW_fnc_drawLine;
[_yellowMarkerPositions,"colorYellow"] call FW_fnc_drawLine;
[_greenMarkerPositions,"colorGUER"] call FW_fnc_drawLine;
