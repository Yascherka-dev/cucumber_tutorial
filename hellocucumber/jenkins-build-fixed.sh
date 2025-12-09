#!/bin/sh
# Script Jenkins corrigé - Crée le rapport au bon endroit

set -e

echo "=========================================="
echo "BUILD JENKINS - CUCUMBER TESTS"
echo "=========================================="

# Installation Node.js
if ! command -v node >/dev/null 2>&1; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || {
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    }
    nvm install 20
    nvm use 20
fi

echo "Node.js: $(node --version)"
WORKSPACE=$(pwd)
echo "Workspace: $WORKSPACE"
echo ""

# Trouver package.json
if [ -f "package.json" ]; then
    PROJECT_DIR="$WORKSPACE"
elif [ -f "hellocucumber/package.json" ]; then
    PROJECT_DIR="$WORKSPACE/hellocucumber"
    cd "$PROJECT_DIR"
else
    echo "✗ package.json non trouvé!"
    exit 1
fi

echo "Projet: $(pwd)"
echo ""

# Nettoyer
rm -rf reports/ target/
echo ""

# Installer et tester
npm install
npm run test:jenkins

echo ""
echo "=== VÉRIFICATION ET PRÉPARATION ==="

if [ -f "reports/cucumber_report.json" ]; then
    echo "✓ Fichier généré: $(pwd)/reports/cucumber_report.json"
    
    # CRÉER UN RÉPERTOIRE DÉDIÉ POUR LE PLUGIN
    # Le plugin attend un RÉPERTOIRE, pas un fichier !
    mkdir -p "$WORKSPACE/cucumber-reports"
    cp reports/cucumber_report.json "$WORKSPACE/cucumber-reports/cucumber_report.json"
    
    echo "✓ Copie créée dans: $WORKSPACE/cucumber-reports/cucumber_report.json"
    ls -lh "$WORKSPACE/cucumber-reports/"
    
    # Vérifier JSON
    node -e "JSON.parse(require('fs').readFileSync('$WORKSPACE/cucumber-reports/cucumber_report.json', 'utf8')); console.log('✓ JSON valide')"
    
    echo ""
    echo "=========================================="
    echo "✓ BUILD RÉUSSI"
    echo "=========================================="
    echo ""
    echo "→ CHEMIN POUR JENKINS: cucumber-reports/"
    echo "  (Le plugin attend un RÉPERTOIRE, pas un fichier)"
    
else
    echo "✗ ERREUR: Rapport non généré!"
    exit 1
fi

