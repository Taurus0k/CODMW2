/*
    Pred Shax System by Antiga (https://twitter.com/mp_rust)
        - Credits to Jepe (https://twitter.com/jepex) & Magenta (https://twitter.com/ohjain) for doing this first.
    
    How to use:

    Initialize these variables:
        self.nonPredShaxWeapon = false;
        self.exagShax = false;
        self.instantPredCrash = false;
        setDvar( "missileRemoteSpeedTargetRange", "6000 12000" );
    
    1. Selecting your Shax Weapon first before beginning the predShaxFunction Function.
        - self thread SelectPredShaxWeap();
            - This also pulls the times for the shax weapons + checks if it's a shaxable weapon.
                - If you need more guns, you are more than welcome to do the timings yourself.

    2. Decide whether instant pred crashing should be enabled.
        - self thread InstaPredCrash();
            - This allows you to crash instantly and still show the shax.

    3. Decide whether to make the shax slow down once it's showing.
        - self thread exagShax();

    4. Use your own bind system to initiate the function itself.
        - self thread predShaxFunction();

    This system is very old and could be buggy, but I've tested many times without issues.
*/

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\gametypes\_rank;
#include maps\mp\gametypes\_damage;

SelectPredShaxWeap()
{
	self.shaxGun = self getCurrentWeapon();
    self.shaxGunStock = self getWeaponAmmoStock(self.shaxGun);
    self.nonPredShaxWeapon = false;
    if(isSubStr(self.shaxGun, "akimbo"))
    {
        self.nonPredShaxWeapon = true;
    }
    else if(isSubStr(self.shaxGun, "uzi"))
    {
        self.screenDelay = 1.2;
    }   
    else if(isSubStr(self.shaxGun, "tmp"))
    {
        self.screenDelay = .8;
    }
    else if(isSubStr(self.shaxGun, "kriss"))
    {
        self.screenDelay = .8;
    } 
    else if(isSubStr(self.shaxGun, "aa12"))
    {
        self.screenDelay = 1.15;
    } 
    else if(isSubStr(self.shaxGun, "pp2000"))
    {
        self.screenDelay = .775;
    }
    else if(isSubStr(self.shaxGun, "fal"))
    {
        self.screenDelay = .95;
    }
    else if(isSubStr(self.shaxGun, "ump45"))
    {
        self.screenDelay = 1;
    }
    else if(isSubStr(self.shaxGun, "glock"))
    {
        self.screenDelay = .85;
    }
    else
    {
        self.nonPredShaxWeapon = true;
    }
}

exagShax()
{
    if(!self.exagShax)
        self.exagShax = true;
    else
        self.exagShax = false;
}

InstaPredCrash()
{
    if(!self.instantPredCrash)
    {
        self.instantPredCrash = true;
        setDvar( "missileRemoteSpeedTargetRange", "9999 99999" );
    } else {
        self.instantPredCrash = false;
        setDvar( "missileRemoteSpeedTargetRange", "6000 12000" );
    }
}

predShaxFunction()
{
    if(!self.nonPredShaxWeapon)
    {
        self.currTimescale = getDvarFloat("timescale");
        akimbo = false;
        nonShax = self getCurrentWeapon();
        ksWep = "killstreak_predator_missile_mp";
        self giveweapon(ksWep);
        self takeweapon(nonShax);
        self switchToWeapon(ksWep);
        wait 0.1;
        if(isSubStr(nonShax, "akimbo"))
            akimbo = true;
        self giveWeapon(nonShax, self.camo, akimbo);
        self switchToWeapon(nonShax);
        wait 0.40;
        self takeweapon(ksWep);
        self setUsingRemote( "remotemissile" );
        result = "success"; 
        level thread maps\mp\killstreaks\_remotemissile::_fire( undefined, self );
        wait 0.75;
        self ThermalVisionFOFOverlayOff();
        self ControlsUnlink();
        self CameraUnlink();
        if(!self _hasPerk("specialty_fastreload"))
        {
            self thread maps\mp\killstreaks\_remotemissile::staticEffect(self.screenDelay * 2.25);
        } else {
            self thread maps\mp\killstreaks\_remotemissile::staticEffect(self.screenDelay);
        }
        self giveWeapon(self.shaxGun);
        self setSpawnWeapon(self.shaxGun);
        self setWeaponAmmoclip(self.shaxGun, 0);
        if ( getDvarInt( "camera_thirdPerson" ) )
            self setThirdPersonDOF( true );
        self ThermalVisionOff();
        self clearUsingRemote();
        waittillframeend;
        self setweaponammostock(self.shaxGun, self.shaxGunStock);
        if(!self _hasPerk("specialty_fastreload"))
        {
            wait self.screenDelay * 2.25;
        } else {
            wait self.screenDelay;
        }
        if(self.exagShax)
        {
            setdvar("timescale", 0.25);
        }
        wait 0.15;
        self unlink(); //Failsafe..
        waittillframeend;
        self takeweapon(self.shaxGun);
        if(self.exagShax)
        {
            setdvar("timescale", self.currTimescale);
        }
        waitframe();
        self switchToWeapon(nonShax);
        waitframe();
        self disableWeapons();
        waitframe();
        self enableWeapons();
    } else {
        self iPrintLnBold("^2Current Weapon does not have Shax Timings...");
    }
}