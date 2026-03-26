cmake_minimum_required(VERSION 3.30...4.2)

project(ots
  HOMEPAGE_URL "https://github.com/InCom-0/ots"
  VERSION "9.2.0"
  DESCRIPTION
  "Sanitizer for OpenType."
  LANGUAGES C CXX
)

set(CMAKE_CXX_SCAN_FOR_MODULES OFF)
option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(ots_BUILD_SHARED_LIB "Build a shared version of ots" ${BUILD_SHARED_LIBS})
option(ots_STAGE_OUTPUTS "Stage build output artifacts into proper directory structure" ${PROJECT_IS_TOP_LEVEL})

option(CPM_USE_LOCAL_PACKAGES "Use local (usually system installed) packages for dependencies." ON)
option(CPM_LOCAL_PACKAGES_ONLY "Forbid the build system from downloading missing dependencies." OFF)

option(ots_GRAPHITE "Sanitize Graphite tables" ON)
option(ots_SYNTHESIZE_MISSING_GVAR "Synthesize an empty gvar if fvar is present" ON)
option(ots_COLR_CYCLE_CHECK "Reject fonts with cycles in COLRv1 paint graph" ON)

option(ots_BUILD_EXECUTABLES "Build all executables (individually overrideable)" ${PROJECT_IS_TOP_LEVEL})
option(ots_BUILD_SANITIZE "Build ots-sanitize executable" ${ots_BUILD_EXECUTABLES})
option(ots_BUILD_FUZZER "Build ots-fuzzer executable" ${ots_BUILD_EXECUTABLES})
option(ots_BUILD_IDEMPOTENT "Build ots-idempotent executable" ${ots_BUILD_EXECUTABLES})
option(ots_BUILD_VALIDATOR_CHECKER "Build ots-validator-checker executable" ${ots_BUILD_EXECUTABLES})
option(ots_BUILD_SIDE_BY_SIDE "Build ots-side-by-side executable" ${ots_BUILD_EXECUTABLES})
option(ots_BUILD_CFF_CHARSTRING "Build ots-cff_charstring executable" ${ots_BUILD_EXECUTABLES})

include(cmake/incom/StdlibQuery.cmake)


#####################################################################
### Staging ###
#####################################################################
include(cmake/incom/StageOutputs.cmake)
if(ots_STAGE_OUTPUTS)
  stageOutputDirsFor(ots)
endif()


########################################################
### Target specification ###
########################################################
include(CMake_dependencies.cmake) ### Loads and declares the required external libraries using CPM or CMake's FetchContent.

if(ots_BUILD_SHARED_LIB)
  add_library(ots SHARED)
else()
  add_library(ots STATIC)
endif()
add_library(ots::ots ALIAS ots)

set(OTS_SOURCES
  src/avar.cc
  src/cff.cc
  src/cff_charstring.cc
  src/cmap.cc
  src/colr.cc
  src/cpal.cc
  src/cvar.cc
  src/cvt.cc
  src/fpgm.cc
  src/fvar.cc
  src/gasp.cc
  src/gdef.cc
  src/glyf.cc
  src/gpos.cc
  src/gsub.cc
  src/gvar.cc
  src/hdmx.cc
  src/head.cc
  src/hhea.cc
  src/hvar.cc
  src/kern.cc
  src/layout.cc
  src/loca.cc
  src/ltsh.cc
  src/math.cc
  src/maxp.cc
  src/metrics.cc
  src/mvar.cc
  src/name.cc
  src/os2.cc
  src/ots.cc
  src/post.cc
  src/prep.cc
  src/stat.cc
  src/variations.cc
  src/vdmx.cc
  src/vhea.cc
  src/vorg.cc
  src/vvar.cc
)

target_sources(ots PRIVATE ${OTS_SOURCES})
target_sources(ots
  PUBLIC
  FILE_SET pub_headers
  TYPE HEADERS
  BASE_DIRS
  include)

target_sources(ots
  PRIVATE
  FILE_SET priv_headers
  TYPE HEADERS
  BASE_DIRS
  src)

