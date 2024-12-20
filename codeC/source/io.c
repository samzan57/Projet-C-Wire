#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"

// Maximum size of a line in the file
#define MAX_LINE 1024

// Function to load data from the CSV file
AVLNode* charger_fichier_csv(char* chemin_fichier) {
    FILE* fichier = fopen(chemin_fichier, "r");
    if (!fichier) {
        perror ("Erreur lors de l'ouverture du fichier");
        return NULL;
    }

    char ligne[MAX_LINE];
    AVLNode* root = NULL;

    int ligne_num = 0;
    // Read each line of the file
    while (fgets(ligne, MAX_LINE, fichier)) {
        ligne_num++;

        // Ignore the header
        if (ligne_num == 1 && strstr(ligne, "id_station;capacity;load") != NULL) {
            continue;
        }

        char* id_station = strtok(ligne, ";");
        char* capacity_str = strtok(NULL, ";");
        char* load_str = strtok(NULL, "\n");

        if (!id_station || !capacity_str || !load_str) {
            fprintf(stderr, "Ligne mal formatée (ligne %d) ignorée : %s\n", ligne_num, ligne);
            continue;
        }

        // Secure conversion of strings to integers
        int capacity = atoi(capacity_str);
        int load = atoi(load_str);
       
        // Insert into the AVL tree
        root = insert_avl(root, id_station, capacity, load);
    }

    fclose(fichier);
    return root;
}

// In-order traversal to write data to a file
void parcours_infixe(AVLNode* node, FILE* fichier) {
    if (!node) return;

    parcours_infixe(node->left, fichier);
    fprintf(fichier, "%s:%d:%d\n", node->id_station, node->total_capacity, node->total_load);
    parcours_infixe(node->right, fichier);
}

// Function to export the AVL tree to a CSV file
int exporter_avl_csv(AVLNode* root, char* chemin_fichier) {
    FILE* fichier = fopen(chemin_fichier, "w");
    if (!fichier) {
        perror("Erreur lors de la création du fichier de sortie");
        return 0;
    }

    fprintf(fichier, "id_station:capacity:load\n");
    parcours_infixe(root, fichier);
    fclose(fichier);

    printf("Exportation réussie dans le fichier : %s\n", chemin_fichier);
    return 1;
}