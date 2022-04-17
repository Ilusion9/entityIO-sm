#pragma semicolon 1
#pragma dynamic 1048576
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <dhooks>

public Plugin myinfo =
{
	name = "Entity Inputs & Outputs",
	author = "Ilusion",
	description = "Hook or get informations about entity inputs and outputs.",
	version = "1.0",
	url = "https://github.com/Ilusion9/"
};

#define FIELDTYPE_FLOAT                  1
#define FIELDTYPE_STRING                 2
#define FIELDTYPE_VECTOR                 3
#define FIELDTYPE_INTEGER                5
#define FIELDTYPE_BOOLEAN                6
#define FIELDTYPE_SHORT                  7
#define FIELDTYPE_CHARACTER              8
#define FIELDTYPE_COLOR32                9
#define FIELDTYPE_CLASSPTR               12
#define FIELDTYPE_EHANDLE                13
#define FIELDTYPE_POSITION_VECTOR        15

#define FIELDTYPE_DESC_INPUT         8
#define FIELDTYPE_DESC_OUTPUT        16

enum FieldType
{
	FieldType_None,
	FieldType_Float,
	FieldType_String,
	FieldType_Vector,
	FieldType_Integer,
	FieldType_Boolean,
	FieldType_Character,
	FieldType_Color,
	FieldType_Entity
}

enum struct ParamInfo
{
	bool bValue;
	int iValue;
	float flValue;
	char sValue[256];
	int clrValue[4];
	float vecValue[3];
	FieldType fieldType;
}

int g_Offset_ActionList;
int g_Offset_ActionTarget;
int g_Offset_ActionInput;
int g_Offset_ActionParam;
int g_Offset_ActionDelay;
int g_Offset_ActionTimesToFire;
int g_Offset_ActionIDStamp;
int g_Offset_ActionNextIDStamp;
int g_Offset_DataDescMap;
int g_Offset_DataBaseMap;
int g_Offset_DataNumFields;
int g_Offset_DataFieldOffset;
int g_Offset_DataFieldFlags;
int g_Offset_DataFieldName;
int g_Offset_DataFieldSize;

GlobalForward g_Forward_OnEntityInput;
Handle g_DHook_AcceptInput;
Handle g_SDKCall_GetDataDescMap;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("EntityIO_FindEntityFirstInput", Native_FindEntityFirstInput);
	CreateNative("EntityIO_FindEntityNextInput", Native_FindEntityNextInput);
	CreateNative("EntityIO_FindEntityFirstOutput", Native_FindEntityFirstOutput);
	CreateNative("EntityIO_FindEntityNextOutput", Native_FindEntityNextOutput);
	CreateNative("EntityIO_FindEntityOutputOffset", Native_FindEntityOutputOffset);
	CreateNative("EntityIO_FindEntityFirstOutputAction", Native_FindEntityFirstOutputAction);
	CreateNative("EntityIO_FindEntityNextOutputAction", Native_FindEntityNextOutputAction);
	
	CreateNative("EntityIO_HasEntityInput", Native_HasEntityInput);
	CreateNative("EntityIO_HasEntityOutput", Native_HasEntityOutput);
	
	CreateNative("EntityIO_AddEntityOutputAction", Native_AddEntityOutputAction);
	
	CreateNative("EntityIO_GetEntityInputName", Native_GetEntityInputName);
	CreateNative("EntityIO_GetEntityOutputName", Native_GetEntityOutputName);
	CreateNative("EntityIO_GetEntityOutputOffset", Native_GetEntityOutputOffset);
	CreateNative("EntityIO_GetEntityOutputActionTarget", Native_GetEntityOutputActionTarget);
	CreateNative("EntityIO_GetEntityOutputActionInput", Native_GetEntityOutputActionInput);
	CreateNative("EntityIO_GetEntityOutputActionParam", Native_GetEntityOutputActionParam);
	CreateNative("EntityIO_GetEntityOutputActionDelay", Native_GetEntityOutputActionDelay);
	CreateNative("EntityIO_GetEntityOutputActionTimesToFire", Native_GetEntityOutputActionTimesToFire);
	CreateNative("EntityIO_GetEntityOutputActionID", Native_GetEntityOutputActionID);
	
	RegPluginLibrary("entityIO");
}

