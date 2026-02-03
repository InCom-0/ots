cmake_minimum_required(VERSION 3.30...4.0)

project(ots
  HOMEPAGE_URL "https://github.com/InCom-0/ots"
  VERSION "9.2.0"
  DESCRIPTION
  "Sanitizer for OpenType."
  LANGUAGES C CXX)

set(CMAKE_CXX_SCAN_FOR_MODULES OFF)
option(BUILD_SHARED_LIBS "Build shared libraries" ON)

option(ots_GRAPHITE "Sanitize Graphite tables" ON)
option(ots_SYNTHESIZE_MISSING_GVAR "Synthesize an empty gvar if fvar is present" ON)
option(ots_COLR_CYCLE_CHECK "Reject fonts with cycles in COLRv1 paint graph" ON)

option(ots_STAGE_OUTPUTS "Stage build output artifacts into proper directory structure" ${PROJECT_IS_TOP_LEVEL})

option(ots_BUILD_DEMOS "Build demos for otfccxx" ${PROJECT_IS_TOP_LEVEL})
option(ots_BUILD_SHARED_LIB "Build a shared version of otfccxx" ${BUILD_SHARED_LIBS})

if(CMAKE_BUILD_TYPE STREQUAL "Debug")

  
endif()


#####################################################################
### Staging ###
#####################################################################
include(cmake/StageOutputs.cmake)
if(ots_STAGE_OUTPUTS)
  stageOutputDirsFor(ots)
endif()


########################################################
### Target specification ###
########################################################
include(CMake_dependencies.cmake) ### Loads and declares the required external libraries using CPM or CMake's FetchContent.

if(ots_BUILD_SHARED_LIB)
  add_library(ots-lib SHARED)
else()
  add_library(ots-lib STATIC)
endif()
add_library(ots-lib::ots-lib ALIAS otfccxx)

target_sources(ots-lib PRIVATE src/otfccxx.cpp src/fmem_file.cpp src/machinery_stderr_capt.cpp)
target_sources(ots-lib
  PUBLIC
  FILE_SET pub_headers
  TYPE HEADERS
  BASE_DIRS
  include)

target_sources(ots-lib
  PRIVATE
  FILE_SET priv_headers
  TYPE HEADERS
  BASE_DIRS
  src)

target_link_libraries(ots-lib PRIVATE woff2dec)

target_compile_features(ots-lib PRIVATE cxx_std_11)

# if(ots_BUILD_SHARED_LIB)
#   set_target_properties(otfccxx PROPERTIES
#     CXX_VISIBILITY_PRESET hidden
#     VISIBILITY_INLINES_HIDDEN YES
#   )
#   target_compile_definitions(otfccxx
#     PRIVATE OTFCCXX_EXPORTS
#     PUBLIC OTFCCXX_SHARED
#   )
# endif()


########################################################
### Executable targets ###
########################################################
if(ots_BUILD_DEMOS)

endif()


#####################################################################
### Platform specific hacks ###
#####################################################################
if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT MATCHES "MSVC")
  add_compile_options(/utf-8)
  add_compile_definitions(NOMINMAX)
endif()


#####################################################################
### Installing, packaging ###
#####################################################################
if(ots_BUILD_SHARED_LIB)
  install(
    TARGETS ots-lib
    EXPORT ots_target
    RUNTIME_DEPENDENCY_SET ots_depset
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    FILE_SET pub_headers
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  )

  # When compling with MinGW we need to include the runtime DLLs along
  if(MINGW)
    get_filename_component(OTS_CXX_COMPILER_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)
    install(
      RUNTIME_DEPENDENCY_SET ots_depset
      PRE_EXCLUDE_REGEXES
      [[api-ms-.*]]
      [[ext-ms-.*]]
      POST_INCLUDE_REGEXES
      [[libstdc\+\+*]]
      [[libgcc_s*]]
      [[libwoff2*]]
      [[libharfbuzz*]]
      POST_EXCLUDE_REGEXES
      [[\\*.dll]]
      DIRECTORIES
      ${OTS_CXX_COMPILER_DIR}
    )
  endif()

  # Creating a script for being able to use 'find_package')
  install(
    EXPORT ots_target
    NAMESPACE ots::
    DESTINATION lib/cmake/ots
  )

else()
  message(STATUS "Installing ots is not available because it is being built as STATIC library")
endif()

# if(PROJECT_IS_TOP_LEVEL AND ots_BUILD_SHARED_LIB)
#   add_subdirectory(cmake/packaging)
# endif()

