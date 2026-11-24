_createMkrRectangle = 
{
    params ["_pos","_mkrColor"];
    _pos params ["_xPos","_yPos"];

    _mkr = createMarker [(format["A_X%1Y%2R%3",_xPos,_yPos,(random 100)]),[_xPos,_yPos]];
    _mkr setMarkerShape "RECTANGLE";
    _mkr setMarkerSize [500, 500];
    _mkr setMarkerColor _mkrColor;
    _mkr setMarkerAlpha 0.5;

    _mkr
};

_redMarkerPositions = [[2500,2500],[3500,2500],[4500,2500],[5500,2500]];
_yellowMarkerPositions = [[2500,3500],[3500,3500],[4500,3500],[5500,3500]];
_greenMarkerPositions = [[2500,4500],[3500,4500],[4500,4500],[5500,4500]];

{([_x,"colorRed"] call _createMkrRectangle)} forEach _redMarkerPositions;
{([_x,"colorYellow"] call _createMkrRectangle)} forEach _yellowMarkerPositions;
{([_x,"colorGUER"] call _createMkrRectangle)} forEach _greenMarkerPositions;

[_redMarkerPositions,"colorRed"] call FW_fnc_drawLine;
[_yellowMarkerPositions,"colorYellow"] call FW_fnc_drawLine;
[_greenMarkerPositions,"colorGUER"] call FW_fnc_drawLine;

// Будуємо замкнений контур по краях жовтого прямокутника з проміжними точками для плавних кутів у FW_fnc_drawLine
private _halfSize = 500;
private _xs = _yellowMarkerPositions apply { _x # 0 };
private _ys = _yellowMarkerPositions apply { _x # 1 };
_xs sort true;

private _minX = (_xs # 0) - _halfSize;
private _maxX = (_xs # (count _xs - 1)) + _halfSize;
private _minY = (selectMin _ys) - _halfSize;
private _maxY = (selectMax _ys) + _halfSize;
private _midY = (_minY + _maxY) * 0.5;

private _blueBorderPositions = [];

// Починаємо не з кута, а з прямої ділянки нижнього краю, щоб місце змикання теж було плавним
private _startIdx = if (count _xs > 1) then { 1 } else { 0 };
for "_i" from _startIdx to (count _xs - 1) do {
    _blueBorderPositions pushBack [_xs # _i, _minY];
};

// Правий край (центр торця для плавного заокруглення кутів)
_blueBorderPositions pushBack [_maxX, _midY];

// Верхній край (справа наліво)
for "_i" from (count _xs - 1) to 0 step -1 do {
    _blueBorderPositions pushBack [_xs # _i, _maxY];
};

// Лівий край (центр торця)
_blueBorderPositions pushBack [_minX, _midY];

// Завершуємо нижній край і замикаємо контур у початковій точці
for "_i" from 0 to _startIdx do {
    _blueBorderPositions pushBack [_xs # _i, _minY];
};

_marker = [_blueBorderPositions, "ColorBlue"] call FW_fnc_drawLine;

_markerPos = getMarkerPos _marker;
_markerPosTo = [_markerPos # 0, _markerPos # 1 + 2000];
[_marker,_markerPos,_markerPosTo,10] call FW_fnc_moveLine;
