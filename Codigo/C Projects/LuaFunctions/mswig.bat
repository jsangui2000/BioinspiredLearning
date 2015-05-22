"C:\\Users\\PS\Desktop\\work\\swigwin-3.0.5\\swig.exe" -lua example.i
REM g++ LuaFunctions.cpp -o host -I"C:\\Program Files (x86)\\Lua\\5.1\\include\\" -L"C:\\Program Files (x86)\\Lua\\5.1\\lib\\" -llua5.1 -llua51

gcc -I"C:\\Program Files (x86)\\Lua\\5.1\\include\\" -L"C:\\Program Files (x86)\\Lua\\5.1\\lib\\"  -llua5.1 -llua51 -c example_wrap.c -o example_wrap.o

gcc -I"C:\\Program Files (x86)\\Lua\\5.1\\include\\" -L"C:\\Program Files (x86)\\Lua\\5.1\\lib\\"  -llua5.1 -llua51 -c example.c -o example.o

gcc -LC:"C:\\Program Files (x86)\\Lua\\5.1\\include\\" -L"C:\\Program Files (x86)\\Lua\\5.1\\lib\\" -shared example_wrap.o example.o -llua51 -o example.dll
