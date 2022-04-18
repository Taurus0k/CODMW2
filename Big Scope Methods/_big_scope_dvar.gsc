/*
    Dvar Method for Big Scoping - This was in the older version of BASH, people got ahold of it or figured it out..

    player.pers["help_me_scope"] = false; - Call this on playerconnect.

    Call this On PlayerSpawn so it sticks throughout rounds:
    if(self.pers["help_me_scope"])
        self thred help_me_scope();
    else
        self notify("stop_scope");

    Default DVAR Values:
    self setClientDvar("perk_quickDrawSpeedScale", 1.5); // Default Values

    The function: scope_helper toggles it on or off.

*/

scope_helper()
{
	if(!self.pers["help_me_scope"])
	{
		self.pers["help_me_scope"] = true;
		self thread help_me_scope();
	} else {
		self.pers["help_me_scope"] = false;
		self setClientDvar("perk_quickDrawSpeedScale", 1.5);
		self notify("stop_scope");
	}
}

help_me_scope()
{
	self endon("disconnect");
	self endon("stop_scope");
	level endon("round_end_finished");
	for(;;)
	{
        sniperClass = getweaponclass(self getCurrentWeapon());
        if(sniperClass == "weapon_sniper")
        {
            self setClientDvar("perk_quickDrawSpeedScale", 1.95);
        } else {
            self setClientDvar("perk_quickDrawSpeedScale", 1.5);
        }
        waitframe();
    }
}
