#include <sdktools>
#include <sourcemod>
#include <debugoverlays>

#define GAMEDATA_FILE "debugoverlays.games"

Handle fnLine;
Handle fnSweptBox;
Handle fnText;
Handle fnBoxAngles;
Handle fnSphere;

ConVar cvDefaultOverlayTime;
float defaultOverlayTime;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("DrawSweptBox", Native_DrawSweptBox);
	CreateNative("DrawLine", Native_DrawLine);
	CreateNative("DrawText", Native_DrawText);
	CreateNative("DrawBox", Native_DrawBoxAngles);
	CreateNative("DrawSphere", Native_DrawSphere);
	return APLRes_Success;
}

void OndefaultOverlayTimeChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	defaultOverlayTime = convar.FloatValue;
}

public any Native_DrawSphere(Handle plugin, int numParams)
{
	float position[3], angles[3];

	GetNativeArray(1, position, sizeof(position));
	GetNativeArray(3, angles, sizeof(angles));
	
	float radius = GetNativeCell(2);

	int r = GetNativeCell(4);
	int g = GetNativeCell(5);
	int b = GetNativeCell(6);
	int a = GetNativeCell(7);

	bool noDepthTest = GetNativeCell(8);

	float duration = GetNativeCell(9);
	if (duration == DRAW_TIME_DEFAULT) {
		duration = defaultOverlayTime;
	}

	SDKCall(fnSphere, position, angles, radius, r, g, b, a, noDepthTest, duration);
	return 0;
}

public any Native_DrawBoxAngles(Handle plugin, int numParams)
{
	float start[3], mins[3], maxs[3], angles[3];

	GetNativeArray(1, start, sizeof(start));
	GetNativeArray(2, mins, sizeof(mins));
	GetNativeArray(3, maxs, sizeof(maxs));
	GetNativeArray(4, angles, sizeof(angles));

	int r = GetNativeCell(5);
	int g = GetNativeCell(6);
	int b = GetNativeCell(7);
	int a = GetNativeCell(8);

	float duration = GetNativeCell(9);
	if (duration == DRAW_TIME_DEFAULT) {
		duration = defaultOverlayTime;
	}

	SDKCall(fnBoxAngles, start, mins, maxs, angles, r, g, b, a, duration);
	return 0;
}

public any Native_DrawText(Handle plugin, int numParams)
{
	float origin[3];
	GetNativeArray(1, origin, sizeof(origin));

	char text[1024];
	GetNativeString(2, text, sizeof(text));

	int viewCheck = GetNativeCell(3);
	float duration = GetNativeCell(4);
	if (duration == DRAW_TIME_DEFAULT) {
		duration = defaultOverlayTime;
	}

	SDKCall(fnText, origin, text, viewCheck, duration);
	return 0;
}

public any Native_DrawLine(Handle plugin, int numParams)
{
	float start[3], end[3];

	GetNativeArray(1, start, sizeof(start));
	GetNativeArray(2, end, sizeof(end));

	int   r           = GetNativeCell(3);
	int   g           = GetNativeCell(4);
	int   b           = GetNativeCell(5);
	int   noDepthTest = GetNativeCell(6);
	float duration    = GetNativeCell(7);
	if (duration == DRAW_TIME_DEFAULT) {
		duration = defaultOverlayTime;
	}

	SDKCall(fnLine, start, end, r, g, b, noDepthTest, duration);
	return 0;
}

public any Native_DrawSweptBox(Handle plugin, int numParams)
{
	float start[3], end[3], mins[3], maxs[3], angles[3];

	GetNativeArray(1, start, sizeof(start));
	GetNativeArray(2, end, sizeof(end));
	GetNativeArray(3, mins, sizeof(mins));
	GetNativeArray(4, maxs, sizeof(maxs));
	GetNativeArray(5, angles, sizeof(angles));

	int r = GetNativeCell(6);
	int g = GetNativeCell(7);
	int b = GetNativeCell(8);
	int a = GetNativeCell(9);

	float duration = GetNativeCell(10);
	if (duration == DRAW_TIME_DEFAULT) {
		duration = defaultOverlayTime;
	}

	SDKCall(fnSweptBox, start, end, mins, maxs, angles, r, g, b, a, duration);
	return 0;
}

public void OnPluginStart()
{
	cvDefaultOverlayTime = CreateConVar("debugoverlays_default_draw_time", "3.0", "The default time, in seconds, to draw overlays for");
	defaultOverlayTime = cvDefaultOverlayTime.FloatValue;
	cvDefaultOverlayTime.AddChangeHook(OndefaultOverlayTimeChanged);

	GameData gamedata = new GameData(GAMEDATA_FILE);
	if (!gamedata)
	{
		SetFailState("Failed to open " ... GAMEDATA_FILE);
	}

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "NDebugOverlay::Line");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // r
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // g
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // b
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // noDepthTest
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);         // duration
	if (!(fnLine = EndPrepSDKCall()))
	{
		SetFailState("Failed to resolve NDebugOverlay::Line signature");
	}

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "NDebugOverlay::SweptBox");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);        // startpos
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);        // endpos
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);        // mins
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);        // maxs
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef);        // angles
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // r
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // g
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // b
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // a
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);         // duration
	if (!(fnSweptBox = EndPrepSDKCall()))
	{
		SetFailState("Failed to resolve NDebugOverlay::SweptBox signature");
	}

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "NDebugOverlay::Text");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);        // origin
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);       // text
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // viewCheck
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);         // duration
	if (!(fnText = EndPrepSDKCall()))
	{
		SetFailState("Failed to resolve NDebugOverlay::Text signature");
	}

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "NDebugOverlay::BoxAngles");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);        // origin
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);        // mins
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);        // maxs
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef);        // angles
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // r
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // g
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // b
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // a
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);         // duration
	if (!(fnBoxAngles = EndPrepSDKCall()))
	{
		SetFailState("Failed to resolve NDebugOverlay::BoxAngles signature");
	}

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "NDebugOverlay::Sphere");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);				// position
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);				// angles
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // r
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // g
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // b
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);  // noDepthTest
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);         // duration
	if (!(fnSphere = EndPrepSDKCall()))
	{
		SetFailState("Failed to resolve NDebugOverlay::Sphere signature");
	}

}
