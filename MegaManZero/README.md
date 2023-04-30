## Mega Man Zero Autosplitter
 
Auto Splitter for Mega Man Zero GBA

- [LiveSplit](http://livesplit.github.io/) - Here you can find out more about and download LiveSplit. It is a popular timer program typically used for speedruns.
- [ASL](https://github.com/LiveSplit/LiveSplit/blob/master/Documentation/Auto-Splitters.md) - Here you can find more information about ASL (basically C#) and autosplitters in general.

**Supported emulators:**
 - Bizhawk using the VBA-NEXT core! (This is the only allowed core for the Zero games)
 - There might also be a limitation with Win10 only. If you have issues when not on Win10, please message me on Discord.
 - VBA-rr-svn480

## Features

- Automatically start the timer when you start a run. Time starts after selecting New Game
- Automatically split at each score screen
- Automatically split when you lose control after Seraph X is killed
- Automatically reset when the game is reset

## Installation 

- Go to "Edit Splits.." in LiveSplit
- Enter the name of the game in "Game Name"
  - This must be entered correctly for LiveSplit to know which script to load
- Click the "Activate" button to download and enable the autosplitter script
  - If you ever want to stop using the autosplitter altogether, just click "Deactivate"

## Manual Installation (skip if you used the 'Activate' Button)

- Download https://raw.githubusercontent.com/Coltaho/Autosplitters/master/MegaManZero/MMZautosplit.asl
- Edit Layout
- Add Other /Scriptable Componment / Script Path: Browse to the "MMZautosplit.asl" file you downloaded previously
- Enable Start/Split feature here
  
## Set-up (if auto-installed)

- Go to "Edit Splits..." in LiveSplit
- Click "Settings" to configure the autosplitter
  - **Note:** If for some reason LiveSplit does not automatically load the script, click "Browse...", navigate to "\LiveSplit\Components\" and select the appropriate script.
- Enable Start/Split feature here
  
Here you can enable/disable the options for auto start and auto splitting.

## Bugs

- Let me know of any bugs

## Thanks

- Thanks to [Hetfield](http://twitch.tv/hetfield90) for help with the RAM addresses used

## Contact

If you encounter any issues or have feature requests, please let me know! 

- [Coltaho](http://twitch.tv/Coltaho) or Coltaho#2016 on Discord
