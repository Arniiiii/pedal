# pedal

Another my project for a weekend: make my pedals do something.

## What problem I had

I have a set of old foot pedals and a steering wheel that are connectable via USB.

The problem: how to use them in games that do not support steering wheel and pedals in Linux?

### Solution

Read input events from pedals, think what to do, send changed output (i.e. pressing a button on keyboard) via Linux's uinput module to the system.

## Requirements

- Linux
- A modern C++ compiler ( tested with g++-14 and clang-20 )
- CMake
- a generator that CMake can generate to ( Ninja or Make ).

Technically speaking, in current state of the CMake scripts here, you should have locally installed:
 
 - Linux's headers, in case you didn't have.
 - Boost ( I've set minimum 1.85.0, but you can patch to any version you think you need, since I needed only boost::asio ), because it's actually good.
 - Corral , a library for structured asynchronous programming. 
 - Liburing, because it's maybe faster with it.
 - Quill, one of the fastest text based logging libraries in C++.
 - PackageProject.cmake , a script for easy installing any CMake project (though it sucks: it doesn't generate .pc).
 - CPM , a script for downloading-bundling or finding installed packages. Can be automatically downloaded at configuring.
 - AddBoost.cmake , my script for downloading-bundling or finding Boost. 

But, as you may think not all of the packages do exist on all main distros. Currently, because there's no one reported that they need the package to be more portable, I assume you can use `gentoo` in docker, preferably musl, compile statically, then copy binary to your main Linux. All of the required packages can be found either in `::gentoo` aka main default overlay(repo of recipes) or in my `::ex_repo` overlay.

Assuming you are in gentoo docker (via i.e. `docker run -it gentoo/stage3:amd64-openrc /bin/bash` or if you are ready to compile a lot of packages for dependencies: `docker run -it gentoo/stage3:amd64-musl /bin/bash`), here's the commands I would expect to work (not tested, but should work):
`emerge-webrsync`
`getuto`
`FEATURES="parallel-install parallel-fetch" emerge -vtg -j8 -l $(nproc) eselect-repository`
`eselect repository enable ex_repo`
`emaint sync --repo ex_repo`
`echo -e "dev-cpp/corral ~amd64\ndev-cpp/quill ~amd64\ndev-cmake/packageproject-cmake ~amd64\ndev-cmake/cpm-cmake ~amd64\ndev-cmake/addboost-cmake ~amd64" > /etc/portage/package.accept_keywords/any_file`
`FEATURES="parallel-install parallel-fetch" emerge -vtg -j8 -l $(nproc) dev-build/cmake dev-libs/boost dev-cpp/corral dev-cpp/quill dev-cmake/packageproject-cmake dev-cmake/cpm-cmake dev-cmake/addboost-cmake sys-libs/liburing sys-kernel/linux-headers`
`cd to_folder_with_the_repo`
`cmake -S . -B ./build -DCPM_LOCAL_PACKAGES_ONLY=1`
`cmake --build ./build -j $(nproc) --verbose`
now presumably a binary executable at `./build/pedal-1.0`

# License

MIT
