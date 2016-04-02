private ["_playArray","_lastRest","_blood","_timesincedrink","_bloodinc","_Moves","_sleepArray","_animState","_started","_finished","_timer","_i","_r","_cureAttempt","_isAsleep","_cureChance","_infectedStatus","_randomamount"];
//_timesincedrink = time - dayz_lastDrink;
//_bloodinc =100; Removed for now(untested) due to it not needed yet
//http://community.bistudio.com/wiki/ArmA2:_Moves

_sleepArray = ["aidlppnemstpsnonwnondnon_sleepc_laydown","aidlppnemstpsnonwnondnon_sleepc_lookaround","aidlppnemstpsnonwnondnon_sleepc_scratch","aidlppnemstpsnonwnondnon_sleepc_sleep","aidlppnemstpsnonwnondnon_sleepc_sleep0"];

//not in a vehicle
//_playArray = _sleepArray call BIS_fnc_selectRandom;
player playmove "AidlPpneMstpSnonWnonDnon_SleepC_sleep";

if (r_action) exitwith {};

r_action = true;
	
r_interrupt = false;
_animState = animationState player;
r_doLoop = true;
_started = false;
_finished = false;
_timer = diag_tickTime;
_i = 0;
_r = 0;
_blood = 0;
_cureAttempt = 0;
_lastRest = player getVariable ["lastRest", 0];

while {r_doLoop} do {
	_isAsleep = (animationState player) in _sleepArray;
	if (_isAsleep && !_started) then {_started = true;};

	if (_started) then {
		if (!r_player_unconscious) then {
			if (r_player_infected) then {
				//every 30 seconds run Random Chance to cure infection
				if (diag_ticktime - _lastRest > 30) then {
					//Save the amount so if the player interrupts
					player setVariable ["lastRest", diag_ticktime];
					//Update the local value.
					_lastRest = diag_ticktime;
					
					//10% chance of cure to infection every 60 seconds of sleeping
					_cureChance = 0.10 + _cureAttempt;
					if ([_cureChance] call fn_chance) then {
						r_player_infected = false;
						player setVariable["USEC_infected",false,false];
						
						PVDZ_serverStoreVar = [player,"USEC_infected",false];
						publicVariableServer "PVDZ_serverStoreVar";
					} else {
						_infectedStatus = if (r_player_infected) then { "Infected" } else { "Cured" };
						_cureAttempt = _cureAttempt + 0.01;
						cutText [format [localize "str_sleepInfection",r_player_blood,_infectedStatus], "PLAIN DOWN"];
					};
				};
			};
			
			//make sure player isnt infected or inpain.
			if (!r_player_injured && !r_player_infected && !(r_player_Sepsis select 0)) then {
				//Give 53 + random amount of blood every 16 secs if player isn't injured.
				if ((diag_tickTime - _timer) >= 16) then {
					if (r_player_blood < 12000) then {
						//Make the random amount of blood you can gain equal to the percentage of blood you have.
						_randomamount = round(random (r_player_blood/12000*100));
						_blood = 53 + _randomamount; //Max Possible 153.
					};
					
					//Make sure we don't go over the max amount
					if ((r_player_blood - 12000) < _blood) then {
						r_player_bloodregen = r_player_bloodregen + _blood;
					} else {
						r_player_blood = 12000;
					};
					
					_timer = diag_tickTime;
					_infectedStatus = if (r_player_infected) then { "Yes" } else { "Cured" };
					cutText [format [localize "str_sleepStats",_blood,r_player_blood], "PLAIN DOWN"];
				};	
			};
			
			if (!_isAsleep) then {
				//_playArray = _sleepArray call BIS_fnc_selectRandom;
				player switchMove "AidlPpneMstpSnonWnonDnon_SleepC_sleep";
			};
		};

		if (r_interrupt ) then {
			r_doLoop = false;
		};
		uiSleep 0.1;
	};
};

r_doLoop = false;

if (r_interrupt) then {
	systemChat (localize "str_endSleepStandUp");
	r_interrupt = false;
	player playmoveNow "";
	player playActionNow "stop";
};

r_action = false;

//Removed due to player sync returning []
//PVDZ_plr_Save = [player,nil,true,dayz_playerAchievements];
//publicVariableServer "PVDZ_plr_Save";