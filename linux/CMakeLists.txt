cmake_minimum_required(VERSION 3.10)
project(runner LANGUAGES CXX)

# Set the application target name.
set(BINARY_NAME "medicine_reminder")

# Configure build options.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING
    "Choose the type of build, options are: Debug Profile Release."
    FORCE)
endif()

# Compilation flags that should be applied to Flutter and plugins.
add_definitions("-DAPPLICATION_ID=\"com.example.medicine_reminder\"")

# List of source files for the application.
list(APPEND SOURCE_FILES
  "main.cc"
  "my_application.cc"
)

# Apply standard compile/link settings to the runner executable.
add_executable(${BINARY_NAME} ${SOURCE_FILES})
