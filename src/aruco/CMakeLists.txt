SET (LIBNAME ${EXTRALIBNAME}aruco)
set(sources
    cameraparameters.cpp
    cvdrawingutils.cpp
    dictionary.cpp
    ippe.cpp
    marker.cpp
    markerdetector.cpp
    markerlabeler.cpp
    markermap.cpp
    posetracker.cpp
    markerlabelers/dictionary_based.cpp
    debug.cpp
    markerlabelers/svmmarkers.cpp
)

set(headers
    aruco_export.h
    cameraparameters.h
    cvdrawingutils.h
    dictionary.h
    ippe.h
    marker.h
    markerdetector.h
    markerlabeler.h
    markermap.h
    posetracker.h
    markerlabelers/dictionary_based.h
    timers.h
     debug.h
     aruco.h
    markerlabelers/svmmarkers.h
)

add_library(${LIBNAME} ${sources} ${headers})
 
set_target_properties(${LIBNAME} PROPERTIES          # create *nix style library versions + symbolic links
    DEFINE_SYMBOL ARUCO_DSO_EXPORTS
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_SOVERSION}
    CLEAN_DIRECT_OUTPUT 1                       # allow creating static and shared libs without conflicts
    OUTPUT_NAME "${LIBNAME}${PROJECT_DLLVERSION}"    # avoid conflicts between library and binary target names
)

target_link_libraries(${LIBNAME} PUBLIC opencv_core)
target_link_libraries(${LIBNAME} PRIVATE opencv_imgproc opencv_calib3d opencv_features2d opencv_ml)

INSTALL(TARGETS ${LIBNAME}
    RUNTIME DESTINATION bin COMPONENT main			# Install the dll file in bin directory
    LIBRARY DESTINATION lib PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE COMPONENT main
    ARCHIVE DESTINATION lib COMPONENT main)			# Install the dll.a file in lib directory

IF(ARUCO_DEVINSTALL)
  install(FILES ${headers} DESTINATION include/aruco)
ENDIF()
 
