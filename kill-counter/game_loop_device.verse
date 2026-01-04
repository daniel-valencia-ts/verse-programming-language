<#>
    The following is an implementation in which only sentries count as eliminations.
    However, by changing some functions and adding more code, we can make it track players too.
    These custom devices are very versatile, so you can modify them as you desire to act
    as you need them to for you island.
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

game_loop_device := class(creative_device):

    # Other devices required for this one to work properly, from which we will get data and also call certain functions.
    @editable
    PlayersData : player_manager_device = player_manager_device{}
    @editable
    KillCounterManager : kill_counter_device = kill_counter_device{}

    # An array of all the sentry spawners, so we can track when one of those sentries is eliminated.
    @editable
    SentrySpawners : []sentry_device = array{}

    OnBegin<override>()<suspends> : void =
        # Call a function that does everything needed for the kill counting logic to work.
        InitGame()

        # When a player joins the game after it has started, initiate them.
        GetPlayspace().PlayerAddedEvent().Subscribe(InitPlayer)
        # When a player leaves the game, remove all of the data related to them.
        GetPlayspace().PlayerRemovedEvent().Subscribe(TerminatePlayer)
        
    InitGame() : void =
        # Initialize all players who are in the hash map by the beginning of the game.
        AllPlayers := GetPlayspace().GetPlayers()
        for (Player : AllPlayers):
            InitPlayer(Player)

        # Whenever a sentry dies, call the IncreasePlayerKills function.
        for (SentrySpawner : SentrySpawners):
            SentrySpawner.EliminatedEvent.Subscribe(IncreasePlayerKills)

    # Create an entry in the PlayerKills hash map set to zero, and initialize the 'KillCounterWidget' of the given player.
    InitPlayer(Player : player) : void =
        if (set PlayersData.PlayerKills[Player] = 0):
            KillCounterManager.InitPlayerKillCounterWidget(Player)

    <#>
        Whenever a player leaves, eliminate any entry they had in either hash map.
        Since hash maps are immutable in Verse, we have to create an entire new map in which the player's entries
        aren't included.
    TerminatePlayer(Player : player) : void =
        var NewPlayerKillsMap : [agent]int = map{}
        for (Key -> Value : PlayersData.PlayerKills, Key <> Player):
            set NewPlayerKillsMap = ConcatenateMaps(NewPlayerKillsMap, map{Key => Value})
        set PlayersData.PlayerKills = NewPlayerKillsMap

        var NewKillCounterWidgetsMap : [player]KillCounterWidget = map{}
        for (Key -> Value : PlayersData.KillCounterWidgets, Key <> Player):
            set NewKillCounterWidgetsMap = ConcatenateMaps(NewKillCounterWidgetsMap, map{Key => Value})
        set PlayersData.KillCounterWidgets = NewKillCounterWidgetsMap

    # Increase the player's kill counter by one and update their widget.
    IncreasePlayerKills(MaybeAgent : ?agent) : void =
        if (Agent := MaybeAgent?):
            if (CurrentKills := PlayersData.PlayerKills[Agent]):
                if ( set PlayersData.PlayerKills[Agent] = CurrentKills + 1):
                    if (Player := player[Agent]):
                        KillCounterManager.UpdateWidget(Player)
