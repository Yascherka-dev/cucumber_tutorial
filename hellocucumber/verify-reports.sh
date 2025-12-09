#!/bin/bash
# Script de vérification pour diagnostiquer les problèmes de rapports Jenkins

echo "=== Vérification des rapports Cucumber ==="
echo ""

# Vérifier si le dossier reports existe
if [ -d "reports" ]; then
    echo "✓ Le dossier 'reports' existe"
else
    echo "✗ Le dossier 'reports' n'existe pas"
    echo "  Création du dossier..."
    mkdir -p reports
fi

# Vérifier si le fichier JSON existe
if [ -f "reports/cucumber_report.json" ]; then
    echo "✓ Le fichier 'reports/cucumber_report.json' existe"
    echo "  Taille: $(du -h reports/cucumber_report.json | cut -f1)"
    echo "  Chemin absolu: $(pwd)/reports/cucumber_report.json"
else
    echo "✗ Le fichier 'reports/cucumber_report.json' n'existe pas"
    echo "  Exécution des tests pour le générer..."
    npm run test:jenkins
fi

echo ""
echo "=== Emplacement actuel ==="
echo "Répertoire de travail: $(pwd)"
echo ""

echo "=== Structure des fichiers ==="
find . -name "cucumber_report.json" -type f 2>/dev/null | head -10

echo ""
echo "=== Contenu du dossier reports ==="
ls -lah reports/ 2>/dev/null || echo "Le dossier reports est vide ou n'existe pas"

echo ""
echo "=== Pour Jenkins ==="
echo "Si vous êtes dans Jenkins, le chemin devrait être relatif au workspace Jenkins."
echo "Exemples de chemins possibles:"
echo "  - Si le workspace est à la racine du projet: hellocucumber/reports/cucumber_report.json"
echo "  - Si le workspace est dans hellocucumber: reports/cucumber_report.json"
echo "  - Chemin absolu (non recommandé): $(pwd)/reports/cucumber_report.json"

