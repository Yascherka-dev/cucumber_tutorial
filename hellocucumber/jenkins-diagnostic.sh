#!/bin/bash
# Script de diagnostic pour Jenkins - à ajouter dans les Build Steps

echo "=========================================="
echo "DIAGNOSTIC JENKINS - Cucumber Reports"
echo "=========================================="
echo ""

echo "1. Répertoire de travail actuel:"
pwd
echo ""

echo "2. Contenu du répertoire actuel:"
ls -la
echo ""

echo "3. Recherche du fichier cucumber_report.json:"
find . -name "cucumber_report.json" -type f 2>/dev/null
echo ""

echo "4. Si dans hellocucumber, vérification du dossier reports:"
if [ -d "reports" ]; then
    echo "   ✓ Le dossier reports existe"
    ls -la reports/
    if [ -f "reports/cucumber_report.json" ]; then
        echo "   ✓ Le fichier JSON existe"
        echo "   Taille: $(du -h reports/cucumber_report.json | cut -f1)"
        echo "   Chemin relatif depuis $(pwd): reports/cucumber_report.json"
    else
        echo "   ✗ Le fichier JSON n'existe pas dans reports/"
    fi
else
    echo "   ✗ Le dossier reports n'existe pas"
fi
echo ""

echo "5. Si à la racine, vérification de hellocucumber/reports:"
if [ -d "hellocucumber/reports" ]; then
    echo "   ✓ Le dossier hellocucumber/reports existe"
    ls -la hellocucumber/reports/
    if [ -f "hellocucumber/reports/cucumber_report.json" ]; then
        echo "   ✓ Le fichier JSON existe"
        echo "   Taille: $(du -h hellocucumber/reports/cucumber_report.json | cut -f1)"
        echo "   Chemin relatif depuis $(pwd): hellocucumber/reports/cucumber_report.json"
    else
        echo "   ✗ Le fichier JSON n'existe pas dans hellocucumber/reports/"
    fi
else
    echo "   ✗ Le dossier hellocucumber/reports n'existe pas"
fi
echo ""

echo "=========================================="
echo "RECOMMANDATION POUR JENKINS:"
echo "=========================================="
if [ -f "reports/cucumber_report.json" ]; then
    echo "Utilisez ce chemin dans Jenkins: reports/cucumber_report.json"
elif [ -f "hellocucumber/reports/cucumber_report.json" ]; then
    echo "Utilisez ce chemin dans Jenkins: hellocucumber/reports/cucumber_report.json"
else
    echo "Le fichier n'a pas été trouvé. Vérifiez que les tests ont bien été exécutés."
fi
echo "=========================================="

