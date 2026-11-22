cmake_minimum_required(VERSION 3.18)
project(lpairs2 LANGUAGES C CXX)

# SDL sources are fetched by ../../../../setup_sdl.sh into third_party/
set(TP "${CMAKE_CURRENT_LIST_DIR}/../../../../third_party")
foreach(lib SDL2 SDL2_image SDL2_ttf SDL2_mixer)
  if(NOT EXISTS "${TP}/${lib}/CMakeLists.txt")
    message(FATAL_ERROR "${lib} sources missing in ${TP}/${lib}. Run ./setup_sdl.sh first.")
  endif()
endforeach()

# ---- SDL2 -----------------------------------------------------------------
set(BUILD_SHARED_LIBS ON CACHE BOOL "" FORCE)
set(SDL_SHARED ON  CACHE BOOL "" FORCE)
set(SDL_STATIC OFF CACHE BOOL "" FORCE)
set(SDL_TEST   OFF CACHE BOOL "" FORCE)
add_subdirectory("${TP}/SDL2" SDL2)

# ---- SDL2_image: PNG + JPG only (bundled stb_image backend) ---------------
set(SDL2IMAGE_INSTALL     OFF CACHE BOOL "" FORCE)
set(SDL2IMAGE_SAMPLES     OFF CACHE BOOL "" FORCE)
set(SDL2IMAGE_DEPS_SHARED OFF CACHE BOOL "" FORCE)
set(SDL2IMAGE_VENDORED    ON  CACHE BOOL "" FORCE)
set(SDL2IMAGE_BACKEND_STB ON  CACHE BOOL "" FORCE)
set(SDL2IMAGE_AVIF OFF CACHE BOOL "" FORCE)
set(SDL2IMAGE_JXL  OFF CACHE BOOL "" FORCE)
set(SDL2IMAGE_TIF  OFF CACHE BOOL "" FORCE)
set(SDL2IMAGE_WEBP OFF CACHE BOOL "" FORCE)
add_subdirectory("${TP}/SDL2_image" SDL2_image)

# ---- SDL2_ttf: FreeType only, no HarfBuzz ---------------------------------
set(SDL2TTF_INSTALL  OFF CACHE BOOL "" FORCE)
set(SDL2TTF_SAMPLES  OFF CACHE BOOL "" FORCE)
set(SDL2TTF_VENDORED ON  CACHE BOOL "" FORCE)
set(SDL2TTF_HARFBUZZ OFF CACHE BOOL "" FORCE)
add_subdirectory("${TP}/SDL2_ttf" SDL2_ttf)

# ---- SDL2_mixer: the game only plays WAV ----------------------------------
set(SDL2MIXER_INSTALL     OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_SAMPLES     OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_DEPS_SHARED OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_VENDORED    ON  CACHE BOOL "" FORCE)
set(SDL2MIXER_WAVE ON  CACHE BOOL "" FORCE)
set(SDL2MIXER_FLAC OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_MOD  OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_MP3  OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_MIDI OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_OPUS OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_GME  OFF CACHE BOOL "" FORCE)
add_subdirectory("${TP}/SDL2_mixer" SDL2_mixer)

# ---- the game (SDLActivity loads it as libmain.so) ------------------------
file(GLOB LPAIRS_SRC CONFIGURE_DEPENDS "${CMAKE_CURRENT_LIST_DIR}/lpairs2/*.cpp")
add_library(main SHARED ${LPAIRS_SRC})
target_compile_features(main PRIVATE cxx_std_14)
target_compile_definitions(main PRIVATE HAVE_CONFIG_H)
target_compile_options(main PRIVATE -Wall)
target_include_directories(main PRIVATE "${CMAKE_CURRENT_LIST_DIR}/lpairs2")
target_link_libraries(main PRIVATE
  SDL2::SDL2 SDL2_image::SDL2_image SDL2_ttf::SDL2_ttf SDL2_mixer::SDL2_mixer
  log)
