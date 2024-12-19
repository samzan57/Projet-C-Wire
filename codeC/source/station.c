#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"

// Creation  of an station function
Station* creer_station(char* id_station, int capacity, int load) {
   //Allocate memory for a new stattion
    Station* station = (Station*)malloc(sizeof(Station));
    if (!station) {
        perror("Erreur d'allocation mémoire");
        return NULL;
    }

    strncpy(station->id_station, id_station, sizeof(station->id_station) - 1);
    station->id_station[sizeof(station->id_station) - 1] = '\0'; // Ensure the string is null-terminated
    // Initialisation
    station->capacity = capacity;
    station->load = load;
    return station;
}

// Function to display a station
void afficher_station(Station* station) {
    if (!station) return;
    printf("Station ID: %s, Capacity: %d, Load: %d\n", station->id_station, station->capacity, station->load);
}

// function to free a station
void liberer_station(Station* station) {
    if (!station) return;
    free(station);
}