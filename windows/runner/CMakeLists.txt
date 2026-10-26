cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. Add run-time sources here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "Runner.rc"
)

# Apply standard compile/link settings to the runner executable.
target_compile_definitions(${BINARY_NAME} PRIVATE
  $<$<CONFIG:Debug>:DEBUG>
)

target_include_directories(${BINARY_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Link Flutter and plugin dependencies.
target_link_libraries(${BINARY_NAME} PRIVATE
  dwmapi
)
