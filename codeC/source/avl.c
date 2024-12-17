#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "avl.h"

// Création d'un nœud AVL
AVLNode* create_node(char* id_station, int capacity, int load) {
    AVLNode* node = (AVLNode*)malloc(sizeof(AVLNode));
    if (!node) {
        perror("Erreur d'allocation mémoire");
        exit(EXIT_FAILURE);
    }
    strncpy(node->id_station, id_station, sizeof(node->id_station) - 1);
    node->id_station[sizeof(node->id_station) - 1] = '\0'; // S'assurer que la chaîne est terminée
    node->total_capacity = capacity;
    node->total_load = load;
    node->height = 1;
    node->left = node->right = NULL;
    return node;
}

// Hauteur d'un nœud
int height(AVLNode* node) {
    return node ? node->height : 0;
}

// Facteur d'équilibre
int balance_factor(AVLNode* node) {
    return height(node->left) - height(node->right);
}

// Rotation droite
AVLNode* rotate_right(AVLNode* a) {
    AVLNode* pivot = a->left;
    AVLNode* temp = pivot->right;

    pivot->right = a;
    a->left = temp;

    // Mise à jour des hauteurs
    a->height = 1 + (height(a->left) > height(a->right) ? height(a->left) : height(a->right));
    pivot->height = 1 + (height(pivot->left) > height(pivot->right) ? height(pivot->left) : height(pivot->right));

    return pivot; // Nouveau root
}

// Rotation gauche
AVLNode* rotate_left(AVLNode* a) {
    AVLNode* pivot = a->right;
    AVLNode* temp = pivot->left;

    pivot->left = a;
    a->right = temp;

    // Mise à jour des hauteurs
    a->height = 1 + (height(a->left) > height(a->right) ? height(a->left) : height(a->right));
    pivot->height = 1 + (height(pivot->left) > height(pivot->right) ? height(pivot->left) : height(pivot->right));

    return pivot; // Nouveau root
}


// Insertion dans l'arbre AVL
AVLNode* insert_avl(AVLNode* root, char* id_station, int capacity, int load) {
    if (!root) return create_node(id_station, capacity, load);

    // Conversion des `id_station` en entiers pour la comparaison
    int id1 = atoi(id_station); // Convertir l'identifiant courant
    int id2 = atoi(root->id_station); // Convertir l'identifiant du nœud

    if (id1 < id2) {
        root->left = insert_avl(root->left, id_station, capacity, load);
    } else if (id1 > id2) {
        root->right = insert_avl(root->right, id_station, capacity, load);
    } else {
        // Mise à jour des sommes pour un `id_station` existant
        root->total_capacity += capacity;
        root->total_load += load;
        return root;
    }

    // Calculer la hauteur
    root->height = 1 + (height(root->left) > height(root->right) ? height(root->left) : height(root->right));

    // Rééquilibrage si nécessaire
    int balance = balance_factor(root);

    // Cas de rotation
    if (balance > 1 && atoi(id_station) < atoi(root->left->id_station)) {
        return rotate_right(root);
    }
    if (balance < -1 && atoi(id_station) > atoi(root->right->id_station)) {
        return rotate_left(root);
    }
    if (balance > 1 && atoi(id_station) > atoi(root->left->id_station)) {
        root->left = rotate_left(root->left);
        return rotate_right(root);
    }
    if (balance < -1 && atoi(id_station) < atoi(root->right->id_station)) {
        root->right = rotate_right(root->right);
        return rotate_left(root);
    }

    return root;
}


// Parcours infixe (trié)
void inorder_traversal(AVLNode* root, void (*action)(AVLNode*, void*), void* context) {
    if (root) {
        inorder_traversal(root->left, action, context);
        action(root, context);
        inorder_traversal(root->right, action, context);
    }
}

// Libération de l'arbre AVL
void free_avl(AVLNode* root) {
    if (!root) return;
    free_avl(root->left);
    free_avl(root->right);
    free(root);
}