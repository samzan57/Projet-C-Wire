
# Variables
CC = gcc
CFLAGS = -Wall -Werror -g
SOURCES = source/main.c source/io.c source/avl.c source/station.c
OBJECTS = $(SOURCES:.c=.o)
TARGET = c-wire # Name of the executable(generated in the current directory)
GLOBAL.H = source/global.h
# Rules
all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $(OBJECTS)

%.o: %.c $(GLOBAL_H)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	@echo "Cleaning up..."
	rm -f $(OBJECTS) $(TARGET)

.PHONY: all clean