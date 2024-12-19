#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"

// Création of an AVL node
AVLNode* create_node(char* id_station, int capacity, int load) {
    // Allocate memory for a new node
    AVLNode* node = (AVLNode*)malloc(sizeof(AVLNode));
    if (!node) {
        perror("Erreur d'allocation mémoire");
        exit(EXIT_FAILURE);
    }
    strncpy(node->id_station, id_station, sizeof(node->id_station) - 1);
    node->id_station[sizeof(node->id_station) - 1] = '\0'; // Ensure the string is null-terminated
    // Initialize node data
    node->total_capacity = capacity;
    node->total_load = load;
    node->height = 1;
    // Initialize  child pointers to NULL (no subtree initially)
    node->left = NULL;
    node->right = NULL;
    return node;
}

// Height of a node
int height(AVLNode* node) {
    return node ? node->height : 0;
}

// Balance factor
int balance_factor(AVLNode* node) {
    return height(node->left) - height(node->right);
}

//  Right Rotation 
AVLNode* rotate_right(AVLNode* a) {
    AVLNode* pivot = a->left;
    AVLNode* temp = pivot->right;

    pivot->right = a;
    a->left = temp;

    // Update heights
    a->height = 1 + (height(a->left) > height(a->right) ? height(a->left) : height(a->right));
    pivot->height = 1 + (height(pivot->left) > height(pivot->right) ? height(pivot->left) : height(pivot->right));

    return pivot; // New root
}

//  Left Rotation 
AVLNode* rotate_left(AVLNode* a) {
    AVLNode* pivot = a->right;
    AVLNode* temp = pivot->left;

    pivot->left = a;
    a->right = temp;

    // Update heights
    a->height = 1 + (height(a->left) > height(a->right) ? height(a->left) : height(a->right));
    pivot->height = 1 + (height(pivot->left) > height(pivot->right) ? height(pivot->left) : height(pivot->right));

    return pivot; // New root
}


// Insertion into the AVL tree
AVLNode* insert_avl(AVLNode* root, char* id_station, int capacity, int load) {
    if (!root) return create_node(id_station, capacity, load);

    // Convert id_station to integers for comparison
    int id1 = atoi(id_station); // Convert the current identifier
    int id2 = atoi(root->id_station); //  Convert the node identifier
    
    if (id1 < id2) {
        root->left = insert_avl(root->left, id_station, capacity, load);
    } else if (id1 > id2) {
        root->right = insert_avl(root->right, id_station, capacity, load);
    } else {
        // Update sums for an existing id_station
        root->total_capacity += capacity;
        root->total_load += load;
        return root;
    }

    // Calculate the height
    root->height = 1 + (height(root->left) > height(root->right) ? height(root->left) : height(root->right));

    //  Rebalance if necessary
    int balance = balance_factor(root);

     // Right Rotation 
    if (balance > 1 && atoi(id_station) < atoi(root->left->id_station)) {
        return rotate_right(root);
    }
    // Left Rotation 
    if (balance < -1 && atoi(id_station) > atoi(root->right->id_station)) {
        return rotate_left(root);
    }
    // Double left-right  rotation 
    if (balance > 1 && atoi(id_station) > atoi(root->left->id_station)) {
        root->left = rotate_left(root->left);
        return rotate_right(root);
    }
    // Double  right-left rotation 
    if (balance < -1 && atoi(id_station) < atoi(root->right->id_station)) {
        root->right = rotate_right(root->right);
        return rotate_left(root);
    }

    return root;
}

// in-order traversal function (sorted)
void inorder_traversal(AVLNode* root) {
    if (root != NULL) {
        inorder_traversal(root->left);    // Traverse the left subtree
        printf("Station: %s, Capacity: %d, Load: %d\n",
               root->id_station, root->total_capacity, root->total_load); // Process the node
        inorder_traversal(root->right);   // Traverse the right subtree
    }
}

// Free the AVL tree
void free_avl(AVLNode* root) {
    if (!root) return;
    free_avl(root->left);
    free_avl(root->right);
    free(root);
}