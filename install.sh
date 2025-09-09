#!/usr/bin/env bash

THIS_DIR=$(cd $(dirname $0); pwd)
PREFIX=${PREFIX:-"${THIS_DIR}/install"}
RISCV_PREFIX="${PREFIX}/riscv64-cmake"

# Clean previous builds
echo "Cleaning previous build artifacts..."
find . -name "build" -type d -path "*/pkg/*" -exec rm -rf {} + 2>/dev/null
find . -name "*.so" -path "*/pkg/*" -delete 2>/dev/null
find . -name "*.so" -path "*/extra/*" -delete 2>/dev/null

# Make sure native luarocks is available
if [ ! -f "$PREFIX/bin/luarocks" ]; then
    echo "Error: Native luarocks not found. Please run './install.sh -b' first"
    exit 1
fi
setup_lua_env_cmd=$($PREFIX/bin/luarocks path)
eval "$setup_lua_env_cmd"

mkdir -p "$RISCV_PREFIX/lib/lua/5.1"
mkdir -p "$RISCV_PREFIX/share/lua/5.1"

# Cross-compilation environment
export CC="riscv64-linux-gnu-gcc"
export CXX="riscv64-linux-gnu-g++"
export AR="riscv64-linux-gnu-ar"
export RANLIB="riscv64-linux-gnu-ranlib"

export CFLAGS="-march=rv64gc -mabi=lp64d -fPIC -DNO_AVX -DNO_SSE"
export CXXFLAGS="-march=rv64gc -mabi=lp64d -fPIC -DNO_AVX -DNO_SSE"
export LDFLAGS="-latomic -lm -lpthread"

# Test cross-compiler
echo 'int main(){return 0;}' | $CC $CFLAGS -x c - -o test_riscv 2>/dev/null
if [ -f test_riscv ]; then
    rm -f test_riscv
else
    echo "ERROR: Cross-compiler not working. Install with: sudo apt install gcc-riscv64-linux-gnu"
    exit 1
fi

#
## Optional packages
#echo "Installing optional Torch packages"
#cd ${THIS_DIR}/pkg/gnuplot          && $PREFIX/bin/luarocks make rocks/gnuplot-scm-1.rockspec
#cd ${THIS_DIR}/exe/env              && $PREFIX/bin/luarocks make env-scm-1.rockspec
#cd ${THIS_DIR}/extra/nnx            && $PREFIX/bin/luarocks make nnx-0.1-1.rockspec
#cd ${THIS_DIR}/exe/qtlua            && $PREFIX/bin/luarocks make rocks/qtlua-scm-1.rockspec
#cd ${THIS_DIR}/pkg/qttorch          && $PREFIX/bin/luarocks make rocks/qttorch-scm-1.rockspec
#cd ${THIS_DIR}/extra/threads        && $PREFIX/bin/luarocks make rocks/threads-scm-1.rockspec
#cd ${THIS_DIR}/extra/argcheck       && $PREFIX/bin/luarocks make rocks/argcheck-scm-1.rockspec


#echo ""
#echo "=== Building TH Library using bare cmake ==="
#cd pkg/torch/lib/TH
#mkdir -p build-riscv
#cd build-riscv
#
#cmake .. \
#    -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" \
#    -DCMAKE_C_FLAGS="$CFLAGS" -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
#    -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
#    -DCMAKE_SHARED_LINKER_FLAGS="$LDFLAGS" \
#    -DCMAKE_INSTALL_PREFIX="$RISCV_PREFIX" \
#    -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
#    -DWITH_OPENMP=OFF -DWITH_SSE=OFF -DWITH_AVX=OFF \
#    -DTH_HAVE_X86_SIMD=OFF 2>&1 | tee /tmp/th-build.log
#
#make -j2 VERBOSE=1 2>&1 | tee -a /tmp/th-build.log && make install 2>&1 | tee -a /tmp/th-build.log
#
#cd "$THIS_DIR"
#
#setup_lua_env_cmd=$($PREFIX/bin/luarocks path)
#eval "$setup_lua_env_cmd"
