cmake_minimum_required(VERSION 3.14...3.22)

# ---- Project ----

# Note: update this to your new project's name and version
project(
  pedal
  VERSION 1.0
  LANGUAGES CXX
)

option(BUILD_SHARED_LIBS "yes/no" NO)
option(ENABLE_POLYHEDRAL_OPTIMIZATION
       "yes/no . Graphite for GCC and Polly for Clang" YES
)
option(ENABLE_LTO_OPTIMIZATION "yes/no . Graphite for GCC and Polly for Clang"
       YES
)

set(FETCHCONTENT_QUIET
    OFF
    CACHE BOOL "Make downloading of packages quiet"
)

# ---- Include guards ----

if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(
    FATAL_ERROR
      "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there."
  )
endif()

# ---- Create executable ----

add_executable(${PROJECT_NAME} ./standalone/source/main.cpp)
set_target_properties(${PROJECT_NAME} PROPERTIES CXX_STANDARD 23)

if(CMAKE_BUILD_TYPE STREQUAL Debug)
  if(GNU)
    target_compile_options(
      ${PROJECT_NAME} PUBLIC -fconcepts-diagnostics-depth=10
    )
  endif()
endif()

# ---- Add dependencies via CPM ----
# see https://github.com/TheLartians/CPM.cmake for more info

include(cmake/getCPM.cmake)

set(TRY_BOOST_VERSION "1.85.0")
# set(BOOST_NOT_HEADER_ONLY_COMPONENTS_THAT_YOU_NEED "thread")
set(BOOST_HEADER_ONLY_COMPONENTS_THAT_YOU_NEED "asio")
# set(BOOST_MY_OPTIONS "BOOST_ENABLE_PYTHON ON;")

include(${CMAKE_CURRENT_LIST_DIR}/cmake/packages/add_boost.cmake)

add_boost(TRY_BOOST_VERSION BOOST_HEADER_ONLY_COMPONENTS_THAT_YOU_NEED
          BOOST_NOT_HEADER_ONLY_COMPONENTS_THAT_YOU_NEED ${PROJECT_NAME}
)

include(./cmake/packages/add_liburing.cmake)

target_link_libraries(${PROJECT_NAME} PUBLIC PkgConfig::liburing)

include(./cmake/packages/add_quill.cmake)

target_link_libraries(${PROJECT_NAME} PRIVATE quill::quill)

include(./cmake/packages/add_corral.cmake)

target_link_libraries(${PROJECT_NAME} PRIVATE corral::corral)

# ---- Stupid customizations ----

include(./cmake/optimization_flags/lto.cmake)
set_project_lto_opts(${PROJECT_NAME})

include(./cmake/optimization_flags/polyhedral.cmake)
set_project_polyhedral_opts(${PROJECT_NAME})

# ---- Warnings              ----

include(./cmake/warnings.cmake)
set_project_warnings(${PROJECT_NAME})

# ---- Create an installable target ----
# this allows users to install and find the library via `find_package()`.

include(cmake/packages/add_packageproject.cmake)

# the location where the project's version header will be placed should match
# the project's regular header paths
string(TOLOWER ${PROJECT_NAME}/version.h VERSION_HEADER_LOCATION)
string(TOLOWER ${PROJECT_NAME}/export.h EXPORT_HEADER_LOCATION)

set_property(TARGET ${PROJECT_NAME} PROPERTY VERSION ${PROJECT_VERSION})

packageProject(
  NAME ${PROJECT_NAME}
  VERSION ${PROJECT_VERSION}
  BINARY_DIR ${PROJECT_BINARY_DIR}
  COMPATIBILITY "AnyNewerVersion" DISABLE_VERSION_SUFFIX ON
)
