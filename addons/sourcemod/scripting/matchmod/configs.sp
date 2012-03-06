/*
===============================================================================================================
MatchMod for Team Fortress 2

NAME			: Configs.sp        
VERSION			: 2.0
AUTHOR			: Charles 'Hawkeye' Mabbott
DESCRIPTION		: Script designed to handle the configuration file aspects of the mod
REQUIREMENTS	: Sourcemod 1.2+

===============================================================================================================
*/


/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Action:Command_Say(client, args)

Routine allows for the listening of various commands issued, the following commands are listened for:
	- From Console (Client 0)
		- say lobbyId    (issued by TF2Lobby.Com when a lobby begins, includes Lobby's Numeric LobbyId)
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public Action:Command_Say(client, const String:command[], args) {
	// This function is used to detect if TF2Lobby.com is activating a match
	if (client == 0) {
		decl String:sLobbyKey[32];
		new String:sLobbyInfo[4][10];
		GetCmdArg(1, sLobbyKey, sizeof(sLobbyKey));
		ExplodeString(sLobbyKey, "",sLobbyInfo, sizeof(sLobbyInfo), sizeof(sLobbyInfo[]));
		
		if (StrEqual(sLobbyInfo[0], "LobbyId", false)) {
			strcopy(g_sConfigSet, sizeof(g_sConfigSet), "lobby");
			g_bAllowHalf = false;
			g_bAllowOT = false;
			g_bAllowReady = false;
			g_iHalfScore = 0;
			g_iMaxScore = 5;
			g_iMinPlayers = 5;
			g_iAutoPlayers = 6;
			g_bSwapTeams = false;
			g_iMatchState = 1;
			AdvanceMatchState();
		}
	}
		
	return Plugin_Continue;
}

ExecuteIdleConfig() {

	new String:sConfig[25];
	// Idle Configuration for MatchMod
	// updated 3-Mar-2012
	
	SetConVarInt(FindConVar("decalfrequency"), 10);
	SetConVarInt(FindConVar("host_framerate"), 0);


	SetConVarInt(FindConVar("tf_allow_player_use"), 0);
	SetConVarInt(FindConVar("tf_allow_taunt_switch"), 1);
	SetConVarInt(FindConVar("tf_arena_first_blood"), 0);
	SetConVarInt(FindConVar("tf_arena_round_time"), 1);
	SetConVarInt(FindConVar("tf_arena_use_queue"), 1);
	SetConVarInt(FindConVar("tf_clamp_airducks"), 1);
	SetConVarInt(FindConVar("tf_ctf_bonus_time"), 10);
	SetConVarInt(FindConVar("tf_damage_disablespread"), 0);
	SetConVarInt(FindConVar("tf_forced_holiday"), 0);
	SetConVarInt(FindConVar("tf_flag_caps_per_round"), 3);
	SetConVarInt(FindConVar("tf_medieval"), 0);
	SetConVarInt(FindConVar("tf_overtime_nag"), 0);
	SetConVarInt(FindConVar("tf_playergib"), 1);
	SetConVarInt(FindConVar("tf_teamtalk"), 0);
	SetConVarInt(FindConVar("tf_tournament_classlimit_scout"), -1);
	SetConVarInt(FindConVar("tf_tournament_classlimit_soldier"), -1);
	SetConVarInt(FindConVar("tf_tournament_classlimit_pyro"), -1);
	SetConVarInt(FindConVar("tf_tournament_classlimit_demoman"), -1);
	SetConVarInt(FindConVar("tf_tournament_classlimit_heavy"), -1);
	SetConVarInt(FindConVar("tf_tournament_classlimit_engineer"), -1);
	SetConVarInt(FindConVar("tf_tournament_classlimit_medic"), -1);
	SetConVarInt(FindConVar("tf_tournament_classlimit_spy"), -1);
	SetConVarInt(FindConVar("tf_tournament_classlimit_sniper"), -1);
	SetConVarInt(FindConVar("tf_tournament_hide_domination_icons"), 0);
	SetConVarInt(FindConVar("tf_use_fixed_weaponspreads"), 0);
	SetConVarInt(FindConVar("tf_weapon_criticals"), 1);


	SetConVarInt(FindConVar("mp_allowspectators"), 1);
	SetConVarInt(FindConVar("mp_autoteambalance"), 1);
	SetConVarInt(FindConVar("mp_bonusroundtime"), 15);
	SetConVarInt(FindConVar("mp_chattime"), 10);
	SetConVarInt(FindConVar("mp_disable_respawn_times"), 0);
	SetConVarInt(FindConVar("mp_enableroundwaittime"), 1);
	SetConVarInt(FindConVar("mp_fadetoblack"), 0);
	SetConVarInt(FindConVar("mp_forceautoteam"), 0);
	SetConVarInt(FindConVar("mp_forcecamera"), 1);
	SetConVarInt(FindConVar("mp_forcerespawn"), 1);
	SetConVarInt(FindConVar("mp_fraglimit"), 0);
	SetConVarInt(FindConVar("mp_friendlyfire"), 0);
	SetConVarInt(FindConVar("mp_highlander"), 0);
	SetConVarInt(FindConVar("mp_idledealmethod"), 1);
	SetConVarInt(FindConVar("mp_idlemaxtime"), 3);
	SetConVarInt(FindConVar("mp_match_end_at_timelimit"), 0);
	SetConVarInt(FindConVar("mp_respawnwavetime"), 10);
	SetConVarInt(FindConVar("mp_show_voice_icons"), 1);
	SetConVarInt(FindConVar("mp_stalemate_enable"), 0);
	SetConVarInt(FindConVar("mp_stalemate_timelimit"), 240);
	SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 1);
	SetConVarInt(FindConVar("mp_time_between_capscoring"), 30);
	SetConVarInt(FindConVar("mp_tournament"), 0);
	SetConVarInt(FindConVar("mp_tournament_allow_non_admin_restart"), 1);


	SetConVarInt(FindConVar("mp_maxrounds"), 0);
	SetConVarInt(FindConVar("mp_timelimit"), 0);
	SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
	SetConVarInt(FindConVar("mp_windifference"), 0);
	SetConVarInt(FindConVar("mp_windifference_min"), 0);
	SetConVarInt(FindConVar("mp_winlimit"), 0);


	SetConVarInt(FindConVar("sv_allow_color_correction"), 1);
	SetConVarInt(FindConVar("sv_allow_voice_from_file"), 1);
	SetConVarInt(FindConVar("sv_allow_votes"), 1);
	SetConVarInt(FindConVar("sv_allow_wait_command"), 1);
	SetConVarInt(FindConVar("sv_allowdownload"), 1);
	SetConVarInt(FindConVar("sv_allowupload"), 1);
	SetConVarInt(FindConVar("sv_alltalk"), 0);
	SetConVarInt(FindConVar("sv_cacheencodedents"), 1);
	SetConVarInt(FindConVar("sv_cheats"), 0);
	SetConVarInt(FindConVar("sv_consistency"), 1);
	SetConVarInt(FindConVar("sv_enableoldqueries"), 0);
	SetConVarInt(FindConVar("sv_forcepreload"), 1);
	SetConVarInt(FindConVar("sv_gravity"), 800);
	SetConVarInt(FindConVar("sv_lan"), 0);
	SetConVarFloat(FindConVar("sv_max_connects_sec"), 2.0);
	SetConVarInt(FindConVar("sv_max_connects_window"), 4);
	SetConVarInt(FindConVar("sv_max_connects_sec_global"), 0);
	SetConVarInt(FindConVar("sv_pausable"), 0);
	ServerCommand("sv_pure 0");
	SetConVarInt(FindConVar("sv_pure_kick_clients"), 1);
	SetConVarInt(FindConVar("sv_pure_trace"), 0);
	SetConVarInt(FindConVar("sv_rcon_log"), 1);
	SetConVarInt(FindConVar("sv_showladders"), 0);
	SetConVarInt(FindConVar("sv_specaccelerate"), 5);
	SetConVarInt(FindConVar("sv_specnoclip"), 1);
	SetConVarInt(FindConVar("sv_specspeed"), 3);
	SetConVarInt(FindConVar("sv_turbophysics"), 0);
	SetConVarInt(FindConVar("sv_use_steam_voice"), 1);
	SetConVarInt(FindConVar("sv_voiceenable"), 1);
	SetConVarInt(FindConVar("sv_vote_allow_spectators"), 0);
	SetConVarInt(FindConVar("sv_vote_failure_timer"), 300);
	SetConVarInt(FindConVar("sv_vote_issue_changelevel_allowed"), 0);
	SetConVarInt(FindConVar("sv_vote_issue_kick_allowed"), 0);
	SetConVarInt(FindConVar("sv_vote_issue_nextlevel_allowed"), 1);
	SetConVarInt(FindConVar("sv_vote_issue_nextlevel_allowextend"), 1);
	SetConVarInt(FindConVar("sv_vote_issue_nextlevel_choicesmode"), 1);
	SetConVarInt(FindConVar("sv_vote_issue_nextlevel_prevent_change"), 1);
	SetConVarInt(FindConVar("sv_vote_issue_restart_game_allowed"), 1);
	SetConVarInt(FindConVar("sv_vote_issue_scramble_teams_allowed"), 1);
	SetConVarInt(FindConVar("sv_vote_kick_ban_duration"), 1);

	
	SetConVarInt(FindConVar("sv_client_cmdrate_difference"), 20);
	SetConVarInt(FindConVar("sv_client_max_interp_ratio"), 5);
	SetConVarInt(FindConVar("sv_client_min_interp_ratio"), 1);
	SetConVarInt(FindConVar("sv_client_predict"), -1);
	SetConVarInt(FindConVar("sv_maxrate"), 0);
	SetConVarInt(FindConVar("sv_maxupdaterate"), 66);
	SetConVarInt(FindConVar("sv_maxcmdrate"), 66);
	SetConVarInt(FindConVar("sv_mincmdrate"), 10);
	SetConVarInt(FindConVar("sv_minrate"), 3500);
	SetConVarInt(FindConVar("sv_minupdaterate"), 10);


	SetConVarInt(FindConVar("tv_delay"), 120);
	SetConVarInt(FindConVar("tv_maxrate"), 8000);
	SetConVarInt(FindConVar("tv_delaymapchange"), 0);
	
	GetConVarString(FindConVar("servercfgfile"), sConfig, sizeof(sConfig));
	ServerCommand("exec %s", sConfig);
	PrintToChatAll("\x04[MatchMod]\x01 Restoring Server Configuration");
}
	
