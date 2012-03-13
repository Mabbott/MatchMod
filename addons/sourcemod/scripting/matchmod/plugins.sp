/*
===============================================================================================================
MatchMod for Team Fortress 2

NAME			: plugins.sp        
VERSION			: 2.0
AUTHOR			: Charles 'Hawkeye' Mabbott
DESCRIPTION		: Script designed to handle plugin management for MatchMod
REQUIREMENTS	: Sourcemod 1.2+

===============================================================================================================
*/

// This array stores all the "safe" plugins that have been deemed to work with Matchmod
new String:g_sWhitelist[7][64] = {
				"admin-flatfile",
				"adminhelp",
				"adminmenu",
				"basecommands",
				"basebans",
				"sourcebans",
				"matchmod"
		};

public Event_RoundRestartSeconds(Handle:event, const String:name[], bool:dontBroadcast) {
	// Here we are going to want to assess all loaded plugins and unload anything that might not work for a Match
}