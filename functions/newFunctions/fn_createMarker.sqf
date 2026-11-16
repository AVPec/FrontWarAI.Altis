params [
    ["_target", [], [[], objNull, grpNull]],
	["_markerLabel", "", [""]],
    ["_isTracking", false, [false]],
    ["_markerType", "hd_dot", [""]]
];

// Helper to resolve current position from position array, object, or group
private _fn_getTargetPos = {
    params ["_tgt"];
    switch (typeName _tgt) do {
        case "ARRAY": {_tgt};
        case "OBJECT": {getPos _tgt};
        case "GROUP": {getPos (leader _tgt)}
    };
};
private _initialPos = [_target] call _fn_getTargetPos;

// Generate a unique marker identifier
private _markerName = format ["mkr_%1",random 100000];

// Create the marker and apply properties (use Local commands first to minimize network traffic, then broadcast on final command)
private _mkr = createMarker [_markerName, _initialPos];
_mkr setMarkerShapeLocal "ICON";
_mkr setMarkerTypeLocal _markerType;
_mkr setMarkerText _markerLabel;

// Start tracking loop if enabled and target is a dynamic entity (OBJECT or GROUP)
if (_isTracking) then {

    if (typeName _tgt == "OBJECT") then {
        _mkr setMarkerColor ([side _tgt, true] call BIS_fnc_sideColor);
        while {alive _tgt} do {
            _mkr setMarkerPos (getPos _tgt);
            sleep 0.5;
        }
    } else {
        _mkr setMarkerColor ([side _tgt, true] call BIS_fnc_sideColor);
        while {count (units _tgt) > 0} do {
            _mkr setMarkerPos (getPos (leader _tgt));
            sleep 0.5;
        }
    };
    deleteMarker _mkr; // Clean up marker when target is no longer valid
};
