#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

_init()
{
    /* Strings + Dvars */
	game["strings"]["change_class"] = undefined; //Removes Class Change Text
    level.pers["meters"] = 10; //Meters required to kill.
    setDvarIfUninitialized("class_change", 1); //Enables/Disabled Mid-Game CC
    setDvarIfUninitialized("first_blood", 0); //Enables/Disabled First Blood
    level thread on_player_connect();
}

on_player_connect()
{
    self endon("disconnect");
    for(;;)
    {
        level waittill( "connected", player );

        if(!player isBot())
        {
            if(!isDefined(player.pers["allow_fast_mantle"]))
                player.pers["allow_fast_mantle"] = true;
            if(!isDefined(player.pers["alt_swap"]))
                player.pers["alt_swap"] = false;
            if(!isDefined(player.pers["allow_soh"]))
                player.pers["allow_soh"] = true;

            player_thread_calling(player);
            if(player isHost())
            {
                if(!isDefined(player.pers["bot_origin"]))
                    player.pers["bot_origin"] = 0;
                if(!isDefined(player.pers["bot_angles"]))
                    player.pers["bot_angles"] = 0;
                
                player thread tele_bots_cmd();

                setDvar("g_teamcolor_myteam", "0.501961 0.8 1 1" ); 	
                setDvar("g_teamTitleColor_myteam", "0.501961 0.8 1 1" );
                setDvar("safeArea_adjusted_horizontal", 0.85);
                setDvar("safeArea_adjusted_vertical", 0.85);
                setDvar("safeArea_horizontal", 0.85);
                setDvar("safeArea_vertical", 0.85);
                setDvar("ui_streamFriendly", true);
                setDvar("jump_slowdownEnable", 1);
                setDvar("ui_streamFriendly", true);
                setDvar("sv_extraPenetration", 1);
                setDvar("sv_extraPenetrationMultiplier", 9999);
                setDvar("cg_newcolors", 0);
                setDvar("intro", 0);
                setDvar("cl_autorecord", 0);
            }
        }
        player thread on_player_spawn();
    }
}

on_player_spawn()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("spawned_player");
        force_load_bot_position();//Keep here...
        if(self isBot())//Bot check...
        {
            self _clearPerks();
            self takeAllWeapons();
        }
        if(self isHost())//Host only functionality...
        {
            self freezeControls(false);
            self thread knife_x_prone_ads();
            gametype_verification();//Forces disconnect if gametype is not Search and Destroy!
        }
    }
}

player_thread_calling(client)
{
    client thread welcome_message();
    client thread do_refill_all_cmd();
    client thread allow_mara_mantle_cmd();
    client thread kill_cmd();
    client thread alt_swap_cmd();
    client thread allow_soh_cmd();
    /* DVARS */
    client setClientDvar("g_teamcolor_myteam", "0.501961 0.8 1 1" ); 	
    client setClientDvar("g_teamTitleColor_myteam", "0.501961 0.8 1 1" );
    client setClientDvar("safeArea_adjusted_horizontal", 0.85);
    client setClientDvar("safeArea_adjusted_vertical", 0.85);
    client setClientDvar("safeArea_horizontal", 0.85);
    client setClientDvar("safeArea_vertical", 0.85);
    client setClientDvar("ui_streamFriendly", true);
    client setClientDvar("cg_newcolors", 0);
    client setClientDvar("intro", 0);
    client setClientDvar("cl_autorecord", 0);
}

gametype_verification()
{
    if(level.gametype != "sd")
    {
        self iPrintLnBold("^1Invalid Gametype - Please utilize S&D!");
        wait 0.50;
        exec("disconnect");
    }
}

welcome_message()
{
    self waittill("spawned_player");
    self iprintln("Welcome ^1" + self.name + " to ^1Brax PKG^7 by ^1@mp_rust^7!\nThis mod was inspired by ^1@plugwalker47^7\nUse [{+stance}] & [{+melee}] for a Ammo Refill!");
}

/* BOT LOGIC */
tele_bots_cmd()
{
	self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("tele", "+tele");
        self waittill("tele");
        self.pers["bot_origin"] = self getOrigin();
        self.pers["bot_angles"] = self getplayerangles();
        waitframe();
        for(i = 0; i < level.players.size; i++)
        {
            if(level.players[i].pers["team"] != self.pers["team"] && isSubStr( level.players[i].guid, "bot" ))
            {
                    level.players[i] setOrigin( self.pers["bot_origin"] );
                    level.players[i] setPlayerAngles( self.pers["bot_angles"] );
            }
        }
        self iPrintLnBold("Bots Position: ^2Saved");
    }
}

