DEBUG ?= 0
STATIC_SDL2_IMAGE ?= 0
TARGET ?= controllermap
PREFIX ?= /usr
FB ?= /dev/fb0
OPTIMIZATION ?= -O2
CFLAGS ?= -g $(OPTIMIZATION) -fdata-sections -ffunction-sections -Wl,-rpath,$(PREFIX)/lib -Wl,--enable-new-dtags

CC = $(CROSS_COMPILE)gcc
CFLAGS += $(shell sdl2-config --libs --cflags)

SOURCES = $(wildcard *.c)
OBJECTS = $(SOURCES:.c=.o)

PNG = $(wildcard *.png)
PNG_H = $(PNG:.png=.png.h)

ifeq ($(STATIC_SDL2_IMAGE), 1)
	CFLAGS += -l:libSDL2_image.a
else
	CFLAGS += -lSDL2_image
endif

ifeq ($(DEBUG), 1)
	CFLAGS += -DDEBUG_CONTROLLERMAP
endif

ifneq ($(FB),)
	CFLAGS += -DFRAMEBUFFER_DEVICE=$(FB)
endif

all: $(TARGET)

$(TARGET): $(PNG_H) $(OBJECTS)
	$(CC) -o $(TARGET) $(OBJECTS) $(CFLAGS) -Wl,--gc-sections
	$(CROSS_COMPILE)strip "$@"

ifneq ($(UPX),)
	upx $(UPX) "$@"
endif

	touch "$@"
	ls -lah "$@"

$(TARGET).o: $(PNG_H)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@ && touch "$@"

%.png.h: %.png
	xxd -i "$<" "$@" && touch "$@"

clean:
	$(RM) $(PNG_H) $(OBJECTS) $(TARGET)

.PHONY: all clean
