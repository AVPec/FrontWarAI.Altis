

_createCtrlNumOfAp = {
	params ["_ctrl01Pos","_ctrl02Pos","_side","_clrHTML","_strPoints"];
	disableSerialization;  
	(("icon" + str _side) call BIS_fnc_rscLayer) cutRsc ["RscDynamicText", "PLAIN"];  
	_display = uiNamespace getVariable "BIS_dynamicText";  
	_icon = _display displayCtrl 9999;  
	_text = parseText format ["<t size = '3' color='%1'><img image='a3\missions_f_tank\data\img\intros\t02\t02_intro_05\t_intro_02_05_fog.paa'/></t>",_clrHTML];  
	_icon ctrlSetStructuredText _text;  
	_icon ctrlSetPosition _ctrl01Pos;  
	_icon ctrlCommit 0;  


	(("points" + str _side) call BIS_fnc_rscLayer) cutRsc ["RscDynamicText", "PLAIN"];  
	_display = uiNamespace getVariable "BIS_dynamicText";  
	_displayCtrl = _display displayCtrl 9999;
	_displayCtrl ctrlSetPosition _ctrl02Pos;
	_displayCtrl ctrlCommit 0;

	_displayCtrl
};

_updateCtrl = {
	_this params ["_eastCtrl","_guerCtrl"];
		{
			_availablePoints = missionNamespace getVariable _x#1;
			_text = parseText format ["<t shadow = '1.8' size = '.8' font='PuristaBold'>   " + str _availablePoints + "</t>"];  
			_x#0 ctrlSetStructuredText _text;
		} forEach [[_eastCtrl,"APeast"],[_guerCtrl,"APguerilla"]]
};

_eastCtrl = [[.6, -.45, 1, 1],[.6, -.4, 1, 1],"EAST","#7f0000","APeast"] call _createCtrlNumOfAp;
_guerCtrl = [[-.6, -.45, 1, 1],[-.6, -.4, 1, 1],"GUER","#007f00","APguerilla"] call _createCtrlNumOfAp;

while {true} do {
	[_eastCtrl,_guerCtrl] call _updateCtrl;
	sleep 20;
};