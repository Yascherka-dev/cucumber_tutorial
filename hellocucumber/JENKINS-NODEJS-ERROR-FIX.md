# Correction de l'erreur "No installation null found"

## Problème

L'erreur `No installation null found. Please define one in manager Jenkins` signifie que :
- Vous avez coché "Provide Node & npm bin/ folder to PATH" dans Build Environment
- Mais vous n'avez pas sélectionné d'installation Node.js, ou elle n'est pas configurée

## Solution

### Option 1 : Configurer correctement Node.js (Recommandé)

1. **Vérifier/Configurer Node.js dans Jenkins** :
   - Allez dans **Manage Jenkins** → **Global Tool Configuration**
   - Section **NodeJS**
   - Si aucune installation n'existe, cliquez sur **Add NodeJS**
   - Configurez :
     - **Name** : `NodeJS` (ou un nom de votre choix)
     - **Version** : Sélectionnez une version (ex: `20.x`)
     - ✅ Cochez **Install automatically**
   - Cliquez sur **Save**

2. **Configurer votre Job** :
   - Ouvrez votre job
   - Section **Build Environment**
   - ✅ Cochez **"Provide Node & npm bin/ folder to PATH"**
   - **IMPORTANT** : Dans le menu déroulant, **sélectionnez l'installation Node.js** que vous venez de créer (ex: `NodeJS`)
   - Ne laissez pas "null" ou vide !

3. **Sauvegardez** le job

### Option 2 : Désactiver Node.js dans Build Environment (si vous avez Node.js installé autrement)

Si Node.js est déjà disponible dans votre conteneur Jenkins (sans le plugin), vous pouvez :

1. **Décocher** "Provide Node & npm bin/ folder to PATH" dans Build Environment
2. Utiliser directement `npm` dans vos scripts (s'il est dans le PATH système)

## Vérification

Après avoir configuré Node.js, testez avec ce script dans Build Steps :

```bash
echo "=== Vérification Node.js ==="
which node
which npm
node --version
npm --version
```

Si ces commandes fonctionnent, Node.js est correctement configuré.

## Script de build complet (après correction Node.js)

Une fois Node.js configuré, utilisez ce script :

```bash
#!/bin/bash
set -e

echo "=== Vérification ==="
node --version
npm --version
pwd
echo ""

echo "=== Nettoyage ==="
rm -rf reports/
echo ""

echo "=== Installation ==="
npm install
echo ""

echo "=== Exécution des tests ==="
npm run test:jenkins
echo ""

echo "=== Vérification du fichier JSON ==="
if [ -f "reports/cucumber_report.json" ]; then
    echo "✓ Fichier trouvé: $(pwd)/reports/cucumber_report.json"
    ls -lh reports/cucumber_report.json
    
    # Vérifier le JSON
    node -e "JSON.parse(require('fs').readFileSync('reports/cucumber_report.json', 'utf8')); console.log('✓ JSON valide')"
    
    # Créer une copie à la racine
    cp reports/cucumber_report.json ./cucumber_report.json
    echo "✓ Copie créée: ./cucumber_report.json"
    
    # Afficher tous les fichiers JSON
    echo ""
    echo "=== Fichiers JSON trouvés ==="
    find . -name "*.json" -type f
    
else
    echo "✗ Fichier non trouvé!"
    find . -name "*.json" -type f
    exit 1
fi
```

## Configuration Post-build Actions

Après avoir exécuté le script, utilisez **UN** de ces chemins :

1. `reports/cucumber_report.json` (fichier original)
2. `cucumber_report.json` (copie à la racine)
3. `**/cucumber_report.json` (pattern - cherche partout)

**Recommandation** : Utilisez `reports/cucumber_report.json` d'abord, puis `**/cucumber_report.json` si ça ne fonctionne pas.