target_sources(ots
  PRIVATE
  FILE_SET priv_auto_config
  TYPE HEADERS
  BASE_DIRS
  cmake/config/auto)


target_link_libraries(ots PRIVATE ZLIB::ZLIB)

target_link_libraries(ots PRIVATE WOFF2::woff2dec)

target_compile_features(ots PRIVATE cxx_std_11)

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

#############################################################
### Automatic code generation (for version numbers, etc.) ###
#############################################################

# Values passed to cmake/config/configUpdate.cmake (script mode, no project context).
set(HAVE_WIN32 0)
if(WIN32)
  set(HAVE_WIN32 1)
endif()

set(OTS_DEBUG 0)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(OTS_DEBUG 1)
endif()

set(COM_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/generated/private_inc/auto/config.h)
add_custom_command(
  OUTPUT ${COM_OUTPUT}
  COMMAND ${CMAKE_COMMAND}
  -D TO_OUTPUT=${COM_OUTPUT}
  -D TO_INPUT=${CMAKE_CURRENT_SOURCE_DIR}/cmake/config/config.h.in
  -D HAVE_WIN32=${HAVE_WIN32}
  -D OTS_COLR_CYCLE_CHECK=${ots_COLR_CYCLE_CHECK}
  -D OTS_DEBUG=${OTS_DEBUG}
  -D OTS_GRAPHITE=${ots_GRAPHITE}
  -D OTS_SYNTHESIZE_MISSING_GVAR=${ots_SYNTHESIZE_MISSING_GVAR}
  -D PROJECT_NAME=${PROJECT_NAME}
  -D FULL_VERSION=${PROJECT_VERSION}
  -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/config/configUpdate.cmake
  DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/config/config.h.in
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/config/configUpdate.cmake
  VERBATIM)

add_custom_target(ENSUREAutoFileDeps ALL DEPENDS ${COM_OUTPUT})
add_dependencies(ots ENSUREAutoFileDeps)


########################################################
### Executable targets ###
########################################################
if(ots_BUILD_SANITIZE)

endif()


#####################################################################
### Platform specific hacks ###
#####################################################################
if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT MATCHES "MSVC")
  add_compile_options(/utf-8)
  add_compile_definitions(NOMINMAX)
  set_source_files_properties(
    src/glyf.cc
    PROPERTIES
    COMPILE_OPTIONS "/wd4267"
  )
endif()


#####################################################################
### Installing, packaging ###
#####################################################################
# if(ots_BUILD_SHARED_LIB)
# install(
#   TARGETS ots
#   EXPORT ots_target
#   RUNTIME_DEPENDENCY_SET ots_depset
#   RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
#   LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
#   ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
#   PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
#   FILE_SET pub_headers
#   DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
# )

#   # When compling with MinGW we need to include the runtime DLLs along
#   if(MINGW)
#     get_filename_component(OTS_CXX_COMPILER_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)
#     install(
#       RUNTIME_DEPENDENCY_SET ots_depset
#       PRE_EXCLUDE_REGEXES
#       [[api-ms-.*]]
#       [[ext-ms-.*]]
#       POST_INCLUDE_REGEXES
#       [[libstdc\+\+*]]
#       [[libgcc_s*]]
#       [[libwoff2*]]
#       [[libharfbuzz*]]
#       POST_EXCLUDE_REGEXES
#       [[\\*.dll]]
#       DIRECTORIES
#       ${OTS_CXX_COMPILER_DIR}
#     )
#   endif()

#   # Creating a script for being able to use 'find_package')
#   install(
#     EXPORT ots_target
#     NAMESPACE ots::
#     DESTINATION lib/cmake/ots
#   )

# else()
#   message(STATUS "Installing ots is not available because it is being built as STATIC library")
# endif()

# if(PROJECT_IS_TOP_LEVEL AND ots_BUILD_SHARED_LIB)
#   add_subdirectory(cmake/packaging)
# endif()

