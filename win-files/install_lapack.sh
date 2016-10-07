echo SOFT $SOFT
echo BASE $BASE
echo DOWNLOADS $DOWNLOADS

export PATH=/mingw64/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/sbin:/bin:/c/Windows:/c/Windows/System32

cd "${SOFT}"
cd lapack-3.6.1
mkdir build
cd build
# mkdir -p "${BASE}/install/lua/5.1"
mkdir -p "${BASE}/install/bin"
# "C:\Program Files\CMake\bin\cmake" "-DCMAKE_INSTALL_PREFIX=${BASE}/install" -G "MSYS Makefiles" -DBUILD_SHARED_LIBS=1 -DCMAKE_GNUtoMS=1 -DCMAKE_Fortran_COMPILER=/mingw64/bin/x86_64-w64-mingw32-gfortran.exe ..
export COMMONPROGRAMFILES="C:\\Program Files\\Common Files"
export VS140COMNTOOLS="C:\\Program Files (x86)\\Microsoft Visual Studio 14.0\\Common7\Tools\\"
"C:\Program Files\CMake\bin\cmake" "-DCMAKE_INSTALL_PREFIX=${BASE}/install" -G "MSYS Makefiles" -DBUILD_SHARED_LIBS=1 -DCMAKE_GNUtoMS=1 "-DCMAKE_GNUtoMS_VCVARS=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\amd64\vcvars64.bat" -DCMAKE_Fortran_COMPILER=/mingw64/bin/x86_64-w64-mingw32-gfortran.exe ..
make -j 8
make install

pushd /mingw64/bin
pwd
cp libgcc_s_seh-1.dll libgfortran-3.dll libquadmath-0.dll libwinpthread-1.dll "${BASE}/install/bin"
popd

# touch "${SOFT}/lapack_done.flg"
