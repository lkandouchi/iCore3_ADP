cmake_minimum_required(VERSION 3.0.0)
project(YourProjectName VERSION 0.1.0)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)

# Set the C and C++ standard you wish to use (e.g., C99, C++11)
set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 11)

# Compiler options
add_compile_options(-Wall -Wextra -pedantic)

# Include directories
include_directories(include)

# Find all source files
file(GLOB_RECURSE SOURCES "main/*.c" "main/*.cpp" "driver/*.c" "driver/*.cpp")

# Specify the executable
add_executable(YourExecutableName ${SOURCES})

# Link libraries if there are any
# target_link_libraries(YourExecutableName lib1 lib2 ...)
