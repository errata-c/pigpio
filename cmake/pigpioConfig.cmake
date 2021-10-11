include(CMakeFindDependencyMacro)

if(NOT TARGET Threads::Threads)
	set(THREADS_PREFER_PTHREAD_FLAG ON)
	find_dependency(Threads)
endif()

if(NOT TARGET rt::rt)
	include(${CMAKE_CURRENT_LIST_DIR}/Findrt.cmake)
endif()

if(NOT TARGET pigpio::pigpio)
	include(${CMAKE_CURRENT_LIST_DIR}/pigpioTargets.cmake)
endif()
