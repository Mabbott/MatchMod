/*
===============================================================================================================
MatchMod for Team Fortress 2

NAME			: ReadyUp.sp        
VERSION			: 2.0
AUTHOR			: Charles 'Hawkeye' Mabbott
DESCRIPTION		: Script designed to handle the Advanced Ready-Up aspects of MatchMod
REQUIREMENTS	: Sourcemod 1.2+

===============================================================================================================
*/

new Handle:g_hCountdownActive = INVALID_HANDLE;	// Used to carry the timer after both teams have said go
new bool:g_bBluForced = false;	// If true, the variable means the BLU team has readied up 1 man down
new bool:g_bRedForced = false;	// If true, the variable means the RED team has readied up 1 man down
new bool:g_bRedAllowForce = false;  // If true, the variable means BLU can now force themselves ready
new bool:g_bBluAllowForce = false;	// If true, the variable means BLU can now force themselves ready
new bool:g_bReadyStart = false;	// Stores that the match countdown has begun and determined if it needs to be cancelled
new bool:g_bReadyUp = false;	// Variable they tells all functions if ready-up is currently active
new g_iReadyStatus[MAXPLAYERS + 1];	// Array used to store the ready status of all the players
new g_iRedTeamMin;	// Minimum number of RED players required to force a ready up (1 man down)
new g_iRedTeamAuto;	// Minimum number of RED players for the team to be automatically readied up
new g_iBluTeamMin;	// Minimum number of BLU players required (1 man down)
new g_iBluTeamAuto;	// Minimum number of BLU players for the team to be automatically readied up


/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Action:OnClientCommand(client, args)

Routine is designed to detect the map type and set a variable used by other features of MatchMod
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public Action:OnClientCommand(client, args) {

	new String:sCmd[30];
	GetCmdArg(0, sCmd, sizeof(sCmd));
	
	// This check effectively disabled the players ability to ready up the team via the native UI
	if (StrEqual(sCmd, "tournament_readystate") && g_bReadyUp ) {
		return Plugin_Handled;
	}
	
	// Required to not through an error, effectively tell the engine to carry on
	return Plugin_Continue;
}

/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Action:OnClientDisconnect(client, args)

If a client disconnects during ready-up, we want to ensure the readyup flag is cleared so it does not interfere with the counts
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public OnClientDisconnect(client) {
	if (g_bReadyUp) {
		g_iReadyStatus[client] = false;
		ReadyUpStatus();
	}
}

/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Action:Command_Ready(client, args)

