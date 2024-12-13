#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "station.h"

// Fonction pour créer une station
Station* creer_station(char* id_station, int capacity, int load) {
    Station* station = (Station*)malloc(sizeof(Station));
    if (!station) {
        perror("Erreur d'allocation mémoire");
        return NULL;
    }

    strncpy(station->id_station, id_station, sizeof(station->id_station) - 1);
    station->id_station[sizeof(station->id_station) - 1] = '\0';
    station->capacity = capacity;
    station->load = load;
    return station;
}

// Fonction pour afficher une station
void afficher_station(Station* station) {
    if (!station) return;
    printf("Station ID: %s, Capacity: %d, Load: %d\n", station->id_station, station->capacity, station->load);
}

// Fonction pour libérer une station
void liberer_station(Station* station) {
    if (!station) return;
    free(station);
}
