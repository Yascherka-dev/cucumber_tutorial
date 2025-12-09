#!/bin/bash
# Script de build Jenkins utilisant Docker
# À utiliser si npm n'est pas disponible dans Jenkins

set -e

echo "=========================================="
echo "BUILD JENKINS - Cucumber Tests (Docker)"
echo "=========================================="

WORKSPACE_DIR=$(pwd)
echo "Répertoire de travail: $WORKSPACE_DIR"
echo ""

# Vérifier que Docker est disponible
if ! command -v docker &> /dev/null; then
    echo "✗ ERREUR: Docker n'est pas disponible!"
    echo "Installez Docker ou configurez Node.js dans Jenkins."
    exit 1
fi

echo "=== Exécution des tests avec Docker ==="
docker run --rm \
  -v "$WORKSPACE_DIR:/workspace" \
  -w /workspace \
  node:latest \
  sh -c "npm install && npm run test:jenkins"

echo ""
echo "=== Vérification du rapport JSON ==="
if [ -f "reports/cucumber_report.json" ]; then
    echo "✓ Rapport généré avec succès!"
    echo "Emplacement: $(pwd)/reports/cucumber_report.json"
    echo "Taille: $(du -h reports/cucumber_report.json | cut -f1)"
    echo ""
    echo "→ Chemin à utiliser dans Jenkins Post-build Actions:"
    echo "   reports/cucumber_report.json"
    echo ""
    echo "OU utilisez le pattern (recommandé):"
    echo "   **/cucumber_report.json"
else
    echo "✗ ERREUR: Le fichier reports/cucumber_report.json n'a pas été généré!"
    echo "Contenu du dossier reports/:"
    ls -la reports/ 2>/dev/null || echo "Le dossier reports n'existe pas"
    echo ""
    echo "Recherche de tous les fichiers JSON:"
    find . -name "*.json" -type f
    exit 1
fi

echo "=========================================="
echo "Build terminé avec succès!"
echo "=========================================="

