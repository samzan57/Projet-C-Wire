#ifndef GLOBAL_H
#define GLOBAL_H

// Déclaration des structures
typedef struct {
    char id_station[50]; // Station Identifier
    int capacity;        // Capacity
    int load;            // Load
} Station;

typedef struct AVLNode {
    char id_station[50];  // Station Identifier
    int total_capacity;   // Sum of Capacities
    int total_load;       // Sum of Loads
    int height;           // Sum of Loads
    int balance;        // balance factor
    struct AVLNode* left;
    struct AVLNode* right;
} AVLNode;

// Prototype of Different Functions
// Station Functions
Station* creer_station(char* id_station, int capacity, int load);
void afficher_station(Station* station);
void liberer_station(Station* station);

// AVL Functions
AVLNode* create_node(char* id_station, int capacity, int load);
int height(AVLNode* node);
int balance_factor(AVLNode* node);
AVLNode* rotate_right(AVLNode* a);
AVLNode* rotate_left(AVLNode* a);
AVLNode* insert_avl(AVLNode* root,char* id_station, int capacity, int load);
void inorder_traversal(AVLNode* root);
void free_avl(AVLNode* root);

// IO Functions
AVLNode* charger_fichier_csv(char* chemin_fichier);
void parcours_infixe(AVLNode* node, FILE* fichier);
int exporter_avl_csv(AVLNode* root, char* chemin_fichier);

#endif // GLOBAL_H