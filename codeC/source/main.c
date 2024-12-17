#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "avl.h"
#include "io.h"

int main(int argc, char* argv[]) {
    if (argc != 4) {
        fprintf (stderr, "Usage : %s <fichier_entrée> <fichier_sortie> <header>\n", argv[0]);
        return EXIT_FAILURE;
    }

    char* input_file = argv[1];
    char* output_file = argv[2];
    char* header = argv[3];

    // Charger les données du fichier CSV dans l'arbre AVL
    AVLNode* root = charger_fichier_csv(input_file);
    if (!root) {
        fprintf (stderr, "Erreur lors du chargement des données depuis %s\n", input_file);
        return EXIT_FAILURE;
    }

    // Ouvrir le fichier de sortie
    FILE* output = fopen(output_file, "w");
    if (!output) {
        perror("Erreur lors de l'ouverture du fichier de sortie");
        free_avl(root);
        return EXIT_FAILURE;
    }

    fprintf(output, "%s\n", header);

    // Écrire les résultats dans le fichier de sortie
    parcours_infixe(root, output);

    fclose(output);
    free_avl(root);

    printf("Traitement terminé. Résultats écrits dans : %s\n", output_file);
    return EXIT_SUCCESS;
}