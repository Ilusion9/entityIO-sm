# Descriptions
Hook or get informations about entity inputs and outputs.

# Dependencies
dhooks - https://forums.alliedmods.net/showpost.php?p=2588686&postcount=589

# Game Bugs
If you change map entities with Stripper (or other plugins based on OnLevelInit), then the paramType in EntityIO_OnEntityInput can be EntityIO_FieldType_String.

# Enums
```sourcepawn
enum EntityIO_FieldType
{
	EntityIO_FieldType_None,
	EntityIO_FieldType_Float,
	EntityIO_FieldType_String,
	EntityIO_FieldType_Vector,
	EntityIO_FieldType_Integer,
	EntityIO_FieldType_Boolean,
	EntityIO_FieldType_Character,
	EntityIO_FieldType_Color,
	EntityIO_FieldType_Entity
}
```

# Forwards
```sourcepawn
/**
 * Called when an entity receives an input.
 *
 * @param entity             Entity's index.
 * @param input              Input's name.
 * @param caller             Caller's index.
 * @param activator          Activator's index.
 * @param paramType          Parameter's type.
 * @param paramValue         Parameter's value.
 * @param paramArray         Parameter's value as an array.
 * @param paramString        Parameter's value as a string.
 * @param outputID           Output's ID.
 */
void EntityIO_OnEntityInput(int entity, const char[] input, int caller, int activator, EntityIO_FieldType paramType, any paramValue, const any[] paramArray, const char[] paramString, int outputId);
```

# Natives
```sourcepawn
/**
 * Retrieves an action's target from an entity's output.
 *
 * @param address        Action's address.
 * @param target         Buffer to store the action's target.
 * @param maxLen         Maximum length of string buffer.
 * @error                Invalid address.
 * @return               Number of cells written.
 */
int EntityIO_GetEntityOutputActionTarget(Address address, char[] target, int maxLen);

/**
 * Retrieves an action's input from an entity's output.
 *
 * @param address        Action's address.
 * @param input          Buffer to store the action's input.
 * @param maxLen         Maximum length of string buffer.
 * @error                Invalid address.
 * @return               Number of cells written.
 */
int EntityIO_GetEntityOutputActionInput(Address address, char[] input, int maxLen);

/**
 * Retrieves an action's parameter from an entity's output.
 *
 * @param address        Action's address.
 * @param param          Buffer to store the action's parameter.
 * @param maxLen         Maximum length of string buffer.
 * @error                Invalid address.
 * @return               Number of cells written.
 */
int EntityIO_GetEntityOutputActionParam(Address address, char[] param, int maxLen);

/**
 * Retrieves an action's remaining times to fire from an entity's output.
 *
 * @param address        Action's address.
 * @error                Invalid address.
 * @return               Action's remaining times to fire.
 */
int EntityIO_GetEntityOutputActionTimesToFire(Address address);

/**
 * Retrieves an action's ID from an entity's output.
 *
 * @param address        Action's address.
 * @error                Invalid address.
 * @return               Action's ID.
 */
int EntityIO_GetEntityOutputActionID(Address address);

/**
 * Retrieves an action's delay from an entity's output.
 *
 * @param address        Action's address.
 * @error                Invalid address.
 * @return               Action's delay.
 */
float EntityIO_GetEntityOutputActionDelay(Address address);

/**
 * Retrieves the first action's address from an entity's output.
 *
 * @param entity        Entity's index.
 * @param output        Output's name from the entity's datamap.
 * @error               Invalid entity index.
 * @return              The action's address.
 */
Address EntityIO_FindEntityFirstOutputAction(int entity, const char[] output);

/**
 * Retrieves the next action's address from an entity's output.
 *
 * @param address        The address after which to begin searching from.
 * @error                Invalid address.
 * @return               The next action's address.
 */
Address EntityIO_FindEntityNextOutputAction(Address address);
```

# Examples
## Get entity output actions
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
	
	Address address = EntityIO_FindEntityFirstOutputAction(entity, "m_OnPressed");
	if (address != Address_Null)
	{
		do
		{
			char target[256];
			EntityIO_GetEntityOutputActionTarget(address, target, sizeof(target));
			
			char input[256];
			EntityIO_GetEntityOutputActionInput(address, input, sizeof(input));
			
			char params[256];
			EntityIO_GetEntityOutputActionParam(address, params, sizeof(params));
			
			float delay = EntityIO_GetEntityOutputActionDelay(address);
			int timesToFire = EntityIO_GetEntityOutputActionTimesToFire(address);
			int IDStamp = EntityIO_GetEntityOutputActionID(address);
		}
		
	} while ((address = EntityIO_FindEntityNextOutputAction(address)) != Address_Null);
}
```
