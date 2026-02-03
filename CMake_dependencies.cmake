include(cmake/CPM.cmake)

# We need to provide custom CMake module/script for WOFF2 (FindWOFF2.cmake)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

if(NOT CPM_USE_LOCAL_PACKAGES)
  set(CPM_USE_LOCAL_PACKAGES ON)
endif()

# ZLIB
# ZLIB provides .pc so we prefer to find it using PkgConfig
set(PKG_CONFIG_USE_STATIC_LIBS ON)
find_package(PkgConfig)
if(PkgConfig_FOUND)
  # Check the module name with: pkg-config --modversion zlib
  pkg_check_modules(ZLIB_PC IMPORTED_TARGET zlib)
  if(NOT TARGET PkgConfig::ZLIB_PC)
    message(STATUS "PkgConfig did not find zlib. ots project will try to build and link static version of zlib.")
  endif()
else()
  message(STATUS "Could NOT find PkgConfig. ots project will try to build and link static version of zlib.")
endif()

# If we cannot find it using PkgConfig, we build a static version from source
if(NOT TARGET PkgConfig::ZLIB_PC)
  set(__BACKUP_CPM_USE_LOCAL_PACKAGES ${CPM_USE_LOCAL_PACKAGES})
  set(CPM_USE_LOCAL_PACKAGES OFF)
  CPMAddPackage(
    URI "gh:madler/zlib@1.3.1.2"
    OPTIONS
    "ZLIB_BUILD_SHARED OFF"
    "ZLIB_INSTALL OFF"
    "ZLIB_BUILD_TESTING OFF"
    NAME ZLIB
  )
  set(CPM_USE_LOCAL_PACKAGES ${__BACKUP_CPM_USE_LOCAL_PACKAGES})
  unset(__BACKUP_CPM_USE_LOCAL_PACKAGES)
  add_library(ZLIB::ZLIB ALIAS zlibstatic)
endif()

# WOFF2
CPMAddPackage(
  URI "gh:InCom-0/woff2#otfccxx"
  OPTIONS "NOISY_LOGGING OFF" "BUILD_SHARED_LIBS OFF"
  NAME WOFF2
)

if(WOFF2_ADDED)
  set(OTS_WOFF2_BUILDFROMSOURCE TRUE)
endif()

if(ZLIB_ADDED)
  set(OTS_ZLIB_BUILDFROMSOURCE TRUE)
endif()
