#!/usr/bin/env bash

set -e  # Exit on any error

# ==============================================================================
# Configuration and Setup
# ==============================================================================

THIS_DIR=$(cd "$(dirname "$0")"; pwd)
PREFIX=${PREFIX:-"${THIS_DIR}/install"}
RISCV_PREFIX="${PREFIX}/riscv64-cmake"

# Cross-compilation toolchain configuration
export CC="riscv64-linux-gnu-gcc"
export CXX="riscv64-linux-gnu-g++"
export AR="riscv64-linux-gnu-ar"
export RANLIB="riscv64-linux-gnu-ranlib"

# Compiler flags for RISC-V 64-bit with disabled SIMD
export CFLAGS="-march=rv64gc -mabi=lp64d -fPIC"
export CXXFLAGS="-march=rv64gc -mabi=lp64d -fPIC"
export LDFLAGS="-latomic -lm -lpthread"

# CMake configuration arguments (reused across all builds)
CMAKE_ARGS=(
    "CC=$CC"
    "CXX=$CXX"
    "AR=$AR"
    "RANLIB=$RANLIB"
    "STRIP=$STRIP"
    "CFLAGS=$CFLAGS"
    "CXXFLAGS=$CXXFLAGS"
    "LDFLAGS=$LDFLAGS"
    "CMAKE_C_COMPILER=$CC"
    "CMAKE_CXX_COMPILER=$CXX"
    "CMAKE_C_FLAGS=$CFLAGS"
    "CMAKE_CXX_FLAGS=$CXXFLAGS"
    "CMAKE_SHARED_LINKER_FLAGS=$LDFLAGS"
    "CMAKE_POSITION_INDEPENDENT_CODE=ON"
    "BUILD_SHARED_LIBS=OFF"
)

# ==============================================================================
# Utility Functions
# ==============================================================================

# Function to install a luarocks package with cross-compilation settings
install_luarock() {
    local package_dir="$1"
    local rockspec="$2"
    local exit_code="${3:-1}"  # Default exit code is 1
    
    echo "Installing $(basename "$package_dir")..."
    
    if [[ ! -d "$package_dir" ]]; then
        echo "Error: Directory $package_dir not found"
        exit "$exit_code"
    fi
    
    cd "$package_dir"
    "$PREFIX/bin/luarocks" make "$rockspec" \
        --tree="$RISCV_PREFIX" \
        "${CMAKE_ARGS[@]}" || exit "$exit_code"
    
    echo "✓ Successfully installed $(basename "$package_dir")"
}

# Function to validate cross-compiler
validate_cross_compiler() {
    echo "Testing cross-compiler..."
    if echo 'int main(){return 0;}' | $CC $CFLAGS -x c - -o test_riscv 2>/dev/null; then
        rm -f test_riscv
        echo "✓ Cross-compiler working"
    else
        echo "ERROR: Cross-compiler not working. Install with: sudo apt install gcc-riscv64-linux-gnu"
        exit 1
    fi
}

# ==============================================================================
# Cleanup and Preparation
# ==============================================================================

echo "Cleaning previous build artifacts..."
find . -name "build" -type d -path "*/pkg/*" -exec rm -rf {} + 2>/dev/null || true
find . -name "*.so" -path "*/pkg/*" -delete 2>/dev/null || true
find . -name "*.so" -path "*/extra/*" -delete 2>/dev/null || true

# Verify native luarocks is available
if [[ ! -f "$PREFIX/bin/luarocks" ]]; then
    echo "Error: Native luarocks not found. Please run './install-x86.sh -b' first"
    exit 1
fi

# Setup Lua environment
echo "Setting up Lua environment..."
setup_lua_env_cmd=$("$PREFIX/bin/luarocks" path)
eval "$setup_lua_env_cmd"

# Create necessary directories
mkdir -p "$RISCV_PREFIX/lib/lua/5.1"
mkdir -p "$RISCV_PREFIX/share/lua/5.1"

# Validate cross-compiler
validate_cross_compiler

echo "✓ Setup complete. Starting package installation..."

# ==============================================================================
# Common Lua Packages Installation
# ==============================================================================

echo ""
echo "=== Installing Common Lua Packages ==="

install_luarock "${THIS_DIR}/extra/luafilesystem" "rockspecs/luafilesystem-1.6.3-1.rockspec"
install_luarock "${THIS_DIR}/extra/penlight" "penlight-scm-1.rockspec"
install_luarock "${THIS_DIR}/extra/lua-cjson" "lua-cjson-2.1devel-1.rockspec"

