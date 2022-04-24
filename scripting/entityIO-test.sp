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
	
	DisplayEntityInputs(caller);
	PrintToServer("\n");
	
	DisplayEntityOutputs(caller);
	PrintToServer("\n");
	
	DisplayEntityOutputActions(caller, output);
	PrintToServer("\n");
	
	DisplayAllEntityActions(caller);
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

void DisplayEntityInputs(int entity)
{
	char className[256];
	GetEntityClassname(entity, className, sizeof(className));
	
	PrintToServer("Get all inputs of entity index %d (%s).", entity, className);
	
	Handle inputIter = EntityIO_FindEntityFirstInput(entity);
	if (inputIter)
	{
		do
		{
			char input[256];
			EntityIO_GetEntityInputName(inputIter, input, sizeof(input));
			
			PrintToServer("Input of entity index %d (%s): %s.", entity, className, input);
			
		} while (EntityIO_FindEntityNextInput(inputIter));
	}
	else
	{
		PrintToServer("No inputs of entity index %d (%s) found.", entity, className);
	}
	
	delete inputIter;
}

void DisplayEntityOutputs(int entity)
{
	char className[256];
	GetEntityClassname(entity, className, sizeof(className));
	
	PrintToServer("Get all outputs of entity index %d (%s).", entity, className);
	
	Handle outputIter = EntityIO_FindEntityFirstOutput(entity);
	if (outputIter)
	{
		do
		{
			char output[256];
			EntityIO_GetEntityOutputName(outputIter, output, sizeof(output));
			
			PrintToServer("Output of entity index %d (%s): %s (Offset: %d).", entity, className, output, EntityIO_GetEntityOutputOffset(outputIter));
			
		} while (EntityIO_FindEntityNextOutput(outputIter));
	}
	else
	{
		PrintToServer("No outputs of entity index %d (%s) found.", entity, className);
	}
	
	delete outputIter;
}

void DisplayEntityOutputActions(int entity, const char[] output)
{
	int offset = EntityIO_FindEntityOutputOffset(entity, output);
	if (offset == -1)
	{
		return;
	}
	
	char className[256];
	GetEntityClassname(entity, className, sizeof(className));
	
	PrintToServer("Get all actions of entity index %d (%s) (Output: %s).", entity, className, output);
	
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
			
			PrintToServer("Action of entity index %d (%s) (Output: %s): %s:%s:%s:%f:%d (Id: %d).", entity, className, output, target, input, param, EntityIO_GetEntityOutputActionDelay(actionIter), EntityIO_GetEntityOutputActionTimesToFire(actionIter), EntityIO_GetEntityOutputActionID(actionIter));
			
		} while (EntityIO_FindEntityNextOutputAction(actionIter));
	}
	else
	{
		PrintToServer("No actions of entity index %d (%s) (Output: %s).", entity, className, output);
	}
	
	delete actionIter;
}

void DisplayAllEntityActions(int entity)
{
	char className[256];
	GetEntityClassname(entity, className, sizeof(className));
	
	PrintToServer("Get all actions of entity index %d (%s).", entity, className);
	
	Handle outputIter = EntityIO_FindEntityFirstOutput(entity);
	if (outputIter)
	{
		do
		{
			char output[256];
			EntityIO_GetEntityOutputName(outputIter, output, sizeof(output));
			
			int offset = EntityIO_GetEntityOutputOffset(outputIter);
			
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
					
					PrintToServer("Action of entity index %d (%s) (Output: %s): %s:%s:%s:%f:%d (Id: %d).", entity, className, output, target, input, param, EntityIO_GetEntityOutputActionDelay(actionIter), EntityIO_GetEntityOutputActionTimesToFire(actionIter), EntityIO_GetEntityOutputActionID(actionIter));
					
				} while (EntityIO_FindEntityNextOutputAction(actionIter));
			}
			else
			{
				PrintToServer("No actions of entity index %d (%s) (Output: %s).", entity, className, output);
			}
			
			delete actionIter;
			
		} while (EntityIO_FindEntityNextOutput(outputIter));
	}
	else
	{
		PrintToServer("(func_button) No outputs of entity found.");
	}
	
	delete outputIter;
}