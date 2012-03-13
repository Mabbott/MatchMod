/*
===============================================================================================================
MatchMod for Team Fortress 2

NAME			: logging.sp        
VERSION			: 2.0
AUTHOR			: Charles 'Hawkeye' Mabbott
DESCRIPTION		: Script designed to handle the extra logging used by stat parsers
REQUIREMENTS	: Sourcemod 1.2+

Note				: Code heavily based on plugin written by Jean-Denis Caron	
===============================================================================================================
*/

new bool:bIsPaused;

DisableLogging() {
	// PrintToChatAll("\x04[MatchMod]\x01 %T", "Disable log", LANG_SERVER);
	ServerCommand("log off");
}


EnableLogging() {
	// PrintToChatAll("\x04[MatchMod]\x01 %T", "Enable log", LANG_SERVER);
	ServerCommand("log on");
}

public Action:Listener_Pause(client, const String:command[], args) {
	if (g_bMatchLive) {
		bIsPaused = !bIsPaused;
		
		if (bIsPaused) {
			LogToGame("World triggered \"Game_Paused\"");
		}
		else {
			LogToGame("World triggered \"Game_Unpaused\"");
		}
	}
}

public Event_ItemPickup(Handle:event, const String:name[], bool:dontBroadcast) {
	if (g_bMatchLive) {
		decl String:sPlayerName[32];
		decl String:sPlayerSteamId[64];
		decl String:sPlayerTeam[64];
		decl String:sItem[64];

		new iPlayerId = GetEventInt(event, "userid");
		new iPlayer = GetClientOfUserId(iPlayerId);
		GetClientAuthString(iPlayer, sPlayerSteamId, sizeof(sPlayerSteamId));
		GetClientName(iPlayer, sPlayerName, sizeof(sPlayerName));
		sPlayerTeam = GetPlayerTeam(GetClientTeam(iPlayer));
		GetEventString(event, "item", sItem, sizeof(sItem));

		LogToGame("\"%s<%d><%s><%s>\" picked up item \"%s\"",
			sPlayerName,
			iPlayerId,
			sPlayerSteamId,
			sPlayerTeam,
		sItem);
	}
}

public Event_PlayerHealed(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (g_bMatchLive) {
		decl String:sPatientName[32];
		decl String:sHealerName[32];
		decl String:sPatientSteamId[64];
		decl String:sHealerSteamId[64];
		decl String:sPatientTeam[64];
		decl String:sHealerTeam[64];

		new iPatientId = GetEventInt(event, "patient");
		new iHealerId = GetEventInt(event, "healer");
		new iPatient = GetClientOfUserId(iPatientId);
		new iHealer = GetClientOfUserId(iHealerId);
		new iAmount = GetEventInt(event, "amount");

		GetClientAuthString(iPatient, sPatientSteamId, sizeof(sPatientSteamId));
		GetClientName(iPatient, sPatientName, sizeof(sPatientName));
		GetClientAuthString(iHealer, sHealerSteamId, sizeof(sHealerSteamId));
		GetClientName(iHealer, sHealerName, sizeof(sHealerName));

		sPatientTeam = GetPlayerTeam(GetClientTeam(iPatient));
		sHealerTeam = GetPlayerTeam(GetClientTeam(iHealer));

		LogToGame("\"%s<%d><%s><%s>\" triggered \"healed\" against \"%s<%d><%s><%s>\" (healing \"%d\")",
			sHealerName,
			iHealerId,
			sHealerSteamId,
			sHealerTeam,
			sPatientName,
			iPatientId,
			sPatientSteamId,
			sPatientTeam,
			iAmount);
	}
}

public Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (g_bMatchLive) {
		decl String:sClientName[32];
		decl String:sSteamId[64];
		decl String:sTeam[64];

		new iUserId = GetClientOfUserId(GetEventInt(event, "userid"));
		new iAttackerId = GetEventInt(event, "attacker");
		new iAttacker = GetClientOfUserId(iAttackerId);
		new iDamage = GetEventInt(event, "damageamount");
		if(iUserId != iAttacker && iAttacker != 0)
		{
			GetClientAuthString(iAttacker, sSteamId, sizeof(sSteamId));
			GetClientName(iAttacker, sClientName, sizeof(sClientName));
			sTeam = GetPlayerTeam(GetClientTeam(iAttacker));
			LogToGame("\"%s<%d><%s><%s>\" triggered \"damage\" (damage \"%d\")",
				sClientName,
				iAttackerId,
				sSteamId,
				sTeam,
				iDamage);
		}
	}
}

public Event_PlayerSpawned(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (g_bMatchLive) {
		decl String:sClientName[32];
		decl String:sSteamId[64];
		decl String:sTeam[64];
		new String:sClasses[10][64] = {
				"undefined",
				"scout",
				"sniper",
				"soldier",
				"demoman",
				"medic",
				"heavyweapons",
				"pyro",
				"spy",
				"engineer"
		};

		new iUser = GetClientOfUserId(GetEventInt(event, "userid"));
		new iClss = GetEventInt(event, "class");

		GetClientAuthString(iUser, sSteamId, sizeof(sSteamId));
		GetClientName(iUser, sClientName, sizeof(sClientName));
		sTeam = GetPlayerTeam(GetClientTeam(iUser));
		LogToGame("\"%s<%d><%s><%s>\" spawned as \"%s\"",
			sClientName,
			iUser,
			sSteamId,
			sTeam,
			sClasses[iClss]);
	}
}

String:GetPlayerTeam(teamIndex)
{
	decl String:sTeam[64];

	switch (teamIndex)
	{
		case RED:
			sTeam = "Red";
		case BLU:
			sTeam = "Blue";
		default:
			sTeam = "undefined";
	}

	return sTeam;
}