public void OnPluginStart()
{	
	Handle configFile = LoadGameConfigFile("entityIO.games");
	if (!configFile)
	{
		SetFailState("Failed to load \"entityIO.games\" gamedata.");
	}
	
	int acceptInputOffset = GameConfGetOffset(configFile, "CBaseEntity::AcceptInput");
	if (acceptInputOffset == -1)
	{
		SetFailState("Failed to load \"CBaseEntity::AcceptInput\" offset.");
	}
	
	g_Offset_ActionList = GameConfGetOffset(configFile, "CBaseEntityOutput::m_ActionList");
	if (g_Offset_ActionList == -1)
	{
		SetFailState("Failed to load \"CBaseEntityOutput::m_ActionList\" offset.");
	}
	
	g_Offset_ActionTarget = GameConfGetOffset(configFile, "CEventAction::m_iTarget");
	if (g_Offset_ActionTarget == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_iTarget\" offset.");
	}
	
	g_Offset_ActionInput = GameConfGetOffset(configFile, "CEventAction::m_iTargetInput");
	if (g_Offset_ActionInput == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_iTargetInput\" offset.");
	}
	
	g_Offset_ActionParam = GameConfGetOffset(configFile, "CEventAction::m_iParameter");
	if (g_Offset_ActionParam == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_iParameter\" offset.");
	}
	
	g_Offset_ActionDelay = GameConfGetOffset(configFile, "CEventAction::m_flDelay");
	if (g_Offset_ActionDelay == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_flDelay\" offset.");
	}
	
	g_Offset_ActionTimesToFire = GameConfGetOffset(configFile, "CEventAction::m_nTimesToFire");
	if (g_Offset_ActionTimesToFire == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_nTimesToFire\" offset.");
	}
	
	g_Offset_ActionIDStamp = GameConfGetOffset(configFile, "CEventAction::m_iIDStamp");
	if (g_Offset_ActionIDStamp == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_iIDStamp\" offset.");
	}
	
	g_Offset_ActionNextIDStamp = GameConfGetOffset(configFile, "CEventAction::s_iNextIDStamp");
	if (g_Offset_ActionNextIDStamp == -1)
	{
		SetFailState("Failed to load \"CEventAction::s_iNextIDStamp\" offset.");
	}
	
	int getDataDescMapOffset = GameConfGetOffset(configFile, "CBaseEntity::GetDataDescMap");
	if (getDataDescMapOffset == -1)
	{
		SetFailState("Failed to load \"CBaseEntity::GetDataDescMap\" offset.");
	}
	
	g_Offset_DataDescMap = GameConfGetOffset(configFile, "datamap_t::dataDesc");
	if (g_Offset_DataDescMap == -1)
	{
		SetFailState("Failed to load \"datamap_t::dataDesc\" offset.");
	}
	
	g_Offset_DataBaseMap = GameConfGetOffset(configFile, "datamap_t::baseMap");
	if (g_Offset_DataBaseMap == -1)
	{
		SetFailState("Failed to load \"datamap_t::baseMap\" offset.");
	}
	
	g_Offset_DataNumFields = GameConfGetOffset(configFile, "datamap_t::dataNumFields");
	if (g_Offset_DataNumFields == -1)
	{
		SetFailState("Failed to load \"datamap_t::dataNumFields\" offset.");
	}
	
	g_Offset_DataFieldOffset = GameConfGetOffset(configFile, "typedescription_t::fieldOffset");
	if (g_Offset_DataFieldOffset == -1)
	{
		SetFailState("Failed to load \"typedescription_t::fieldOffset\" offset.");
	}
	
	g_Offset_DataFieldFlags = GameConfGetOffset(configFile, "typedescription_t::flags");
	if (g_Offset_DataFieldFlags == -1)
	{
		SetFailState("Failed to load \"typedescription_t::flags\" offset.");
	}
	
	g_Offset_DataFieldName = GameConfGetOffset(configFile, "typedescription_t::externalName");
	if (g_Offset_DataFieldName == -1)
	{
		SetFailState("Failed to load \"typedescription_t::externalName\" offset.");
	}
	
	g_Offset_DataFieldSize = GameConfGetOffset(configFile, "sizeof::typedescription_t");
	if (g_Offset_DataFieldSize == -1)
	{
		SetFailState("Failed to load \"sizeof::typedescription_t\" offset.");
	}
	
	delete configFile;
	
	g_Forward_OnEntityInput = new GlobalForward("EntityIO_OnEntityInput", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_Cell, Param_Any, Param_Array, Param_String, Param_Cell);
	
	g_DHook_AcceptInput = DHookCreate(acceptInputOffset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, DHook_AcceptInput);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_CharPtr);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_Object, 20, DHookPass_ByVal | DHookPass_ODTOR | DHookPass_OCTOR | DHookPass_OASSIGNOP);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_Int);
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetVirtual(getDataDescMapOffset);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_SDKCall_GetDataDescMap = EndPrepSDKCall();
	
	if (!g_SDKCall_GetDataDescMap)
	{
		SetFailState("Failed to set up \"GetDataDescMap\" call.");
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	DHookEntity(g_DHook_AcceptInput, false, entity);
}

