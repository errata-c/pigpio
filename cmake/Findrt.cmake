# Findrt.cmake - Try to find the rt library
# Once done this will define
#
#  rt_FOUND - System has rt
#  rt_INCLUDE_DIR - The rt include directory
#  rt_LIBRARIES - The libraries needed to use rt
#  rt_DEFINITIONS - Compiler switches required for using rt
#
# Also creates an import target called rt::rt
if (NOT TARGET rt::rt)
	find_path (rt_INCLUDE_DIR NAMES time.h
	  PATHS
	  /usr
	  /usr/local
	  /opt
	  PATH_SUFFIXES
	)

	find_library(rt_LIBRARIES NAMES rt
	  PATHS
	  /usr
	  /usr/local
	  /opt
	)
	
	add_library(rt::rt INTERFACE IMPORTED)

	set_target_properties(rt::rt PROPERTIES
	INTERFACE_INCLUDE_DIRECTORIES ${rt_INCLUDE_DIR}
	INTERFACE_LINK_LIBRARIES ${rt_LIBRARIES}
	)
endif()