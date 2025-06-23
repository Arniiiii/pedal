find_package(PkgConfig REQUIRED)

pkg_check_modules(liburing REQUIRED IMPORTED_TARGET liburing)
