//Made by Coltaho 2/25/2019

state("fceux", "v2.2.3")
{
	byte enemyhp : 0x436B04, 0x467;
	byte enemyid : 0x436B04, 0x44F; //Number the enemy appears in the stage, 255 if despawned
	byte myhp : 0x436B04, 0xB0; //128 is dead (disregards high bit)
	byte soundfx : 0x436B04, 0x702; //65 is teleport
	byte stage : 0x436B04, 0x22;
	byte screen : 0x436B04, 0xCB; //1 on intro screen
	byte selection : 0x436B04, 0x200; //151 on Game Start
	byte levelscreen : 0x436B04, 0xF9 //actual screen num in stage
}

state("fceux", "v2.6.4")
{
	byte enemyhp : 0x3DA4EC, 0x467;
	byte enemyid : 0x3DA4EC, 0x44F; //Number the enemy appears in the stage, 255 if despawned
	byte myhp : 0x3DA4EC, 0xB0; //128 is dead (disregards high bit)
	byte soundfx : 0x3DA4EC, 0x702; //65 is teleport
	byte stage : 0x3DA4EC, 0x22;
	byte screen : 0x3DA4EC, 0xCB; //1 on intro screen
	byte selection : 0x3DA4EC, 0x200; //151 on Game Start
	byte levelscreen : 0x3DA4EC, 0xF9 //actual screen num in stage
}

state("nestopia")
{
	// base 0x0000 address of ROM : "nestopia.exe", 0x1b2bcc, 0, 8, 0xc, 0xc, 0x68;
	// just add your fceux offset to 0x68 to get the final nestopia offset
	byte enemyhp : "nestopia.exe", 0x1b2bcc, 0, 8, 0xc, 0xc, 0x4CF;
	byte enemyid : "nestopia.exe", 0x1b2bcc, 0, 8, 0xc, 0xc, 0x4B7;
	byte myhp : "nestopia.exe", 0x1b2bcc, 0, 8, 0xc, 0xc, 0x118;
	byte soundfx : "nestopia.exe", 0x1b2bcc, 0, 8, 0xc, 0xc, 0x76A;
	byte stage : "nestopia.exe", 0x1b2bcc, 0, 8, 0xc, 0xc, 0x8A;
	byte screen : "nestopia.exe", 0x1b2bcc, 0, 8, 0xc, 0xc, 0x133;
	byte selection : "nestopia.exe", 0x1b2bcc, 0, 8, 0xc, 0xc, 0x268;
	byte levelscreen : "nestopia.exe", 0x1b2bcc, 0, 8, 0xc, 0xc, 0x161;
}

startup
{
	settings.Add("optionsection", true, "---Options---");
	settings.Add("cossackfade", true, "Split at fade out after Cossack 4", "optionsection");
	
	settings.Add("infosection", true, "---Info---");
	settings.Add("info", true, "Mega Man 4 Autosplitter v1.2 by Coltaho", "infosection");
	settings.Add("info0", true, "- Supported emulators : FCEUX, Netstopia (maybe)", "infosection");
	settings.Add("info1", true, "- Website : https://github.com/Coltaho/Autosplitters", "infosection");
}

init
{
	print("--Setting init variables!--");
	refreshRate = 60;
	
	if (modules.First().ModuleMemorySize == 0x487000)
        version = "v2.2.3";
    else if (modules.First().ModuleMemorySize == 0x603000)
        version = "v2.6.4";
}

start {
	if (current.screen == 2 && current.selection == 151 && current.soundfx == 6 && old.soundfx != 6) {
		print("--Starting--");
		return true;
	}
}

reset {
	if (current.stage == 16 && current.screen == 0 && current.soundfx == 0 && current.enemyid == 0) {
		print("--Resetting--");
		return true;
	}	
}

update {
	// print("--Stage: " + current.stage + " | LevelScreen: " + current.levelscreen + " | EnemyID: " + current.enemyid + " | EnemyHP: " + current.enemyhp + " | SFX: " + current.soundfx);
}

split
{
	if (old.soundfx == 67 && current.soundfx == 65 && !(current.levelscreen == 10 && current.stage == 3)) {
		print("--Teleport Split--");
		return true;
	}
	
	if (settings["cossackfade"] && old.stage == 11 && current.stage == 18 && current.soundfx == 0) {
		print("--Cossack 4 Split on Fade--");
		return true;
	}
	
	if (current.stage == 15 && old.enemyid == 6 && current.enemyid == 255 && current.enemyhp == 0 && old.enemyhp > 0 && current.myhp > 128) {
		print("--Wily Capsule killed! Game beaten!--");
		return true;
	}
}