# ==============================================================================
# Core Torch Packages Installation
# ==============================================================================

echo ""
echo "=== Installing Core Torch Packages ==="

install_luarock "${THIS_DIR}/extra/luaffifb" "luaffi-scm-1.rockspec"
#install_luarock "${THIS_DIR}/pkg/sundown" "rocks/sundown-scm-1.rockspec"
install_luarock "${THIS_DIR}/pkg/cwrap" "rocks/cwrap-scm-1.rockspec"
install_luarock "${THIS_DIR}/pkg/paths" "rocks/paths-scm-1.rockspec"

install_luarock "${THIS_DIR}/pkg/torch" "rocks/torch-scm-1.rockspec"

#install_luarock "${THIS_DIR}/pkg/dok" "rocks/dok-scm-1.rockspec"
#install_luarock "${THIS_DIR}/exe/trepl" "trepl-scm-1.rockspec"
#install_luarock "${THIS_DIR}/pkg/sys" "sys-1.1-0.rockspec"
#install_luarock "${THIS_DIR}/pkg/xlua" "xlua-1.0-0.rockspec"

# ==============================================================================
# Extended Torch Packages Installation
# ==============================================================================

echo ""
echo "=== Installing Extended Torch Packages ==="

install_luarock "${THIS_DIR}/extra/moses" "rockspec/moses-1.6.1-1.rockspec"
install_luarock "${THIS_DIR}/extra/nn" "rocks/nn-scm-1.rockspec"
#install_luarock "${THIS_DIR}/extra/graph" "rocks/graph-scm-1.rockspec"
#install_luarock "${THIS_DIR}/extra/nngraph" "nngraph-scm-1.rockspec"
#install_luarock "${THIS_DIR}/pkg/image" "image-1.1.alpha-0.rockspec"
#install_luarock "${THIS_DIR}/pkg/optim" "optim-1.0.5-0.rockspec"

# ==============================================================================
# Optional Packages (Commented Out)
# ==============================================================================

# Uncomment and modify as needed:
# echo ""
# echo "=== Installing Optional Torch Packages ==="
# install_luarock "${THIS_DIR}/pkg/gnuplot" "rocks/gnuplot-scm-1.rockspec"
# install_luarock "${THIS_DIR}/exe/env" "env-scm-1.rockspec"
# install_luarock "${THIS_DIR}/extra/nnx" "nnx-0.1-1.rockspec"
# install_luarock "${THIS_DIR}/exe/qtlua" "rocks/qtlua-scm-1.rockspec"
# install_luarock "${THIS_DIR}/pkg/qttorch" "rocks/qttorch-scm-1.rockspec"
# install_luarock "${THIS_DIR}/extra/threads" "rocks/threads-scm-1.rockspec"
# install_luarock "${THIS_DIR}/extra/argcheck" "rocks/argcheck-scm-1.rockspec"



# ==============================================================================
# Uncomment if you need to build TH library directly with CMake:
# ==============================================================================

# echo ""
# echo "=== Building TH Library using bare cmake ==="
# cd "${THIS_DIR}/pkg/torch/lib/TH"
# mkdir -p build-riscv
# cd build-riscv
# 
# cmake .. \
#     -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" \
#     -DCMAKE_C_FLAGS="$CFLAGS" -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
#     -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
#     -DCMAKE_SHARED_LINKER_FLAGS="$LDFLAGS" \
#     -DCMAKE_INSTALL_PREFIX="$RISCV_PREFIX" \
#     -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
#     -DWITH_OPENMP=OFF -DWITH_SSE=OFF -DWITH_AVX=OFF \
#     -DTH_HAVE_X86_SIMD=OFF 2>&1 | tee /tmp/th-build.log
# 
# make -j2 VERBOSE=1 2>&1 | tee -a /tmp/th-build.log && \
#     make install 2>&1 | tee -a /tmp/th-build.log
# 
# cd "$THIS_DIR"
# 
# # Reset Lua environment
# setup_lua_env_cmd=$("$PREFIX/bin/luarocks" path)
# eval "$setup_lua_env_cmd"

echo ""
echo "✅ All packages installed successfully!"
echo "Installation directory: $RISCV_PREFIX"
echo "To verify installation, check for RISC-V shared objects:"
echo "find '$RISCV_PREFIX' -name '*.so' | head -5 | xargs file"