public MRESReturn DHook_AcceptInput(int pThis, Handle hReturn, Handle hParams)
{
	char input[256];
	DHookGetParamString(hParams, 1, input, sizeof(input));
	
	int activator = -1;
	if (!DHookIsNullParam(hParams, 2))
	{
		activator = DHookGetParam(hParams, 2);
	}
	
	int caller = -1;
	if (!DHookIsNullParam(hParams, 3))
	{
		caller = DHookGetParam(hParams, 3);
	}
	
	ParamInfo paramInfo;
	int fieldType = DHookGetParamObjectPtrVar(hParams, 4, 16, ObjectValueType_Int);
	
	switch (fieldType)
	{
		case FIELDTYPE_FLOAT:
		{
			paramInfo.flValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Float);
			paramInfo.fieldType = FieldType_Float;
		}
		
		case FIELDTYPE_STRING:
		{
			DHookGetParamObjectPtrString(hParams, 4, 0, ObjectValueType_String, paramInfo.sValue, sizeof(ParamInfo::sValue));
			paramInfo.fieldType = FieldType_String;
		}
		
		case FIELDTYPE_VECTOR, FIELDTYPE_POSITION_VECTOR:
		{
			DHookGetParamObjectPtrVarVector(hParams, 4, 0, ObjectValueType_Vector, paramInfo.vecValue);
			paramInfo.fieldType = FieldType_Vector;
		}
		
		case FIELDTYPE_INTEGER, FIELDTYPE_SHORT:
		{
			paramInfo.iValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Int);
			paramInfo.fieldType = FieldType_Integer;
		}
		
		case FIELDTYPE_BOOLEAN:
		{
			paramInfo.bValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Bool);
			paramInfo.fieldType = FieldType_Boolean;
		}
		
		case FIELDTYPE_CHARACTER:
		{
			paramInfo.iValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Int);
			paramInfo.fieldType = FieldType_Character;
		}
		
		case FIELDTYPE_COLOR32:
		{
			int color = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Int);
			paramInfo.clrValue[0] = color & 0xFF;
			paramInfo.clrValue[1] = (color >> 8) & 0xFF;
			paramInfo.clrValue[2] = (color >> 16) & 0xFF;
			paramInfo.clrValue[3] = (color >> 24) & 0xFF;
			paramInfo.fieldType = FieldType_Color;
		}
		
		case FIELDTYPE_CLASSPTR, FIELDTYPE_EHANDLE:
		{
			paramInfo.iValue = DHookGetParamObjectPtrVar(hParams, 4, 0, ObjectValueType_Ehandle);
			paramInfo.fieldType = FieldType_Entity;
		}
		
		default:
		{
			paramInfo.fieldType = FieldType_None;
		}
	}
	
	int outputId = DHookGetParam(hParams, 5);	
	
	Call_StartForward(g_Forward_OnEntityInput);
	Call_PushCell(pThis);
	Call_PushString(input);
	Call_PushCell(caller);
	Call_PushCell(activator);
	Call_PushCell(paramInfo.fieldType);
	
	if (paramInfo.fieldType == FieldType_Boolean)
	{
		Call_PushCell(paramInfo.bValue);
		Call_PushNullVector();
		Call_PushNullString();
	}
	else if (paramInfo.fieldType == FieldType_Integer 
		|| paramInfo.fieldType == FieldType_Character 
		|| paramInfo.fieldType == FieldType_Entity)
	{
		Call_PushCell(paramInfo.iValue);
		Call_PushNullVector();
		Call_PushNullString();
	}
	else if (paramInfo.fieldType == FieldType_Float)
	{
		Call_PushFloat(paramInfo.flValue);
		Call_PushNullVector();
		Call_PushNullString();
	}
	else if (paramInfo.fieldType == FieldType_String)
	{
		Call_PushCell(0);
		Call_PushNullVector();
		Call_PushString(paramInfo.sValue);
	}
	else if (paramInfo.fieldType == FieldType_Color)
	{
		Call_PushCell(0);
		Call_PushArray(paramInfo.clrValue, sizeof(ParamInfo::clrValue));
		Call_PushNullString();
	}
	else if (paramInfo.fieldType == FieldType_Vector)
	{
		Call_PushCell(0);
		Call_PushArray(paramInfo.vecValue, sizeof(ParamInfo::vecValue));
		Call_PushNullString();
	}
	else
	{
		Call_PushCell(0);
		Call_PushNullVector();
		Call_PushNullString();
	}
	
	Call_PushCell(outputId);
	Call_Finish();
	
	return MRES_Ignored;
}

