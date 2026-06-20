
include(cmake/CPM_0.42.3.cmake)


# We need to provide custom CMake module/script for WOFF2 (FindWOFF2.cmake)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/incom/modules")


if(OTS_BUILD_SHARED_LIB)
    set(OTS_BUILD_STATIC_LIB OFF)
else()
    set(OTS_BUILD_STATIC_LIB ON)
endif()

find_package(ZLIB)

if (NOT ZLIB_FOUND)
    CPMAddPackage(
        URL https://github.com/madler/zlib/releases/download/v1.3.2/zlib-1.3.2.tar.xz
        URL_HASH SHA256=d7a0654783a4da529d1bb793b7ad9c3318020af77667bcae35f95d0e42a792f3
        EXCLUDE_FROM_ALL TRUE
        OPTIONS
        "ZLIB_BUILD_SHARED ${OTS_BUILD_SHARED_LIB}"
        "ZLIB_BUILD_STATIC ${OTS_BUILD_STATIC_LIB}"
        "ZLIB_INSTALL OFF"
        "ZLIB_INSTALL_COMPAT_DLL OFF"
        "ZLIB_BUILD_TESTING OFF"
        "ZLIB_BUILD_MINIZIP OFF"
        "ZLIB_BUILD_EXAMPLES OFF"
        VERSION 1.3.2
        NAME ZLIB
    )
endif()
unset(ZLIB_USE_STATIC_LIBS)

if(ZLIB_ADDED AND (NOT TARGET ZLIB::ZLIB))
    if(OTS_BUILD_STATIC_LIB)
        add_library(ZLIB::ZLIB ALIAS zlibstatic)
    else()
        add_library(ZLIB::ZLIB ALIAS zlib)
    endif()
endif()

CPMAddPackage(
    URI "gh:InCom-0/woff2#otfccxx"
    OPTIONS
    "NOISY_LOGGING OFF"
    "BUILD_SHARED_LIBS ${OTS_BUILD_SHARED_LIB}"
    NAME WOFF2
    FIND_PACKAGE_ARGUMENTS "COMPONENTS woff2dec woff2enc"
)


