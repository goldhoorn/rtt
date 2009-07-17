###########################################################
#                                                         #
# Look for dependencies required by individual components #
#                                                         #
###########################################################

# Modules path (for searching FindXXX.cmake files)
LIST(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/config")

# Look for boost
IF (NOT CMAKE_CROSS_COMPILE) # NOTE: What happens if CMAKE_CROSS_COMPILE is TRUE?
  FIND_PACKAGE(Boost 1.32 REQUIRED)
  IF(Boost_FOUND)
    IF (NOT Boost_INCLUDE_DIRS STREQUAL "/usr/include")
      SET( RTT_CFLAGS "${RTT_CFLAGS} -I${BOOST_DIR}" )
    ENDIF (NOT Boost_INCLUDE_DIRS STREQUAL "/usr/include")
    SET(ORO_SUPPORT_BOOST TRUE CACHE INTERNAL "" FORCE)
  ELSE(Boost_FOUND)
    SET(ORO_SUPPORT_BOOST FALSE CACHE INTERNAL "" FORCE)
  ENDIF(Boost_FOUND)
ENDIF (NOT CMAKE_CROSS_COMPILE)

# Look for Xerces 

# If a nonstandard path is used when crosscompiling, uncomment the following lines
# IF(NOT CMAKE_CROSS_COMPILE) # NOTE: There now exists a standard CMake variable named CMAKE_CROSSCOMPILING
#   set(Xerces_ROOT_DIR /path/to/xerces CACHE INTERNAL "" FORCE) # you can also use set(ENV{Xerces_ROOT_DIR} /path/to/xerces)
# ENDIF(NOT CMAKE_CROSS_COMPILE)

FIND_PACKAGE(Xerces)

IF(Xerces_FOUND)
  SET(OROPKG_SUPPORT_XERCES_C TRUE CACHE INTERNAL "" FORCE)
  INCLUDE_DIRECTORIES(${Xerces_INCLUDE_DIRS})
  LINK_LIBRARIES(${Xerces_LIBRARIES}) # NOTE: Deprecated command
  SET(ORODAT_CORELIB_PROPERTIES_MARSHALLING_INCLUDE "\"marsh/CPFMarshaller.hpp\"")
  SET(OROCLS_CORELIB_PROPERTIES_MARSHALLING_DRIVER "CPFMarshaller")
  SET(ORODAT_CORELIB_PROPERTIES_DEMARSHALLING_INCLUDE "\"marsh/CPFDemarshaller.hpp\"")
  SET(OROCLS_CORELIB_PROPERTIES_DEMARSHALLING_DRIVER "CPFDemarshaller")
ELSE(Xerces_FOUND)
  SET(OROPKG_SUPPORT_XERCES_C FALSE CACHE INTERNAL "" FORCE)
  SET(ORODAT_CORELIB_PROPERTIES_MARSHALLING_INCLUDE "\"marsh/CPFMarshaller.hpp\"")
  SET(OROCLS_CORELIB_PROPERTIES_MARSHALLING_DRIVER "CPFMarshaller")
  SET(ORODAT_CORELIB_PROPERTIES_DEMARSHALLING_INCLUDE "\"marsh/TinyDemarshaller.hpp\"")
  SET(OROCLS_CORELIB_PROPERTIES_DEMARSHALLING_DRIVER "TinyDemarshaller")
ENDIF(Xerces_FOUND)

SET( OROCOS_TARGET gnulinux CACHE STRING "The Operating System target. One of [lxrt gnulinux xenomai macosx]")
STRING(TOUPPER ${OROCOS_TARGET} OROCOS_TARGET_CAP)

SET(LINUX_SOURCE_DIR ${LINUX_SOURCE_DIR} CACHE PATH "path to linux source dir" FORCE)

IF(OROCOS_TARGET STREQUAL "lxrt")
  SET(OROPKG_OS_LXRT TRUE CACHE INTERNAL "" FORCE)
  SET(RTAI_INSTALL_DIR ${RTAI_INSTALL_DIR} CACHE PATH "path to rtai installation dir" FORCE)
  # Look for LXRT
  # the recommended CMake method
  IF (NOT RTAI_INCLUDE_DIR)
	# use different variable than RTAI_INCLUDE_DIR, as the first SET in the
	# block below resets things and breaks the CMake cache when you rerun
	# cmake/ccmake.
	FIND_PATH(RTAI_INCLUDE_PATH rtai/rtai_lxrt.h)
	FIND_LIBRARY(RTAI_INSTALL_LIB lxrt)
#	MESSAGE(STATUS "RTAI: include ${RTAI_INCLUDE_PATH}")
#	MESSAGE(STATUS "RTAI: library ${RTAI_INSTALL_LIB}")
	IF ( RTAI_INCLUDE_PATH AND RTAI_INSTALL_LIB )
	  SET(RTAI_INCLUDE_DIR ${RTAI_INCLUDE_PATH}/rtai)
	  # presume RTAI_INSTALL_LIB is of form /path/to/lib/libnative.so, and
	  # so need to strip back to /path/to
	  GET_FILENAME_COMPONENT(RTAI_INSTALL_LIB2 ${RTAI_INSTALL_LIB} PATH)
	  GET_FILENAME_COMPONENT(RTAI_INSTALL_DIR ${RTAI_INSTALL_LIB2} PATH)
	  MESSAGE("-- Looking for RTAI/LXRT - found in ${RTAI_INSTALL_DIR}")
	ENDIF ( RTAI_INCLUDE_PATH AND RTAI_INSTALL_LIB )
  ENDIF (NOT RTAI_INCLUDE_DIR)

  IF (RTAI_INSTALL_DIR STREQUAL "")
    SET(RTAI_INSTALL_DIR "/usr/realtime")
  ENDIF (RTAI_INSTALL_DIR STREQUAL "")

  IF( EXISTS ${RTAI_INSTALL_DIR}/include/rtai_lxrt.h)
    MESSAGE("-- Looking for RTAI/LXRT - found in ${RTAI_INSTALL_DIR}")
    SET( RTAI_INCLUDE_DIR ${RTAI_INSTALL_DIR}/include)
  ENDIF( EXISTS ${RTAI_INSTALL_DIR}/include/rtai_lxrt.h)

  #If RTAI_INCLUDE_DIR has been defined, you must have defined also
  # RTAI_INSTALL_DIR.
  IF( RTAI_INCLUDE_DIR AND RTAI_INSTALL_DIR)
    SET(OROPKG_SUPPORT_RTAI TRUE CACHE INTERNAL "" FORCE)
    INCLUDE_DIRECTORIES(${RTAI_INCLUDE_DIR} ${LINUX_SOURCE_DIR}/include)
    SET(RTT_CFLAGS "${RTT_CFLAGS} -I${RTAI_INCLUDE_DIR} -I${LINUX_SOURCE_DIR}/include" CACHE INTERNAL "")
    SET(RTT_LINKFLAGS "${RTT_LINKFLAGS} -L${RTAI_INSTALL_DIR}/lib -llxrt -lpthread" CACHE INTERNAL "")
    LINK_LIBRARIES(lxrt pthread dl)
    LINK_DIRECTORIES(${RTAI_INSTALL_DIR}/lib)
  ELSE( RTAI_INCLUDE_DIR AND RTAI_INSTALL_DIR )
    MESSAGE(FATAL_ERROR "-- Looking for LXRT - not found (tried: ${RTAI_INSTALL_DIR}/include/rtai_lxrt.h, ${CMAKE_INCLUDE_PATH})")
    SET(OROPKG_SUPPORT_RTAI FALSE CACHE INTERNAL "" FORCE)
  ENDIF( RTAI_INCLUDE_DIR AND RTAI_INSTALL_DIR )
ELSE(OROCOS_TARGET STREQUAL "lxrt")
  SET(OROPKG_OS_LXRT FALSE CACHE INTERNAL "" FORCE)
ENDIF(OROCOS_TARGET STREQUAL "lxrt")


IF(OROCOS_TARGET STREQUAL "xenomai")
  # Look for Xenomai
  SET(XENOMAI_INSTALL_DIR ${XENOMAI_INSTALL_DIR} CACHE PATH "path to xenomai installation dir" FORCE)
  IF (XENOMAI_INSTALL_DIR STREQUAL "")
    SET(XENOMAI_INSTALL_DIR "/usr/realtime")
  ENDIF (XENOMAI_INSTALL_DIR STREQUAL "")
  SET(OROPKG_OS_XENOMAI TRUE CACHE INTERNAL "" FORCE)
  # Standard path of Xenomai: ( XENOMAI_INSTALL_DIR == /usr/realtime )
  IF(EXISTS ${XENOMAI_INSTALL_DIR}/include/native/task.h)
    MESSAGE("-- Looking for XENOMAI - found in ${XENOMAI_INSTALL_DIR}/include")
    SET( XENOMAI_INCLUDE_DIR "${XENOMAI_INSTALL_DIR}/include" )
  ENDIF(EXISTS ${XENOMAI_INSTALL_DIR}/include/native/task.h)
  # Debian package of Xenomai: ( XENOMAI_INSTALL_DIR == /usr )
  IF(EXISTS ${XENOMAI_INSTALL_DIR}/include/xenomai/native/task.h)
    MESSAGE("-- Looking for XENOMAI - found in ${XENOMAI_INSTALL_DIR}/include/xenomai")
    SET( XENOMAI_INCLUDE_DIR "${XENOMAI_INSTALL_DIR}/include/xenomai" )
  ENDIF(EXISTS ${XENOMAI_INSTALL_DIR}/include/xenomai/native/task.h)
  # Debian package of Xenomai: ( XENOMAI_INSTALL_DIR == /usr/xenomai )
  IF(EXISTS ${XENOMAI_INSTALL_DIR}/xenomai/include/native/task.h)
    MESSAGE("-- Looking for XENOMAI - found in ${XENOMAI_INSTALL_DIR}/xenomai/include")
    SET( XENOMAI_INCLUDE_DIR "${XENOMAI_INSTALL_DIR}/xenomai/include" )
    SET( XENOMAI_INSTALL_DIR "${XENOMAI_INSTALL_DIR}/xenomai")
  ENDIF(EXISTS ${XENOMAI_INSTALL_DIR}/xenomai/include/native/task.h)
  # the recommended CMake method
  IF (NOT XENOMAI_INCLUDE_DIR)
	# use different variable than XENOMAI_INCLUDE_DIR, as the first SET in the
	# block above resets things and breaks the CMake cache when you rerun
	# cmake/ccmake.
	FIND_PATH(XENOMAI_INCLUDE_PATH native/task.h)
    FIND_LIBRARY(XENOMAI_INSTALL_LIB native)
#	MESSAGE(STATUS "Xenomai: include ${XENOMAI_INCLUDE_DIR}")
#	MESSAGE(STATUS "Xenomai: library ${XENOMAI_INSTALL_LIB}")
	IF ( XENOMAI_INCLUDE_PATH AND XENOMAI_INSTALL_LIB )
	  SET(XENOMAI_INCLUDE_DIR ${XENOMAI_INCLUDE_PATH})
	  # presume XENOMAI_INSTALL_LIB is of form /path/to/lib/libnative.so, and
	  # so need to strip back to /path/to
	  GET_FILENAME_COMPONENT(XENOMAI_INSTALL_LIB2 ${XENOMAI_INSTALL_LIB} PATH)
	  GET_FILENAME_COMPONENT(XENOMAI_INSTALL_DIR ${XENOMAI_INSTALL_LIB2} PATH)
      MESSAGE("-- Looking for XENOMAI - found in ${XENOMAI_INSTALL_DIR}")
	ENDIF ( XENOMAI_INCLUDE_PATH AND XENOMAI_INSTALL_LIB )
  ENDIF (NOT XENOMAI_INCLUDE_DIR)

  IF ( XENOMAI_INCLUDE_DIR )
    SET(XENOMAI_SUPPORT TRUE CACHE INTERNAL "" FORCE)
    INCLUDE_DIRECTORIES( ${XENOMAI_INCLUDE_DIR} )
    SET(RTT_CFLAGS "${RTT_CFLAGS} -I${XENOMAI_INCLUDE_DIR}" CACHE INTERNAL "")
    SET(RTT_USER_LINKFLAGS "${RTT_LINKFLAGS} -L${XENOMAI_INSTALL_DIR}/lib -lnative -lpthread" CACHE INTERNAL "")
    LINK_LIBRARIES(native pthread dl)
    LINK_DIRECTORIES(${XENOMAI_INSTALL_DIR}/lib)
  ELSE( XENOMAI_INCLUDE_DIR )
    MESSAGE(FATAL_ERROR "-- Looking for XENOMAI - not found (tried: ${XENOMAI_INSTALL_DIR}/include/native/task.h, ${XENOMAI_INSTALL_DIR}/include/xenomai/native/task.h and CMAKE_INCLUDE_PATH environment variable)")
    SET(XENOMAI_SUPPORT FALSE CACHE INTERNAL "" FORCE)
  ENDIF( XENOMAI_INCLUDE_DIR )
ELSE(OROCOS_TARGET STREQUAL "xenomai")
  SET(XENOMAI_INSTALL_DIR "/usr/realtime" CACHE INTERNAL "path to xenomai installation dir")
  SET(OROPKG_OS_XENOMAI FALSE CACHE INTERNAL "" FORCE)
ENDIF(OROCOS_TARGET STREQUAL "xenomai")


IF(OROCOS_TARGET STREQUAL "gnulinux")
  SET(OROPKG_OS_GNULINUX TRUE CACHE INTERNAL "" FORCE)
  SET(RTT_LINKFLAGS "${RTT_LINKFLAGS} -lrt" CACHE INTERNAL "")
  SET(RTT_USER_LINKFLAGS "${RTT_USER_LINKFLAGS} -lpthread" CACHE INTERNAL "")
  LINK_LIBRARIES(pthread dl rt)
ELSE(OROCOS_TARGET STREQUAL "gnulinux")
  SET(OROPKG_OS_GNULINUX FALSE CACHE INTERNAL "" FORCE)
ENDIF(OROCOS_TARGET STREQUAL "gnulinux")

IF(OROCOS_TARGET STREQUAL "macosx")
  SET(OROPKG_OS_MACOSX TRUE CACHE INTERNAL "" FORCE)
  SET(RTT_USER_LINKFLAGS "${RTT_USER_LINKFLAGS} -lpthread" CACHE INTERNAL "")
  LINK_LIBRARIES(pthread dl)
ELSE(OROCOS_TARGET STREQUAL "macosx")
  SET(OROPKG_OS_MACOSX FALSE CACHE INTERNAL "" FORCE)
ENDIF(OROCOS_TARGET STREQUAL "macosx")


IF(OROCOS_TARGET STREQUAL "ecos")

  # Look for Ecos
  SET(ECOS_INSTALL_DIR ${ECOS_INSTALL_DIR} CACHE PATH "path to ecos installation dir" FORCE)
  IF (ECOS_INSTALL_DIR STREQUAL "")
    SET(ECOS_INSTALL_DIR "/opt/ecos/install")
  ENDIF (ECOS_INSTALL_DIR STREQUAL "")
  SET(OROPKG_OS_ECOS TRUE CACHE INTERNAL "" FORCE)
  IF(EXISTS ${ECOS_INSTALL_DIR}/include/pkgconf/system.h)
    MESSAGE("-- Looking for ECOS - found in ${ECOS_INSTALL_DIR}")
    SET(ECOS_SUPPORT TRUE CACHE INTERNAL "" FORCE)
    INCLUDE_DIRECTORIES(${ECOS_INSTALL_DIR}/include)
    SET(RTT_CFLAGS "${RTT_CFLAGS} -I${ECOS_INSTALL_DIR}/include" CACHE INTERNAL "")
    SET(RTT_LINKFLAGS "${RTT_LINKFLAGS} -L${ECOS_INSTALL_DIR}/lib -ltarget" CACHE INTERNAL "")
    LINK_LIBRARIES( target )
    LINK_DIRECTORIES(${ECOS_INSTALL_DIR}/lib)
  ELSE(EXISTS ${ECOS_INSTALL_DIR}/include/pkgconf/system.h)
    MESSAGE(FATAL_ERROR "-- Looking for ECOS - not found (tried: ${ECOS_INSTALL_DIR}/include/pkgconf/system.h)")
    SET(ECOS_SUPPORT FALSE CACHE INTERNAL "" FORCE)
  ENDIF(EXISTS ${ECOS_INSTALL_DIR}/include/pkgconf/system.h)

  MESSAGE( "Turning BUILD_STATIC ON for ecos.")
  SET( FORCE_BUILD_STATIC ON CACHE INTERNAL "" FORCE)
  SET( BUILD_STATIC ON CACHE BOOL "Build Orocos RTT as a static library" FORCE)

ELSE(OROCOS_TARGET STREQUAL "ecos")
  SET(OROPKG_OS_ECOS FALSE CACHE INTERNAL "" FORCE)
  SET(ECOS_INSTALL_DIR "/opt/ecos/install" CACHE INTERNAL "path to ecos installation dir")
ENDIF(OROCOS_TARGET STREQUAL "ecos")


# The machine type is tested using compiler macros in rtt-config.h.in
