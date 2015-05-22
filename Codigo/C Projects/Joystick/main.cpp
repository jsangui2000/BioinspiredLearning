#include <dinput.h>
#include <iostream>
using namespace std;

LPDIRECTINPUT8 di;
HRESULT hr;

BOOL CALLBACK enumCallback(const DIDEVICEINSTANCE* instance, VOID* context);


LPDIRECTINPUTDEVICE8 joystick;
DIDEVCAPS capabilities;


BOOL CALLBACK enumCallback(const DIDEVICEINSTANCE* instance, VOID* context)
{
	HRESULT hr;

	// Obtain an interface to the enumerated joystick.
	hr = di->CreateDevice(instance->guidInstance, &joystick, NULL);

	// If it failed, then we can't use this joystick. (Maybe the user unplugged
	// it while we were in the middle of enumerating it.)
	if (FAILED(hr)) { 
		return DIENUM_CONTINUE;
	}

	// Stop enumeration. Note: we're just taking the first joystick we get. You
	// could store all the enumerated joysticks and let the user pick.
	return DIENUM_STOP;
}



int main()
{
	// Create a DirectInput device
	if (FAILED(hr = DirectInput8Create(GetModuleHandle(NULL), DIRECTINPUT_VERSION, 
		IID_IDirectInput8, (VOID**)&di, NULL))) {
			return hr;
	}

	// Look for the first simple joystick we can find.
	if (FAILED(hr = di->EnumDevices(DI8DEVCLASS_GAMECTRL, enumCallback,
		NULL, DIEDFL_ATTACHEDONLY))) {
			return hr;
	}

	// Make sure we got a joystick
	if (joystick == NULL) {
		printf("Joystick not found.\n");
		return E_FAIL;
	}

	if (FAILED(hr = joystick->SetDataFormat(&c_dfDIJoystick2))) {
		return hr;
	}

	if (FAILED(hr = joystick->SetCooperativeLevel(NULL, DISCL_EXCLUSIVE |
		DISCL_FOREGROUND))) {
			return hr;
	}

	capabilities.dwSize = sizeof(DIDEVCAPS);
	if (FAILED(hr = joystick->GetCapabilities(&capabilities))) {
		return hr;
	}

	system("pause");
	return 0;
}