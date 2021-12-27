
/*
    This aimbot was inspired by Loof's TSD mod (https://twitter.com/2loof). This was not ripped from anything and was written solely to mimic what he had.
        PS: Thank loof(https://twitter.com/2loof) for the original idea, huge appreciation for his own ideas/work.
            - None of these are parsing variables, if you want them to save through rounds, you must know how to parse data.

    On Player Spawn Call:
        self.loofTKAM = false;
        self.LoofIMP = false;
        level.NoobAim = undefined;
        self.radiusAmount = 125; //Can be adjusted to your liking.

    Functions Explained:
        - selectPlayer(player): Selects the individual for the Aimbot Action
        - toggleLoofTK: Toggles the Throwingknife Aimbot
        - toggleLoofIMP: Toggles the Noobtube Aimbot
*/

selectPlayer(player)
{
	level.NoobAim = player;
	self iprintlnBold(player.name + " is now selected for TK or Noobtube Aimbot!");
}

toggleLoofTK()
{
    if(!self.loofTKAM)
    {
        self.loofTKAM = true;
        self thread LooftKAimbot();
    } else {
        self.loofTKAM = false;
        self notify("stopDaLOOFTK");
    }
}

LooftKAimbot()
{
    self endon("stopDaLOOFTK");
    self endon("disconnect");
    for(;;)
    {
        self waittill("grenade_fire", grenade, grenadeName );
        if( grenadeName != "throwingknife_mp")
            continue;
        grenade waittill( "missile_stuck", stuckTo );
        if(distance(grenade.origin, level.NoobAim.origin) < self.radiusAmount)
        {
            self thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback();
            grenade radiusDamage(level.NoobAim.origin, 100, 9999, 9998, self, "MOD_IMPACT");
        }
        waitframe();
    }
}

toggleLoofIMP()
{
    if(!self.LoofIMP)
    {
        self.LoofIMP = true;
        self thread LoofIMPAIM();
    } else {
        self.LoofIMP = false;
        self notify("stopDaLOOFIM");
    }
}

LoofIMPAIM()
{
    self endon("stopDaLOOFIM");
    self endon("disconnect");
    for(;;)
    {
        self waittill("missile_fire", missile, weaponName);
        if(weaponName == "m79_mp" || isSubStr(weaponName, "gl_"))
        {
            missile waittill("death");
            if(distance(missile.origin, level.NoobAim.origin) < self.radiusAmount)
            {
                self thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback();
                missile radiusDamage(level.NoobAim.origin, 100, 9999, 9998, self, "MOD_IMPACT");
            }
        }
        waitframe();
    }
}