int GetStringFromAddress(Address address, char[] buffer, int maxLen)
{
	int i;
	while (i < maxLen)
	{
		buffer[i] = view_as<char>(LoadFromAddress(address + view_as<Address>(i), NumberType_Int8));
		if (!buffer[i])
		{
			break;
		}
		
		i++;
	}
	
	return i;
}

public int Native_FindEntityFirstInput(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	Address dataMap = view_as<Address>(SDKCall(g_SDKCall_GetDataDescMap, entity));
	if (dataMap == Address_Null)
	{
		return false;
	}
	
	while (dataMap != Address_Null)
	{
		int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		
		for (int i = 0; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
		{
			int flags = LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldFlags + i), NumberType_Int16);
			if (!view_as<bool>(flags & FIELDTYPE_DESC_INPUT))
			{
				continue;
			}
			
			SetNativeCellRef(2, dataMap);
			SetNativeCellRef(3, dataDesc + view_as<Address>(i));
			
			return true;
		}
		
		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	return false;
}

public int Native_FindEntityNextInput(Handle plugin, int numParams)
{
	Address dataMap = GetNativeCellRef(1);
	if (dataMap == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid datamap address %d", view_as<int>(dataMap));
	}
	
	Address address = GetNativeCellRef(2);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	int startIndex = -1;
	while (dataMap != Address_Null)
	{
		int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		
		if (startIndex == -1)
		{
			startIndex = view_as<int>(address) - view_as<int>(dataDesc) + g_Offset_DataFieldSize;
		}
		
		for (int i = startIndex; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
		{
			int flags = LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldFlags + i), NumberType_Int16);
			if (!view_as<bool>(flags & FIELDTYPE_DESC_INPUT))
			{
				continue;
			}
			
			SetNativeCellRef(1, dataMap);
			SetNativeCellRef(2, dataDesc + view_as<Address>(i));
			
			return true;
		}
		
		startIndex = 0;
		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	return false;
}

public int Native_FindEntityFirstOutput(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	Address dataMap = view_as<Address>(SDKCall(g_SDKCall_GetDataDescMap, entity));
	if (dataMap == Address_Null)
	{
		return false;
	}
	
	while (dataMap != Address_Null)
	{
		int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		
		for (int i = 0; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
		{
			int flags = LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldFlags + i), NumberType_Int16);
			if (!view_as<bool>(flags & FIELDTYPE_DESC_OUTPUT))
			{
				continue;
			}
			
			SetNativeCellRef(2, dataMap);
			SetNativeCellRef(3, dataDesc + view_as<Address>(i));
			
			return true;
		}
		
		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	return false;
}

