/*
===============================================================================================================
MatchMod for Team Fortress 2

NAME			: leagues.sp        
VERSION			: 2.0
AUTHOR			: Charles 'Hawkeye' Mabbott
DESCRIPTION		: Script designed to houe all theleague specific commands and configuration files
REQUIREMENTS	: Sourcemod 1.2+

===============================================================================================================
*/


/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
ExecuteOvertime()

Determines the currently running ruleset and execute the appropriate overtime configuration
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
ExecuteOvertime() {
	if (strcmp(g_sConfigSet, "default", false) == 0) {
		ExecuteNativeConfig(OVERTIME);
	}
	else if (strcmp(g_sConfigSet, "lobby", false) == 0) {
		// Do nothing, no overtime in a lobby
	}
	else if (strcmp(g_sConfigSet, "esea", false) == 0) {
		ExecuteESEAConfig(OVERTIME);
	}
}


/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Action:Command_MatchModESEA(client, args)

Begins a match designed around ESEA regulations
---------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public Action:Command_MatchModESEA(client, args) {

	if (CheckCommandAccess(client, "sm_pug", ADMFLAG_RESERVATION, true)) {
		if (args < 1) {
			ReplyToCommand(client, "[MatchMod] Usage: sm_esea <password>");
			return Plugin_Handled;
		}
		
		if (g_iMatchState > 0) {
			ReplyToCommand(client, "[MatchMod] A Game is already in progress.");
			return Plugin_Handled;
		}

		switch (g_iMapType)
		{
			case PUSH:
			{
				g_iHalfScore = 3;
				g_iMaxScore = 5;
			}
			case STOPWATCH:
			{
			}
			case CTF:
			{
			}
			case PAYLOAD:
			{
				ReplyToCommand(client, "[MatchMod] ESEA does not support Payload.");
				return Plugin_Handled;
			}
			case PAYLOADRACE:
			{
				ReplyToCommand(client, "[MatchMod] ESEA does not support Payload Race.");
				return Plugin_Handled;
			}
			case KOTH:
			{
				g_iHalfScore = 3;
				g_iMaxScore = 5;
			}
			case ARENA:
			{
				ReplyToCommand(client, "[MatchMod] ESEA does not support Arena.");
				return Plugin_Handled;
			}
			case TC:
			{
				ReplyToCommand(client, "[MatchMod] ESEA does not support Territory Control.");
				return Plugin_Handled;
			}
		}
		
		decl String:sPassword[64];
		
		strcopy(g_sConfigSet, sizeof(g_sConfigSet), "esea");
		GetCmdArg(1, sPassword, sizeof(sPassword));
		ServerCommand("sv_password %s", sPassword);		
		ExecuteWhitelist();
		ExecuteESEAConfig(REGULATION);
		g_bAllowOT = true;
		g_bAllowReady = true;
		g_bAllowHalf = true;
		g_bSwapTeams = true;
		g_iMinPlayers = 5;
		g_iAutoPlayers = 6;
		g_iMatchState = 1;
		AdvanceMatchState();
	}
	return Plugin_Handled;
}


ExecuteESEAConfig(iState) {

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
				
				PrintToChatAll("\x04[MatchMod]\x01 ESEA Push config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				PrintToChatAll("\x04[MatchMod]\x01 ESEA Push overtime config loaded");
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
				
				PrintToChatAll("\x04[MatchMod]\x01 ESEA Stopwatch config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 0);
				SetConVarInt(FindConVar("mp_maxrounds"), 2);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 1);
				
				PrintToChatAll("\x04[MatchMod]\x01 ESEA Stopwatch overtime config loaded");
			}
		}
		case CTF:
		{
			if (iState == REGULATION) {
				SetConVarInt(FindConVar("mp_timelimit"), 20);
				SetConVarInt(FindConVar("mp_winlimit"), 0);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				ServerCommand("mp_tournament_restart");
				
				PrintToChatAll("\x04[MatchMod]\x01 ESEA CTF config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 10);
				SetConVarInt(FindConVar("mp_winlimit"), 0);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				PrintToChatAll("\x04[MatchMod]\x01 ESEA CTF overtime config loaded");
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
				
				PrintToChatAll("\x04[MatchMod]\x01 ESEA Payload config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 0);
				SetConVarInt(FindConVar("mp_maxrounds"), 2);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 1);
				
				PrintToChatAll("\x04[MatchMod]\x01 ESEA Payload overtime config loaded");
			}
		}
		case PAYLOADRACE:
		{
			if (iState == REGULATION) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				ServerCommand("mp_tournament_restart");
				
				PrintToChatAll("\x04[MatchMod]\x01 ESEA Payload Race config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				PrintToChatAll("\x04[MatchMod]\x01 ESEA Payload Race overtime config loaded");
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
				
				PrintToChatAll("\x04[MatchMod]\x01 ESEA KotH config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);

				PrintToChatAll("\x04[MatchMod]\x01 ESEA KotH overtime config loaded");
			}
		}
		case ARENA:
		{
			if (iState == REGULATION) {
				SetConVarInt(FindConVar("mp_timelimit"), 30);
				SetConVarInt(FindConVar("mp_winlimit"), 10);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				ServerCommand("mp_tournament_restart");
				
				PrintToChatAll("\x04[MatchMod]\x01 ESEA Arena config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 10);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);

				PrintToChatAll("\x04[MatchMod]\x01 ESEA Arena overtime config loaded");
			}
		}
		case TC:
		{
			if (iState == REGULATION) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);
				
				ServerCommand("mp_tournament_restart");
				
				PrintToChatAll("\x04[MatchMod]\x01 ESEA Territory Control config loaded");
			}
			else if (iState == OVERTIME) {
				SetConVarInt(FindConVar("mp_timelimit"), 0);
				SetConVarInt(FindConVar("mp_winlimit"), 1);
				SetConVarInt(FindConVar("mp_tournament_stopwatch"), 0);

				PrintToChatAll("\x04[MatchMod]\x01 ESEA Territory Control overtime config loaded");
			}
		}
	}
}