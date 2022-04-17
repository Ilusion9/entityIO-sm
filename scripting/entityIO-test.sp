#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <entityIO>

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
	
	// has entity this output?
	if (EntityIO_HasEntityInput(caller, "Use"))
	{
		PrintToServer("(func_button) Found \"OnPressed\" output for func_button.");
	}
	
	DisplayEntityOutputActions(caller, output);
	DisplayEntityInputs(caller);
	DisplayEntityOutputs(caller);
}

public void EntityIO_OnEntityInput(int entity, const char[] input, int caller, int activator, EntityIO_FieldType paramType, any paramValue, const any[] paramArray, const char[] paramString, int outputId)
{
	char classname[256];
	GetEntityClassname(entity, classname, sizeof(classname));
	
	if (!StrEqual(classname, "func_button", true))
	{
		return;
	}
	
	// search for Use inputs
	if (!StrEqual(input, "Use", false))
	{
		return;
	}
	
	// has entity this input?
	if (EntityIO_HasEntityInput(entity, "Use"))
	{
		PrintToServer("(func_button) Found \"Use\" input for func_button.");
	}
}

void DisplayEntityOutputActions(int entity, const char[] output)
{
	// find entity's output offset (OnPressed)
	int offset = EntityIO_FindEntityOutputOffset(entity, output);
	if (offset == -1)
	{
		return;
	}
	
	PrintToServer("(func_button) Output offset for OnPressed: %d.", offset);
	
	// get all actions of entity's OnPressed output
	PrintToServer("(func_button) Get all actions of OnPressed.");
	
	Address address;
	if (EntityIO_FindEntityFirstOutputAction(entity, offset, address))
	{
		do
		{
			char target[256];
			EntityIO_GetEntityOutputActionTarget(address, target, sizeof(target));
			
			char input[256];
			EntityIO_GetEntityOutputActionInput(address, input, sizeof(input));
			
			char param[256];
			EntityIO_GetEntityOutputActionParam(address, param, sizeof(param));
			
			PrintToServer("(func_button) Action: %s:%s:%s:%f:%d (Id: %d).", target, input, param, EntityIO_GetEntityOutputActionDelay(address), EntityIO_GetEntityOutputActionTimesToFire(address), EntityIO_GetEntityOutputActionID(address));
			
		} while (EntityIO_FindEntityNextOutputAction(address));
	}
	else
	{
		PrintToServer("(func_button) No actions of OnPressed found.");
	}
}

void DisplayEntityInputs(int entity)
{
	// iterate through entity's inputs
	PrintToServer("(func_button) Get all inputs.");
	
	Address dataMap, address;
	if (EntityIO_FindEntityFirstInput(entity, dataMap, address))
	{
		do
		{
			char output[256];
			EntityIO_GetEntityInputName(address, output, sizeof(output));
			
			PrintToServer("(func_button) Input: %s.", output);
			
		} while (EntityIO_FindEntityNextInput(dataMap, address));
	}
	else
	{
		PrintToServer("(func_button) No inputs.");
	}
}

void DisplayEntityOutputs(int entity)
{
	// iterate through entity's outputs
	PrintToServer("(func_button) Get all outputs.");
	
	Address dataMap, address;
	if (EntityIO_FindEntityFirstOutput(entity, dataMap, address))
	{
		do
		{
			char output[256];
			EntityIO_GetEntityOutputName(address, output, sizeof(output));
			
			PrintToServer("(func_button) Output: %s (Offset: %d).", output, EntityIO_GetEntityOutputOffset(address));
			
		} while (EntityIO_FindEntityNextOutput(dataMap, address));
	}
	else
	{
		PrintToServer("(func_button) No outputs.");
	}
}