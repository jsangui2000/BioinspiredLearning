#include <Windows.h>

bool checkKey(int num)
{
	return GetAsyncKeyState(num);
}


