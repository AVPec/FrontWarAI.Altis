params ["_frontPositions","_greenPositions"];

_pointsEast = ((east countSide allunits) * 5) + (missionNamespace getVariable "APeast");
_pointsGuerilla = ((independent countSide allunits) * 5) + (missionNamespace getVariable "APguerilla");

profilenamespace setvariable ["Save001",[_frontPositions,_greenPositions,_pointsEast,_pointsGuerilla]];
saveProfileNamespace;