public int Native_FindEntityNextOutput(Handle plugin, int numParams)
{
	Address dataMap = GetNativeCellRef(1);
	if (dataMap == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid datamap address %d", view_as<int>(dataMap));
	}
	
	Address address = GetNativeCellRef(2);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	int startIndex = -1;
	while (dataMap != Address_Null)
	{
		int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		
		if (startIndex == -1)
		{
			startIndex = view_as<int>(address) - view_as<int>(dataDesc) + g_Offset_DataFieldSize;
		}
		
		for (int i = startIndex; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
		{
			int flags = LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldFlags + i), NumberType_Int16);
			if (!view_as<bool>(flags & FIELDTYPE_DESC_OUTPUT))
			{
				continue;
			}
			
			SetNativeCellRef(1, dataMap);
			SetNativeCellRef(2, dataDesc + view_as<Address>(i));
			
			return true;
		}
		
		startIndex = 0;
		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	return false;
}

public int Native_FindEntityOutputOffset(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	char output[256];
	GetNativeString(2, output, sizeof(output));
	
	Address dataMap = view_as<Address>(SDKCall(g_SDKCall_GetDataDescMap, entity));
	if (dataMap == Address_Null)
	{
		return -1;
	}
	
	while (dataMap != Address_Null)
	{
		int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		
		for (int i = 0; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
		{
			int flags = LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldFlags + i), NumberType_Int16);
			if (!view_as<bool>(flags & FIELDTYPE_DESC_OUTPUT))
			{
				continue;
			}
			
			Address addressName = view_as<Address>(LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldName + i), NumberType_Int32));
			if (addressName == Address_Null)
			{
				continue;
			}
			
			char externalName[256];
			GetStringFromAddress(addressName, externalName, sizeof(externalName));
			
			if (!StrEqual(externalName, output, true))
			{
				continue;
			}
			
			return view_as<int>(LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldOffset + i), NumberType_Int16));
		}

		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	return -1;
}

public int Native_FindEntityFirstOutputAction(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	Address address = GetEntityAddress(entity);
	if (address == Address_Null)
	{
		return false;
	}
	
	int offset = GetNativeCell(2);
	if (offset == -1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid output offset %d", offset);
	}
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(offset) + view_as<Address>(g_Offset_ActionList), NumberType_Int32));
	SetNativeCellRef(3, address);
	
	return true;
}

public int Native_FindEntityNextOutputAction(Handle plugin, int numParams)
{
	Address address = GetNativeCellRef(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionNextIDStamp), NumberType_Int32));
	if (address == Address_Null)
	{
		return false;
	}
	
	SetNativeCellRef(1, address);
	return true;
}

public int Native_HasEntityInput(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	char input[256];
	GetNativeString(2, input, sizeof(input));
	
	Address dataMap = view_as<Address>(SDKCall(g_SDKCall_GetDataDescMap, entity));
	if (dataMap == Address_Null)
	{
		return false;
	}
	
	while (dataMap != Address_Null)
	{
		int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		
		for (int i = 0; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
		{
			int flags = LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldFlags + i), NumberType_Int16);
			if (!view_as<bool>(flags & FIELDTYPE_DESC_INPUT))
			{
				continue;
			}
			
			Address addressName = view_as<Address>(LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldName + i), NumberType_Int32));
			if (addressName == Address_Null)
			{
				continue;
			}
			
			char externalName[256];
			GetStringFromAddress(addressName, externalName, sizeof(externalName));
			
			if (!StrEqual(externalName, input, true))
			{
				continue;
			}
			
			return true;
		}

		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	return false;
}

public int Native_HasEntityOutput(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	char output[256];
	GetNativeString(2, output, sizeof(output));
	
	Address dataMap = view_as<Address>(SDKCall(g_SDKCall_GetDataDescMap, entity));
	if (dataMap == Address_Null)
	{
		return false;
	}
	
	while (dataMap != Address_Null)
	{
		int numFields = LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataNumFields), NumberType_Int32);
		Address dataDesc = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataDescMap), NumberType_Int32));
		
		for (int i = 0; i < numFields * g_Offset_DataFieldSize; i += g_Offset_DataFieldSize)
		{
			int flags = LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldFlags + i), NumberType_Int16);
			if (!view_as<bool>(flags & FIELDTYPE_DESC_OUTPUT))
			{
				continue;
			}
			
			Address addressName = view_as<Address>(LoadFromAddress(dataDesc + view_as<Address>(g_Offset_DataFieldName + i), NumberType_Int32));
			if (addressName == Address_Null)
			{
				continue;
			}
			
			char externalName[256];
			GetStringFromAddress(addressName, externalName, sizeof(externalName));
			
			if (!StrEqual(externalName, output, true))
			{
				continue;
			}
			
			return true;
		}

		dataMap = view_as<Address>(LoadFromAddress(dataMap + view_as<Address>(g_Offset_DataBaseMap), NumberType_Int32));
	}
	
	return false;
}

