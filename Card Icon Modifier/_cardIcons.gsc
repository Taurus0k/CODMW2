/*
    Card Icon Modifications by @mp_rust

    Releasing this since it is very old and can be made better, I figure many players can get some use out of this...
    This allows for you to remove the rank icon, emblem, title, name, and the background.

    Also don't forget to use the playercard_killedby_hd.menu file I included...

*/

    /* Call this OnPlayerConnect: */
    setDvarIfUninitialized("nomoreBackground", 0);
	setDvarIfUninitialized("noMoreRank", 0);
	setDvarIfUninitialized("noCardIcon", 0);
	setDvarIfUninitialized("noCardTitle", 0);
	setDvarIfUninitialized("noCardName", 0);

    /* Call this OnPlayerSpawned: */
    if(!getDvarInt("noCardIcon"))
	{
		self.noCardIcon = false;
	} else {
		self.noCardIcon = true;
	}

	if(!getDvarInt("nomoreBackground"))
	{
		self.transparentKC = false;
	} else {
		self.transparentKC = true;
	}

	if(!getDvarInt("noMoreRank"))
	{
		self.noMoreRank = false;
	} else {
		self.noMoreRank = true;
	}

	if(!getDvarInt("noCardTitle"))
	{
		self.noCardTitle = false;
	} else {
		self.noCardTitle = true;
	}

	if(!getDvarInt("noCardName"))
	{
		self.noCardName = false;
	} else {
		self.noCardName = true;
	}

    /* Example of Menu Use Case: */
    self addoption("cardIconS", "Disable Rank", ::removeRankIcon);
    self addoption("cardIconS", "Disable Card Icon", ::removeCardIcon);
    self addoption("cardIconS", "Disable Card Title", ::removeCardTitle);
    self addoption("cardIconS", "Disable Name", ::removeCardName);
    self addoption("cardIconS", "Transparent Calling Card", ::seeThruKCCard);

    /* Actual Functions: */
    removeRankIcon()
    {
        if(!self.noMoreRank) 
        {
            self.noMoreRank = true;
            setDvar("noMoreRank", 1);
        } else {
            self.noMoreRank = false;
            setDvar("noMoreRank", 0);
        }
    }

    removeCardIcon()
    {
        if(!self.noCardIcon) 
        {
            self.noCardIcon = true;
            setDvar("noCardIcon", 1);
        } else {
            self.noCardIcon = false;
            setDvar("noCardIcon", 0);
        }
    }

    removeCardTitle()
    {
        if(!self.noCardTitle) 
        {
            self.noCardTitle = true;
            setDvar("noCardTitle", 1);
        } else {
            self.noCardTitle = false;
            setDvar("noCardTitle", 0);
        }
    }

    removeCardName()
    {
        if(!self.noCardName) 
        {
            self.noCardName = true;
            setDvar("noCardName", 1);
        } else {
            self.noCardName = false;
            setDvar("noCardName", 0);
        }
    }

    seeThruKCCard()
    {
        if(!self.transparentKC)
        {
            self.transparentKC = true;
            self setClientDvar("nomoreBackground", 1);
        } else {
            self.transparentKC = false;
            self setClientDvar("nomoreBackground", 0);       
        }
    }