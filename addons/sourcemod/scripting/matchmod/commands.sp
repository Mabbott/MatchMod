/*
===============================================================================================================
MatchMod for Team Fortress 2

NAME			: Commands.sp        
VERSION			: 2.0
AUTHOR			: Charles 'Hawkeye' Mabbott
DESCRIPTION		: Script designed to house many of the commands available in MatchMod
REQUIREMENTS	: Sourcemod 1.2+

===============================================================================================================
*/


/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Action:Command_MatchModPug(client, args)

Routine will allow the beginning of a Pick-up game with the following characteristics
	- No ready-up sequence
	- Single half with no overtime period
	- Runs the PUG config set
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public Action:Command_MatchModPug(client, args) {

	if (CheckCommandAccess(client, "sm_pug", ADMFLAG_RESERVATION, true)) {
		if (args < 1) {
			ReplyToCommand(client, "[MatchMod] Usage: sm_pug <password>");
			return Plugin_Handled;
		}
		
		if (g_iMatchState > 0) {
			ReplyToCommand(client, "[MatchMod] A Game is already in progress.");
			return Plugin_Handled;
		}

		decl String:sPassword[64];

		strcopy(g_sConfigSet, sizeof(g_sConfigSet), "default");
		g_bAllowHalf = false;
		g_bAllowOT = false;
		g_bAllowReady = false;
		g_iHalfScore = 0;
		g_iMaxScore = 5;
		g_iMinPlayers = 5;
		g_iAutoPlayers = 6;
		g_bSwapTeams = false;
		g_iMatchState = 1;
		GetCmdArg(1, sPassword, sizeof(sPassword));
		ServerCommand("sv_password %s", sPassword);
		ExecuteNativeConfig(REGULATION);
		AdvanceMatchState();
	}
	return Plugin_Handled;
}

/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Action:Command_MatchModScrim(client, args)

Routine will allow the beginning of a Pick-up game with the following characteristics
	- No ready-up sequence
	- Single half with overtime period
	- Runs the PUG config set
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public Action:Command_MatchModScrim(client, args) {

	if (CheckCommandAccess(client, "sm_scrim", ADMFLAG_RESERVATION, true)) {
		if (args < 1) {
			ReplyToCommand(client, "[MatchMod] Usage: sm_scrim <password>");
			return Plugin_Handled;
		}

		if (g_iMatchState > 0) {
			ReplyToCommand(client, "[MatchMod] A Game is already in progress.");
			return Plugin_Handled;
		}

		decl String:sPassword[64];

		strcopy(g_sConfigSet, sizeof(g_sConfigSet), "default");
		g_bAllowHalf = false;
		g_bAllowOT = true;
		g_bAllowReady = false;
		g_iHalfScore = 0;
		g_iMaxScore = 5;
		g_iMinPlayers = 5;
		g_iAutoPlayers = 6;
		g_bSwapTeams = false;
		g_iMatchState = 1;
		GetCmdArg(1, sPassword, sizeof(sPassword));
		ServerCommand("sv_password %s", sPassword);
		ExecuteNativeConfig(REGULATION);
		AdvanceMatchState();		
	}
	return Plugin_Handled;
}

/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Action:Command_MatchModMatch(client, args)

Routine will allow the beginning of a Pick-up game with the following characteristics
	- Ready-up sequence
	- Runs defined number of players for ready up
	- Two half and overtime period
	- Runs the defined config set
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public Action:Command_MatchModMatch(client, args) {

	if (CheckCommandAccess(client, "sm_match", ADMFLAG_RESERVATION, true)) {
		if (args < 1) {
			ReplyToCommand(client, "[MatchMod] Usage: sm_match <password>");
			return Plugin_Handled;
		}

		if (g_iMatchState > 0) {
			ReplyToCommand(client, "[MatchMod] A Game is already in progress.");
			return Plugin_Handled;
		}

		decl String:sPassword[64];
		
		strcopy(g_sConfigSet, sizeof(g_sConfigSet), "default");
		g_bAllowHalf = true;
		g_bAllowOT = true;
		g_bAllowReady = true;
		g_iHalfScore = 3;
		g_iMaxScore = 5;
		g_iMinPlayers = 5;
		g_iAutoPlayers = 6;
		g_bSwapTeams = true;
		g_iMatchState = 1;
		GetCmdArg(1, sPassword, sizeof(sPassword));
		ServerCommand("sv_password %s", sPassword);
		ExecuteNativeConfig(REGULATION);
		AdvanceMatchState();
	}
	return Plugin_Handled;
}
