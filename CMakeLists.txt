cmake_minimum_required(VERSION 3.16)

project(pigpio
LANGUAGES C 
VERSION 0.79.0
)

include(CMakeDependentOption)

# Options for the project
option(BUILD_SHARED_LIBS "Create shared libraries" ON)
option(BUILD_DAEMON "Build the daemon and the pigs executable for controlling the GPIO remotely" ON)
option(BUILD_EXECUTABLES "Build the executables for the pigpio libraries" ON)
option(BUILD_VCD_CONVERTER "Build the vcd converter for use with GTKWave" ON)

# Get the install/uninstall script
include(FetchContent)
FetchContent_Declare(
	ez-cmake
	GIT_REPOSITORY "https://github.com/errata-c/ez-cmake.git"
	GIT_TAG "main"
)
FetchContent_MakeAvailable(ez-cmake)



# Add cmake directory for finding modules
list (APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

find_package(Threads REQUIRED)
find_package(rt REQUIRED)

set(TARGETS_TO_INSTALL pigpio_common pigpio)

# common configuration to all targets
add_library(pigpio_common INTERFACE)
target_compile_options(pigpio_common INTERFACE "$<BUILD_INTERFACE:-Wall>")
target_include_directories(pigpio_common INTERFACE
	"$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/pigpio>"
	"$<INSTALL_INTERFACE:include>"
)

# libpigpio.(so|a)
add_library(pigpio 
	src/pigpio.c 
	src/command.c 
	src/custom.cext
)
target_link_libraries(pigpio PUBLIC pigpio_common Threads::Threads)


if(BUILD_EXECUTABLES)
	# x_pigpio
	add_executable(x_pigpio 
		src/x_pigpio.c
	)
	target_link_libraries(x_pigpio PUBLIC 
		pigpio rt::rt Threads::Threads
	)

	# x_pigpiod_if
	add_executable(x_pigpiod_if 
		src/x_pigpiod_if.c
	)
	target_link_libraries(x_pigpiod_if PUBLIC 
		pigpiod_if rt::rt Threads::Threads
	)

	# x_pigpiod_if2
	add_executable(x_pigpiod_if2 
		src/x_pigpiod_if2.c
	)
	target_link_libraries(x_pigpiod_if2 PUBLIC 
		pigpiod_if2 rt::rt Threads::Threads
	)
endif()

if(BUILD_DAEMON)
	# pigpiod
	add_executable(pigpiod 
		src/pigpiod.c
	)
	target_link_libraries(pigpiod PUBLIC 
		pigpio rt::rt Threads::Threads
	)

	# pigs
	add_executable(pigs 
		src/pigs.c 
		src/command.c
	)
	target_link_libraries(pigs PUBLIC 
		pigpio_common Threads::Threads
	)
	
	# libpigpiod_if.(so|a)
	add_library(pigpiod_if 
		src/pigpiod_if.c 
		src/command.c
	)
	target_link_libraries(pigpiod_if PUBLIC pigpio_common)


	# libpigpiod_if2.(so|a)
	add_library(pigpiod_if2 
		src/pigpiod_if2.c 
		src/command.c
	)
	target_link_libraries(pigpiod_if2 PUBLIC pigpio_common)
	
	list(APPEND TARGETS_TO_INSTALL pigpiod_if pigpiod_if2 pigpiod pigs)
endif()

if(BUILD_VCD_CONVERTER)
	# pig2vcd
	add_executable(pig2vcd 
		src/pig2vcd.c 
		src/command.c
	)
	target_link_libraries(pig2vcd PUBLIC 
		pigpio_common Threads::Threads
	)
	
	list(APPEND TARGETS_TO_INSTALL pig2vcd)
endif()


# Configure and install project

include(GenerateExportHeader)
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

generate_export_header(${PROJECT_NAME})

install(TARGETS ${TARGETS_TO_INSTALL}
    EXPORT ${PROJECT_NAME}Targets
	LIBRARY  DESTINATION lib
	ARCHIVE  DESTINATION lib
	RUNTIME  DESTINATION bin
)

write_basic_package_version_file(
	"${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
	VERSION ${${PROJECT_NAME}_VERSION}
	COMPATIBILITY AnyNewerVersion
)

export(EXPORT ${PROJECT_NAME}Targets
  FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake"
  NAMESPACE pigpio::
)

set(ConfigPackageLocation share/cmake/${PROJECT_NAME})
install(EXPORT ${PROJECT_NAME}Targets
  FILE
    ${PROJECT_NAME}Targets.cmake
  NAMESPACE
    pigpio::
  DESTINATION
    ${ConfigPackageLocation}
)

install(
  FILES
    "${CMAKE_CURRENT_LIST_DIR}/cmake/${PROJECT_NAME}Config.cmake"
	"${CMAKE_CURRENT_LIST_DIR}/cmake/Findrt.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  DESTINATION
    ${ConfigPackageLocation}
)

# Removed the permissions lines from these install commands, the default permissions are the same.
install(FILES "include/pigpio/pigpio.h" "include/pigpio/pigpiod_if.h" "include/pigpio/pigpiod_if2.h"
	DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/pigpio"
)

file(GLOB man_1_SRC "*.1")
install(FILES ${man_1_SRC}
	DESTINATION "${CMAKE_INSTALL_MANDIR}/man1"
)

file(GLOB man_3_SRC "*.3")
install(FILES ${man_3_SRC}
	DESTINATION "${CMAKE_INSTALL_MANDIR}/man3"
)

# Install python modules.
find_package(Python COMPONENTS Interpreter QUIET)

if(Python_FOUND)
	configure_file("${CMAKE_CURRENT_LIST_DIR}/cmake/setup.py.in"
		"${CMAKE_CURRENT_BINARY_DIR}/setup.py"
	)

	install(CODE "execute_process(COMMAND ${Python_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/setup.py install)")
endif()

# package project

include (CPack)