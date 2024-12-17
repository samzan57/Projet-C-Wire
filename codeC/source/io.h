
#ifndef IO_H
#define IO_H

#include "avl.h"

// Prototypes of the input/output functions
AVLNode* charger_fichier_csv(char* chemin_fichier);
int exporter_avl_csv(AVLNode* root, char* chemin_fichier, char* header);
void parcours_infixe(AVLNode* node, FILE* fichier);
#endif