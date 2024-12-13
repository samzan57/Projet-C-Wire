
#ifndef STATION_H
#define STATION_H

typedef struct {
    char id_station[50];
    int capacity;
    int load;
} Station;

Station* creer_station(char* id_station, int capacity, int load);
void afficher_station(Station* station);
void liberer_station(Station* station);

#endif
