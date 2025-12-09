# Correction des erreurs Jenkins détectées

## Problème 1 : Erreur Git "Couldn't find any revision to build"

### Solution

Dans votre job Jenkins, section **Source Code Management** :

1. Vérifiez que l'URL du dépôt est correcte : `https://github.com/Yascherka-dev/cucumber_tutorial`
2. **CRITIQUE** : Dans "Branches to build", changez :
   - De : `*/master` (par défaut)
   - Vers : `*/main` (si votre branche principale est `main`)
   - OU : `**` (pour toutes les branches)

### Vérification

Pour vérifier quelle est votre branche principale :
```bash
git branch -a
```

## Problème 2 : Le plugin traite le chemin comme un répertoire

Dans les logs, on voit :
```
[CucumberReport] JSON report directory is "reports/cucumber_report.json"
[CucumberReport] Copied 0 files from workspace "/var/jenkins_home/workspace/hellocucumber/reports/cucumber_report.json"
```

Le plugin cherche un **répertoire** au lieu d'un **fichier**.

### Solution

Dans **Post-build Actions** → **Publish Cucumber Test Result Reports** :

**Option 1 (Recommandée)** : Utilisez un pattern avec wildcard
```
**/cucumber_report.json
```

**Option 2** : Spécifiez le chemin du fichier (pas du répertoire)
```
reports/cucumber_report.json
```

**Option 3** : Si vous êtes dans le workspace `hellocucumber`, utilisez :
```
reports/cucumber_report.json
```

## Configuration complète du Job

### 1. Source Code Management
- **Repository URL** : `https://github.com/Yascherka-dev/cucumber_tutorial`
- **Branches to build** : `*/main` (ou `*/master` selon votre branche)
- ✅ **Corrigé** : Le problème Git est résolu, la branche `main` est maintenant détectée

### 2. Build Environment

**IMPORTANT** : Avant de configurer les Build Steps, vous devez installer Node.js :

1. **Installer le plugin NodeJS** : Manage Jenkins → Plugins → Rechercher "NodeJS Plugin" → Installer
2. **Configurer Node.js** : Manage Jenkins → Global Tool Configuration → NodeJS → Add NodeJS → Sélectionner version 20.x
3. **Dans votre Job** : Build Environment → Cocher "Provide Node & npm bin/ folder to PATH" → Sélectionner votre version Node.js

📖 **Guide complet** : Voir `JENKINS-NODEJS-SETUP.md`

### 3. Build Steps - Execute shell

Une fois Node.js configuré, utilisez ce script :

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
    echo ""
    echo "→ Chemin pour Jenkins: reports/cucumber_report.json"
else
    echo "✗ ERREUR: Fichier non trouvé!"
    echo "Recherche de tous les fichiers JSON:"
    find . -name "*.json" -type f
    exit 1
fi
```

### 4. Post-build Actions

- Cochez **"Publish Cucumber Test Result Reports"**
- **JSON Reports Path** : `**/cucumber_report.json` (pattern recommandé)
  - OU : `reports/cucumber_report.json` (si workspace dans hellocucumber)

**⚠️ Note** : Le pattern `**/cucumber_report.json` fonctionne mieux que le chemin direct dans certains cas.

## Vérification après correction

Après avoir appliqué ces corrections, relancez le build et vérifiez dans les logs :

1. ✅ Git fonctionne : "Checking out revision ..."
2. ✅ Les tests s'exécutent : "3 scenarios (3 passed)"
3. ✅ Le fichier est trouvé : "Copied 1 files from workspace"
4. ✅ Le rapport est généré : "Processing 1 json files"

## Problème : npm et Docker non disponibles

Si vous voyez les erreurs :
- `npm: command not found`
- `docker: command not found`

Cela signifie que ni Node.js ni Docker ne sont installés dans votre conteneur Jenkins.

### ✅ Solution recommandée : Installer Node.js via le plugin

**C'est la solution la plus simple et la plus propre** :

1. **Installer le plugin NodeJS** :
   - Allez dans **Manage Jenkins** → **Plugins**
   - Recherchez **"NodeJS Plugin"**
   - Installez-le

2. **Configurer Node.js** :
   - Allez dans **Manage Jenkins** → **Global Tool Configuration**
   - Section **NodeJS** → **Add NodeJS**
   - Sélectionnez une version (ex: `20.x`)
   - Cochez **Install automatically**
   - Sauvegardez

3. **Configurer votre Job** :
   - Dans votre job → **Build Environment**
   - Cochez **"Provide Node & npm bin/ folder to PATH"**
   - Sélectionnez la version Node.js configurée

4. **Utilisez ce script dans Build Steps** :
   ```bash
   npm install
   npm run test:jenkins
   ```

📖 **Guide détaillé** : Consultez `JENKINS-NODEJS-SETUP.md` pour les instructions complètes.

### Alternative : Installation manuelle

Si le plugin ne fonctionne pas, consultez `JENKINS-NODEJS-SETUP.md` pour d'autres méthodes d'installation.

## Si le problème persiste

Ajoutez cette commande dans les Build Steps pour voir exactement où le fichier est créé :

```bash
echo "=== DIAGNOSTIC COMPLET ==="
pwd
echo ""
echo "Recherche de tous les fichiers JSON:"
find . -name "*.json" -type f
echo ""
echo "Contenu du dossier reports:"
ls -la reports/ 2>/dev/null || echo "Dossier reports n'existe pas"
```

Puis utilisez le chemin exact trouvé dans la configuration Jenkins.