Allows a player to signify they are ready to begin a game
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public Action:Command_Ready(client, args) {
	// Only run if the the readyup functions are enabled
	if (g_bReadyUp) {
		new String:sName[MAX_NAME_LENGTH];

		if (g_iReadyStatus[client]) {
			ReplyToCommand(client, "[MatchMod] %t", "Player previous ready");			
		}
		else {
			g_iReadyStatus[client] = true;
			ReplyToCommand(client, "[MatchMod] %t", "Player ready");
			GetClientName(client, sName, sizeof(sName));
			PrintToChatAll("\x04[MatchMod]\x01 %T", "Player is ready", LANG_SERVER, sName);
		}
		
		ReadyUpStatus();
		
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Action:Command_UnReady(client, args)

Allows a player to signify they are not ready to begin a game
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public Action:Command_UnReady(client, args) {
	// Only run if the the readyup functions are enabled
	if (g_bReadyUp) {
		new String:sName[MAX_NAME_LENGTH];

		if (!g_iReadyStatus[client]) {
			ReplyToCommand(client, "[MatchMod] %t", "Player previous unready");			
		}
		else {
			g_iReadyStatus[client] = false;
			ReplyToCommand(client, "[MatchMod] %t", "Player unready");
			GetClientName(client, sName, sizeof(sName));
			PrintToChatAll("\x04[MatchMod]\x01 %T", "Player is unready", LANG_SERVER, sName);
		}
		
		ReadyUpStatus();
		
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Action:Command_Start(client, args)

Allows a player to signify the team is ready to begin even though they are short one player
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public Action:Command_Start(client, args) {

	if (g_bReadyUp) {
		new iTeam = GetClientTeam(client);
		
		if (iTeam == RED && g_bRedAllowForce) {
			g_bRedForced = true;
		}

		if (iTeam == BLU && g_bBluAllowForce) {
			g_bBluForced = true;
		}
		
		ReadyUpStatus();
	}
	else {
		ReplyToCommand(client, "[MatchMod] %t", "Force not allowed");
	}
	
	return Plugin_Handled;
}

/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
ReadyUpStatus()

Determines the count of currently ready players on each team and determines if the match should begin or not
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
ReadyUpStatus() {
	
	if (g_bReadyUp) {
		decl iCounter;
		new iRedCount, iBluCount;
		new bool:bRedReady = false;
		new bool:bBluReady = false;
		
		// This loop checks all players ready status and counts up each teams separately
		for (iCounter = 1; iCounter <= MaxClients; iCounter++) {
			if (IsClientConnected(iCounter) && ~IsFakeClient(iCounter)) {
				if (g_iReadyStatus[iCounter]) {
					new team = GetClientTeam(iCounter);
					
					if (team == RED) {
						iRedCount++;
					}
					
					if (team == BLU) {
						iBluCount++;
					}
				}
			}
		}
		
		// We now cycle through all the scenarios to interpret the results
		
		// If Red team has the minimum required but not the enough or auto ready up
		if (iRedCount >= g_iRedTeamMin && iRedCount < g_iRedTeamAuto) {
			if (!g_bRedForced) {
				PrintToChatAll("\x04[MatchMod]\x01 %T", "Red team minimum", LANG_SERVER);
				PrintToChatAll("\x04[MatchMod]\x01 %T", "Red can start", LANG_SERVER);
				bRedReady = false;
				g_bRedAllowForce = true;		
			}
		}
		
		// If Red team has reached the automatic ready up state
		else if (iRedCount >= g_iRedTeamAuto) {
			if (!bRedReady) {
				PrintToChatAll("\x04[MatchMod]\x01 %T", "Red team ready", LANG_SERVER);
				bRedReady = true;
			}
		}
		
		// If Red team does not have enough players readied up
		else if (iRedCount < g_iRedTeamMin) {
			bRedReady = false;
			g_bRedAllowForce = false;
		}
		
		// If Blu team has the minimum required but not the enough or auto ready up
		if (iBluCount >= g_iBluTeamMin && iBluCount < g_iBluTeamAuto) {
			if (!g_bBluForced) {
				PrintToChatAll("\x04[MatchMod]\x01 %T", "Blu team minimum", LANG_SERVER);
				PrintToChatAll("\x04[MatchMod]\x01 %T", "Blu can start", LANG_SERVER);
				bBluReady = false;
				g_bBluAllowForce = true;		
			}
		}
		
		// If Blu team has reached the automatic ready up state
		else if (iBluCount >= g_iBluTeamAuto) {
			if (!bBluReady) {
				PrintToChatAll("\x04[MatchMod]\x01 %T", "Blu team ready", LANG_SERVER);
				bBluReady = true;
			}
		}
		
		// If Blu team does not have enough players readied up
		else if (iBluCount < g_iBluTeamMin) {
			bBluReady = false;
			g_bBluAllowForce = false;
		}
		
		// Now that we have evaluated the counts, we can now check if the teams are ready
		if ((bBluReady || g_bBluForced) && (bRedReady || g_bRedForced)) {
			// Both teams are in a ready state, we can go forward
			if (!g_bReadyStart) {
				g_bReadyStart = true;
				// A 10 second timer is created, during the 10 seconds, the countdown can be canceled, after the timer there is no method to cancel the start
				g_hCountdownActive = CreateTimer(10.0, startRound);
				PrintCenterTextAll("%T", "Countdown begin", LANG_SERVER);
			}
		}
		else if ((!bBluReady || !g_bBluForced) && (!bRedReady || !g_bRedForced)) {
			// Neither team is ready or someone unreadied, so we need to kill the countdown
			if (g_bReadyStart) {
				PrintToChatAll("\x04[MatchMod]\x01 %T", "Countdown aborted", LANG_SERVER);
				KillTimer(g_hCountdownActive);
				g_bReadyStart = false;
			}
		}	
	}
}

/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Action:startRound(Handle:timer)

A timer that is used to begin the match and provide a verbal countdown to the players
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public Action:startRound(Handle:timer) {
	// The timer counts for 10 seconds, then initiates the 5 second countdown so the in-game announcer can be heard
	ServerCommand("mp_restartgame 5");
}

/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Begin_ReadyUp

Processes the beginning of the ready-up sequence and sets the requirements for teams to get ready
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
Begin_ReadyUp(iMin, iAuto) {
	// Begins Readyup, sets to the proper number of players passed from menu system
	new iCounter;
	g_iRedTeamMin = iMin;
	g_iRedTeamAuto = iAuto;
	g_iBluTeamMin = iMin;
	g_iBluTeamAuto = iAuto;
		
	g_bRedForced = false;
	g_bBluForced = false;
	g_bRedAllowForce = false;
	g_bBluAllowForce = false;
	g_bReadyUp = true;

	for (iCounter = 1; iCounter < MaxClients; iCounter++) {
		g_iReadyStatus[iCounter] = false;
	}		

	PrintToChatAll("\x04[MatchMod]\x01 %T", "Begin ready up", LANG_SERVER);
}

/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
End_ReadyUp

Processes the beginning of the ready-up sequence and sets the requirements for teams to get ready
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
End_ReadyUp() {
	// Ends Readyup, sets all variables back to zero, and clears out tracking array
	new iCounter;
	g_iRedTeamMin = 0;
	g_iRedTeamAuto = 0;
	g_iBluTeamMin = 0;
	g_iBluTeamAuto = 0;
	
	g_bRedForced = false;
	g_bBluForced = false;
	g_bRedAllowForce = false;
	g_bBluAllowForce = false;
	g_bReadyUp = false;
		
	for (iCounter = 1; iCounter < MaxClients; iCounter++) {
		g_iReadyStatus[iCounter] = false;
	}
}