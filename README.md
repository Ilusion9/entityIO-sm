# Descriptions
Forwards and Natives for entity inputs and outputs. Only tested in CSGO (windows and linux) and CSS (windows). Might work in TF2, L4D2, DOD.

# Dependencies
dhooks - https://forums.alliedmods.net/showpost.php?p=2588686&postcount=589

# Game Bugs
If you change map entities with Stripper (or other plugins based on OnLevelInit), then the paramType in EntityIO_OnEntityInput or EntityIO_OnEntityInput_Post can be EntityIO_VariantType_String.

# Examples
## Display Inputs
```sourcepawn
Handle inputIter = EntityIO_FindEntityFirstInput(entity);
if (inputIter)
{
	do
	{
		char input[256];
		EntityIO_GetEntityInputName(inputIter, input, sizeof(input));
		
		PrintToServer("Input: %s.", input);
		
	} while (EntityIO_FindEntityNextInput(inputIter));
}

delete inputIter;
```

## Display Outputs
```sourcepawn
Handle outputIter = EntityIO_FindEntityFirstOutput(entity);
if (outputIter)
{
	do
	{
		char output[256];
		EntityIO_GetEntityOutputName(outputIter, output, sizeof(output));
		
		PrintToServer("Output: %s (Offset: %d).", output, EntityIO_GetEntityOutputOffset(outputIter));
		
	} while (EntityIO_FindEntityNextOutput(outputIter));
}

delete outputIter;
```

## Display Output Actions
```sourcepawn
public void OnPluginStart()
{
	HookEntityOutput("func_button", "OnPressed", Output_OnEntityOutput);
}

public void Output_OnEntityOutput(const char[] output, int caller, int activator, float delay)
{
	if (!IsValidEntity(caller))
	{
		return;
	}
	
	int offset = EntityIO_FindEntityOutputOffset(entity, output);
	if (offset == -1)
	{
		return;
	}
	
	Handle actionIter = EntityIO_FindEntityFirstOutputAction(entity, offset);
	if (actionIter)
	{
		do
		{
			char target[256];
			EntityIO_GetEntityOutputActionTarget(actionIter, target, sizeof(target));
			
			char input[256];
			EntityIO_GetEntityOutputActionInput(actionIter, input, sizeof(input));
			
			char param[256];
			EntityIO_GetEntityOutputActionParam(actionIter, param, sizeof(param));
			
			PrintToServer("Action (Output: %s): %s:%s:%s:%f:%d (Id: %d).", output, target, input, param, EntityIO_GetEntityOutputActionDelay(actionIter), EntityIO_GetEntityOutputActionTimesToFire(actionIter), EntityIO_GetEntityOutputActionID(actionIter));
			
		} while (EntityIO_FindEntityNextOutputAction(actionIter));
	}
	
	delete actionIter;
}
```
