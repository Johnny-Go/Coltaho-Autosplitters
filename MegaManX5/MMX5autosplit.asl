//Made by Coltaho 1/13/2020
//Updated by JohnnyGo 4/29/2023

state("duckstation-qt-x64-ReleaseLTCG") {}
state("duckstation-nogui-x64-ReleaseLTCG") {}
//d1c0c		level
//d1db4		igt
//d1f2c		demoTime

state("emuhawk") {}
//Add 0x11D880 to RAM watch address to get these
//byte level : "octoshock.dll", 0x1EF48C;
//uint igt : "octoshock.dll", 0x1EF634;
//uint demoTime : "octoshock.dll", 0x1EF7AC;

state("RXC2") {
	byte level : 0x33F7444, 0x64;
	float igt : 0x33F7444, 0x208;
	float demoTime : 0x33F7444, 0x230;
}

state("ePSXe", "v2.0.5") {
	byte level : "ePSXe.exe", 0xB53C2C;
	uint igt : "ePSXe.exe", 0xB53DD4;
	uint demoTime : "ePSXe.exe", 0xB53F4C;
}

state("Dolphin", "v5.0") {
	//got the first offset from the RE2 Dolphin autosplitter (https://www.speedrun.com/re2/thread/izb1f/)
	//got the second offset by subtracting the address I found in Cheat Engine from the game memory start (Dolphin.exe+DCE040)
	byte level : "Dolphin.exe", 0xDCE040, 0xB8FD18;
	byte4 igt : "Dolphin.exe", 0xDCE040, 0xB8FEC0;
	byte4 demoTime: "Dolphin.exe", 0xDCE040, 0xB8FECC;
}

state("x5") {
	byte level : "x5.exe", 0x39298C;
	uint igt : "x5.exe", 0x392B34;
	uint demoTime : "x5.exe", 0x38F1F4;
}

startup {
	print("--[Autosplitter] Starting up!");
	refreshRate = 1;
	
	settings.Add("infosection", true, "---Info---");
	settings.Add("info", true, "Mega Man X5 AutoSplitter v2.0 by Coltaho and JohnnyGo", "infosection");
	settings.Add("info0", true, "- Compare against Game Time, does not autosplit", "infosection");
	settings.Add("info1", true, "- Supported emulators/versions : Bizhawk, ePSXe, Dolphin, DuckStation, PC XLC, and Windows X5", "infosection");
	settings.Add("info2", true, "- Website : https://github.com/Coltaho/Autosplitters", "infosection");
	settings.Add("info3", true, "- Website : https://github.com/Johnny-Go/Autosplitters", "infosection");
	
	//setup reset action
	LiveSplit.Model.Input.EventHandlerT<LiveSplit.Model.TimerPhase> resetAction = (s,e) =>
	{
		vars.firstPass = true;
		vars.convertedIGT = 0;
		vars.convertedDemoTime = 0;
		vars.level = -1;
	};
	vars.resetAction = resetAction;
	timer.OnReset += vars.resetAction;
}

