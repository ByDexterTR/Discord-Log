#include <sourcemod>
#include <discord>
#include <steamworks>

#pragma semicolon 1
#pragma newdecls required

char WebHook[192], clientresim[65][192], ApiKey[33];

ConVar webhook = null, devapikey = null;

#define LoopClientsValid(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsValidClient(%1))

public Plugin myinfo = 
{
	name = "Gelişmiş Discord Chat Mesajı", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	LoopClientsValid(i)
	{
		OnClientPostAdminCheck(i);
	}
	devapikey = CreateConVar("sm_bydexter_apikey", "", "https://steamcommunity.com/dev/apikey Siteden api key alınız.", FCVAR_PROTECTED); devapikey.GetString(ApiKey, 33); devapikey.AddChangeHook(devapikeyget);
	webhook = CreateConVar("sm_discord-chat_webhook", "", "Discord Webhook"); webhook.GetString(WebHook, 192); webhook.AddChangeHook(webhookget);
	AutoExecConfig(true, "discord-chat", "ByDexter");
}

public void devapikeyget(ConVar convar, const char[] oldValue, const char[] newValue) { webhook.GetString(ApiKey, 33); }
public void webhookget(ConVar convar, const char[] oldValue, const char[] newValue) { webhook.GetString(WebHook, 192); }

public void OnClientPostAdminCheck(int client)
{
	if (IsValidClient(client))
	{
		clientresim[client] = "https://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg";
		int Len = strlen(ApiKey);
		if (Len >= 30)
		{
			RequestAvatar(client);
		}
	}
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if (IsValidClient(client))
	{
		char name[128], steamid[32], format[256];
		GetClientName(client, name, 128);
		GetClientAuthId(client, AuthId_Steam2, steamid, 32);
		GetCommunityID(steamid, format, 256);
		DiscordWebHook hook = new DiscordWebHook(WebHook);
		hook.SlackMode = true;
		MessageEmbed Embed = new MessageEmbed();
		Format(format, 256, "http://steamcommunity.com/profiles/%s", format);
		Embed.SetTitleLink(format);
		Format(format, 256, "%s | %s", name, steamid);
		Embed.SetTitle(format);
		Embed.AddField(sArgs, " ", false);
		FormatTime(format, 256, "%F %R", GetTime());
		Format(format, 256, "%s", format);
		Embed.SetFooter(format);
		Embed.SetThumb(clientresim[client]);
		int team = GetClientTeam(client);
		if (team == 3)
		{
			Embed.SetColor("#0080f6");
		}
		else if (team == 2)
		{
			Embed.SetColor("#f68a00");
		}
		else
		{
			Embed.SetColor("#ebf9ff");
		}
		hook.Embed(Embed);
		hook.Send();
		delete hook;
	}
}

bool GetCommunityID(char[] AuthID, char[] FriendID, int size)
{
	if (strlen(AuthID) < 11 || AuthID[0] != 'S' || AuthID[6] == 'I')
	{
		FriendID[0] = 0;
		return false;
	}
	int iUpper = 765611979;
	int iFriendID = StringToInt(AuthID[10]) * 2 + 60265728 + AuthID[8] - 48;
	int iDiv = iFriendID / 100000000;
	int iIdx = 9 - (iDiv ? iDiv / 10 + 1:0);
	iUpper += iDiv;
	IntToString(iFriendID, FriendID[iIdx], size - iIdx);
	iIdx = FriendID[9];
	IntToString(iUpper, FriendID, size);
	FriendID[9] = iIdx;
	return true;
}

void RequestAvatar(int client)
{
	char auth[64];
	GetClientAuthId(client, AuthId_SteamID64, auth, 64);
	Handle request = CreateRequest_RequestAvatar(client, auth);
	SteamWorks_SendHTTPRequest(request);
}

