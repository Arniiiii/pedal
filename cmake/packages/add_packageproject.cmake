# find_package(PackageProject.cmake REQUIRED)
include(${CMAKE_CURRENT_LIST_DIR}/../getCPM.cmake)

set(PackageProject.cmake_VERSION "13.0.5")

CPMAddPackage(
  NAME PackageProject.cmake
  VERSION "${PackageProject.cmake_VERSION}"
  URL "https://github.com/Arniiiii/PackageProject.cmake/archive/refs/tags/${PackageProject.cmake_VERSION}.tar.gz"
)
