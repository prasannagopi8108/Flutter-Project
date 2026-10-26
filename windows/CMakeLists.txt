cmake_minimum_required(VERSION 3.14)
project(medicine_reminder LANGUAGES CXX)

set(BINARY_NAME "medicine_reminder")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Configure build options.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING
      "Choose the type of build, options are: Debug Profile Release."
      FORCE)
  endif()
endif()

# Set compiler settings.
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source-level debugging for all configurations.
add_compile_options($<$<CXX_COMPILER_ID:MSVC>:/Zi>)
add_link_options($<$<CXX_COMPILER_ID:MSVC>:/DEBUG>)

# Define compilation flags.
add_definitions(-DUNICODE -D_UNICODE)

# Include the Flutter toolchain.
include(flutter/generated_plugins.cmake OPTIONAL)

add_subdirectory(runner)
