<#>
    For this code to work, you are required to have previously built a Widget,
    which in my case I named "KillCounterWidget".
    Nevertheless, you can name it whatever you want, as long as it has a 'message' variable
    linked to a UEFN Text Block from the UMG UI editor.

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }

# Turn any given 'string' into a 'message', which can be displayed on screen.
ToMessage<localizes>(String : string) : message = "{String}"

kill_counter_device := class(creative_device):

    # Link this device with the other device that holds all players' data, such as how many kills each of them have.
    @editable
    PlayersData : player_manager_device = player_manager_device{}

    <#>
        When a player joins to the match, call this function, which relies on a helper function 
        to create a 'KillCounterWidget', that is added to the entry of this player in the KillCounterWidgets hash map,
        so that we can update it later when needed.
    InitPlayerKillCounterWidget(Player : player) : void =
        if (PlayerUI := GetPlayerUI[Player]):
            if (Kills := PlayersData.PlayerKills[Player]):
                NewWidget := CreateWidget(Kills)
                if (set PlayersData.KillCounterWidgets[Player] = NewWidget):
                    PlayerUI.AddWidget(NewWidget)

    <#> 
        Create a new instance of the 'KillCounterWidget' class, and assign to the "KillsNumber" variable 
        the current amount of eliminations the player has in the PlayerKills hash map, and then the value of that
        variable will be showed on screen through the widget.
        Again, the "KillsNumber" variable can be named as you desire when you are creating the widget.
    CreateWidget(Kills : int) : KillCounterWidget =
        Widget := KillCounterWidget{}
        set Widget.KillsNumber = ToMessage("{Kills}")
        return Widget

    # Update the number of eliminations that is shown on screen to match the current number in the hash map.
    UpdateWidget(Player : player) : void =
        if (Widget := PlayersData.KillCounterWidgets[Player]):
            if (Kills := PlayersData.PlayerKills[Player]):
                set Widget.KillsNumber = ToMessage("{Kills}")