#!/bin/bash
# Script de build Jenkins SANS utiliser le plugin NodeJS
# Installe Node.js directement dans le script

set -e

echo "=========================================="
echo "BUILD JENKINS - Installation Node.js"
echo "=========================================="

# Vérifier si Node.js est déjà installé
if command -v node &> /dev/null; then
    echo "✓ Node.js est déjà installé: $(node --version)"
    echo "✓ npm est disponible: $(npm --version)"
else
    echo "=== Installation de Node.js ==="
    
    # Créer le dossier pour nvm si nécessaire
    export NVM_DIR="$HOME/.nvm"
    mkdir -p "$NVM_DIR"
    
    # Installer nvm (Node Version Manager)
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        echo "Téléchargement de nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    fi
    
    # Charger nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Installer Node.js 20
    echo "Installation de Node.js 20..."
    nvm install 20
    nvm use 20
    
    echo "✓ Node.js installé: $(node --version)"
    echo "✓ npm installé: $(npm --version)"
fi

echo ""
echo "=== Répertoire de travail ==="
pwd
echo ""

echo "=== Nettoyage ==="
rm -rf reports/
echo ""

echo "=== Installation des dépendances ==="
npm install
echo ""

echo "=== Exécution des tests Cucumber ==="
npm run test:jenkins
echo ""

echo "=== VÉRIFICATION DU RAPPORT JSON ==="
if [ -f "reports/cucumber_report.json" ]; then
    echo "✓ Fichier trouvé: $(pwd)/reports/cucumber_report.json"
    ls -lh reports/cucumber_report.json
    
    # Vérifier que le JSON est valide
    echo ""
    echo "Vérification du format JSON..."
    node -e "JSON.parse(require('fs').readFileSync('reports/cucumber_report.json', 'utf8')); console.log('✓ JSON valide')"
    
    # Créer une copie à la racine pour faciliter la recherche
    cp reports/cucumber_report.json ./cucumber_report.json
    echo "✓ Copie créée: ./cucumber_report.json"
    
    echo ""
    echo "=== FICHIERS JSON TROUVÉS ==="
    find . -name "cucumber_report.json" -type f
    
    echo ""
    echo "=========================================="
    echo "✓ BUILD RÉUSSI - Rapport généré"
    echo "=========================================="
    echo ""
    echo "Chemins possibles pour Jenkins:"
    echo "  1. reports/cucumber_report.json"
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

