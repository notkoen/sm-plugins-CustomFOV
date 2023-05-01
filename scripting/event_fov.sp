#pragma newdecls required
#pragma semicolon 1

#include <sdktools>
#include <sourcemod>

ConVar g_cvFOV;
int g_iFOV;

public Plugin myinfo =
{
	name = "[Event] Custom FOV",
	author = "koen",
	description = "",
	version = "",
	url = "https://github.com/notkoen"
};

public void OnPluginStart()
{
	g_cvFOV = CreateConVar("sm_event_fov", "90", "Set desired event field of view", _, true, 35.0, true, 150.0); // Anything past 150 fucks up the game
	HookConVarChange(g_cvFOV, OnConvarChange);
	g_iFOV = g_cvFOV.IntValue;
	AutoExecConfig(true);

	RegAdminCmd("sm_setfov", Command_Fov, ADMFLAG_ROOT, "Force change FOV");

	HookEvent("player_spawn", Event_OnSpawn);
}

public void OnConvarChange(Handle cvar, const char[] oldValue, const char[] newValue)
{
	g_iFOV = g_cvFOV.IntValue;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
			SetFov(i, g_iFOV);
	}
}

public Action Command_Fov(int client, int args)
{
	if (args < 1)
	{
		PrintToChat(client, " \x04[FOV] \x01Usage: sm_fov [35-150]");
		return Plugin_Handled;
	}

	g_iFOV = GetCmdArgInt(1);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
			SetFov(i, g_iFOV);
	}
	PrintToChat(client, " \x04[FOV] \x01Default field of view has been set to: \x04%d", g_iFOV);
	return Plugin_Continue;
}

public void Event_OnSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	CreateTimer(0.25, FixUpFov, GetClientUserId(client));
}

public Action FixUpFov(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
		return Plugin_Stop;

	if (!IsClientInGame(client))
		return Plugin_Stop;

	SetFov(client, g_iFOV);
	return Plugin_Stop;
}

void SetFov(int client, int fov)
{
	SetEntProp(client, Prop_Send, "m_iFOV", fov);
	SetEntProp(client, Prop_Send, "m_iDefaultFOV", fov);
}