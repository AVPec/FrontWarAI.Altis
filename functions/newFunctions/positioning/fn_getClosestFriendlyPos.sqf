params [
    ["_target", objNull, [objNull, grpNull]],
    "_side"
];

_currentPos = (
    switch (typeName _target) do {
        case "OBJECT": {getPos _target};
        case "GROUP": {getPos (leader _target)}
    }
);
_currentPos params ["_xPos","_yPos"];
_posMiddleOfSquare = [floor(_xPos/1000)*1000 + 500, floor(_yPos/1000)*1000 + 500];

_friendlyPositions = (if (_side == independent) then {"GreenPos"} else {"RedPos"});
_friendlyPositions = missionNamespace getVariable _friendlyPositions;

_searchedPos = [];
_i = 1;
while {(_searchedPos isEqualTo []) && (_i < 4)} do 
{
    _arrOfCirclePositions = [_i,false,_posMiddleOfSquare,1000] call FW_fnc_getCirclePositions;
    _i = _i + 1;

    private _copy = +_arrOfCirclePositions;
    private _shuffledArr = [];

    while {count _copy > 0} do {
        _shuffledArr pushBack (_copy deleteAt (floor random (count _copy)));
    };

    _numOfArr = count _shuffledArr;
    for [{_j = 0}, {_j < _numOfArr}, {_j = _j + 1}] do {
        _slctdPos = _shuffledArr # _j;
        if (_slctdPos in _friendlyPositions) exitWith {_j = _numOfArr; _searchedPos = _slctdPos;};
    };
};

if (_searchedPos isEqualTo []) then {
    _sortedByDistFrindlyPos = [_friendlyPositions, [], {_currentPos distance2D _x}, "ASCEND"] call BIS_fnc_sortBy;
    _searchedPos = _sortedByDistFrindlyPos # (round(random 3));
};
copyToClipboard str _searchedPos;
_searchedPos