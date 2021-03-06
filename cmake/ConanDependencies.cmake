conan_basic_setup()
set(CMAKE_SKIP_RPATH 0)

# set up apple frameworks
if(APPLE)
  find_library(COREFOUNDATION_LIBRARY CoreFoundation )
  find_library(COCOA_LIBRARY Cocoa)
  find_library(CARBON NAMES Carbon)
  find_library(IOKIT NAMES IOKit)
  find_library(OpenGL_LIBRARY OpenGL)
  find_library(OPENGL_glu_LIBRARY AGL DOC "AGL lib for OSX")
  find_package(GLEW REQUIRED)
endif(APPLE)

# core libraries
set(LUAJIT_LIBRARIES ${CONAN_LIBS_LUAJIT-ROCKS})
set(MSGPACK_LIBRARIES ${CONAN_LIBS_MSGPACK})

# optional stuff

# setting up ogre libraries and all it's dependencies
if(CONAN_LIBS_OGRE)
  set(OGRE_LIBRARIES
    ${CONAN_LIBS_OGRE}
    ${CONAN_LIBS_BOOST}
    ${CONAN_LIBS_FREETYPE}
    ${CONAN_LIBS_ZZIPLIB}
    ${CONAN_LIBS_ZLIB}
    ${CONAN_LIBS_LIBPNG}
    ${CONAN_LIBS_FREEIMAGE}
    ${CONAN_LIBS_BZIP2}
  )
  set(OGRE_FOUND true)
endif(CONAN_LIBS_OGRE)

# for static build
if(CONAN_USER_OGRE_STATIC)
  add_definitions("-D OGRE_STATIC")

  # adding plugins includes
  set(OGRE_INCLUDE_DIRS
    ${CONAN_INCLUDE_DIRS_OGRE}/Plugins/OctreeSceneManager
    ${CONAN_INCLUDE_DIRS_OGRE}/Plugins/BSPSceneManager
    ${CONAN_INCLUDE_DIRS_OGRE}/Plugins/PCZSceneManager
    ${CONAN_INCLUDE_DIRS_OGRE}/Plugins/ParticleFX
    ${CONAN_INCLUDE_DIRS_OGRE}/Overlay/
    ${GLEW_INCLUDE_DIRS}
    ${OGRE_INCLUDE_DIRS}
  )
endif(CONAN_USER_OGRE_STATIC)

# OIS
if(CONAN_LIBS_OIS)
  set(OIS_INCLUDE_DIRS ${CONAN_INCLUDE_DIRS_OIS}/OIS)
  set(OIS_LIBRARIES ${CONAN_LIBS_OIS})
  set(OIS_FOUND true)
endif(CONAN_LIBS_OIS)

# LibRocket
if(CONAN_LIBS_LIBROCKET)
  set(LIBROCKET_INCLUDE_DIRS ${CONAN_INCLUDE_DIRS_LIBROCKET})
  set(LIBROCKET_LIBRARIES ${CONAN_LIBS_LIBROCKET})
  set(LIBROCKET_FOUND true)
endif(CONAN_LIBS_LIBROCKET)
