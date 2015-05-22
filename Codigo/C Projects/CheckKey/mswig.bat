"C:\\Users\\PS\Desktop\\work\\swigwin-3.0.5\\swig.exe" -c++ -lua checkKey.i
REM g++ LuaFunctions.cpp -o host -I"C:\\Program Files (x86)\\Lua\\5.1\\include\\" -L"C:\\Program Files (x86)\\Lua\\5.1\\lib\\" -llua5.1 -llua51

g++ -I"C:\\Program Files (x86)\\Lua\\5.1\\include\\" -L"C:\\Program Files (x86)\\Lua\\5.1\\lib\\"  -llua5.1 -llua51 -c checkKey_wrap.cxx -o checkKey_wrap.o

g++ -c checkKey.cpp -o checkKey.o

g++ -LC:"C:\\Program Files (x86)\\Lua\\5.1\\include\\" -L"C:\\Program Files (x86)\\Lua\\5.1\\lib\\" -shared checkKey_wrap.o checkKey.o -llua51 -o checkKey.dll
