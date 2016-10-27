for /d %%G in ("exe\lua-5.*") do rmdir /s /q "%%~G"

for /d %%G in ("win-files\3rd\wineditline-*") do rmdir /s /q "%%~G"\build
cd win-files\3rd\dlfcn-win32 && git clean -fdx && git checkout -f && cd ..\..\..\

cd exe\luajit-2.0 && git clean -fdx && git checkout -f && cd ..\..\
cd exe\luajit-2.1 && git clean -fdx && git checkout -f && cd ..\..\
cd exe\luarocks && git clean -fdx && git checkout -f && cd ..\..\

cd extra\luafilesystem && git clean -fdx && git checkout -f && cd ..\..\
cd extra\penlight && git clean -fdx && git checkout -f && cd ..\..\
cd extra\lua-cjson && git clean -fdx && git checkout -f && cd ..\..\

cd extra\luaffifb && git clean -fdx && git checkout -f && cd ..\..\
cd pkg\sundown && git clean -fdx && git checkout -f && cd ..\..\
cd pkg\cwrap && git clean -fdx && git checkout -f && cd ..\..\
cd pkg\paths && git clean -fdx && git checkout -f && cd ..\..\
cd pkg\torch && git clean -fdx && git checkout -f && cd ..\..\
cd pkg\dok && git clean -fdx && git checkout -f && cd ..\..\
cd pkg\sys && git clean -fdx && git checkout -f && cd ..\..\
cd exe\trepl && git clean -fdx && git checkout -f && cd ..\..\
cd pkg\xlua && git clean -fdx && git checkout -f && cd ..\..\
cd extra\nn && git clean -fdx && git checkout -f && cd ..\..\
cd extra\graph && git clean -fdx && git checkout -f && cd ..\..\
cd extra\nngraph && git clean -fdx && git checkout -f && cd ..\..\
cd pkg\image && git clean -fdx && git checkout -f && cd ..\..\
cd pkg\optim && git clean -fdx && git checkout -f && cd ..\..\

cd pkg\gnuplot && git clean -fdx && git checkout -f && cd ..\..\ 
cd exe\env && git clean -fdx && git checkout -f && cd ..\..\ 
cd extra\nnx && git clean -fdx && git checkout -f && cd ..\..\ 
cd exe\qtlua && git clean -fdx && git checkout -f && cd ..\..\ 
cd pkg\qttorch && git clean -fdx && git checkout -f && cd ..\..\ 
cd extra\threads && git clean -fdx && git checkout -f && cd ..\..\ 
cd extra\argcheck && git clean -fdx && git checkout -f && cd ..\..\ 

cd extra\graphicsmagick && git clean -fdx && git checkout -f && cd ..\..\ 
cd extra\totem && git clean -fdx && git checkout -f && cd ..\..\ 
