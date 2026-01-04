using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

player_manager_device := class(creative_device):
    <#>
        Create an empty map used to store how many kills each player has.
        We use the agent type as a key for the sake of convenience, since usually when
        working with the 'elimination_result' struct will be mostly dealing with agents.
        Also, since the 'player' class is compatible with the 'agent' class if you will, 
        we can freely use a 'player' object as a key rather than an explicit 'agent'.
    var PlayerKills : [agent]int = map{}
    <#>
        We do the same but this time for holding the 'KillCounterWidget' of each player, making
        it easier for us to update the desired widget with ease.
    var KillCounterWidgets : [player]KillCounterWidget = map{}