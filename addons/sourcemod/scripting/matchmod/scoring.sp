/*
===============================================================================================================
MatchMod for Team Fortress 2

NAME			: scoring.sp        
VERSION			: 2.0
AUTHOR			: Charles 'Hawkeye' Mabbott
DESCRIPTION		: Script designed to house all the score tracking and the announcer of MatchMod
REQUIREMENTS	: Sourcemod 1.2+

===============================================================================================================
*/

new g_iRedScore;	// Tracks the score of Red
new g_iBluScore;	// Tracks the score of Blu
new g_iRoundCounter;	// Used to count the number of rounds in Attack/Defend stype gameplay
new String:g_sRedTeamName[32] = "RED";	// Tracks the Red team name
new String:g_sBluTeamName[32] = "BLU";	// Tracks the Blu team name

public Event_GameWinPanel(Handle:event, const String:name[], bool:dontBroadcast) {
	if (!g_bMatchLive) {
		return;
	}
	else {
		switch (g_iMapType)
		{
			case ARENA, KOTH, PUSH, CTF:
			{
				new iRedScore = GetEventInt(event, "red_score");
				new iBluScore = GetEventInt(event, "blue_score");
				
				g_iRedScore = iRedScore;
				g_iBluScore = iBluScore;
			}
			case STOPWATCH, PAYLOAD:
			{
				new bool:bRoundComplete = GetEventBool(event, "round_complete");
				
				if (bRoundComplete) {
					g_iRoundCounter++;
					if (g_iRoundCounter == 2) { // We Played the rounds we need
						new iTeam = GetEventInt(event, "winning_team");

						if (iTeam == RED) {
							g_iRedScore++;
						}
						else if (iTeam == BLU) {
							g_iBluScore++;
						}				
					}
				}
			}
			case PAYLOADRACE:
			{
			}
			case TC:
			{
				new iTeam = GetEventInt(event, "winning_team");
				new iRoundComplete = GetEventInt(event, "round_complete");

				if (iRoundComplete == 1) {
					if (iTeam == RED) {
						g_iRedScore++;
					}
					else if (iTeam == BLU) {
						g_iBluScore++;
					}				
				}
			}
		}
	}
}

public Event_CTFFlagCaptured(Handle:event, const String:name[], bool:dontBroadcast) {
	if (!g_bMatchLive) {
		return;
	}
}

public Event_TeamplayRoundActive(Handle:event, const String:name[], bool:dontBroadcast) {
	if (g_bMatchLive) {
		new String:sPlayByPlay[128];
		new String:sTimeRemaining[256];
		new iTempTime;
		new iTimeLeft;
		
		iTempTime = GetConVarInt(FindConVar("mp_timelimit"));
		
		if (iTempTime >= 1) {
			GetMapTimeLeft(iTimeLeft);
			
			Format(sTimeRemaining, 256, "%d:%02d", (iTimeLeft / 60), (iTimeLeft % 60));
			
			Format(sPlayByPlay, sizeof(sPlayByPlay), "\x04[MatchMod]\x01 %T", "Time remaining", LANG_SERVER, sTimeRemaining);
			PrintToChatAll(sPlayByPlay);
		}
	
		switch (g_iMapType) {
			case PUSH, KOTH:
			{
				if (g_iRedScore == g_iBluScore) {
					Format(sPlayByPlay, sizeof(sPlayByPlay), "\x04[MatchMod]\x01 %T", "Score tied", LANG_SERVER, g_iRedScore, g_iBluScore);
				}
				else if (g_iRedScore > g_iBluScore) {
					Format(sPlayByPlay, sizeof(sPlayByPlay), "\x04[MatchMod]\x01 %T", "Score lead", LANG_SERVER, g_sRedTeamName, g_iRedScore, g_iBluScore);
				}
				else if (g_iRedScore < g_iBluScore) {
					Format(sPlayByPlay, sizeof(sPlayByPlay), "\x04[MatchMod]\x01 %T", "Score lead", LANG_SERVER, g_sBluTeamName, g_iBluScore, g_iRedScore);
				}
				
				PrintToChatAll(sPlayByPlay);
			}
		}
	}
}

public Action:Command_SetTeamName(client, args) {
	if (args < 1) {
		ReplyToCommand(client, "[MatchMod] Usage: sm_teamname \"<name>\"");
		return Plugin_Handled;
	}
	
	if (g_iMatchState < 3) {
		decl String:sAssignTeamName[32];
		
		new iTeam = GetClientTeam(client);
		
		GetCmdArg(1, sAssignTeamName, sizeof(sAssignTeamName));
		
		if (iTeam == RED) {
			strcopy(g_sRedTeamName, sizeof(g_sRedTeamName), sAssignTeamName);
			SetConVarString(FindConVar("mp_tournament_redteamname"), sAssignTeamName);
		}
		else if (iTeam == BLU) {
			strcopy(g_sBluTeamName, sizeof(g_sBluTeamName), sAssignTeamName);
			SetConVarString(FindConVar("mp_tournament_blueteamname"), sAssignTeamName);
		}
		else {
			ReplyToCommand(client, "[MatchMod] %t", "Cannot name");
		}
	}
	return Plugin_Handled;
}

SetScoreboardNames() {
	SetConVarString(FindConVar("mp_tournament_redteamname"), g_sRedTeamName);
	SetConVarString(FindConVar("mp_tournament_blueteamname"), g_sBluTeamName);
}

ScoreAnnouncer() {
	if (g_bMatchLive) {
		new String:sPlayByPlay[128];
		new String:sTimeRemaining[256];
		new iTempTime;
		new iTimeLeft;
		
		iTempTime = GetConVarInt(FindConVar("mp_timelimit"));
		
		if (iTempTime >= 1) {
			GetMapTimeLeft(iTimeLeft);
			
			Format(sTimeRemaining, 256, "%d:%02d", (iTimeLeft / 60), (iTimeLeft % 60));
			
			Format(sPlayByPlay, sizeof(sPlayByPlay), "\x04[MatchMod]\x01 %T", "Time remaining", LANG_SERVER, sTimeRemaining);
			PrintToChatAll(sPlayByPlay);
		}
	
		switch (g_iMapType) {
			case PUSH, KOTH:
			{
				if (g_iRedScore == g_iBluScore) {
					Format(sPlayByPlay, sizeof(sPlayByPlay), "\x04[MatchMod]\x01 %T", "Score tied", LANG_SERVER, g_iRedScore, g_iBluScore);
				}
				else if (g_iRedScore > g_iBluScore) {
					Format(sPlayByPlay, sizeof(sPlayByPlay), "\x04[MatchMod]\x01 %T", "Score lead", LANG_SERVER, g_sRedTeamName, g_iRedScore, g_iBluScore);
				}
				else if (g_iRedScore < g_iBluScore) {
					Format(sPlayByPlay, sizeof(sPlayByPlay), "\x04[MatchMod]\x01 %T", "Score lead", LANG_SERVER, g_sBluTeamName, g_iBluScore, g_iRedScore);
				}
				
				PrintToChatAll(sPlayByPlay);
			}
		}
	}
}

SwapTeamScores() {
	new iTmpScore;
	new String:iTmpName[32];
	
	iTmpScore = g_iRedScore;
	g_iRedScore = g_iBluScore;
	g_iBluScore = iTmpScore;
	iTmpScore = 0;
	
	strcopy(iTmpName, sizeof(iTmpName), g_sRedTeamName);
	strcopy(g_sRedTeamName, sizeof(g_sRedTeamName), g_sBluTeamName);
	strcopy(g_sBluTeamName, sizeof(g_sBluTeamName), iTmpName);
}