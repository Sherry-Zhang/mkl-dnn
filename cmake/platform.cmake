#===============================================================================
# Copyright 2016-2017 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#===============================================================================
# Manage platform-specific quirks
#===============================================================================

if(platform_cmake_included)
    return()
endif()
set(platform_cmake_included true)

add_definitions(-DMKLDNN_DLL -DMKLDNN_DLL_EXPORTS)

# UNIT8_MAX-like macros are a part of the C99 standard and not a part of the
# C++ standard (see C99 standard 7.18.2 and 7.18.4)
add_definitions(-D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS)

set(CMAKE_CCXX_FLAGS)

if(WIN32)
    set(USERCONFIG_PLATFORM "x64")
    set(CMAKE_CCXX_FLAGS "${CMAKE_CCXX_FLAGS} /MP")
    if(MSVC)
        set(CMAKE_CCXX_FLAGS "${CMAKE_CCXX_FLAGS} /wd4800") # int -> bool
        set(CMAKE_CCXX_FLAGS "${CMAKE_CCXX_FLAGS} /wd4068") # unknown pragma
        set(CMAKE_CCXX_FLAGS "${CMAKE_CCXX_FLAGS} /wd4305") # double -> float
    endif()
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
        set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -QxHOST")
    endif()
elseif(UNIX OR APPLE)
    set(CMAKE_CCXX_FLAGS "${CMAKE_CCXX_FLAGS} -Wall -Werror -Wno-unknown-pragmas")
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        # Clang cannot vectorize some loops with #pragma omp simd and gets
        # very upset. Tell it that it's okay and that we love it
        # unconditionnaly.
        set(CMAKE_CCXX_FLAGS "${CMAKE_CCXX_FLAGS} -Wno-pass-failed")
    endif()
    set(CMAKE_CCXX_FLAGS "${CMAKE_CCXX_FLAGS} -fvisibility=internal")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fvisibility-inlines-hidden")
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
        set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -xHOST")
    endif()
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_CCXX_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CCXX_FLAGS}")

if(APPLE)
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    # FIXME: this is ugly but required when compiler does not add its library
    # paths to rpath (like Intel compiler...)
    foreach(_ ${CMAKE_C_IMPLICIT_LINK_DIRECTORIES})
        set(_rpath "-Wl,-rpath,${_}")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${_rpath}")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${_rpath}")
    endforeach()
endif()
