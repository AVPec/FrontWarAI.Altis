_debug = true;

_availablePoints = 0;
_stackPoints = 0;

[] spawn 
{
	while {true} do 
	{
		_availablePoints = floor (_availablePoints + (10 - (_availablePoints * .01)));
		sleep 180;
	};
};


if (_debug)then
{
	disableSerialization;  
	("first_stroke" call BIS_fnc_rscLayer) cutRsc ["RscDynamicText", "PLAIN"];  
	_display = uiNamespace getVariable "BIS_dynamicText";  
	_icon = _display displayCtrl 9999;  
	_text = parseText format ["<t size = '3' color='#007f00'> <img image='a3\missions_f_tank\data\img\intros\t02\t02_intro_05\t_intro_02_05_fog.paa'/></t> " + "                                                               " + "<t size = '3' color='#7f0000'><img image='a3\missions_f_tank\data\img\intros\t02\t02_intro_05\t_intro_02_05_fog.paa'/></t>"];  
	_icon ctrlSetStructuredText _text;  
	_icon ctrlSetPosition [0, -.45, 1, 1];  
	_icon ctrlCommit 0;  

	[] spawn 
	{
		("second_stroke" call BIS_fnc_rscLayer) cutRsc ["RscDynamicText", "PLAIN"];  

		_display = uiNamespace getVariable "BIS_dynamicText";  
		_textTrader = _display displayCtrl 9999;
		_friendlySidePoints = 150;  
		_enemySidePoints = 180;  
		_text = parseText format ["<t shadow = '1.8' size = '.8' font='PuristaBold'>   " + str _friendlySidePoints + "                                                                 " + str _enemySidePoints + "</t>"];  
		_textTrader ctrlSetStructuredText _text;  
		_textTrader ctrlSetPosition [0, -.4, 1, 1];  
		_textTrader ctrlCommit 0; 
	}
}