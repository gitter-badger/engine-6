set(LIB_NAME "RocketUI")

include_directories(
    ${LIBROCKET_INCLUDE_DIRS}
)

set(LIBROCKET_LIBS ${LIBROCKET_LIBRARIES})
if(UNIX AND NOT APPLE)
  set(LIBROCKET_LIBS -Wl,--whole-archive ${LIBROCKET_LIBRARIES} -Wl,--no-whole-archive)
endif(UNIX AND NOT APPLE)

set(LIBS GsageCore ${LIBROCKET_LIBS})

file(GLOB sources src/*.cpp)

if(APPLE)
  set(LIBS ${LIBS}
    ${COREFOUNDATION_LIBRARY})
endif(APPLE)

if(OGRE_FOUND)
  include_directories(${OGRE_INCLUDE_DIRS}
          ${gsage_SOURCE_DIR}/PlugIns/OgrePlugin/include)

  set(LIBS ${LIBS}
      OgrePlugin
      ${OGRE_LIBRARIES}
      ${OGRE_Overlay_LIBRARIES})

  file(GLOB ogre_related_sources src/ogre/*.cpp)
  set(sources ${ogre_related_sources} ${sources})
  add_definitions(-DOGRE_INTERFACE)
endif(OGRE_FOUND)

gsage_plugin(${LIB_NAME} SHARED ${sources})
target_link_libraries(${LIB_NAME} ${LIBS})
