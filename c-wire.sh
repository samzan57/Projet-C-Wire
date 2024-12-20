#!/bin/bash

# Recherche automatique du fichier d'entrée dans le dossier input/
file_path=$(ls input/*.dat 2>/dev/null | head -n 1)

if [ -z "$file_path" ]; then
  echo "Erreur : Aucun fichier d'entrée trouvé dans le dossier 'input/'."
  exit 1
fi
# Initialisation des variables pour les stations et les consommateurs
station_type="$1"
consumer_type="$2"

# Vérification des options interdites
if [[ "$station_type" == "hva" && "$consumer_type" == "all" ]] ||
   [[ "$station_type" == "hva" && "$consumer_type" == "indiv" ]] ||
   [[ "$station_type" == "hvb" && "$consumer_type" == "all" ]] ||
   [[ "$station_type" == "hvb" && "$consumer_type" == "indiv" ]]; then
  echo "Erreur : Les options $station_type $consumer_type sont interdites."
  afficher_aide
fi

# Initialisation des variables pour les centrales
central_id="$3"

# Vérification de l'option d'aide
if [[ "$1" == "-h" ]]; then
    start_time=$(date +%s.%N)  

    echo ""
    echo "Utilisation: ./c-wire.sh [type_station] [type_consommateur] [id_centrale (optionnel)]"
    echo ""
    echo "Options:"
    echo "    type_station           Type de station : hvb, hva, lv (obligatoire)"
    echo "    type_consommateur      Type de consommateur : comp, indiv, all (obligatoire)"
    echo "    id_centrale            Identifiant de la centrale (optionnel)"
    echo "    -h                     Affiche ce message d'aide"
    echo ""
    echo "Restrictions:"
    echo "    Les options suivantes sont interdites :"
    echo "        hvb all"
    echo "        hvb indiv"
    echo "        hva all"
    echo "        hva indiv"

    end_time=$(date +%s.%N)  # Fin du calcul de la durée
    elapsed_time=$(echo "$end_time - $start_time" | bc) 

    # Affichage de la durée en secondes
    echo "Durée totale d'affichage de l'aide : $elapsed_time secondes"
    exit 0
fi

# Initialisation de la variable start_time pour calculer le temps d'exécution
start_time=$(date +%s.%N)

# Gestion de sortie
exit_script() {
  end_time=$(date +%s.%N)
  elapsed_time=$(echo "$end_time - $start_time" | bc)

  if [ "$1" -ne 0 ]; then
    echo "Erreur rencontrée. Temps d'exécution: $elapsed_time seconds."
  else
    echo "temps écoulé: $elapsed_time secondes"
    echo "le fichier final est diponible dans: $aggregated_output_file"
  fi

  exit "$1"
}


# Vérification des arguments
if [ $# -lt 2 ]; then
  echo "DEBUG : Arguments insuffisants"
  echo "Erreur : Veuillez fournir au moins deux arguments (station et consommateur)."
  afficher_aide
fi

# Préparation des dossiers
graphs_path="graphs"
tmp_path="tmp"
tests_path="tests"

# Vider les dossiers tmp et graphs s'ils existent, sinon les créer
[ -d "$graphs_path" ] && rm -rf "$graphs_path"/* || mkdir -p "$graphs_path"
[ -d "$tmp_path" ] && rm -rf "$tmp_path"/* || mkdir -p "$tmp_path"

# Créer le dossier tests s'il n'existe pas
[ -d "$tests_path" ] || mkdir -p "$tests_path"

# Vérification de l'exécutable C
C_executable="codeC/c-wire"

if [ ! -f "$C_executable" ]; then
  echo "L'exécutable $C_executable est introuvable. Tentative de compilation..."
  
  # Vérification de la présence d'un Makefile
  if [ ! -f "codeC/Makefile" ]; then
    echo "Erreur : Makefile introuvable dans le répertoire 'codeC'."
    exit 1
  fi

  # Compilation
  (cd codeC && make)
  if [ $? -ne 0 ]; then
    echo "Erreur : La compilation a échoué."
    exit 1
  fi

  echo "Compilation réussie."
fi

# Filtrage des colonnes en fonction de la station
output_file="$tmp_path/output.csv"

case "$station_type" in 
  hvb)
    echo "Exécution du tri selon la colonne Station HVB"
	echo "HVB Station;Company;Individual;Capacity;Load" > "$output_file"
    cut -d';' -f2,5,6,7,8 "$file_path" | tail -n +2 | tr '-' '0' | awk -F';' '$1 != 0' | sort -n -t';' -k1 >> "$output_file"
    echo "Le tri selon la colonne Station HVB a été exécuté"
    ;;
  hva)
    echo "Exécution du tri selon la colonne Station HVA"
	echo "HVA Station; Company;Individual;Capacity;Load" > "$output_file"
    cut -d';' -f3,5,6,7,8 "$file_path" | tail -n +2 | tr '-' '0' | awk -F';' '$1 != 0' | sort -n -t';' -k1 >> "$output_file"
    echo "Le tri selon la colonne Station HVA a été exécuté"
    ;;
  lv)
    echo "Exécution du tri selon la colonne Station LV"
    echo "LV Station;Company;Individual;Capacity;Load" > "$output_file"
    
    if [[ "$consumer_type" == "comp" ]]; then
        # Filtrer uniquement les lignes où Company est non nul
        tail -n +2 "$file_path" | awk -F';' '$5 > 0 && $4 != "-" {print $4 ";" $5 ";" $6 ";" $7 ";" $8}' >> "$output_file"
    elif [[ "$consumer_type" == "indiv" ]]; then
        # Filtrer uniquement les lignes où Individual est non nul
        tail -n +2 "$file_path" | awk -F';' '$6 > 0 && $4 != "-" {print $4 ";" $5 ";" $6 ";" $7 ";" $8}' >> "$output_file"
    else
        # Par défaut, inclure toutes les lignes
        tail -n +2 "$file_path" | awk -F';' '$4 != "-" {print $4 ";" $5 ";" $6 ";" $7 ";" $8}' >> "$output_file"
    fi
    echo "Le tri selon la colonne Station LV a été exécuté"
    ;;

esac

# Génération de l'entête personnalisé
case "$consumer_type" in
  comp)
    header_suffix="(comp)"
    ;;
  indiv)
    header_suffix="(indiv)"
    ;;
  all)
    header_suffix="(all)"
    ;;
esac
case "$station_type" in
  hvb)
    header_prefix="HVB Station"
    ;;
  hva)
    header_prefix="HVA Station"
    ;;
  lv)
    header_prefix="LV Station"
    ;;
esac
header="$header_prefix:total_capacity:total_load $header_suffix"
# Filtrage des colonnes en fonction de l'identifiant de centrale
if [ -n "$central_id" ]; then
  echo "Filtrage par identifiant de centrale : $central_id"
  grep "^$central_id;" "$output_file" > "$tmp_path/filtered_by_central.csv"
  mv "$tmp_path/filtered_by_central.csv" "$output_file"
fi

# Filtrage des colonnes en fonction des consommateurs
final_output_file="$tmp_path/final_output.csv"
case "$consumer_type" in
  comp)
    echo "id_station;capacity;load" > "$final_output_file"
    tail -n +2 "$output_file" | awk -F';' 'NF >= 5 && $1 ~ /^[0-9]+$/ {print $1 ";" $4 ";" $5}' >> "$final_output_file"
    echo "Le tri selon la colonne Company a été exécuté"
    ;;
  indiv)
    echo "id_station;capacity;load" > "$final_output_file"
    tail -n +2 "$output_file" | awk -F';' 'NF >= 5 && $1 ~ /^[0-9]+$/ {print $1 ";" $4 ";" $5}' >> "$final_output_file"
    echo "Le tri selon la colonne Individual a été exécuté"
    ;;
  all)
    echo "id_station;capacity;load" > "$final_output_file"
    tail -n +2 "$output_file" | awk -F';' 'NF >= 5 && $1 ~ /^[0-9]+$/ {print $1 ";" $4 ";" $5}' >> "$final_output_file"
    echo "Le tri selon toutes les colonnes a été exécuté"
    ;;
esac

# Appel à la partie C
aggregated_output_file="$tests_path/${station_type}_${consumer_type}.csv"
cd codeC 
./c-wire "../$final_output_file" "../$aggregated_output_file" "$header"
cd ..

# Traitement spécifique pour "lv all"
if [[ "$station_type" == "lv" && "$consumer_type" == "all" ]]; then
    minmax_output_file="$tests_path/lv_all_minmax.csv"

    echo "Min and Max 'capacity-load' extreme nodes" > "$minmax_output_file"
    echo "$header" >> "$minmax_output_file"

# Calcul de la différence entre load et capacity, trié par consommation
    tail -n +2 "$aggregated_output_file" | \
    awk -F':' '{print $1 ":" $2 ":" $3}' | sort -t':' -k3,3nr > "$tmp_path/sorted_lv.csv"

# Extraire les 10 postes avec le plus de consommation dans un fichier temporaire
    head -n 10 "$tmp_path/sorted_lv.csv" > "$tmp_path/top10_lv.csv"

# Ajouter les 10 postes avec le plus de consommation au fichier final
    cat "$tmp_path/top10_lv.csv" >> "$minmax_output_file"

# Extraire les 10 postes avec le moins de consommation
    grep -v -f "$tmp_path/top10_lv.csv" "$tmp_path/sorted_lv.csv" | tail -n 10 >> "$minmax_output_file"

   echo "Le fichier des postes extrêmes a été créé : $minmax_output_file"

# Préparer les données pour le graphique
   gnuplot_data_file="$tmp_path/lv_graph_data.dat"
   tail -n +3 "$minmax_output_file" | \
   awk -F':' '{difference = $2 - $3; color = (difference < 0 ? "red" : "green"); print $1, difference, color}' > "$gnuplot_data_file"

# Générer le graphique avec GnuPlot
   gnuplot_script="$tmp_path/lv_graph.gnuplot"
   graph_output_file="graphs/lv_all_graph.png"

gnuplot <<EOF 
reset session
set terminal pngcairo size 1500,750 enhanced font "Arial,12"
set output '$graph_output_file'
set title "10 Most and Least Loaded LV Stations"
set boxwidth 0.5
set style fill solid 1.0
set ylabel "Capacity - Load Difference"
set xlabel "Station ID"
set xtics rotate by -45 scale 0
set grid ytics
plot 'tmp/lv_graph_data.dat' using 1:2:3 with boxes linecolor rgb variable notitle

EOF

echo "Graphique généré : $graph_output_file"
fi

exit_script 0 #  pour afficher les résultats et quitter 