force_load_bot_position()
{
    for(i = 0; i < level.players.size; i++)
    {
        if(level.players[i].pers["team"] != self.pers["team"] && isSubStr( level.players[i].guid, "bot" ))
        {
                level.players[i] setOrigin( self.pers["bot_origin"] );
                level.players[i] setPlayerAngles( self.pers["bot_angles"] );
        }
    }
}

/* In-game Commands */
allow_mara_mantle_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("afm", "+afm");
        self waittill("afm");
        if(!self.pers["allow_fast_mantle"])
        {
            self.pers["allow_fast_mantle"] = true;
            self maps\mp\perks\_perks::givePerk("specialty_fastmantle");
        } else {
            self.pers["allow_fast_mantle"] = false;
            self _unsetPerk("specialty_fastmantle");
        }
        self iPrintLn("Fast Mantle Perk: " + bool_to_text(self.pers["allow_fast_mantle"]));
    }
}

allow_soh_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("soh", "+soh");
        self waittill("soh");
        if(!self.pers["allow_soh"])
        {
            self.pers["allow_soh"] = true;
            self maps\mp\perks\_perks::givePerk("specialty_fastreload");
        } else {
            self.pers["allow_soh"] = false;
            self _unsetPerk("specialty_fastreload");
        }
        self iPrintLn("Fast Reload Perk: " + bool_to_text(self.pers["allow_soh"]));
    }
}

kill_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("die", "+die");
        self waittill("die");
        self suicide();
    }
}

do_refill_all_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("melee", "+melee");
        self waittill("melee");
        if(self getStance() == "crouch")
        {
            weapon_list = self GetWeaponsListAll();
            foreach ( weapon in weapon_list )
            {
                self giveMaxAmmo(weapon);
            }
        }
    }
}

knife_x_prone_ads()
{
	self endon("disconnect");
	for(;;)
	{
        self notifyOnPlayerCommand("melee", "+melee");
        self waittill("melee");
        if(self getStance() == "prone" && self adsButtonPressed())
        {
            self giveWeapon("stinger_mp");
            self dropItem("stinger_mp");
        }
	}
}

alt_swap_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("as", "+as");
        self waittill("as");
        if(!self.pers["alt_swap"])
        {
            self.pers["alt_swap"] = true;
            if(isSubStr(self.secondaryWeapon, "usp") || isSubStr(self.primaryWeapon, "usp"))
            {
                self giveWeapon("beretta_mp");
            } else {
                self giveWeapon("usp_mp");
            }
        } else {
            self.pers["alt_swap"] = false;
            if(isSubStr(self.secondaryWeapon, "usp") || isSubStr(self.primaryWeapon, "usp"))
            {
                self takeWeapon("beretta_mp");
            } else {
                self takeWeapon("usp_mp");
            }
        }
        self iPrintLn("Alt-Swap: " + bool_to_text(self.pers["alt_swap"]));
    }
}

/* Utils */

bool_to_text(bool)
{
    if(bool)
        return "[^2On^7]";
    else
        return "[^1Off^7]";
}

/*
	Re-call the damage-hook.
*/

init_new_hooks()
{
	level.prevCallbackPlayerDamage = level.callbackPlayerDamage;
	level.callbackPlayerDamage = ::new_damage_hook;
}

new_damage_hook(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	if( sMeansofDeath != "MOD_FALLING" && sMeansofDeath != "MOD_TRIGGER_HURT" && sMeansofDeath != "MOD_SUICIDE" ) 
    {
		if(!brax_weapons(sWeapon))//Fake Hitmarkers, but no damage = no risk of accidental killing!
        {
            eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback("damage_feedback");
            return;
        }
		if(brax_weapons(sWeapon) && int(distance(self.origin, eAttacker.origin)*0.0254) < level.pers["meters"] && eAttacker.pers["team"] != self.pers["team"])//Prevents Barrelstuff!
		{
			eAttacker iPrintLnBold("You Must Be Atleast Be [^2" + level.pers["meters"] + "m^7] Away!");
			return;
		}
		if(brax_weapons(sWeapon) && int(distance(self.origin, eAttacker.origin)*0.0254) >= level.pers["meters"])//Prevents Hitmarks + Confirms Meter Check!
			iDamage = 150;
	}
	self [[level.prevCallbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}

brax_weapons( weapons )
{
	if ( !isDefined ( weapons ) )
		return false;
    
	brax_classes = getweaponclass( weapons );

	if ( brax_classes == "weapon_sniper" || isSubStr(weapons, "fal_" ) || weapons == "throwingknife_mp" )
		return true;
    else
        return false;
}