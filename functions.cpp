class FWCore
{
	class Functions 
	{
		file = "functions";
		class checkComps {};
		class createArmoredVeh {};
		class createAttackHelicopter {};
		class createAttackShip {};
		class createCargoShip {};
		class createHideBox {};
		class createHuronLanding {};
		class createHuronParadrop {};
		class createLightVeh {};
		class createMotorizedInf {};
		class createPatrolInf {};
		class createReinforcementInf {};
		class createVictoryBox {};
		class createVictoryVeh {};
		class createVtolParadrop {};
		class getUnitPools {};
		class setSkill {};
		class SHK_buildingPos {};
		class SHK_pos {};
		class SHK_taskPatrol {};
		class spawnVehicle {};

		class createMotorizedInf54 {};

	};
};

class FW
{
    tag = "FW"; // необов'язково, якщо назва класу вже FW, але гарна практика

    class Functions
    {
        file = "functions\newFunctions";
        class createGroups {};
        class createMarker {};
        class drawMapArrow {};
        class findPos {};
        class findSpawnPos {};
        class operateGroups {};
        class orderExecution {};
        class pointSideOnScreen {};
        class saveGame {};
        class spawnUnit {};
    };

    class Positioning
    {
        file = "functions\newFunctions\positioning";
        class getCirclePositions {};
		class getClosestFriendlyPos {};
    };

    class drawMapFrontLine
    {
        file = "functions\mapLine";
		class sortLinePath {};
		class drawLine {};
		class drawLineTEST {};	
		class drawClosedLine {};
		class getDotSquarePositions {};
		class moveLine {};
		class createAndDeformCurvedLine {};
		class updateFrontLines {};
    };	
};