public int Native_AddEntityOutputAction(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	int maxLen = 256;
	
	char output[256];
	GetNativeString(2, output, sizeof(output));
	maxLen += strlen(output);
	
	char target[256];
	GetNativeString(3, target, sizeof(target));
	maxLen += strlen(target);
	
	char input[256];
	GetNativeString(4, input, sizeof(input));
	maxLen += strlen(input);
	
	char param[256];
	GetNativeString(5, param, sizeof(param));
	maxLen += strlen(param);
	
	char[] buffer = new char[maxLen];
	FormatEx(buffer, maxLen, "%s %s:%s:%s:%f:%d", output, target, input, param, GetNativeCell(6), GetNativeCell(7));
	SetVariantString(buffer);
	
	return AcceptEntityInput(entity, "AddOutput");
}

public int Native_GetEntityInputName(Handle plugin, int numParams)
{
	Address address = GetNativeCell(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(g_Offset_DataFieldName), NumberType_Int32));
	if (address == Address_Null)
	{
		return 0;
	}
	
	int maxLen = GetNativeCell(3);
	char[] buffer = new char[maxLen];
	
	int length = GetStringFromAddress(address, buffer, maxLen);
	SetNativeString(2, buffer, maxLen);
	
	return length;
}

public int Native_GetEntityOutputName(Handle plugin, int numParams)
{
	Address address = GetNativeCell(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(g_Offset_DataFieldName), NumberType_Int32));
	if (address == Address_Null)
	{
		return 0;
	}
	
	int maxLen = GetNativeCell(3);
	char[] buffer = new char[maxLen];
	
	int length = GetStringFromAddress(address, buffer, maxLen);
	SetNativeString(2, buffer, maxLen);
	
	return length;
}

public int Native_GetEntityOutputOffset(Handle plugin, int numParams)
{
	Address address = GetNativeCell(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	return view_as<int>(LoadFromAddress(address + view_as<Address>(g_Offset_DataFieldOffset), NumberType_Int32));
}

public int Native_GetEntityOutputActionTarget(Handle plugin, int numParams)
{
	Address address = GetNativeCell(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionTarget), NumberType_Int32));
	if (address == Address_Null)
	{
		return 0;
	}
	
	int maxLen = GetNativeCell(3);
	char[] buffer = new char[maxLen];
	
	int length = GetStringFromAddress(address, buffer, maxLen);
	SetNativeString(2, buffer, maxLen);
	
	return length;
}

public int Native_GetEntityOutputActionInput(Handle plugin, int numParams)
{
	Address address = GetNativeCell(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionInput), NumberType_Int32));
	if (address == Address_Null)
	{
		return 0;
	}
	
	int maxLen = GetNativeCell(3);
	char[] buffer = new char[maxLen];
	
	int length = GetStringFromAddress(address, buffer, maxLen);
	SetNativeString(2, buffer, maxLen);
	
	return length;
}

public int Native_GetEntityOutputActionParam(Handle plugin, int numParams)
{
	Address address = GetNativeCell(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionParam), NumberType_Int32));
	if (address == Address_Null)
	{
		return 0;
	}
	
	int maxLen = GetNativeCell(3);
	char[] buffer = new char[maxLen];
	
	int length = GetStringFromAddress(address, buffer, maxLen);
	SetNativeString(2, buffer, maxLen);
	
	return length;
}

public int Native_GetEntityOutputActionDelay(Handle plugin, int numParams)
{
	Address address = GetNativeCell(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	return view_as<int>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionDelay), NumberType_Int32));
}

public int Native_GetEntityOutputActionTimesToFire(Handle plugin, int numParams)
{
	Address address = GetNativeCell(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	return view_as<int>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionTimesToFire), NumberType_Int32));
}

public int Native_GetEntityOutputActionID(Handle plugin, int numParams)
{
	Address address = GetNativeCell(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	return view_as<int>(LoadFromAddress(address + view_as<Address>(g_Offset_ActionIDStamp), NumberType_Int32));
}