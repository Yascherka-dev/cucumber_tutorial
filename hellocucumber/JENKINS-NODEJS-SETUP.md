# Installation de Node.js dans Jenkins

## Solution 1 : Utiliser le plugin NodeJS (Recommandé)

### Étape 1 : Installer le plugin

1. Dans Jenkins, allez dans **Manage Jenkins** → **Plugins**
2. Cliquez sur l'onglet **Available**
3. Recherchez **"NodeJS Plugin"**
4. Cochez la case et cliquez sur **Install without restart**
5. Attendez la fin de l'installation

### Étape 2 : Configurer Node.js

1. Allez dans **Manage Jenkins** → **Global Tool Configuration**
2. Faites défiler jusqu'à la section **NodeJS**
3. Cliquez sur **Add NodeJS**
4. Configurez :
   - **Name** : `NodeJS` (ou un nom de votre choix)
   - **Version** : Sélectionnez une version récente (ex: `20.x` ou `18.x`)
   - Cochez **Install automatically**
5. Cliquez sur **Save**

### Étape 3 : Configurer votre Job

1. Ouvrez votre job Jenkins
2. Dans la section **Build Environment**, cochez :
   - **Provide Node & npm bin/ folder to PATH**
   - Dans le menu déroulant, sélectionnez la version Node.js que vous venez de configurer
3. Dans **Build Steps**, utilisez maintenant :

```bash
#!/bin/bash
set -e

echo "=== Vérification de Node.js ==="
node --version
npm --version
echo ""

echo "=== Répertoire de travail ==="
pwd
echo ""

echo "=== Installation des dépendances ==="
npm install
echo ""

echo "=== Exécution des tests ==="
npm run test:jenkins
echo ""

echo "=== Vérification du rapport JSON ==="
if [ -f "reports/cucumber_report.json" ]; then
    echo "✓ Fichier JSON généré avec succès"
    echo "Emplacement: $(pwd)/reports/cucumber_report.json"
    ls -lh reports/cucumber_report.json
else
    echo "✗ ERREUR: Fichier non trouvé!"
    find . -name "*.json" -type f
    exit 1
fi
```

## Solution 2 : Installation manuelle de Node.js (si le plugin ne fonctionne pas)

### Option A : Dans le conteneur Jenkins Docker

Si vous utilisez Docker, vous pouvez modifier votre conteneur pour inclure Node.js :

1. Créez un `Dockerfile` pour votre Jenkins :

```dockerfile
FROM jenkins/jenkins:lts

USER root

# Installer Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

USER jenkins
```

2. Reconstruisez votre image Jenkins avec Node.js

### Option B : Installation via script dans le job

Ajoutez cette étape **avant** vos tests dans les Build Steps :

```bash
#!/bin/bash
set -e

echo "=== Installation de Node.js ==="

# Vérifier si Node.js est déjà installé
if command -v node &> /dev/null; then
    echo "Node.js est déjà installé: $(node --version)"
    exit 0
fi

# Installer Node.js via nvm (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || {
    echo "Installation de nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

# Installer et utiliser Node.js 20
nvm install 20
nvm use 20

echo "Node.js installé: $(node --version)"
echo "npm installé: $(npm --version)"
```

**Note** : Cette méthode peut être lente car elle installe Node.js à chaque build.

## Solution 3 : Utiliser un agent Jenkins avec Node.js pré-installé

Si vous avez plusieurs jobs nécessitant Node.js, créez un agent Jenkins (slave) avec Node.js pré-installé.

## Vérification

Après avoir configuré Node.js, testez avec cette commande dans les Build Steps :

```bash
echo "=== Vérification ==="
which node
which npm
node --version
npm --version
```

Si ces commandes fonctionnent, vous pouvez utiliser `npm` dans vos scripts.

## Configuration finale du Job

Une fois Node.js installé, votre configuration complète sera :

### Build Environment
- ✅ **Provide Node & npm bin/ folder to PATH** (si vous utilisez le plugin)

### Build Steps
```bash
#!/bin/bash
set -e

npm install
npm run test:jenkins

# Vérification
if [ -f "reports/cucumber_report.json" ]; then
    echo "✓ Rapport généré: reports/cucumber_report.json"
    ls -lh reports/cucumber_report.json
else
    echo "✗ ERREUR: Rapport non trouvé!"
    exit 1
fi
```

### Post-build Actions
- **Publish Cucumber Test Result Reports**
- **JSON Reports Path** : `**/cucumber_report.json`

