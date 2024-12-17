#ifndef AVL_H
#define AVL_H

typedef struct AVLNode {
    char id_station[50];  // Identifiant de la station
    int total_capacity;   // Somme des capacités
    int total_load;       // Somme des charges
    int height;           // Hauteur du nœud
    int balance;        // facteur d'équilibre d'un noeud
    struct AVLNode* left;
    struct AVLNode* right;
} AVLNode;

// Fonctions AVL
AVLNode* create_node(char* id_station, int capacity, int load);
int height(AVLNode* node);
int balance_factor(AVLNode* node);
AVLNode* rotate_right(AVLNode* a);
AVLNode* rotate_left(AVLNode* a);
AVLNode* insert_avl(AVLNode* root,char* id_station, int capacity, int load);
void inorder_traversal(AVLNode* root, void(*action)(AVLNode*,void*), void* context);
void free_avl(AVLNode* root);

#endif
