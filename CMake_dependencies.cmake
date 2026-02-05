if(NOT DEFINED CPM_USE_LOCAL_PACKAGES)
    set(CPM_USE_LOCAL_PACKAGES ${ots_USE_LOCAL_PACKAGES} CACHE BOOL "CPM will try to find packages locally first" FORCE)
endif()
if(NOT DEFINED CPM_LOCAL_PACKAGES_ONLY)
    set(CPM_LOCAL_PACKAGES_ONLY ${ots_USE_LOCAL_PACKAGES} CACHE BOOL
        "CPM will not be forbidden from downloading packages. Will have to use local packages." FORCE)
endif()

include(cmake/CPM.cmake)


# We need to provide custom CMake module/script for WOFF2 (FindWOFF2.cmake)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

# ZLIB provides .pc so we prefer to find it using PkgConfig
set(PKG_CONFIG_USE_STATIC_LIBS ON)
find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
    # Check the module name with: pkg-config --modversion zlib
    pkg_check_modules(ZLIB_PC IMPORTED_TARGET zlib)
    if(NOT TARGET PkgConfig::ZLIB_PC)
        message(STATUS "PkgConfig did not find zlib. ots project will try to build and link static version of zlib.")
    endif()
else()
    message(STATUS "Could NOT find PkgConfig. ots project will try to build and link static version of zlib.\n")
endif()

# If we cannot find it using PkgConfig, we build a static version from source
if(NOT TARGET PkgConfig::ZLIB_PC)
    CPMAddPackage(
        URI "gh:madler/zlib@1.3.1.2"
        OPTIONS
        "ZLIB_BUILD_SHARED OFF"
        "ZLIB_INSTALL OFF"
        "ZLIB_BUILD_TESTING OFF"
        NAME ZLIB
    )
endif()

# WOFF2
if(WIN32 AND (CMAKE_BUILD_TYPE STREQUAL "Release"))
    set(CPM_USE_LOCAL_PACKAGES OFF)
    CPMAddPackage(
        URI "gh:InCom-0/woff2#otfccxx"
        OPTIONS "NOISY_LOGGING OFF" "BUILD_SHARED_LIBS OFF"
        NAME WOFF2
    )
    unset(CPM_USE_LOCAL_PACKAGES)
else()

endif()
if(WOFF2_ADDED)
    set(OTS_WOFF2_BUILDFROMSOURCE TRUE)
endif()

if(ZLIB_ADDED)
    set(OTS_ZLIB_BUILDFROMSOURCE TRUE)
endif()
