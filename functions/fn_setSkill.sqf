params ["_grp","_rngPrcntg"];		

	_skillset = 
	[
		.1+.4*_rngPrcntg,		// aimingAccuracy 	
		.1+.5*_rngPrcntg,		// aimingShake    	
		.5+3.5*_rngPrcntg,		// aimingSpeed		
		.5+3.5*_rngPrcntg,		// spotDistance    
		.2+3.8*_rngPrcntg,		// spotTime			
		2+3*_rngPrcntg,			// courage			
		2+3*_rngPrcntg,			// reloadSpeed		
		1+7*_rngPrcntg,			// commanding			
		1+5*_rngPrcntg			// general				
	];

	{
		_unit = _x;
		{
			_skillvalue = (_skillset select _forEachIndex) + (random 0.5);
			_unit setSkill [_x,_skillvalue];
		} forEach ['aimingAccuracy','aimingShake','aimingSpeed','spotDistance','spotTime','courage','reloadSpeed','commanding','general'];
	} forEach (units _grp); 