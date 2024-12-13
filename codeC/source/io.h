
#ifndef IO_H
#define IO_H

#include "avl.h"

// Prototypes des fonctions d'entrée/sortie
AVLNode* charger_fichier_csv(char* chemin_fichier);
int exporter_avl_csv(AVLNode* root, const char* chemin_fichier);
void parcours_infixe(AVLNode* node, FILE* fichier);
#endif