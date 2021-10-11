# Findrt.cmake - Try to find the rt library
# Once done this will define
#
#  rt_FOUND - System has rt
#  rt_INCLUDE_DIR - The rt include directory
#  rt_LIBRARIES - The libraries needed to use rt
#  rt_DEFINITIONS - Compiler switches required for using rt
#
# Also creates an import target called rt::rt

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

include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(rt DEFAULT_MSG rt_LIBRARIES rt_INCLUDE_DIR)

mark_as_advanced(rt_INCLUDE_DIR rt_LIBRARIES)

if (NOT TARGET rt::rt)
  add_library(rt::rt INTERFACE IMPORTED)

  set_target_properties(rt::rt PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${rt_INCLUDE_DIR}
    INTERFACE_LINK_LIBRARIES ${rt_LIBRARIES}
  )
endif()