cmake_minimum_required (VERSION 3.0)
project(sz)
set (sz_VERSION_MAJOR 1)
set (sz_VERSION_MINOR 0)
set (CMAKE_CXX_STANDARD 11)
set (CMAKE_CXX_STANDARD_REQUIRED ON)
set (CMAKE_CXX_FLAGS "-g -O3")
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
add_definitions(-DPOLY_REGRESSION_COEF_FILE="${CMAKE_CURRENT_SOURCE_DIR}/data/PolyRegressionCoefAux3D.f32")


get_filename_component(ZTSD_ABS_PATH
                       "../compressor-install"
                       ABSOLUTE)
find_library (ZSTD_LIBS zstd HINTS "${ZTSD_ABS_PATH}/lib")
set (ZSTD_INCLUDES "${ZTSD_ABS_PATH}/include")
add_subdirectory (src)
add_subdirectory (test)

file(GLOB header_files ${PROJECT_SOURCE_DIR}/include/*.hpp)
install(FILES ${header_files} DESTINATION ${CMAKE_INSTALL_PREFIX}/include/sz-auto)
install (TARGETS sz_cpp
  LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
  )