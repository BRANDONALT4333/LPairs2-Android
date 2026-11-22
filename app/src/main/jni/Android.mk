LOCAL_PATH := $(call my-dir)
ROOT_PATH := $(LOCAL_PATH)/../../../..

SDL2_PATH := $(ROOT_PATH)/third_party/SDL2
SDL2_IMAGE_PATH := $(ROOT_PATH)/third_party/SDL2_image
SDL2_TTF_PATH := $(ROOT_PATH)/third_party/SDL2_ttf
SDL2_MIXER_PATH := $(ROOT_PATH)/third_party/SDL2_mixer

# This game only needs JPEG/PNG images and WAV audio.
SUPPORT_WEBP := false
SUPPORT_FLAC := false
SUPPORT_OGG := false
SUPPORT_MP3_MPG123 := false
SUPPORT_MOD_MODPLUG := false
SUPPORT_TIMIDITY := false

include $(SDL2_PATH)/Android.mk
include $(SDL2_IMAGE_PATH)/Android.mk
include $(SDL2_TTF_PATH)/Android.mk
include $(SDL2_MIXER_PATH)/Android.mk

include $(CLEAR_VARS)
LOCAL_MODULE := main
LOCAL_SRC_FILES := $(patsubst $(LOCAL_PATH)/%,%, $(wildcard $(ROOT_PATH)/app/src/main/cpp/lpairs2/*.cpp))
LOCAL_C_INCLUDES := \
    $(ROOT_PATH)/app/src/main/cpp/lpairs2 \
    $(SDL2_PATH)/include \
    $(SDL2_IMAGE_PATH) \
    $(SDL2_TTF_PATH) \
    $(SDL2_MIXER_PATH)
LOCAL_CPPFLAGS += -std=c++14 -D__ANDROID__ -DHAVE_CONFIG_H
LOCAL_SHARED_LIBRARIES := SDL2 SDL2_image SDL2_ttf SDL2_mixer
LOCAL_LDLIBS := -llog -landroid -lGLESv1_CM -lGLESv2
include $(BUILD_SHARED_LIBRARY)
