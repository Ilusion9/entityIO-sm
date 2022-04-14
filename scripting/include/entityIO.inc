#if defined _entityIO_included
 #endinput
#endif
#define _entityIO_included

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
 * @param outputId           Output's ID.
 */
forward void EntityIO_OnEntityInput(int entity, const char[] input, int caller, int activator, EntityIO_FieldType paramType, any paramValue, const any[] paramArray, const char[] paramString, int outputId);

/**
 * Retrieves an action's target from an entity's output.
 *
 * @param address        Action's address.
 * @param target         Buffer to store the action's target.
 * @param maxLen         Maximum length of string buffer.
 * @error                Invalid address.
 * @return               Number of cells written.
 */
native int EntityIO_GetEntityOutputActionTarget(Address address, char[] target, int maxLen);

/**
 * Retrieves an action's input from an entity's output.
 *
 * @param address        Action's address.
 * @param input          Buffer to store the action's input.
 * @param maxLen         Maximum length of string buffer.
 * @error                Invalid address.
 * @return               Number of cells written.
 */
native int EntityIO_GetEntityOutputActionInput(Address address, char[] input, int maxLen);

/**
 * Retrieves an action's parameter from an entity's output.
 *
 * @param address        Action's address.
 * @param param          Buffer to store the action's parameter.
 * @param maxLen         Maximum length of string buffer.
 * @error                Invalid address.
 * @return               Number of cells written.
 */
native int EntityIO_GetEntityOutputActionParam(Address address, char[] param, int maxLen);

/**
 * Retrieves an action's remaining times to fire from an entity's output.
 *
 * @param address        Action's address.
 * @error                Invalid address.
 * @return               Action's remaining times to fire.
 */
native int EntityIO_GetEntityOutputActionTimesToFire(Address address);

/**
 * Retrieves an action's ID from an entity's output.
 *
 * @param address        Action's address.
 * @error                Invalid address.
 * @return               Action's ID.
 */
native int EntityIO_GetEntityOutputActionID(Address address);

/**
 * Retrieves an action's delay from an entity's output.
 *
 * @param address        Action's address.
 * @error                Invalid address.
 * @return               Action's delay.
 */
native float EntityIO_GetEntityOutputActionDelay(Address address);

/**
 * Retrieves the first action's address from an entity's output.
 *
 * @param entity        Entity's index.
 * @param output        Output's name from the entity's datamap.
 * @error               Invalid entity index.
 * @return              The action's address.
 */
native Address EntityIO_FindEntityFirstOutputAction(int entity, const char[] output);

/**
 * Retrieves the next action's address from an entity's output.
 *
 * @param address        The address after which to begin searching from.
 * @error                Invalid address.
 * @return               The next action's address.
 */
native Address EntityIO_FindEntityNextOutputAction(Address address);

/* DO NOT EDIT BELOW THIS LINE */

public SharedPlugin __pl_entityIO = 
{
	name = "entityIO",
	file = "entityIO.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_entityIO_SetNTVOptional()
{
	MarkNativeAsOptional("EntityIO_HookEntityInputs");
	MarkNativeAsOptional("EntityIO_UnhookEntityInputs");
	MarkNativeAsOptional("EntityIO_GetEntityOutputActionTarget");
	MarkNativeAsOptional("EntityIO_GetEntityOutputActionInput");
	MarkNativeAsOptional("EntityIO_GetEntityOutputActionParams");
	MarkNativeAsOptional("EntityIO_GetEntityOutputActionDelay");
	MarkNativeAsOptional("EntityIO_GetEntityOutputActionTimesToFire");
	MarkNativeAsOptional("EntityIO_GetEntityOutputActionID");
	MarkNativeAsOptional("EntityIO_FindEntityFirstOutputAction");
	MarkNativeAsOptional("EntityIO_FindEntityNextOutputAction");
}
#endif