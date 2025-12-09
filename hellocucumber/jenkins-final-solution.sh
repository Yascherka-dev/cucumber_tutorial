#!/bin/bash
# Script final pour Jenkins - Diagnostic complet et génération du rapport

set -e

echo "=========================================="
echo "JENKINS BUILD - CUCUMBER TESTS"
echo "=========================================="

# Vérification de Node.js
echo "=== Vérification de Node.js ==="
if ! command -v node &> /dev/null; then
    echo "✗ ERREUR: Node.js n'est pas installé!"
    echo "Installez le plugin NodeJS dans Jenkins."
    exit 1
fi

echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo ""

# Répertoire de travail
echo "=== Répertoire de travail ==="
WORKSPACE=$(pwd)
echo "Workspace: $WORKSPACE"
echo ""

# Nettoyer les anciens rapports
echo "=== Nettoyage des anciens rapports ==="
rm -rf reports/
echo ""

# Installation des dépendances
echo "=== Installation des dépendances ==="
npm install
echo ""

# Exécution des tests
echo "=== Exécution des tests Cucumber ==="
npm run test:jenkins
echo ""

# Vérification du fichier JSON
echo "=== VÉRIFICATION DU RAPPORT JSON ==="
echo "Recherche du fichier cucumber_report.json..."
find . -name "cucumber_report.json" -type f 2>/dev/null
echo ""

if [ -f "reports/cucumber_report.json" ]; then
    echo "✓ Fichier trouvé: reports/cucumber_report.json"
    echo "Chemin absolu: $(pwd)/reports/cucumber_report.json"
    echo "Taille: $(du -h reports/cucumber_report.json | cut -f1)"
    echo ""
    
    # Vérifier que le fichier n'est pas vide
    if [ ! -s "reports/cucumber_report.json" ]; then
        echo "✗ ERREUR: Le fichier est vide!"
        exit 1
    fi
    
    # Vérifier que c'est un JSON valide
    echo "Vérification du format JSON..."
    if node -e "JSON.parse(require('fs').readFileSync('reports/cucumber_report.json', 'utf8'))" 2>/dev/null; then
        echo "✓ Le fichier JSON est valide"
    else
        echo "✗ ERREUR: Le fichier JSON n'est pas valide!"
        exit 1
    fi
    
    echo ""
    echo "=== CONTENU DU DOSSIER REPORTS ==="
    ls -lah reports/
    echo ""
    
    # Afficher les premiers caractères pour vérification
    echo "=== PREMIERS CARACTÈRES DU FICHIER ==="
    head -c 200 reports/cucumber_report.json
    echo "..."
    echo ""
    
    # Créer aussi une copie à la racine pour faciliter la recherche
    echo "=== Création d'une copie à la racine (backup) ==="
    cp reports/cucumber_report.json ./cucumber_report.json 2>/dev/null || true
    if [ -f "./cucumber_report.json" ]; then
        echo "✓ Copie créée: ./cucumber_report.json"
    fi
    echo ""
    
    echo "=========================================="
    echo "✓ RAPPORT GÉNÉRÉ AVEC SUCCÈS"
    echo "=========================================="
    echo ""
    echo "Chemins possibles pour Jenkins:"
    echo "  1. reports/cucumber_report.json"
    echo "  2. **/cucumber_report.json (pattern)"
    echo "  3. cucumber_report.json (copie à la racine)"
    echo ""
    
else
    echo "✗ ERREUR: Le fichier reports/cucumber_report.json n'a pas été généré!"
    echo ""
    echo "Contenu du répertoire actuel:"
    ls -la
    echo ""
    echo "Recherche de tous les fichiers JSON:"
    find . -name "*.json" -type f 2>/dev/null
    echo ""
    echo "Contenu du dossier reports (si existe):"
    ls -la reports/ 2>/dev/null || echo "Le dossier reports n'existe pas"
    echo ""
    exit 1
fi

