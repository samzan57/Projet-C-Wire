
# Variables
CC = gcc
CFLAGS = -Wall -Werror -g
SOURCES = source/main.c source/io.c source/avl.c source/station.c
OBJECTS = $(SOURCES:.c=.o)
TARGET = c-wire # Name of the executable(generated in the current directory)

# Rules
all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $(OBJECTS)

objs/%.o: source/%.c
	mkdir -p objs
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	@echo "Cleaning up..."
	rm -rf objs/*.o c-wire # Ensures the executable is removed here

.PHONY: all clean