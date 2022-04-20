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
	
	DisplayEntityOutputActions(caller, output);
	PrintToServer("\n");
	
	DisplayEntityInputs(caller);
	PrintToServer("\n");
	
	DisplayEntityOutputs(caller);
	PrintToServer("\n");
}

public Action EntityIO_OnEntityInput(int entity, char input[256], int& activator, int& caller, EntityIO_VariantInfo variantInfo, int outputId)
{
	switch (variantInfo.variantType)
	{
		case EntityIO_VariantType_None:
		{
			PrintToServer("(EntityIO_OnEntityInput) %s : activator %d : caller %d : param void : %d", input, activator, caller, outputId);
		}
		
		case EntityIO_VariantType_Float: 
		{
			PrintToServer("(EntityIO_OnEntityInput) %s : activator %d : caller %d : param float : %f : %d", input, activator, caller, variantInfo.flValue, outputId);
		}
		
		case EntityIO_VariantType_String:
		{
			PrintToServer("(EntityIO_OnEntityInput) %s : activator %d : caller %d : param string : %s : %d", input, activator, caller, variantInfo.sValue, outputId);
		}
		
		case EntityIO_VariantType_Vector:
		{
			PrintToServer("(EntityIO_OnEntityInput) %s : activator %d : caller %d : param vec : %f %f %f : %d", input, activator, caller, variantInfo.vecValue[0], variantInfo.vecValue[1], variantInfo.vecValue[2], outputId);
		}
		
		case EntityIO_VariantType_Integer: 
		{
			PrintToServer("(EntityIO_OnEntityInput) %s : activator %d : caller %d : param int : %d : %d", input, activator, caller, variantInfo.iValue, outputId);
		}
		
		case EntityIO_VariantType_Boolean: 
		{
			PrintToServer("(EntityIO_OnEntityInput) %s : activator %d : caller %d : param bool : %d : %d", input, activator, caller, variantInfo.bValue, outputId);
		}
		
		case EntityIO_VariantType_Character: 
		{
			PrintToServer("(EntityIO_OnEntityInput) %s : activator %d : caller %d : param char : %c : %d", input, activator, caller, view_as<char>(variantInfo.iValue), outputId);
		}
		
		case EntityIO_VariantType_Color:
		{
			PrintToServer("(EntityIO_OnEntityInput) %s : activator %d : caller %d : param color : %d %d %d %d : %d", input, activator, caller, variantInfo.clrValue[0], variantInfo.clrValue[1], variantInfo.clrValue[2], variantInfo.clrValue[3], outputId);
		}
		
		case EntityIO_VariantType_Entity: 
		{
			PrintToServer("(EntityIO_OnEntityInput) %s : activator %d : caller %d : param entity : %d : %d", input, activator, caller, variantInfo.iValue, outputId);
		}
		
		case EntityIO_VariantType_PosVector:
		{
			PrintToServer("(EntityIO_OnEntityInput) %s : activator %d : caller %d : param pos vec : %f %f %f : %d", input, activator, caller, variantInfo.vecValue[0], variantInfo.vecValue[1], variantInfo.vecValue[2], outputId);
		}
	}
	
	return Plugin_Continue;
}

public void EntityIO_OnEntityInput_Post(int entity, const char[] input, int activator, int caller, EntityIO_VariantInfo variantInfo, int outputId)
{	
	switch (variantInfo.variantType)
	{
		case EntityIO_VariantType_None:
		{
			PrintToServer("(EntityIO_OnEntityInput_Post) %s : activator %d : caller %d : param void : %d", input, activator, caller, outputId);
		}
		
		case EntityIO_VariantType_Float: 
		{
			PrintToServer("(EntityIO_OnEntityInput_Post) %s : activator %d : caller %d : param float : %f : %d", input, activator, caller, variantInfo.flValue, outputId);
		}
		
		case EntityIO_VariantType_String:
		{
			PrintToServer("(EntityIO_OnEntityInput_Post) %s : activator %d : caller %d : param string : %s : %d", input, activator, caller, variantInfo.sValue, outputId);
		}
		
		case EntityIO_VariantType_Vector:
		{
			PrintToServer("(EntityIO_OnEntityInput_Post) %s : activator %d : caller %d : param vec : %f %f %f : %d", input, activator, caller, variantInfo.vecValue[0], variantInfo.vecValue[1], variantInfo.vecValue[2], outputId);
		}
		
		case EntityIO_VariantType_Integer: 
		{
			PrintToServer("(EntityIO_OnEntityInput_Post) %s : activator %d : caller %d : param int : %d : %d", input, activator, caller, variantInfo.iValue, outputId);
		}
		
		case EntityIO_VariantType_Boolean: 
		{
			PrintToServer("(EntityIO_OnEntityInput_Post) %s : activator %d : caller %d : param bool : %d : %d", input, activator, caller, variantInfo.bValue, outputId);
		}
		
		case EntityIO_VariantType_Character: 
		{
			PrintToServer("(EntityIO_OnEntityInput_Post) %s : activator %d : caller %d : param char : %c : %d", input, activator, caller, view_as<char>(variantInfo.iValue), outputId);
		}
		
		case EntityIO_VariantType_Color:
		{
			PrintToServer("(EntityIO_OnEntityInput_Post) %s : activator %d : caller %d : param color : %d %d %d %d : %d", input, activator, caller, variantInfo.clrValue[0], variantInfo.clrValue[1], variantInfo.clrValue[2], variantInfo.clrValue[3], outputId);
		}
		
		case EntityIO_VariantType_Entity: 
		{
			PrintToServer("(EntityIO_OnEntityInput_Post) %s : activator %d : caller %d : param entity : %d : %d", input, activator, caller, variantInfo.iValue, outputId);
		}
		
		case EntityIO_VariantType_PosVector:
		{
			PrintToServer("(EntityIO_OnEntityInput_Post) %s : activator %d : caller %d : param pos vec : %f %f %f : %d", input, activator, caller, variantInfo.vecValue[0], variantInfo.vecValue[1], variantInfo.vecValue[2], outputId);
		}
	}
	
	PrintToServer("\n");
}

void DisplayEntityOutputActions(int entity, const char[] output)
{
	int offset = EntityIO_FindEntityOutputOffset(entity, output);
	if (offset == -1)
	{
		return;
	}
	
	PrintToServer("(func_button) Output offset for OnPressed: %d.", offset);
	PrintToServer("\n");
	
	PrintToServer("(func_button) Get all actions of entity (OnPressed output).");
	
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
		PrintToServer("(func_button) No actions of entity found (OnPressed output).");
	}
}

void DisplayEntityInputs(int entity)
{
	PrintToServer("(func_button) Get all inputs of entity.");
	
	Address dataMap, address;
	if (EntityIO_FindEntityFirstInput(entity, dataMap, address))
	{
		do
		{
			char input[256];
			EntityIO_GetEntityInputName(address, input, sizeof(input));
			
			PrintToServer("(func_button) Input: %s.", input);
			
		} while (EntityIO_FindEntityNextInput(dataMap, address));
	}
	else
	{
		PrintToServer("(func_button) No inputs of entity found.");
	}
}

void DisplayEntityOutputs(int entity)
{
	PrintToServer("(func_button) Get all outputs of entity.");
	
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
		PrintToServer("(func_button) No outputs of entity found.");
	}
}