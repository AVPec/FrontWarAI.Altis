params [
    ["_numOfCircle", 1, [0]],
    ["_includeInnerCircles", false, [false]],
    ["_centerPos", [0, 0], [[]]],
    ["_step", 1, [0]]
];

_numOfCircle = floor _numOfCircle;
if (_numOfCircle < 1) exitWith { [[_centerPos # 0, _centerPos # 1]] };

_centerPos params ["_centerX","_centerY"];
private _startCircle = if (_includeInnerCircles) then { 1 } else { _numOfCircle };
private _positions = [];

for "_r" from _startCircle to _numOfCircle do {
    for "_x" from 0 to _r do {
        _positions pushBack [_centerX + (_x * _step), _centerY + (_r * _step)];
    };
    for "_y" from (_r - 1) to -_r step -1 do {
        _positions pushBack [_centerX + (_r * _step), _centerY + (_y * _step)];
    };
    for "_x" from (_r - 1) to -_r step -1 do {
        _positions pushBack [_centerX + (_x * _step), _centerY + (-_r * _step)];
    };
    for "_y" from (-_r + 1) to _r do {
        _positions pushBack [_centerX + (-_r * _step), _centerY + (_y * _step)];
    };
    for "_x" from (-_r + 1) to -1 do {
        _positions pushBack [_centerX + (_x * _step), _centerY + (_r * _step)];
    };
};
_positions
