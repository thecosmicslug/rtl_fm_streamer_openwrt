# Copyright 2012 OSMOCOM Project
#
# This file is part of rtl-sdr
#
# GNU Radio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# GNU Radio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Radio; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street,
# Boston, MA 02110-1301, USA.


########################################################################
# Project setup
########################################################################
cmake_minimum_required(VERSION 3.6)
project(rtlsdr C)

#select the release build type by default to get optimization flags
if(NOT CMAKE_BUILD_TYPE)
   set(CMAKE_BUILD_TYPE "Release")
   message(STATUS "Build type not specified: defaulting to release.")
endif(NOT CMAKE_BUILD_TYPE)
set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE} CACHE STRING "")

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/Modules)

if(NOT LIB_INSTALL_DIR)
   set(LIB_INSTALL_DIR lib)
endif()

# Set the version information here
set(VERSION_INFO_MAJOR_VERSION 0) # increment major on api compatibility changes
set(VERSION_INFO_MINOR_VERSION 5) # increment minor on feature-level changes
set(VERSION_INFO_PATCH_VERSION git) # increment patch for bug fixes and docs
#### include(Version) # setup version info

########################################################################
# Compiler specific setup
########################################################################
if(CMAKE_COMPILER_IS_GNUCC AND NOT WIN32)
    add_compile_options(-Wall)
    add_compile_options(-Wextra)
    add_compile_options(-Wno-unused-parameter)
    add_compile_options(-Wno-unused)
    add_compile_options(-Wsign-compare)
    add_compile_options(-Wdeclaration-after-statement)
    #http://gcc.gnu.org/wiki/Visibility
    add_compile_options(-fvisibility=hidden)
    add_compile_options(-w)
endif()

########################################################################
# Find build dependencies
########################################################################
find_package(PkgConfig)
find_package(LibRTLSDR)
find_package(LibUSB)
find_package(Libev)

set(THREADS_USE_PTHREADS_WIN32 true)
find_package(Threads)

if(NOT THREADS_FOUND)
    message(FATAL_ERROR "pthreads(-win32) required to compile rtl-sdr")
endif()

if(LibRTLSDR_FOUND)
    include_directories(${LibRTLSDR_INCLUDE_DIRS})
    list(APPEND SDR_LIBRARIES ${LibRTLSDR_LIBRARIES})
    add_compile_options(-DRTLSDR)
else()
    message(STATUS "LibRTLSDR not found!")
endif()

if(LibUSB_FOUND)
    include_directories(${LIBUSB_INCLUDE_DIRS})
    list(APPEND SDR_LIBRARIES ${LIBUSB_LIBRARIES})
    set(LIBUSB_LIBRARIES "" CACHE STRING "manual libusb path")
    set(LIBUSB_INCLUDE_DIRS "" CACHE STRING "manual libusb includepath")
    add_compile_options(-DLIBUSB1)
else()
    message(STATUS "libusb-1.0 error messages are not available.")
endif()

if(LIBEV_FOUND)
    include_directories(${LIBEV_INCLUDE_DIR})
    list(APPEND SDR_LIBRARIES ${LIBEV_LIBRARY})
    add_compile_options(-lev)
else()
    message(STATUS "LIBEV_NOT_FOUND error!! ")
endif()

########################################################################
# Setup the include and linker paths
########################################################################
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${LIBUSB_INCLUDE_DIR}
    ${THREADS_PTHREADS_INCLUDE_DIR}
)

#link_directories(
#    ...
#)

# Set component parameters
#set(INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/include CACHE INTERNAL "" FORCE)

########################################################################
# Create uninstall target
########################################################################
configure_file(
    ${CMAKE_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
@ONLY)

add_custom_target(uninstall
    ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
)

########################################################################
# Install udev rules
########################################################################
option(INSTALL_UDEV_RULES "Install udev rules for RTL-SDR" OFF)
if (INSTALL_UDEV_RULES)
    install (
        FILES rtl-sdr.rules
        DESTINATION "/etc/udev/rules.d"
        COMPONENT "udev"
        )
else (INSTALL_UDEV_RULES)
    message (STATUS "Udev rules not being installed, install them with -DINSTALL_UDEV_RULES=ON")
endif (INSTALL_UDEV_RULES)

option(DETACH_KERNEL_DRIVER "Detach kernel driver if loaded" OFF)
if (DETACH_KERNEL_DRIVER)
    message (STATUS "Building with kernel driver detaching enabled")
    add_compile_options(-DDETACH_KERNEL_DRIVER=1)
else (DETACH_KERNEL_DRIVER)
    message (STATUS "Building with kernel driver detaching disabled, use -DDETACH_KERNEL_DRIVER=ON to enable")
endif (DETACH_KERNEL_DRIVER)

########################################################################
# Add subdirectories
########################################################################
add_subdirectory(include)
add_subdirectory(src)

########################################################################
# Create Pkg Config File
########################################################################
FOREACH(inc ${LIBUSB_INCLUDE_DIR})
    LIST(APPEND RTLSDR_PC_CFLAGS "-I${inc}")
ENDFOREACH(inc)

FOREACH(lib ${LIBUSB_LIBRARY_DIRS})
    LIST(APPEND RTLSDR_PC_LIBS "-L${lib}")
ENDFOREACH(lib)

# use space-separation format for the pc file
STRING(REPLACE ";" " " RTLSDR_PC_CFLAGS "${RTLSDR_PC_CFLAGS}")
STRING(REPLACE ";" " " RTLSDR_PC_LIBS "${RTLSDR_PC_LIBS}")

# unset these vars to avoid hard-coded paths to cross environment
IF(CMAKE_CROSSCOMPILING)
    UNSET(RTLSDR_PC_CFLAGS)
    UNSET(RTLSDR_PC_LIBS)
ENDIF(CMAKE_CROSSCOMPILING)

set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix \${prefix})
set(libdir \${exec_prefix}/${LIB_INSTALL_DIR})
set(includedir \${prefix}/include)

CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/librtlsdr.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/librtlsdr.pc
@ONLY)

INSTALL(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/librtlsdr.pc
    DESTINATION ${LIB_INSTALL_DIR}/pkgconfig
)

########################################################################
# Print Summary
########################################################################
MESSAGE(STATUS "Building for version: ${VERSION} / ${LIBVER}")
MESSAGE(STATUS "Using install prefix: ${CMAKE_INSTALL_PREFIX}")
