#include <sourcemod>
#include <discord>

#pragma semicolon 1
#pragma newdecls required

char WebHook[192];

ConVar webhook = null;

public Plugin myinfo = 
{
	name = "Gelişmiş Discord Ban Log", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	webhook = CreateConVar("sm_discord-ban_webhook", "", "Discord Webhook"); webhook.GetString(WebHook, 192); webhook.AddChangeHook(webhookget);
	AutoExecConfig(true, "ByDexter", "discord-ban");
}

public void webhookget(ConVar convar, const char[] oldValue, const char[] newValue) { webhook.GetString(WebHook, 192); }

void SendDiscordBan(int client, int target, char mins[64], const char[] reason)
{
	char TargetSteamid[128];
	GetClientAuthId(target, AuthId_Steam2, TargetSteamid, 128);
	char TargetName[128];
	GetClientName(target, TargetName, 128);
	char TargetSteam[128];
	GetCommunityID(TargetSteamid, TargetSteam, 128);
	Format(TargetSteam, 128, "http://steamcommunity.com/profiles/%s", TargetSteam);
	
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(WebHook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#a300ff");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", TargetName, TargetSteamid, TargetSteam);
	Embed.AddField(":small_orange_diamond: Ceza Alan:", EmbedFormat, true);
	if (IsValidClient(client))
	{
		char ClientSteamid[128];
		GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
		char ClientName[128];
		GetClientName(client, ClientName, 128);
		char ClientSteam[128];
		GetCommunityID(ClientSteamid, ClientSteam, 128);
		Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
		
		Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
		Embed.AddField(":small_blue_diamond: Yetkili:", EmbedFormat, true);
	}
	else
	{
		Embed.AddField(":small_blue_diamond: Yetkili:", "Panel", true);
	}
	Embed.AddField(" ", " ", false);
	Embed.AddField(":receipt: Sebep:", reason, true);
	Embed.AddField(":globe_with_meridians: Süre:", mins, true);
	hook.Embed(Embed);
	hook.SetUsername("Ban");
	
	hook.Send();
	delete hook;
}

void SendDiscordBan2(int client, int target, char mins[64])
{
	char TargetSteamid[128];
	GetClientAuthId(target, AuthId_Steam2, TargetSteamid, 128);
	char TargetName[128];
	GetClientName(target, TargetName, 128);
	char TargetSteam[128];
	GetCommunityID(TargetSteamid, TargetSteam, 128);
	Format(TargetSteam, 128, "http://steamcommunity.com/profiles/%s", TargetSteam);
	
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(WebHook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#a300ff");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", TargetName, TargetSteamid, TargetSteam);
	Embed.AddField(":small_orange_diamond: Ceza Alan:", EmbedFormat, true);
	if (IsValidClient(client))
	{
		char ClientSteamid[128];
		GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
		char ClientName[128];
		GetClientName(client, ClientName, 128);
		char ClientSteam[128];
		GetCommunityID(ClientSteamid, ClientSteam, 128);
		Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
		
		Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
		Embed.AddField(":small_blue_diamond: Yetkili:", EmbedFormat, true);
	}
	else
	{
		Embed.AddField(":small_blue_diamond: Yetkili:", "Panel", true);
	}
	Embed.AddField(" ", " ", false);
	Embed.AddField(":receipt: Sebep:", "Yazılmamış", true);
	Embed.AddField(":globe_with_meridians: Süre:", mins, true);
	hook.Embed(Embed);
	hook.SetUsername("Ban");
	
	hook.Send();
	delete hook;
}

public Action OnBanClient(int client, int time, int flags, const char[] reason, const char[] kick_message, const char[] command, any source)
{
	char mins[64];
	if (time <= 0)
		mins = "Kalıcı";
	else
		Format(mins, sizeof(mins), "%d Dakika", time);
	
	if (reason[0])
	{
		SendDiscordBan(client, source, mins, reason);
	}
	else
	{
		SendDiscordBan2(client, source, mins);
	}
}

void SendDiscordUnban(int client, const char[] idenity)
{
	DiscordWebHook hook = new DiscordWebHook(WebHook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	if (IsValidClient(client))
	{
		char ClientSteamid[128];
		GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
		char ClientName[128];
		GetClientName(client, ClientName, 128);
		char ClientSteam[128];
		GetCommunityID(ClientSteamid, ClientSteam, 128);
		Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
		
		char EmbedFormat[256];
		Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
		Embed.AddField(":small_blue_diamond: Yetkili:", EmbedFormat, true);
		Embed.AddField(":small_orange_diamond: Cezası Kaldırılan:", idenity, true);
		
	}
	else
	{
		Embed.AddField(":small_blue_diamond: Yetkili:", "Panel", true);
		Embed.AddField(":small_orange_diamond: Cezası Kaldırılan:", idenity, true);
	}
	Embed.SetColor("#00a3ff");
	Embed.SetFooter("-ByDexter");
	hook.Embed(Embed);
	hook.SetUsername("Unban");
	hook.Send();
	delete hook;
}

public Action OnRemoveBan(const char[] identity, int flags, const char[] command, any source)
{
	SendDiscordUnban(source, identity);
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

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
} 