init {
	print("--Setting init variables!--");
	refreshRate = 60;
	vars.firstPass = true;
	vars.convertedIGT = 0;
	vars.convertedDemoTime = 0;
	vars.level = -1;
	
	vars.myBaseAddress = IntPtr.Zero;
	vars.watchersInitialized = false;
	vars.tokenSource = new CancellationTokenSource();
	
	vars.initializeWatchers = (Func<bool>)(() =>
	{
		vars.watchers = new MemoryWatcherList() {
			new MemoryWatcher<byte>(new DeepPointer(vars.myBaseAddress + 0xD1C0C)) { Name = "level" },
			new MemoryWatcher<uint>(new DeepPointer(vars.myBaseAddress + 0xD1DB4)) { Name = "igt" },
			new MemoryWatcher<uint>(new DeepPointer(vars.myBaseAddress + 0xD1F2C)) { Name = "demoTime" }
		};
		
		vars.watchersInitialized = true;
		print("--[Autosplitter] Watchers Initialized!");
		return true;
	});

	vars.threadScan = new Thread(() => {
		print("--[Autosplitter] Starting Thread Scan...");
		var processName = game.ProcessName.ToLowerInvariant();
		SignatureScanner gameAssemblyScanner = null;
		ProcessModuleWow64Safe gameAssemblyModule = null;

		//Scans for Bizhawk PS1 MainMem
		SigScanTarget gameScanTarget = new SigScanTarget(0x8, "49 03 c9 ff e1 48 8d 05 ?? ?? ?? ?? 48 89 02");
		IntPtr gameSigAddr = IntPtr.Zero;

		while(!vars.tokenSource.IsCancellationRequested) {
			if ((processName.Length > 10) && (processName.Substring(0, 11) == "duckstation")) {
				//gets base address of the first mem_mapped region of 0x200000 size
				foreach (var page in game.MemoryPages(true)) {
					if ((page.RegionSize != (UIntPtr)0x200000) || (page.Type != MemPageType.MEM_MAPPED))
						continue;
					vars.myBaseAddress = page.BaseAddress;
					break;
				}
				if (vars.myBaseAddress != IntPtr.Zero) {
					print("--[Autosplitter] Duckstation Memory BaseAddress: " + vars.myBaseAddress.ToString("X"));
					vars.initializeWatchers();
				}
			} else if (processName == "emuhawk") {
				if(gameAssemblyScanner == null) {
					ProcessModuleWow64Safe[] loadedModules = null;
					try {
						loadedModules = game.ModulesWow64Safe();
					} catch {
						loadedModules = new ProcessModuleWow64Safe[0];
					}

					gameAssemblyModule = loadedModules.FirstOrDefault(m => m.ModuleName == "octoshock.dll");
					if(gameAssemblyModule == null) {
						print("--[Autosplitter] Modules not initialized");
						Thread.Sleep(500);
						continue;
					}

					gameAssemblyScanner = new SignatureScanner(game, gameAssemblyModule.BaseAddress, gameAssemblyModule.ModuleMemorySize);
				}

				print("--[Autosplitter] Scanning memory");

				if(gameSigAddr == IntPtr.Zero && (gameSigAddr = gameAssemblyScanner.Scan(gameScanTarget)) != IntPtr.Zero) {					
					int offset = (int)((long)game.ReadValue<int>(gameSigAddr) + (long)gameSigAddr + 4 - (long)gameAssemblyModule.BaseAddress);
					print("--[Autosplitter] Bizhawk offset from module to Mem: " + offset.ToString("X"));
					vars.myBaseAddress = gameAssemblyModule.BaseAddress + offset;
					print("--[Autosplitter] Bizhawk Memory BaseAddress: " + vars.myBaseAddress.ToString("X"));
					vars.initializeWatchers();
				}
			} else if (processName == "dolphin" || processName == "rxc2" || processName == "epsxe" || processName == "x5") {
				vars.watchers = new MemoryWatcherList();
				vars.watchersInitialized = true;
			}
			
			if(vars.watchersInitialized) {
				break;
			}

			print("--[Autosplitter] Couldn't find the pointers I want! Game is still starting or an update broke things!");
			Thread.Sleep(2000);
		}
		print("--[Autosplitter] Exited Thread Scan");
	});

	vars.threadScan.Start();
}

update {
	if(!vars.watchersInitialized) {
		return false;
	}

	vars.watchers.UpdateAll(game);

	//reverse bytes and convert to uint for Dolphin
	if(game.ProcessName == "Dolphin") {
		Array.Reverse(current.igt);
		Array.Reverse(current.demoTime);
		vars.convertedIGT = BitConverter.ToUInt32(current.igt, 0);
		vars.convertedDemoTime = BitConverter.ToUInt32(current.demoTime, 0);
		print("" + vars.convertedIGT);
	}
	//convert float to uint for XLC2
	else if(game.ProcessName == "RXC2") {
		vars.convertedIGT = (uint)current.igt;
		vars.convertedDemoTime = (uint)current.demoTime;
	}
	//ePSXe, Windows X5 don't do anything fancy
	else if ( game.ProcessName == "ePSXe" || game.ProcessName == "x5") {
		vars.convertedIGT = current.igt;
		vars.convertedDemoTime = current.demoTime;
	}
	//Bizhawk, DuckStation don't do anything fancy but use the watcher list
	else if (game.ProcessName == "EmuHawk" || game.ProcessName == "duckstation-qt-x64-ReleaseLTCG" || game.ProcessName == "duckstation-nogui-x64-ReleaseLTCG") {
		vars.convertedIGT = vars.watchers["igt"].Current;
		vars.convertedDemoTime = vars.watchers["demoTime"].Current;
	}
}

isLoading {
	return true;
}

gameTime {
	if(vars.firstPass) {
		vars.firstPass = false;
		return TimeSpan.FromMilliseconds(0);
	}

	//for Bizhawk and Duckstattion use watcher list to get level
	if (game.ProcessName == "EmuHawk" || game.ProcessName == "duckstation-qt-x64-ReleaseLTCG" || game.ProcessName == "duckstation-nogui-x64-ReleaseLTCG") {
		vars.level = vars.watchers["level"].Current;
	}
	else {
		vars.level = current.level;
	}

	if(vars.convertedIGT != 0 && vars.level != 22 && vars.convertedDemoTime == 0) {
		return TimeSpan.FromMilliseconds((1000.0 / 60.0) * vars.convertedIGT);
	}
}

exit {
	vars.tokenSource.Cancel();
}

shutdown
{
	//unload reset event
	timer.OnReset -= vars.resetAction;

	vars.tokenSource.Cancel();
}
