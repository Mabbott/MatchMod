/*
===============================================================================================================
MatchMod for Team Fortress 2

NAME			: MatchMod.sp        
VERSION			: 2.0
AUTHOR			: Charles 'Hawkeye' Mabbott
DESCRIPTION		: A plugin designed to assist in Competitive play for Team Fotress 2
REQUIREMENTS	: Sourcemod 1.2+

===============================================================================================================
*/

#pragma semicolon 1

/* SM Includes */
#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "2.0dev"

// English references for Teams
#define SPECTATOR 1
#define RED 2
#define BLU 3

#define REGULATION 0
#define OVERTIME 1

/*
Some Concepts for reference

All variables will follow the below convention
  (g_)xDescription
  
  g_ prefixes all variables global in nature, variables created and destroyed within a object will not have the prefix
  x references the type, h for hande, i for integer, f for float, s for string and so forth
  
*/
new g_iMatchState = 0;   // Determines where in the match sequence we currently are
new g_iHalfScore = 0;	// Determines the maximum score that triggers halftime
new g_iMaxScore = 0;	// determines the maximum score for the entire match
new g_iMinPlayers = 0;	// Minimum number of players to start a Match (some leagues allow to play 1 man down)
new g_iAutoPlayers = 0;	// Number of players for a match to begin
new bool:g_bMatchLive = false;	// If the match is live or not, used to determine if stats/logging is occuring
new bool:g_bAllowHalf = false;	// Determines if a match will allow halftime
new bool:g_bAllowOT = false;	// Determines if a match will allow overtime
new bool:g_bAllowReady = false;	// Determines if a match will utilize the Advanced ReadyUp options
new bool:g_bSwapTeams = false;	// Determines if the teams are swapped at half time and before overtime


new String:g_sLogPath[PLATFORM_MAX_PATH];
new String:g_sConfigSet[16]; // Records the currently active config so we can easily call the overtime configs appropriately

#include "matchmod/mapdetection.sp"
#include "matchmod/readyup.sp"
#include "matchmod/commands.sp"
#include "matchmod/sourcetv.sp"
#include "matchmod/configs.sp"
#include "matchmod/leagues.sp"
#include "matchmod/stats.sp"
#include "matchmod/logging.sp"
#include "matchmod/scoring.sp"
#include "matchmod/plugins.sp"

public Plugin:myinfo =
{
	name = "MatchMod",
	author = "Hawkeye",
	description = "Competitive mod for Team Fortress 2",
	version = PLUGIN_VERSION,
	url = "http://matchmod.net"
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max) {

	// Path used for logging
	BuildPath(Path_SM, g_sLogPath, sizeof(g_sLogPath), "logs/matchmod.log");
	
	return APLRes_Success;
}