Handle CreateRequest_RequestAvatar(int client, char[] auth)
{
	char request_url[512];
	
	Format(request_url, sizeof(request_url), "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&steamids=%s&format=json", ApiKey, auth);
	Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, request_url);
	
	SteamWorks_SetHTTPRequestContextValue(request, GetClientUserId(client));
	SteamWorks_SetHTTPCallbacks(request, RequestAvatar_OnHTTPResponse);
	return request;
}

public int RequestAvatar_OnHTTPResponse(Handle request, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, int userid) {
	
	if (!bRequestSuccessful || eStatusCode != k_EHTTPStatusCode200OK) {
		PrintToServer("HTTP Request to fetch Client's Profile data failed!");
		delete request;
		return;
	}
	
	int client = GetClientOfUserId(userid);
	
	if (!client) {
		delete request;
		return;
	}
	
	int bufferSize;
	
	SteamWorks_GetHTTPResponseBodySize(request, bufferSize);
	
	char[] responseBody = new char[bufferSize];
	SteamWorks_GetHTTPResponseBodyData(request, responseBody, bufferSize);
	delete request;
	
	char sArray[10][256];
	ExplodeString(responseBody, ",", sArray, sizeof(sArray), sizeof(sArray[]));
	if (StrContains(sArray[0], "avatarfull") != -1)
	{
		ReplaceString(sArray[1], 256, "\"avatarfull\":\"", "");
		ReplaceString(sArray[1], 256, "\"", "");
		Format(clientresim[client], 256, "%s", sArray[1]);
	}
	else if (StrContains(sArray[1], "avatarfull") != -1)
	{
		ReplaceString(sArray[1], 256, "\"avatarfull\":\"", "");
		ReplaceString(sArray[1], 256, "\"", "");
		Format(clientresim[client], 256, "%s", sArray[1]);
	}
	else if (StrContains(sArray[2], "avatarfull") != -1)
	{
		ReplaceString(sArray[2], 256, "\"avatarfull\":\"", "");
		ReplaceString(sArray[2], 256, "\"", "");
		Format(clientresim[client], 256, "%s", sArray[2]);
	}
	else if (StrContains(sArray[3], "avatarfull") != -1)
	{
		ReplaceString(sArray[3], 256, "\"avatarfull\":\"", "");
		ReplaceString(sArray[3], 256, "\"", "");
		Format(clientresim[client], 256, "%s", sArray[3]);
	}
	else if (StrContains(sArray[4], "avatarfull") != -1)
	{
		ReplaceString(sArray[4], 256, "\"avatarfull\":\"", "");
		ReplaceString(sArray[4], 256, "\"", "");
		Format(clientresim[client], 256, "%s", sArray[4]);
	}
	else if (StrContains(sArray[5], "avatarfull") != -1)
	{
		ReplaceString(sArray[5], 256, "\"avatarfull\":\"", "");
		ReplaceString(sArray[5], 256, "\"", "");
		Format(clientresim[client], 256, "%s", sArray[5]);
	}
	else if (StrContains(sArray[6], "avatarfull") != -1)
	{
		ReplaceString(sArray[6], 256, "\"avatarfull\":\"", "");
		ReplaceString(sArray[6], 256, "\"", "");
		Format(clientresim[client], 256, "%s", sArray[6]);
	}
	else if (StrContains(sArray[7], "avatarfull") != -1)
	{
		ReplaceString(sArray[7], 256, "\"avatarfull\":\"", "");
		ReplaceString(sArray[7], 256, "\"", "");
		Format(clientresim[client], 256, "%s", sArray[7]);
	}
	else if (StrContains(sArray[8], "avatarfull") != -1)
	{
		ReplaceString(sArray[8], 256, "\"avatarfull\":\"", "");
		ReplaceString(sArray[8], 256, "\"", "");
		Format(clientresim[client], 256, "%s", sArray[8]);
	}
	else if (StrContains(sArray[9], "avatarfull") != -1)
	{
		ReplaceString(sArray[9], 256, "\"avatarfull\":\"", "");
		ReplaceString(sArray[9], 256, "\"", "");
		Format(clientresim[client], 256, "%s", sArray[9]);
	}
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
} 