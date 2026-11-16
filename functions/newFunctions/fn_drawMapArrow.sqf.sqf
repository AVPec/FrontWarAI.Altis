/*
    File: fn_drawMapArrow.sqf
    Description:
        Малює динамічну стрілку на карті (через native UI `drawArrow` та `drawIcon`) від позиції
        гравця/юніта (або групи) до другої точки з кольором сторони групи (`BIS_fnc_sideColor`),
        підписом групи на початку та підписом статусу на кінці стрілки.
        Підтримує видалення створених стрілок/маркерів за ID, за юнітом/групою або всіх одразу.

    Parameters:
        0: _targetA - OBJECT (юніт/гравець) або GROUP (група), або STRING (ID стрілки для видалення)
        1: _targetB - ARRAY (позиція [x,y,z]), OBJECT або GROUP.
                      Якщо не передано ([] або objNull) — видаляє існуючу стрілку для _targetA!
        2: _status  - STRING (текст статусу на кінці стрілки)

    Returns:
        STRING - унікальний ID створеної стрілки (або "" при видаленні / помилці)

    Examples (Створення):
        // 1. Створити стрілку (через execVM або call)
        [player, [2200, 2800, 0], "Атака"] execVM "fn_drawMapArrow.sqf";

        // Або зі збереженням ID стрілки:
        myArrowId = [player, [2200, 2800, 0], "Атака"] call compile preprocessFileLineNumbers "fn_drawMapArrow.sqf";

    Examples (Видалення):
        // Спосіб 1: Видалити стрілку конкретного гравця або групи (просто викличте скрипт без другої точки або через функцію)
        [player] execVM "fn_drawMapArrow.sqf";
        // або:
        [player] call TAG_fnc_deleteMapArrow;

        // Спосіб 2: Видалити за збереженим ID
        [myArrowId] call TAG_fnc_deleteMapArrow;

        // Спосіб 3: Видалити абсолютно всі створені стрілки та маркери
        [] call TAG_fnc_deleteMapArrow;
*/

params [
    ["_targetA", objNull, [objNull, grpNull, ""]],
    ["_targetB", [], [[], objNull, grpNull]],
    ["_status", "", [""]]
];

if (!hasInterface) exitWith { "" };

// Ініціалізуємо глобальну функцію видалення стрілок/маркерів (якщо ще не створена)
if (isNil "TAG_fnc_deleteMapArrow") then {
    TAG_fnc_deleteMapArrow = {
        params [["_filter", nil, [objNull, grpNull, ""]]];
        private _arrows = missionNamespace getVariable ["TAG_mapArrows", []];

        if (isNil "_filter") then {
            // Якщо параметр не передано — очищуємо всі стрілки
            _arrows = [];
        } else {
            // Видаляємо за ID (STRING), або за юнітом (OBJECT), або за групою (GROUP)
            _arrows = _arrows select {
                _x params ["_id", "_tA", "_mA", "_grpA"];
                if (_filter isEqualType "") then {
                    _id != _filter
                } else {
                    if (_filter isEqualType objNull) then {
                        !(_tA isEqualTo _filter)
                    } else {
                        !(_grpA isEqualTo _filter)
                    };
                };
            };
        };

        missionNamespace setVariable ["TAG_mapArrows", _arrows];

        // Якщо стрілок більше немає — знімаємо обробник події Draw з карти
        if (_arrows isEqualTo []) then {
            private _mapCtrl = findDisplay 12 displayCtrl 51;
            private _ehId = missionNamespace getVariable ["TAG_mapArrowsEH", -1];
            if (!isNull _mapCtrl && {_ehId != -1}) then {
                _mapCtrl ctrlRemoveEventHandler ["Draw", _ehId];
            };
            missionNamespace setVariable ["TAG_mapArrowsEH", nil];
        };
    };
};

// Якщо друга точка (_targetB) не задана або _targetA є рядком ID — виконуємо видалення і виходимо
private _isTargetBEmpty = (_targetB isEqualType [] && {count _targetB < 2}) ||
                          {_targetB isEqualType objNull && {isNull _targetB}} ||
                          {_targetB isEqualType grpNull && {isNull _targetB}};

if (_targetA isEqualType "" || _isTargetBEmpty) exitWith {
    [_targetA] call TAG_fnc_deleteMapArrow;
    ""
};

