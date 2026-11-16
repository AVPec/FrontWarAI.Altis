				_cargoVehicle = [["I_MRAP_03_F",4,2,80],["I_G_Van_01_transport_F",13,2,30],["I_G_Van_02_vehicle_F",10,1,10],["I_G_Offroad_01_F",6,3,60]];
				_supportVehicle = [["I_MRAP_03_hmg_F",2,3,80],["I_APC_Wheeled_03_cannon_F",8,1,40]];


				_grpSize = (floor (random 8)) + 7;

				_slctArrayVeh01 = _cargoVehicle + (_supportVehicle apply {[_x#0,_x#1,_x#2,floor((_x#3)*.2)]});

				_arrOfVehForSpawn = [];
				_numOfAvlblSeats = 0;
				while {_numOfAvlblSeats < 14} do 
				{
					_slctArrayVeh02 = [];
					{_slctArrayVeh02 append [_forEachIndex, _x#3]} forEach _slctArrayVeh01;
					_slctdVehIndex = selectRandomWeighted _slctArrayVeh02;
					_slctdVeh = _slctArrayVeh01#_slctdVehIndex;
					_arrOfVehForSpawn append [_slctdVeh];
					_numOfAvlblSeats = _numOfAvlblSeats + _slctdVeh#1;
					_slctArrayVeh03 = [];
					for "_i" from 0 to ((count _slctArrayVeh01)-1) do
					{
						if (_i == _slctdVehIndex) then 
						{
							_checkIfCanAddThatVeh = _slctArrayVeh01#_i;
							if (_checkIfCanAddThatVeh#2 > 1) then 
							{
								_slctArrayVeh03 = _slctArrayVeh03 + [[_checkIfCanAddThatVeh#0,_checkIfCanAddThatVeh#1,(_checkIfCanAddThatVeh#2)-1,_checkIfCanAddThatVeh#3]];
							}
						}else{
							_slctArrayVeh03 = _slctArrayVeh03 + [_slctArrayVeh01#_i];
						}
					};
					_slctArrayVeh01 = _slctArrayVeh03;
				};[[["I_G_Van_02_vehicle_F",10,1,10],["I_G_Offroad_01_F",6,3,60]],[["I_MRAP_03_F",4,2,80],["I_G_Van_01_transport_F",13,2,30],["I_G_Offroad_01_F",6,2,60],["I_MRAP_03_hmg_F",2,3,16],["I_APC_Wheeled_03_cannon_F",8,1,8]]]
				copyToClipboard str [_arrOfVehForSpawn,_slctArrayVeh01]
				//copyToClipboard str _slctArrayVeh01;



									if (withVehicle) 


					{
						



					}

				if (count _selectedPositions > 1) then	
				{
					_selectedPositions params ["_attckPos","_spawnPos"];
					_squadGroups = [];


					7-15
				_cargoVehicle = ["I_MRAP_03_F",4,2,80],["I_G_Van_01_transport_F",13,2,30],["I_G_Van_02_vehicle_F",10,1,10],["I_G_Offroad_01_F",6,3,60];
				_supportVehicle = ["I_MRAP_03_hmg_F",2,80],["I_APC_Wheeled_03_cannon_F",8,40];

[] spawn
{
				_cargoVehicle = [["I_MRAP_03_F",4,2,80],["I_G_Van_01_transport_F",13,2,30],["I_G_Van_02_vehicle_F",10,1,10],["I_G_Offroad_01_F",6,3,60]];
				_supportVehicle = [["I_MRAP_03_hmg_F",2,3,80],["I_APC_Wheeled_03_cannon_F",8,1,40]];


				_grpSize = (floor (random 8)) + 7;

				_slctArrayVeh01 = _cargoVehicle + (_supportVehicle apply {[_x#0,_x#1,_x#2,floor((_x#3)*.2)]});

				_arrOfVehForSpawn = [];
				_numOfAvlblSeats = 0;
				while {_numOfAvlblSeats < 14} do 
				{
					_slctArrayVeh02 = [];
					{_slctArrayVeh02 append [_forEachIndex, _x#3]} forEach _slctArrayVeh01;
										sleep 5;

					_slctdVehIndex = selectRandomWeighted _slctArrayVeh02;
					_slctdVeh = _slctArrayVeh01#_slctdVehIndex;
					_arrOfVehForSpawn append _slctdVeh;
					_numOfAvlblSeats = _numOfAvlblSeats + _slctdVeh#1;
										copyToClipboard str _numOfAvlblSeats;

					_slctArrayVeh03 = [];
					for "_i" from 0 to count _slctArrayVeh01 do
					{
						if (_i == _slctdVehIndex) then 
						{
							_checkIfCanAddThatVeh = _slctArrayVeh01#_i;
							if (_checkIfCanAddThatVeh#2 > 1) then 
							{
								_slctArrayVeh03 append [_checkIfCanAddThatVeh#0,_checkIfCanAddThatVeh#1,(_checkIfCanAddThatVeh#2)-1,_checkIfCanAddThatVeh#3];
							}
						}else{
							_slctArrayVeh03 = _slctArrayVeh03 + _slctArrayVeh01#_i
						}
					};
					_slctArrayVeh01 = _slctArrayVeh03;
				};
				//copyToClipboard str [_arrOfVehForSpawn,_slctArrayVeh01]
}
				_numSlctArrayVeh01 = count _slctArrayVeh01;
				for [{_i = 0}, {_i < _numSlctArrayVeh01}, {_i = _i + 1}] do 
				{
					(_slctArrayVeh01#_i)params["_vehType","_numOfUnits","_maxNumOfSlctdVeh","_slctPrcntg"];
					if (_maxNumOfSlctdVeh > 0) then
					{
						_slctArrayVeh02 pushBack [_vehType,_numOfUnits,_maxNumOfSlctdVeh]
					}
				}



				_numOfUnitsAndGroups = [];
				for "_i" from 1 to 5 do 
				{
					if (_availablePoints > 24) then {_numOfUnitsAndGroups pushBack ((floor (random 4)) + 2)}
				};
				_unitCount = 0
				{_unitCount = _unitCount + _x} forEach _numOfUnitsAndGroups;
				_availableSeats = 0; _availableCargoVehicle = [];
				while {_unitCount > _availableSeats} then {_slctdVehicle = select}





					//if (withVehicleAndDelivery)
					//if (justDelivery)
