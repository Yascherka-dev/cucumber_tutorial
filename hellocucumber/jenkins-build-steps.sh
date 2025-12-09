#!/bin/bash
# Script complet à copier dans les Build Steps de Jenkins
# Ce script gère automatiquement le chemin et génère le rapport

set -e  # Arrêter en cas d'erreur

echo "=========================================="
echo "BUILD JENKINS - Cucumber Tests"
echo "=========================================="

# Déterminer le répertoire de travail
if [ -d "hellocucumber" ]; then
    echo "Workspace à la racine, navigation vers hellocucumber..."
    cd hellocucumber
    WORKSPACE_PATH="hellocucumber"
else
    echo "Workspace dans hellocucumber..."
    WORKSPACE_PATH="."
fi

echo "Répertoire de travail: $(pwd)"
echo ""

# Installer les dépendances
echo "=== Installation des dépendances ==="
npm install
echo ""

# Exécuter les tests
echo "=== Exécution des tests Cucumber ==="
npm run test:jenkins
echo ""

# Vérifier que le fichier existe
echo "=== Vérification du rapport JSON ==="
if [ -f "reports/cucumber_report.json" ]; then
    echo "✓ Rapport généré avec succès!"
    echo "Emplacement: $(pwd)/reports/cucumber_report.json"
    echo "Taille: $(du -h reports/cucumber_report.json | cut -f1)"
    echo ""
    echo "→ Chemin à utiliser dans Jenkins Post-build Actions:"
    if [ "$WORKSPACE_PATH" = "hellocucumber" ]; then
        echo "   hellocucumber/reports/cucumber_report.json"
    else
        echo "   reports/cucumber_report.json"
    fi
    echo ""
    echo "OU utilisez le pattern (recommandé):"
    echo "   **/cucumber_report.json"
else
    echo "✗ ERREUR: Le fichier reports/cucumber_report.json n'a pas été généré!"
    echo "Contenu du dossier reports/:"
    ls -la reports/ 2>/dev/null || echo "Le dossier reports n'existe pas"
    exit 1
fi

echo "=========================================="
echo "Build terminé avec succès!"
echo "=========================================="

