params ["_xPos","_yPos"];

_xStr = str (floor _xPos);
_numOfxStr = count _xStr;
_endPosX = floor (parseNumber ((_xStr select [0,_numOfxStr - 3]) + "500"));

_yStr = str (floor _yPos);
_numOfyStr = count _yStr;
_endPosY = floor (parseNumber ((_yStr select [0,_numOfyStr - 3]) + "500"));

_searchedPos = [_endPosX,_endPosY];
_searchedPos



//[floor(_xPos/1000)*1000 + 500, floor(_yPos/1000)*1000 + 500]