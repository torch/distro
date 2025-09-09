
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR riscv64)

set(CMAKE_C_COMPILER /usr/bin/riscv64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER /usr/bin/riscv64-linux-gnu-g++)

# Set position independent code by default
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Set the flags properly - don't reference CMAKE_C_FLAGS in its own definition
set(CMAKE_C_FLAGS "-march=rv64gc -mabi=lp64d -fPIC")
set(CMAKE_CXX_FLAGS "-march=rv64gc -mabi=lp64d -fPIC")

# Force shared libraries
set(BUILD_SHARED_LIBS OFF)

# For cross-compilation, we need to set the sysroot and find root path
set(CMAKE_FIND_ROOT_PATH /usr/riscv64-linux-gnu)

# Search for programs in host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search for libraries and headers in target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Disable PIE for cross-compilation (can cause linking issues)
set(CMAKE_EXE_LINKER_FLAGS "-no-pie")
set(CMAKE_SHARED_LINKER_FLAGS "")

# Make sure we link against libatomic for RISC-V
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -latomic")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -latomic")