/*
===============================================================================================================
MatchMod for Team Fortress 2

NAME			: MapDetection.sp        
VERSION			: 2.0
AUTHOR			: Charles 'Hawkeye' Mabbott
DESCRIPTION		: Script designed to detect the map type and set some variabls to be referenced in other routinges
REQUIREMENTS	: Sourcemod 1.2+

===============================================================================================================
*/

// English references for map type
#define PUSH 1
#define STOPWATCH 2
#define CTF 3
#define PAYLOAD 4
#define PAYLOADRACE 5
#define KOTH 6
#define ARENA 7
#define TC 8

new g_iMapType = 0;
new String:g_sMapName[36];

/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
DetectMap

Routine is designed to detect the map type and set a variable used by other features of MatchMod
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
DetectMap() {
	// This routine detects the map type, original function written by Berni
	new iEnt = -1, bool:bAttackPoint = false;
	GetCurrentMap(g_sMapName, sizeof(g_sMapName));
	if (strncmp(g_sMapName, "cp_", 3, false) == 0) {
		new iTeam;
		while ((iEnt = FindEntityByClassname(iEnt, "team_control_point")) != -1) {
			iTeam = GetEntProp(iEnt, Prop_Send, "m_iTeamNum");
			/**
			* If there is a blu CP or a neutral CP, then it's not an attack/defend map
			*
			**/
			if (iTeam != RED) {
				g_iMapType = STOPWATCH;
				break;
			}
		}
		if (!bAttackPoint) {
			g_iMapType = PUSH;
		}
	}
	else if (strncmp(g_sMapName, "bball_", 6, false) == 0) {
		g_iMapType = CTF;
	}
	else if (strncmp(g_sMapName, "ctf_", 4, false) == 0) {
		g_iMapType = CTF;
	}
	else if (strncmp(g_sMapName, "koth_", 5, false) == 0) {
		g_iMapType = KOTH;
	}
	else if (strncmp(g_sMapName, "pl_", 3, false) == 0) {
		g_iMapType = PAYLOAD;
	}
	else if (strncmp(g_sMapName, "plr_", 4, false) == 0) {
		g_iMapType = PAYLOADRACE;
	}
	else if (strncmp(g_sMapName, "arena_", 6, false) == 0) {
		g_iMapType = ARENA;
	}
	else if (strncmp(g_sMapName, "tc_", 3, false) == 0) {
		g_iMapType = TC;
	}
	else {
		// In the event we don't know assume PUSH gametype
		g_iMapType = PUSH;
	}
}