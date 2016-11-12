set BASE=%~dp0
set "LUA_CPATH=%BASE%/install/?.DLL;%BASE%/install/LIB/?.DLL;?.DLL"
set "LUA_DEV=%BASE%/install"
set "LUA_PATH=%BASE%/install/?;%BASE%/install/luarocks/?;%BASE%/install/luarocks/?.lua;%BASE%/install/pkg/?;%BASE%/install/pkg/?.lua;%BASE%/install/?.lua;%BASE%/install/lua/?.lua;%BASE%/install/lua/?/init.lua"
set "PATH=%PATH%;%BASE%\install;%BASE%\install\bin"