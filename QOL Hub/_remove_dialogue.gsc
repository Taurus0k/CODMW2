/*
    Removes Leader Dialogue from the Killstreaks + Disabled Music Dialogue via a simple toggle - @mp_rust

    Instructions for Implementation:

        1. In missions or any file that has onPlayerConnect, paste this within there.
            if(!isDefined(player.pers["game_sounds"]))
                player.pers["game_sounds"] = true; //Dialogues are enabled by default.

        2. Within your menu, add this as an option:
            - toggle_music_sounds
                - When it's true, the Dialogue is Enabled.
                - When it's false, the Dialogue is Disabled.
		
	This will help remove both the Music and Voice Dialogue from the game during the duration of play. 
	Due to parsing variables, this means that the settings will stick throughout the entirety of the game or until restart.
*/

toggle_music_sounds()
{
    if(!self.pers["game_sounds"])
    {
        self.pers["game_sounds"] = true;
        self iPrintLn("Dialogue Sounds: ^2Enabled");
    } else {
        self.pers["game_sounds"] = false;
        self iPrintLn("Dialogue Sounds: ^1Disabled");
    }
}

/*
    usedKillstreak & giveOwnedKillstreakItem are the functions we will be replacing.
		- If you are using IW4X, please use: replaceFunc(maps\mp\killstreaks\_killstreaks::usedKillstreak, ::usedKillstreak);
		- If you are using IW4X, please use: replaceFunc(maps\mp\killstreaks\_killstreaks::giveOwnedKillstreakItem, ::giveOwnedKillstreakItem);
			- If you are using Console, just copy and replace the function in the respective spot.
*/

usedKillstreak( streakName, awardXp )
{
	self playLocalSound( "weap_c4detpack_trigger_plr" );

	if ( awardXp )
		self thread [[ level.onXPEvent ]]( "killstreak_" + streakName );

	self thread maps\mp\gametypes\_missions::useHardpoint( streakName );
	
	awardref = maps\mp\_awards::getKillstreakAwardRef( streakName );
	if ( isDefined( awardref ) )
		self thread incPlayerStat( awardref, 1 );

	team = self.team;

	if ( level.teamBased && self.pers["game_sounds"] )
	{
        thread leaderDialog( team + "_friendly_" + streakName + "_inbound", team );

		if ( getKillstreakInformEnemy( streakName ) && self.pers["game_sounds"])
			thread leaderDialog( team + "_enemy_" + streakName + "_inbound", level.otherTeam[ team ] );
	}
	else
	{
		if(self.pers["game_sounds"])
        {
			self thread leaderDialogOnPlayer( team + "_friendly_" + streakName + "_inbound" );
        
            if ( getKillstreakInformEnemy( streakName ) )
            {
                excludeList[0] = self;
                thread leaderDialog( team + "_enemy_" + streakName + "_inbound", undefined, undefined, excludeList );
            }
        }
	}
}

giveOwnedKillstreakItem( skipDialog )
{
	if ( !isDefined( self.pers["killstreaks"][0] ) )
		return;
		
	streakName = self.pers["killstreaks"][0].streakName;

	weapon = getKillstreakWeapon( streakName );
	self giveKillstreakWeapon( weapon );

	if ( !isDefined( skipDialog ) && !level.inGracePeriod && self.pers["game_sounds"])
		self leaderDialogOnPlayer( streakName, "killstreak_earned" );
}

/*
    musicController is the function we will be replacing.
		- If you are using IW4X, please use: replaceFunc(maps\mp\gametypes\_music_and_dialog::musicController, ::musicController);
			- If you are using Console, just copy and replace the function in the respective spot.
*/

musicController()
{
	level endon ( "game_ended" );
	
	if ( !level.hardcoreMode && self.pers["game_sounds"])
		thread suspenseMusic();
	
	level waittill ( "match_ending_soon", reason );
	assert( isDefined( reason ) );

	if ( getWatchedDvar( "roundlimit" ) == 1 || game["roundsPlayed"] == (getWatchedDvar( "roundlimit" ) - 1) && self.pers["game_sounds"])
	{	
		if ( !level.splitScreen )
		{
			if ( reason == "time" )
			{
				if ( level.teamBased )
				{
					if ( game["teamScores"]["allies"] > game["teamScores"]["axis"])
					{
						if ( !level.hardcoreMode )
						{
							playSoundOnPlayers( game["music"]["winning_allies"], "allies" );
							playSoundOnPlayers( game["music"]["losing_axis"], "axis" );
						}
				
						leaderDialog( "winning_time", "allies" );
						leaderDialog( "losing_time", "axis" );
					}
					else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"])
					{
						if ( !level.hardcoreMode )
						{
							playSoundOnPlayers( game["music"]["winning_axis"], "axis" );
							playSoundOnPlayers( game["music"]["losing_allies"], "allies" );
						}
							
						leaderDialog( "winning_time", "axis" );
						leaderDialog( "losing_time", "allies" );
					}
				}
				else
				{
					if ( !level.hardcoreMode)
						playSoundOnPlayers( game["music"]["losing_time"] );
                    
					leaderDialog( "timesup" );
				}
			}	
			else if ( reason == "score" )
			{
				if ( level.teamBased )
				{
					if ( game["teamScores"]["allies"] > game["teamScores"]["axis"])
					{
						if ( !level.hardcoreMode )
						{
							playSoundOnPlayers( game["music"]["winning_allies"], "allies" );
							playSoundOnPlayers( game["music"]["losing_axis"], "axis" );
						}
				
						leaderDialog( "winning_score", "allies" );
						leaderDialog( "losing_score", "axis" );
					}
					else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"])
					{
						if ( !level.hardcoreMode )
						{
							playSoundOnPlayers( game["music"]["winning_axis"], "axis" );
							playSoundOnPlayers( game["music"]["losing_allies"], "allies" );
						}
							
						leaderDialog( "winning_score", "axis" );
						leaderDialog( "losing_score", "allies" );
					}
				}
				else
				{
					winningPlayer = maps\mp\gametypes\_gamescore::getHighestScoringPlayer();
					losingPlayers = maps\mp\gametypes\_gamescore::getLosingPlayers();
					excludeList[0] = winningPlayer;

					if ( !level.hardcoreMode )
					{
						winningPlayer playLocalSound( game["music"]["winning_" + winningPlayer.pers["team"] ] );
						
						foreach ( otherPlayer in level.players )
						{
							if ( otherPlayer == winningPlayer )
								continue;
								
							otherPlayer playLocalSound( game["music"]["losing_" + otherPlayer.pers["team"] ] );							
						}
					}
                    winningPlayer leaderDialogOnPlayer( "winning_score" );
                    leaderDialogOnPlayers( "losing_score", losingPlayers );
				}
			}
			level waittill ( "match_ending_very_soon" );
			leaderDialog( "timesup" );
		}
	}
	else
	{
        if(self.pers["game_sounds"] )
        {
            if ( !level.hardcoreMode )
                playSoundOnPlayers( game["music"]["losing_allies"] );
            
            leaderDialog( "timesup" );
        }
	}
}