// Перевірка першої точки (гравець / юніт або група)
private _modeA = 0; // 1 = OBJECT, 2 = GROUP
private _groupA = grpNull;

if (_targetA isEqualType objNull) then {
    if (!isNull _targetA) then {
        _modeA = 1;
        _groupA = group _targetA;
    };
} else {
    if (!isNull _targetA) then {
        _modeA = 2;
        _groupA = _targetA;
    };
};

if (_modeA == 0 || {isNull _groupA}) exitWith {
    diag_log "[fn_drawMapArrow] ERROR: Некоректний _targetA (має бути живий юніт або група).";
    ""
};

// Перевірка другої точки (координати, юніт або група)
private _modeB = if (_targetB isEqualType []) then {
    0
} else {
    if (_targetB isEqualType objNull) then { 1 } else { 2 }
};

// Отримуємо колір сторони групи через BIS_fnc_sideColor та назву групи
private _sideColor = [side _groupA] call BIS_fnc_sideColor;
private _groupLabel = groupId _groupA;

// Генеруємо унікальний ID стрілки
private _arrowId = format ["arrow_%1_%2", diag_tickTime, floor (random 100000)];

private _arrows = missionNamespace getVariable ["TAG_mapArrows", []];
_arrows pushBack [_arrowId, _targetA, _modeA, _groupA, _targetB, _modeB, _sideColor, _groupLabel, _status];
missionNamespace setVariable ["TAG_mapArrows", _arrows];

// Реєструємо єдиний обробник події Draw на карті (якщо ще не зареєстрований)
if (isNil {missionNamespace getVariable "TAG_mapArrowsEH"}) then {
    missionNamespace setVariable ["TAG_mapArrowsEH", -2]; // прапорець очікування ініціалізації

    [] spawn {
        waitUntil {!isNull (findDisplay 12 displayCtrl 51)};
        private _mapCtrl = findDisplay 12 displayCtrl 51;

        // Якщо під час очікування всі стрілки вже видалили — не додаємо обробник
        if ((missionNamespace getVariable ["TAG_mapArrows", []]) isEqualTo []) exitWith {
            missionNamespace setVariable ["TAG_mapArrowsEH", nil];
        };

        private _ehId = _mapCtrl ctrlAddEventHandler ["Draw", {
            params ["_ctrl"];
            private _dotIcon = "\A3\ui_f\data\map\markers\military\dot_CA.paa";

            {
                _x params ["_id", "_a", "_modeA", "_grpA", "_b", "_modeB", "_rgba", "_labelA", "_labelB"];

                // Позиція початку стрілки (гравець або лідер групи)
                private _posA = if (_modeA == 1) then {
                    if (alive _a) then { getPosWorld _a } else { [] }
                } else {
                    private _ldrA = leader _a;
                    if (!isNull _a && {alive _ldrA}) then { getPosWorld _ldrA } else { [] }
                };

                // Позиція кінця стрілки (фіксовані координати, другий гравець або група)
                private _posB = switch (_modeB) do {
                    case 0: { _b };
                    case 1: { if (alive _b) then { getPosWorld _b } else { [] } };
                    case 2: {
                        private _ldrB = leader _b;
                        if (!isNull _b && {alive _ldrB}) then { getPosWorld _ldrB } else { [] }
                    };
                    default { [] };
                };

                if (!(_posA isEqualTo []) && {!(_posB isEqualTo [])}) then {
                    // 1. Стрілка від точки A до точки B
                    _ctrl drawArrow [_posA, _posB, _rgba];

                    // 2. Маркер з підписом групи на позиції гравця (точка A)
                    _ctrl drawIcon [
                        _dotIcon,
                        _rgba,
                        _posA,
                        20, 20, 0,
                        _labelA,
                        1, 0.05, "PuristaMedium", "right"
                    ];

                    // 3. Маркер з підписом статусу на другому кінці стрілки (точка B)
                    _ctrl drawIcon [
                        _dotIcon,
                        _rgba,
                        _posB,
                        20, 20, 0,
                        _labelB,
                        1, 0.05, "PuristaMedium", "right"
                    ];
                };
            } forEach (missionNamespace getVariable ["TAG_mapArrows", []]);
        }];

        missionNamespace setVariable ["TAG_mapArrowsEH", _ehId];
    };
};

_arrowId