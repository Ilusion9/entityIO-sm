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

int g_ActionListOffset;
int g_ActionTargetOffset;
int g_ActionInputOffset;
int g_ActionParamsOffset;
int g_ActionDelayOffset;
int g_ActionTimesToFireOffset;
int g_ActionIDStampOffset;
int g_ActionNextIDStampOffset;

GlobalForward g_Forward_OnEntityInput;
Handle g_DHook_AcceptInput;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("EntityIO_GetEntityOutputActionTarget", Native_GetEntityOutputActionTarget);
	CreateNative("EntityIO_GetEntityOutputActionInput", Native_GetEntityOutputActionInput);
	CreateNative("EntityIO_GetEntityOutputActionParam", Native_GetEntityOutputActionParam);
	CreateNative("EntityIO_GetEntityOutputActionDelay", Native_GetEntityOutputActionDelay);
	CreateNative("EntityIO_GetEntityOutputActionTimesToFire", Native_GetEntityOutputActionTimesToFire);
	CreateNative("EntityIO_GetEntityOutputActionID", Native_GetEntityOutputActionID);
	CreateNative("EntityIO_FindEntityFirstOutputAction", Native_FindEntityFirstOutputAction);
	CreateNative("EntityIO_FindEntityNextOutputAction", Native_FindEntityNextOutputAction);
	
	RegPluginLibrary("entityIO");
}

public void OnPluginStart()
{	
	Handle configFile = LoadGameConfigFile("entityIO.games");
	if (!configFile)
	{
		SetFailState("Failed to load \"entityIO.games\" gamedata.");
	}
	
	int inputOffset = GameConfGetOffset(configFile, "CBaseEntity::AcceptInput");
	if (inputOffset == -1)
	{
		SetFailState("Failed to load \"CBaseEntity::AcceptInput\" offset.");
	}
	
	g_ActionListOffset = GameConfGetOffset(configFile, "CBaseEntityOutput::m_ActionList");
	if (g_ActionListOffset == -1)
	{
		SetFailState("Failed to load \"CBaseEntityOutput::m_ActionList\" offset.");
	}
	
	g_ActionTargetOffset = GameConfGetOffset(configFile, "CEventAction::m_iTarget");
	if (g_ActionTargetOffset == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_iTarget\" offset.");
	}
	
	g_ActionInputOffset = GameConfGetOffset(configFile, "CEventAction::m_iTargetInput");
	if (g_ActionInputOffset == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_iTargetInput\" offset.");
	}
	
	g_ActionParamsOffset = GameConfGetOffset(configFile, "CEventAction::m_iParameter");
	if (g_ActionParamsOffset == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_iParameter\" offset.");
	}
	
	g_ActionDelayOffset = GameConfGetOffset(configFile, "CEventAction::m_flDelay");
	if (g_ActionDelayOffset == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_flDelay\" offset.");
	}
	
	g_ActionTimesToFireOffset = GameConfGetOffset(configFile, "CEventAction::m_nTimesToFire");
	if (g_ActionTimesToFireOffset == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_nTimesToFire\" offset.");
	}
	
	g_ActionIDStampOffset = GameConfGetOffset(configFile, "CEventAction::m_iIDStamp");
	if (g_ActionIDStampOffset == -1)
	{
		SetFailState("Failed to load \"CEventAction::m_iIDStamp\" offset.");
	}
	
	g_ActionNextIDStampOffset = GameConfGetOffset(configFile, "CEventAction::s_iNextIDStamp");
	if (g_ActionNextIDStampOffset == -1)
	{
		SetFailState("Failed to load \"CEventAction::s_iNextIDStamp\" offset.");
	}
	
	delete configFile;
	
	g_Forward_OnEntityInput = new GlobalForward("EntityIO_OnEntityInput", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_Cell, Param_Any, Param_Array, Param_String, Param_Cell);
	
	g_DHook_AcceptInput = DHookCreate(inputOffset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, DHook_AcceptInput);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_CharPtr);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_Object, 20, DHookPass_ByVal | DHookPass_ODTOR | DHookPass_OCTOR | DHookPass_OASSIGNOP);
	DHookAddParam(g_DHook_AcceptInput, HookParamType_Int);
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

public int Native_GetEntityOutputActionTarget(Handle plugin, int numParams)
{
	Address address = GetNativeCell(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(g_ActionTargetOffset), NumberType_Int32));
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
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(g_ActionInputOffset), NumberType_Int32));
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
	
	address = view_as<Address>(LoadFromAddress(address + view_as<Address>(g_ActionParamsOffset), NumberType_Int32));
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
	
	return view_as<int>(LoadFromAddress(address + view_as<Address>(g_ActionDelayOffset), NumberType_Int32));
}

public int Native_GetEntityOutputActionTimesToFire(Handle plugin, int numParams)
{
	Address address = GetNativeCell(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	return view_as<int>(LoadFromAddress(address + view_as<Address>(g_ActionTimesToFireOffset), NumberType_Int32));
}

public int Native_GetEntityOutputActionID(Handle plugin, int numParams)
{
	Address address = GetNativeCell(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	return view_as<int>(LoadFromAddress(address + view_as<Address>(g_ActionIDStampOffset), NumberType_Int32));
}

public int Native_FindEntityFirstOutputAction(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	char output[256];
	GetNativeString(2, output, sizeof(output));
	
	Address address = GetEntityAddress(entity);
	if (address == Address_Null)
	{
		return view_as<int>(Address_Null);
	}
	
	int offset = FindDataMapInfo(entity, output);
	if (offset == -1)
	{
		return view_as<int>(Address_Null);
	}
	
	return view_as<int>(LoadFromAddress(address + view_as<Address>(offset) + view_as<Address>(g_ActionListOffset), NumberType_Int32));
}

public int Native_FindEntityNextOutputAction(Handle plugin, int numParams)
{
	Address address = GetNativeCell(1);
	if (address == Address_Null)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid address %d", view_as<int>(address));
	}
	
	return view_as<int>(LoadFromAddress(address + view_as<Address>(g_ActionNextIDStampOffset), NumberType_Int32));
}