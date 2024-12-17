#!/bin/bash

# Affichage de l'aide
afficher_aide() {
  echo "Usage : ./c-wire.sh [type_station] [type_consommateur] [id_centrale (optionnel)]"
  echo
  echo "Options :"
  echo "  type_station              Type de station : hvb, hva, lv (obligatoire)"
  echo "  type_consommateur         Type de consommateur : comp, indiv, all (obligatoire)"
  echo "  id_centrale               Identifiant de la centrale (optionnel)"
  echo "  -h                        Affiche cette aide"
  echo
  echo "Restrictions :"
  echo "  Les options suivantes sont interdites :"
  echo "    hvb all"
  echo "    hvb indiv"
  echo "    hva all"
  echo "    hva indiv"
  exit 0
}

# Vérification si l'option -h est présente
if [[ "$1" == "-h" ]]; then
  afficher_aide
fi

# Initialisation des variables

station_type="$1"
consumer_type="$2"
central_id="$3"

# Vérification des arguments
if [ $# -lt 2 ]; then
  echo "DEBUG : Arguments insuffisants"
  echo "Erreur : Veuillez fournir au moins deux arguments (station et consommateur)."
  afficher_aide
fi

# Recherche automatique du fichier d'entrée dans le dossier input/
file_path=$(ls input/*.dat 2>/dev/null | head -n 1)

if [ -z "$file_path" ]; then
  echo "Erreur : Aucun fichier d'entrée trouvé dans le dossier 'input/'."
  exit 1
fi



# Vérification des options interdites
if [[ "$station_type" == "hva" && "$consumer_type" == "all" ]] ||
   [[ "$station_type" == "hva" && "$consumer_type" == "indiv" ]] ||
   [[ "$station_type" == "hvb" && "$consumer_type" == "all" ]] ||
   [[ "$station_type" == "hvb" && "$consumer_type" == "indiv" ]]; then
  echo "Erreur : Les options $station_type $consumer_type sont interdites."
  afficher_aide
fi

# Préparation des dossiers
graphs_path="graphs"
tmp_path="tmp"
tests_path="tests"

[ -d "$graphs_path" ] || mkdir -p "$graphs_path"
[ -d "$tmp_path" ] || mkdir -p "$tmp_path"
[ -d "$tests_path" ] || mkdir -p "$tests_path"

# Initialisation de la variable start_time pour calculer le temps d'exécution
start_time=$(date +%s.%N)

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
    cut -d';' -f4,5,6,7,8 "$file_path" | tail -n +2 | tr '-' '0' | awk -F';' '$1 != 0' | sort -n -t';' -k1 >> "$output_file"
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

# Filtrage des colonnes et application du filtrage des consommateurs
final_output_file="$tmp_path/final_output.csv"
case "$consumer_type" in
  comp)
    echo "id_station:capacity:load" > "$final_output_file"
    tail -n +2 "$output_file" | awk -F';' 'NF >= 5 && $1 ~ /^[0-9]+$/ {print $1 ":" $4 ":" $5}' >> "$final_output_file"
    echo "Le tri selon la colonne Company a été exécuté"
    ;;
  indiv)
    echo "id_station:capacity:load" > "$final_output_file"
    tail -n +2 "$output_file" | awk -F';' 'NF >= 5 && $1 ~ /^[0-9]+$/ {print $1 ":" $4 ":" $5}' >> "$final_output_file"
    echo "Le tri selon la colonne Individual a été exécuté"
    ;;
  all)
    echo "id_station:capacity:load" > "$final_output_file"
    tail -n +2 "$output_file" | awk -F';' 'NF >= 5 && $1 ~ /^[0-9]+$/ {print $1 ":" $4 ":" $5}' >> "$final_output_file"
    echo "Le tri selon toutes les colonnes a été exécuté"
    ;;
esac

# Appel à la partie C
aggregated_output_file="$tests_path/${station_type}_${consumer_type}.csv"
cd codeC 
./c-wire "../$final_output_file" "../$aggregated_output_file" "$header"
cd ..

# Special processing for "lv all"
if [[ "$station_type" == "lv" && "$consumer_type" == "all" ]]; then
    minmax_output_file="tests/lv_all_minmax.csv"

    echo "Min and Max 'capacity-load' extreme nodes" > "$minmax_output_file"
    echo "LV Station:Capacity:Load (all)" >> "$minmax_output_file"

    # Calcul de la différence et tri global
    tail -n +2 "$aggregated_output_file" | \
    awk -F':' '{print $1 ":" $2 ":" $3}' | \
    sort -t':' -k3,3nr > "$tmp_path/sorted_lv.csv"

    # Extraction des 10 postes avec le plus de consommation
    head -n 10 "$tmp_path/sorted_lv.csv" > "$tmp_path/top10_lv.csv"

    # Écriture dans le fichier de sortie
    cat "$tmp_path/top10_lv.csv" >> "$minmax_output_file"

    # Extraction des 10 postes avec le moins de consommation (en excluant les "top 10")
    grep -v -f "$tmp_path/top10_lv.csv" "$tmp_path/sorted_lv.csv" | \
    tail -n 10 >> "$minmax_output_file"

    echo "Le fichier des postes extrêmes a été créé : $minmax_output_file"
fi
# Calcul du temps d'exécution
end_time=$(date +%s.%N)
elapsed_time=$(echo "$end_time - $start_time" | bc)
echo "Elapsed time: $elapsed_time seconds"
echo "The final file is available at: $aggregated_output_file"
