# Solution Jenkins SANS plugin NodeJS

Si vous n'arrivez pas à configurer le plugin NodeJS dans Jenkins, voici une solution qui installe Node.js directement dans le script de build.

## ✅ Solution simple : Script qui installe Node.js automatiquement

### Étape 1 : Désactiver le plugin NodeJS dans votre Job

1. Ouvrez votre job Jenkins
2. Section **Build Environment**
3. **DÉCOCHEZ** "Provide Node & npm bin/ folder to PATH" (si c'est coché)
4. Sauvegardez

### Étape 2 : Utiliser le script avec détection automatique

Dans **Build Steps** → **Execute shell**, copiez-collez ce script complet (il détecte automatiquement où se trouve package.json) :

```bash
#!/bin/bash
set -e

echo "=== Installation de Node.js ==="

# Vérifier si Node.js est déjà installé
if command -v node &> /dev/null; then
    echo "✓ Node.js déjà installé: $(node --version)"
else
    # Installer nvm (Node Version Manager)
    export NVM_DIR="$HOME/.nvm"
    mkdir -p "$NVM_DIR"
    
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash 2>/dev/null || true
    fi
    
    # Charger nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Installer Node.js 20
    nvm install 20 2>/dev/null || nvm use 20
    nvm use 20
    
    echo "✓ Node.js installé: $(node --version)"
fi

echo ""
echo "=== Répertoire de travail initial ==="
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
echo "=== Nettoyage ==="
rm -rf reports/
echo ""

echo "=== Installation des dépendances ==="
npm install
echo ""

echo "=== Exécution des tests ==="
npm run test:jenkins
echo ""

echo "=== Vérification du rapport JSON ==="
if [ -f "reports/cucumber_report.json" ]; then
    echo "✓ Fichier trouvé: $(pwd)/reports/cucumber_report.json"
    ls -lh reports/cucumber_report.json
    
    # Vérifier le JSON
    node -e "JSON.parse(require('fs').readFileSync('reports/cucumber_report.json', 'utf8')); console.log('✓ JSON valide')"
    
    # Créer une copie à la racine du workspace Jenkins
    cp reports/cucumber_report.json "$WORKSPACE/cucumber_report.json"
    echo "✓ Copie créée: $WORKSPACE/cucumber_report.json"
    
    # Afficher tous les fichiers JSON trouvés
    echo ""
    echo "=== FICHIERS JSON TROUVÉS ==="
    find "$WORKSPACE" -name "cucumber_report.json" -type f
    
else
    echo "✗ ERREUR: Fichier non trouvé!"
    find . -name "*.json" -type f
    exit 1
fi
```

### Étape 3 : Configurer Post-build Actions

Dans **Post-build Actions** → **Publish Cucumber Test Result Reports** :

**JSON Reports Path** : Utilisez **UN** de ces chemins :

1. `reports/cucumber_report.json` (recommandé)
2. `**/cucumber_report.json` (pattern - cherche partout)
3. `cucumber_report.json` (si vous créez la copie)

## ⚠️ Important

- **Décochez** "Provide Node & npm bin/ folder to PATH" dans Build Environment
- Le script installe Node.js automatiquement à chaque build (la première fois peut prendre quelques minutes)
- Les builds suivants seront plus rapides car Node.js sera déjà installé

## Alternative : Script plus rapide (si Node.js est déjà installé)

Si Node.js est déjà disponible dans votre système (mais pas via le plugin), utilisez simplement :

```bash
#!/bin/bash
set -e

npm install
npm run test:jenkins

# Vérification
if [ ! -f "reports/cucumber_report.json" ]; then
    echo "✗ ERREUR: Rapport non généré!"
    exit 1
fi

echo "✓ Rapport généré: reports/cucumber_report.json"
ls -lh reports/cucumber_report.json
```

## Vérification

Après avoir exécuté le build, vérifiez dans les logs :

- ✅ `✓ Node.js installé: v20.x.x`
- ✅ `✓ Fichier trouvé: .../reports/cucumber_report.json`
- ✅ `✓ JSON valide`
- ✅ `✓ Copie créée: ./cucumber_report.json`

Si vous voyez ces messages, le rapport est généré correctement !

## Dépannage

### Si l'installation de nvm échoue

Vérifiez que `curl` est disponible dans Jenkins. Si ce n'est pas le cas, utilisez `wget` :

```bash
# Remplacer la ligne curl par :
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

### Si le build est trop lent

L'installation de Node.js prend du temps la première fois. Les builds suivants seront plus rapides car Node.js sera déjà installé dans `$HOME/.nvm`.

### Si vous avez toujours des erreurs

Ajoutez ces commandes de diagnostic au début du script :

```bash
echo "=== Diagnostic ==="
echo "User: $(whoami)"
echo "Home: $HOME"
echo "PATH: $PATH"
echo "PWD: $(pwd)"
```

