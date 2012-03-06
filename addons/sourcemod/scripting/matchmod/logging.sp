/*
===============================================================================================================
MatchMod for Team Fortress 2

NAME			: logging.sp        
VERSION			: 2.0
AUTHOR			: Charles 'Hawkeye' Mabbott
DESCRIPTION		: Script designed to handle the extra logging used by stat parsers
REQUIREMENTS	: Sourcemod 1.2+

===============================================================================================================
*/

DisableLogging() {
	// PrintToChatAll("\x04[MatchMod]\x01 %T", "Disable log", LANG_SERVER);
	ServerCommand("log off");
}


EnableLogging() {
	// PrintToChatAll("\x04[MatchMod]\x01 %T", "Enable log", LANG_SERVER);
	ServerCommand("log on");
}