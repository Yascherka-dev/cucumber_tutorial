#!/bin/bash
# Script Jenkins avec détection automatique du package.json

set -e

echo "=========================================="
echo "BUILD JENKINS - Détection automatique"
echo "=========================================="

# Installation de Node.js
echo "=== Installation de Node.js ==="
if command -v node &> /dev/null; then
    echo "✓ Node.js déjà installé: $(node --version)"
else
    export NVM_DIR="$HOME/.nvm"
    mkdir -p "$NVM_DIR"
    
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash 2>/dev/null || true
    fi
    
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 20 2>/dev/null || nvm use 20
    nvm use 20
    
    echo "✓ Node.js installé: $(node --version)"
fi

echo ""
echo "=== Répertoire de travail ==="
WORKSPACE=$(pwd)
echo "Workspace: $WORKSPACE"
echo ""

# Détecter où se trouve package.json
echo "=== Détection du package.json ==="
if [ -f "package.json" ]; then
    echo "✓ package.json trouvé dans: $WORKSPACE"
    PROJECT_DIR="$WORKSPACE"
elif [ -f "hellocucumber/package.json" ]; then
    echo "✓ package.json trouvé dans: $WORKSPACE/hellocucumber"
    PROJECT_DIR="$WORKSPACE/hellocucumber"
    cd "$PROJECT_DIR"
    echo "Navigation vers: $(pwd)"
else
    echo "✗ ERREUR: package.json non trouvé!"
    echo "Recherche dans tous les dossiers:"
    find . -name "package.json" -type f 2>/dev/null | head -5
    exit 1
fi

echo ""
echo "=== Contenu du répertoire projet ==="
ls -la
echo ""

echo "=== Nettoyage ==="
rm -rf reports/
echo ""

echo "=== Installation des dépendances ==="
npm install
echo ""

echo "=== Exécution des tests ==="
npm run test:jenkins
echo ""

echo "=== VÉRIFICATION DU RAPPORT JSON ==="
if [ -f "reports/cucumber_report.json" ]; then
    echo "✓ Fichier trouvé: $(pwd)/reports/cucumber_report.json"
    ls -lh reports/cucumber_report.json
    
    # Vérifier le JSON
    node -e "JSON.parse(require('fs').readFileSync('reports/cucumber_report.json', 'utf8')); console.log('✓ JSON valide')"
    
    # Créer une copie à la racine du workspace Jenkins
    cp reports/cucumber_report.json "$WORKSPACE/cucumber_report.json"
    echo "✓ Copie créée: $WORKSPACE/cucumber_report.json"
    
    # Afficher tous les fichiers JSON
    echo ""
    echo "=== FICHIERS JSON TROUVÉS ==="
    find "$WORKSPACE" -name "cucumber_report.json" -type f
    
    echo ""
    echo "=========================================="
    echo "✓ BUILD RÉUSSI"
    echo "=========================================="
    echo ""
    echo "Chemins pour Jenkins Post-build Actions:"
    if [ "$PROJECT_DIR" != "$WORKSPACE" ]; then
        echo "  1. hellocucumber/reports/cucumber_report.json"
    else
        echo "  1. reports/cucumber_report.json"
    fi
    echo "  2. cucumber_report.json (copie à la racine)"
    echo "  3. **/cucumber_report.json (pattern)"
    
else
    echo "✗ ERREUR: Le fichier reports/cucumber_report.json n'a pas été généré!"
    echo ""
    echo "Recherche de tous les fichiers JSON:"
    find . -name "*.json" -type f
    echo ""
    echo "Contenu du répertoire:"
    ls -la
    exit 1
fi