ExecuteNativeConfig(iState) {

	new String:sConfig[25];
	// Pick-up Game Configuration for MatchMod
	// updated 3-Mar-2012
	
	// The custom.cfg is still stored as a config to allow server operators to modify some settings easily if it's present
	strcopy(sConfig, sizeof(sConfig), "cfg/matchmod/custom.cfg");
	if (FileExists(sConfig)) {
		ServerCommand("exec \"%s\"", sConfig[4]);
	}
	
	SetConVarInt(FindConVar("decalfrequency"), 60);
	SetConVarInt(FindConVar("host_framerate"), 0);


	SetConVarInt(FindConVar("tf_allow_player_use"), 0);
	SetConVarInt(FindConVar("tf_allow_taunt_switch"), 0);
	SetConVarInt(FindConVar("tf_arena_first_blood"), 0);
	SetConVarInt(FindConVar("tf_arena_round_time"), 0);
	SetConVarInt(FindConVar("tf_arena_use_queue"), 0);
	SetConVarInt(FindConVar("tf_clamp_airducks"), 1);
	SetConVarInt(FindConVar("tf_ctf_bonus_time"), 0);
	SetConVarInt(FindConVar("tf_damage_disablespread"), 1);
	SetConVarInt(FindConVar("tf_forced_holiday"), 0);
	SetConVarInt(FindConVar("tf_flag_caps_per_round"), 0);
	SetConVarInt(FindConVar("tf_medieval"), 0);
	SetConVarInt(FindConVar("tf_overtime_nag"), 0);
	SetConVarInt(FindConVar("tf_playergib"), 1);
	SetConVarInt(FindConVar("tf_teamtalk"), 1);
	SetConVarInt(FindConVar("tf_tournament_classlimit_scout"), 2);
	SetConVarInt(FindConVar("tf_tournament_classlimit_soldier"), 2);
	SetConVarInt(FindConVar("tf_tournament_classlimit_pyro"), 2);
	SetConVarInt(FindConVar("tf_tournament_classlimit_demoman"), 1);
	SetConVarInt(FindConVar("tf_tournament_classlimit_heavy"), 1);
	SetConVarInt(FindConVar("tf_tournament_classlimit_engineer"), 2);
	SetConVarInt(FindConVar("tf_tournament_classlimit_medic"), 1);
	SetConVarInt(FindConVar("tf_tournament_classlimit_spy"), 2);
	SetConVarInt(FindConVar("tf_tournament_classlimit_sniper"), 2);
	SetConVarInt(FindConVar("tf_tournament_hide_domination_icons"), 1);
	SetConVarInt(FindConVar("tf_use_fixed_weaponspreads"), 1);
	SetConVarInt(FindConVar("tf_weapon_criticals"), 0);


	SetConVarInt(FindConVar("mp_allowspectators"), 1);
	SetConVarInt(FindConVar("mp_autoteambalance"), 0);
	SetConVarInt(FindConVar("mp_bonusroundtime"), 10);
	SetConVarInt(FindConVar("mp_chattime"), 15);
	SetConVarInt(FindConVar("mp_disable_respawn_times"), 0);
	SetConVarInt(FindConVar("mp_enableroundwaittime"), 1);
	SetConVarInt(FindConVar("mp_fadetoblack"), 0);
	SetConVarInt(FindConVar("mp_forceautoteam"), 0);
	SetConVarInt(FindConVar("mp_forcecamera"), 1);
	SetConVarInt(FindConVar("mp_forcerespawn"), 1);
	SetConVarInt(FindConVar("mp_fraglimit"), 0);
	SetConVarInt(FindConVar("mp_friendlyfire"), 0);
	SetConVarInt(FindConVar("mp_highlander"), 0);
	SetConVarInt(FindConVar("mp_idledealmethod"), 0);
	SetConVarInt(FindConVar("mp_idlemaxtime"), 0);
	SetConVarInt(FindConVar("mp_match_end_at_timelimit"), 1);
	SetConVarInt(FindConVar("mp_respawnwavetime"), 10);
	SetConVarInt(FindConVar("mp_show_voice_icons"), 0);
	SetConVarInt(FindConVar("mp_stalemate_enable"), 0);
	SetConVarInt(FindConVar("mp_stalemate_timelimit"), 240);
	SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 0);
	SetConVarInt(FindConVar("mp_time_between_capscoring"), 30);
	SetConVarInt(FindConVar("mp_tournament"), 1);
	SetConVarInt(FindConVar("mp_tournament_allow_non_admin_restart"), 0);


	SetConVarInt(FindConVar("mp_maxrounds"), 0);
	SetConVarInt(FindConVar("mp_timelimit"), 0);
	SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
	SetConVarInt(FindConVar("mp_windifference"), 0);
	SetConVarInt(FindConVar("mp_windifference_min"), 0);
	SetConVarInt(FindConVar("mp_winlimit"), 0);


	SetConVarInt(FindConVar("sv_allow_color_correction"), 0);
	SetConVarInt(FindConVar("sv_allow_voice_from_file"), 0);
	SetConVarInt(FindConVar("sv_allow_votes"), 0);
	SetConVarInt(FindConVar("sv_allow_wait_command"), 0);
	SetConVarInt(FindConVar("sv_allowdownload"), 1);
	SetConVarInt(FindConVar("sv_allowupload"), 0);
	SetConVarInt(FindConVar("sv_alltalk"), 1);
	SetConVarInt(FindConVar("sv_cacheencodedents"), 1);
	SetConVarInt(FindConVar("sv_cheats"), 0);
	SetConVarInt(FindConVar("sv_consistency"), 1);
	SetConVarInt(FindConVar("sv_enableoldqueries"), 0);
	SetConVarInt(FindConVar("sv_forcepreload"), 1);
	SetConVarInt(FindConVar("sv_gravity"), 800);
	SetConVarInt(FindConVar("sv_lan"), 0);
	SetConVarFloat(FindConVar("sv_max_connects_sec"), 2.0);
	SetConVarInt(FindConVar("sv_max_connects_window"), 4);
	SetConVarInt(FindConVar("sv_max_connects_sec_global"), 0);
	SetConVarInt(FindConVar("sv_pausable"), 1);
	ServerCommand("sv_pure 2");
	SetConVarInt(FindConVar("sv_pure_kick_clients"), 1);
	SetConVarInt(FindConVar("sv_pure_trace"), 0);
	SetConVarInt(FindConVar("sv_rcon_log"), 1);
	SetConVarInt(FindConVar("sv_showladders"), 0);
	SetConVarInt(FindConVar("sv_specaccelerate"), 5);
	SetConVarInt(FindConVar("sv_specnoclip"), 1);
	SetConVarInt(FindConVar("sv_specspeed"), 3);
	SetConVarInt(FindConVar("sv_turbophysics"), 1);
	SetConVarInt(FindConVar("sv_use_steam_voice"), 1);
	SetConVarInt(FindConVar("sv_voiceenable"), 1);
	SetConVarInt(FindConVar("sv_vote_allow_spectators"), 0);
	SetConVarInt(FindConVar("sv_vote_failure_timer"), 300);
	SetConVarInt(FindConVar("sv_vote_issue_changelevel_allowed"), 0);
	SetConVarInt(FindConVar("sv_vote_issue_kick_allowed"), 0);
	SetConVarInt(FindConVar("sv_vote_issue_nextlevel_allowed"), 0);
	SetConVarInt(FindConVar("sv_vote_issue_nextlevel_allowextend"), 0);
	SetConVarInt(FindConVar("sv_vote_issue_nextlevel_choicesmode"), 0);
	SetConVarInt(FindConVar("sv_vote_issue_nextlevel_prevent_change"), 0);
	SetConVarInt(FindConVar("sv_vote_issue_restart_game_allowed"), 0);
	SetConVarInt(FindConVar("sv_vote_issue_scramble_teams_allowed"), 0);
	SetConVarInt(FindConVar("sv_vote_kick_ban_duration"), 0);

	
	SetConVarInt(FindConVar("sv_client_cmdrate_difference"), 30);
	SetConVarInt(FindConVar("sv_client_max_interp_ratio"), 1);
	SetConVarInt(FindConVar("sv_client_min_interp_ratio"), 1);
	SetConVarInt(FindConVar("sv_client_predict"), 1);
	SetConVarInt(FindConVar("sv_maxrate"), 100000);
	SetConVarInt(FindConVar("sv_maxupdaterate"), 66);
	SetConVarInt(FindConVar("sv_maxcmdrate"), 66);
	SetConVarInt(FindConVar("sv_mincmdrate"), 50);
	SetConVarInt(FindConVar("sv_minrate"), 30000);
	SetConVarInt(FindConVar("sv_minupdaterate"), 50);


	SetConVarInt(FindConVar("tv_delay"), 120);
	SetConVarInt(FindConVar("tv_maxrate"), 8000);
	SetConVarInt(FindConVar("tv_delaymapchange"), 1);


	
	switch (g_iMapType)
	{
		case PUSH:
		{
			if (iState == REGULATION) {
				SetConVarInt(FindConVar("mp_timelimit"), 30);
				if (g_bAllowHalf) {
					SetConVarInt(FindConVar("mp_winlimit"), g_iHalfScore);
				} 
				else {
					SetConVarInt(FindConVar("mp_winlimit"), g_iMaxScore);
				}
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				ServerCommand("mp_tournament_restart");
				
				PrintToChatAll("\x04[MatchMod]\x01 Push config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 10);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				PrintToChatAll("\x04[MatchMod]\x01 Push overtime config loaded");
			}
		}
		case STOPWATCH:
		{
			if (iState == REGULATION) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 0);
				SetConVarInt(FindConVar("mp_maxrounds"), 2);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 1);
				
				ServerCommand("mp_tournament_restart");
				
				PrintToChatAll("\x04[MatchMod]\x01 Stopwatch config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 0);
				SetConVarInt(FindConVar("mp_maxrounds"), 2);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 1);
				
				PrintToChatAll("\x04[MatchMod]\x01 Stopwatch overtime config loaded");
			}
		}
		case CTF:
		{
			if (iState == REGULATION) {
				SetConVarInt(FindConVar("mp_timelimit"), 20);
				SetConVarInt(FindConVar("mp_winlimit"), 0);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				ServerCommand("mp_tournament_restart");
				
				PrintToChatAll("\x04[MatchMod]\x01 CTF config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 20);
				SetConVarInt(FindConVar("mp_winlimit"), 0);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				PrintToChatAll("\x04[MatchMod]\x01 CTF overtime config loaded");
			}
		}
		case PAYLOAD:
		{
			if (iState == REGULATION) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 0);
				SetConVarInt(FindConVar("mp_maxrounds"), 2);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 1);
				
				ServerCommand("mp_tournament_restart");
				
				PrintToChatAll("\x04[MatchMod]\x01 Payload config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 0);
				SetConVarInt(FindConVar("mp_maxrounds"), 2);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 1);
				
				PrintToChatAll("\x04[MatchMod]\x01 Payload overtime config loaded");
			}
		}
		case PAYLOADRACE:
		{
			if (iState == REGULATION) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				ServerCommand("mp_tournament_restart");
				
				PrintToChatAll("\x04[MatchMod]\x01 Payload Race config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				PrintToChatAll("\x04[MatchMod]\x01 Payload Race overtime config loaded");
			}
		}
		case KOTH:
		{
			if (iState == REGULATION) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				if (g_bAllowHalf) {
					SetConVarInt(FindConVar("mp_winlimit"), g_iHalfScore);
				} 
				else {
					SetConVarInt(FindConVar("mp_winlimit"), g_iMaxScore);
				}
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				ServerCommand("mp_tournament_restart");
				
				PrintToChatAll("\x04[MatchMod]\x01 KotH config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);

				PrintToChatAll("\x04[MatchMod]\x01 KotH overtime config loaded");
			}
		}
		case ARENA:
		{
			if (iState == REGULATION) {
				SetConVarInt(FindConVar("mp_timelimit"), 30);
				SetConVarInt(FindConVar("mp_winlimit"), 10);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				ServerCommand("mp_tournament_restart");
				
				PrintToChatAll("\x04[MatchMod]\x01 Arena config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 10);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);

				PrintToChatAll("\x04[MatchMod]\x01 Arena overtime config loaded");
			}
		}
		case TC:
		{
			if (iState == REGULATION) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				ServerCommand("mp_tournament_restart");
				
				PrintToChatAll("\x04[MatchMod]\x01 Territory Control config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);

				PrintToChatAll("\x04[MatchMod]\x01 Territory Control overtime config loaded");
			}
		}
	}
}

ExecuteWhitelist() {

	new String:sWhitelist[40];
	
	Format(sWhitelist, sizeof(sWhitelist), "cfg/matchmod/%s_whitelist.txt", g_sConfigSet);
	
	if (!FileExists(sWhitelist)) {
		PrintToChatAll("\x04[MatchMod]\x01 Unable to find %s_whitelist.txt", g_sConfigSet);
		PrintToChatAll("\x04[MatchMod]\x01 Reverting to default_whitelist.txt");
		ServerCommand("exec matchmod/default-whitelist.cfg");
	}
	else {
		PrintToChatAll("\x04[MatchMod]\x01 Assigning %s_whitelist.txt", g_sConfigSet);
		ServerCommand("exec %s", sWhitelist[4]);
	}
}