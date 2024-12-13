
# Variables
CC = gcc
CFLAGS = -Wall -Werror -g
SOURCES = source/main.c source/io.c source/avl.c source/station.c
OBJECTS = $(SOURCES:.c=.o)
TARGET = c-wire # Nom de l'exécutable (généré dans le dossier courant)

# Règles
all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $(OBJECTS)

objs/%.o: source/%.c
	mkdir -p objs
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	@echo "Cleaning up..."
	rm -rf objs/*.o c-wire # S'assure que l'exécutable est supprimé ici

.PHONY: all clean