public OnPluginStart() {

	LoadTranslations("matchmod.phrases");
	LoadTranslations("matchmod-readyup.phrases");
	
	CreateConVar("matchmod_version", PLUGIN_VERSION, "Version of the MatchMod for TF2 plugin", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	// Listen to global chat for commands fired by TF2Lobby.com
	AddCommandListener(Command_Say, "say");
	
	// Create a command to check the version of the plugin active
	RegConsoleCmd("sm_matchmod_version", Command_MatchModVersion);
	
	// Create commands to begin various match sequences
	RegConsoleCmd("sm_scrim", Command_MatchModScrim);
	RegConsoleCmd("sm_pug", Command_MatchModPug);
	RegConsoleCmd("sm_match", Command_MatchModMatch);
	RegConsoleCmd("sm_esea", Command_MatchModESEA);
	
	// Command to allow the stopping of a match in progress
	RegConsoleCmd("sm_endmatch", Command_MatchModEnd);
	
	// Create commands used by ReadyUp sequences
	RegConsoleCmd("sm_ready", Command_Ready);
	RegConsoleCmd("sm_notready", Command_UnReady);
	RegConsoleCmd("sm_unready", Command_UnReady);
	RegConsoleCmd("sm_start", Command_Start);
	
	// Create commands to allow players to name their team
	RegConsoleCmd("sm_teamname", Command_SetTeamName);

	// Used to capture the actual end of a round
	HookEvent("teamplay_game_over", Event_GameOver);
	HookEvent("tf_game_over", Event_GameOver);
	
	// Used to capture the actual start of game to begin the sequence
	HookEvent("teamplay_restart_round", Event_GameRestart);
	
	// Used to capture the moment the countdown starts before a period begins
	HookEvent("teamplay_round_restart_seconds", Event_RoundRestartSeconds);
	
	// Used to capture when players can begin to move in a round
	HookEvent("teamplay_round_active", Event_TeamplayRoundActive);
	
	// Use to capture when a flag capture occurs and inititates the announcer
	HookEvent("ctf_flag_captured", Event_CTFFlagCaptured);

	// Used to capture the score for tracking purposes
	HookEvent("arena_win_panel", Event_GameWinPanel);	
}

public OnMapStart() {
}

public OnConfigsExecuted() {
	DetectMap();
}

public OnMapEnd() {
}

public OnPluginEnd() {
}



/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Action:Command_MatchModVersion(client, args)

Routine will replay to the client with the version of Matchmod currently running
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public Action:Command_MatchModVersion(client, args) {

	ReplyToCommand(client, "[MatchMod] %t", "Version", PLUGIN_VERSION);
	
	return Plugin_Handled;
}

InitializeVariables() {
	g_iRedScore = 0;
	g_iBluScore = 0;
	g_iRoundCounter = 0;
}


public Event_GameOver(Handle:event, const String:name[], bool:dontBroadcast) {
	if (g_iMatchState > 0) {
		AdvanceMatchState();
	}
}

public Event_GameRestart(Handle:event, const String:name[], bool:dontBroadcast) {
	if (g_iMatchState > 0) {
		AdvanceMatchState();
	}
}


AdvanceMatchState() {

	switch (g_iMatchState)
	{
		
		// Pre-game - Begins 1 - Advances to 2
		case 1:
		{
			DisableLogging();
			PrintToChatAll("\x04[MatchMod]\x01 %T", "Begin pregame", LANG_SERVER);
			InitializeVariables();
			if (g_bAllowReady) {
				Begin_ReadyUp(g_iMinPlayers, g_iAutoPlayers);
			}
			g_iMatchState++;
		}

		// Begin 1st Half - Begins 2 - Advances to 3
		case 2:
		{
			EnableLogging();
			if (g_bReadyUp) {
				End_ReadyUp();
			}
			PrintToChatAll("\x04[MatchMod]\x01 %T", "Begin first half", LANG_SERVER);
			SetScoreboardNames();
			g_bMatchLive = true;
			if (g_bAllowHalf) {
				g_iMatchState++;
			}
			else {
				if (g_bAllowOT) {
					g_iMatchState = 5;
				}
				else {
					g_iMatchState = 7;
				}
			}
			PrintCenterTextAll("%T", "Match live", LANG_SERVER);
		}

		// Advance to Half-time - Begins 3
		case 3:
		{
			PrintToChatAll("\x04[MatchMod]\x01 %T", "End first half", LANG_SERVER);
			PrintCenterTextAll("%T", "Half time", LANG_SERVER);
			ScoreAnnouncer();
			if (g_iMapType == PUSH || g_iMapType == KOTH) {
				SetConVarInt(FindConVar("mp_winlimit"), g_iMaxScore);
			}
			if (g_iMapType == STOPWATCH || g_iMapType == PAYLOAD) {
				g_iRoundCounter = 0;
			}
			if (g_bAllowReady) {
				Begin_ReadyUp(g_iMinPlayers, g_iAutoPlayers);
			}
			g_bMatchLive = false;
			if (g_bAllowOT) {
				g_iMatchState = 5;
			}
			else {
				g_iMatchState++;
			}
			if (g_bSwapTeams) {
				SwapPlayerTeams();
				SwapTeamScores();
			}
			
		
		}

		// Advance to 2nd half - Begins 4 - Advances to 5
		case 4:
		{
			if (g_bReadyUp) {
				End_ReadyUp();
			}
			PrintToChatAll("\x04[MatchMod]\x01 %T", "Begin second half", LANG_SERVER);
			SetScoreboardNames();
			if (g_iMapType == PUSH || g_iMapType == KOTH || g_iMapType == ARENA || g_iMapType == CTF) {
				SetTeamScore(RED, g_iRedScore);
				SetTeamScore(BLU, g_iBluScore);
			}
			g_bMatchLive = true;		
			g_iMatchState++;
			PrintCenterTextAll("%T", "Match live", LANG_SERVER);
		}

		// Post-game - Begins 5 - Advances to 6
		case 5:
		{
			g_bMatchLive = false;
			if (!g_bAllowOT) {
				g_iMatchState = 7;
			}
			else if (g_iRedScore == g_iBluScore) {
				PrintToChatAll("\x04[MatchMod]\x01 %T", "End regulation", LANG_SERVER);
				PrintToChatAll("\x04[MatchMod]\x01 %T", "Teams tied", LANG_SERVER);
				PrintCenterTextAll("%T", "Prepare overtime", LANG_SERVER);			
				g_iMatchState++;
				ExecuteOvertime();
				if (g_iMapType == STOPWATCH || g_iMapType == PAYLOAD) {
					g_iRoundCounter = 0;
				}
				if (g_iMapType == PUSH || g_iMapType == KOTH || g_iMapType == ARENA) {
					SetConVarInt(FindConVar("mp_winlimit"), g_iRedScore + 1);
				}
				if (g_bAllowReady) {
					Begin_ReadyUp(g_iMinPlayers, g_iAutoPlayers);
				}
				if (g_bSwapTeams) {
					SwapPlayerTeams();
				}
			}


		}

		// Overtime - Begins 6 - Advances to 7
		case 6:
		{
			if (g_bReadyUp) {
				End_ReadyUp();
			}
			SetScoreboardNames();
			g_bMatchLive = true;		
			PrintCenterTextAll("%T", "Match live", LANG_SERVER);
			g_iMatchState++;
		}

		// End of game - Begins 7 - resets to 0
		case 7:
		{
			DisableLogging();
			g_iMatchState = 0;
			g_iMinPlayers = 0;
			g_iAutoPlayers = 0;
			g_bMatchLive = false;
			ExecuteIdleConfig();
		}

		default:
		{
			return;
		}
	}
}

SwapPlayerTeams() {
	for (new iClient=1; iClient <= MaxClients; iClient++) {
		if (IsClientInGame(iClient) && (GetClientTeam(iClient) == RED)) {
			ChangeClientTeam(iClient, SPECTATOR);
			ChangeClientTeam(iClient, BLU);
		}
		else if (IsClientInGame(iClient) && (GetClientTeam(iClient) == BLU)) {
			ChangeClientTeam(iClient, SPECTATOR);
			ChangeClientTeam(iClient, RED);
		}
	}
}