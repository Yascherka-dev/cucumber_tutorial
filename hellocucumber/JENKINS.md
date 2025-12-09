# Configuration Jenkins avec Cucumber Reports

Ce guide explique comment configurer Jenkins pour utiliser le plugin Cucumber Reports avec ce projet.

## Prérequis

- Jenkins installé (via Docker dans votre cas)
- Plugin "Cucumber Reports" installé dans Jenkins
- Ce projet configuré pour générer des rapports JSON

## Configuration du projet

Le projet est déjà configuré pour générer les rapports nécessaires :
- Format JSON : `reports/cucumber_report.json`
- Format NDJSON : `reports/cucumber_report.ndjson`

## Configuration Jenkins

### 1. Créer un nouveau Job Jenkins

1. Dans Jenkins, cliquez sur "Nouveau Item"
2. Choisissez "Freestyle project" ou "Pipeline"
3. Donnez un nom à votre projet

### 2. Configuration du Job (Freestyle)

#### Source Code Management
- Si votre code est dans Git, configurez la section "Source Code Management"
- Ajoutez l'URL de votre dépôt Git

#### Build Steps

**Option A : Si vous utilisez Node.js directement**

Si votre workspace Jenkins est à la **racine du projet** :
```bash
cd hellocucumber
npm install
npm run test:jenkins
```

Si votre workspace Jenkins est dans **hellocucumber** :
```bash
npm install
npm run test:jenkins
```

**Option B : Si vous utilisez Docker**
```bash
docker run --rm -v $(pwd):/workspace -w /workspace/hellocucumber node:latest sh -c "npm install && npm run test:jenkins"
```

**Option C : Diagnostic (à ajouter avant les tests)**
```bash
# Exécuter le script de diagnostic pour trouver le bon chemin
cd hellocucumber
./jenkins-diagnostic.sh
```

#### Post-build Actions

1. Cochez "Publish Cucumber Test Result Reports"
2. Dans "JSON Reports Path", entrez **UN** de ces chemins (selon votre configuration) :
   - `hellocucumber/reports/cucumber_report.json` (si workspace à la racine du projet)
   - `reports/cucumber_report.json` (si workspace dans hellocucumber)
   - `**/cucumber_report.json` (pattern - cherche partout, solution la plus sûre)
3. Optionnel : Configurez d'autres options comme les graphiques, les tendances, etc.

**⚠️ IMPORTANT** : 
- Le chemin doit être **relatif au workspace Jenkins**, pas un chemin absolu !
- Si vous avez configuré `reports/cucumber_report.json` et que ça ne fonctionne pas, votre workspace est probablement à la racine → utilisez `hellocucumber/reports/cucumber_report.json`
- **Solution la plus simple** : Utilisez le pattern `**/cucumber_report.json` qui cherche le fichier partout

### 3. Configuration du Job (Pipeline)

Si vous utilisez un Pipeline Jenkinsfile, voici un exemple :

```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'VOTRE_URL_GIT'
            }
        }
        
        stage('Install Dependencies') {
            steps {
                dir('hellocucumber') {
                    sh 'npm install'
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                dir('hellocucumber') {
                    sh 'npm run test:jenkins'
                }
            }
        }
    }
    
    post {
        always {
            cucumber(
                jsonReportPaths: 'hellocucumber/reports/cucumber_report.json',
                trendsLimit: 10,
                trendsDisplayLimit: 10
            )
        }
    }
}
```

### 4. Exécution et Visualisation

1. Lancez le build Jenkins
2. Une fois le build terminé, vous verrez un lien "Cucumber Reports" dans le menu latéral
3. Cliquez dessus pour voir les rapports détaillés avec :
   - Vue d'ensemble des scénarios
   - Graphiques de tendances
   - Détails des tests passés/échoués
   - Durée d'exécution

## Dépannage

### Erreur : "No JSON report file was found!"

Cette erreur signifie que Jenkins ne trouve pas le fichier JSON. Voici comment la résoudre :

#### Solution 1 : Diagnostic complet dans Jenkins

**IMPORTANT** : Ajoutez ces commandes dans vos **Build Steps** (avant la Post-build Action) :

```bash
# Afficher où vous êtes
echo "=== RÉPERTOIRE DE TRAVAIL ==="
pwd
echo ""

# Aller dans hellocucumber si nécessaire
if [ -d "hellocucumber" ]; then
    cd hellocucumber
    echo "Allé dans hellocucumber, nouveau répertoire:"
    pwd
    echo ""
fi

# Installer et exécuter les tests
npm install
npm run test:jenkins

# VÉRIFICATION CRITIQUE - Afficher où le fichier est créé
echo "=== RECHERCHE DU FICHIER JSON ==="
find . -name "cucumber_report.json" -type f
echo ""

# Afficher le chemin exact à utiliser
if [ -f "reports/cucumber_report.json" ]; then
    echo "✓ Fichier trouvé: reports/cucumber_report.json"
    echo "→ Utilisez ce chemin dans Jenkins: reports/cucumber_report.json"
elif [ -f "hellocucumber/reports/cucumber_report.json" ]; then
    echo "✓ Fichier trouvé: hellocucumber/reports/cucumber_report.json"
    echo "→ Utilisez ce chemin dans Jenkins: hellocucumber/reports/cucumber_report.json"
else
    echo "✗ Fichier non trouvé! Vérifiez les erreurs ci-dessus."
    exit 1
fi
```

**Après avoir exécuté ce diagnostic**, utilisez le chemin exact affiché dans la configuration Jenkins.

#### Solution 2 : Utiliser un pattern (recommandé)

Dans "JSON Reports Path", utilisez simplement :
```
**/cucumber_report.json
```
Ce pattern cherche le fichier partout et fonctionne dans tous les cas.

#### Solution 2 : Vérifier que le fichier est généré

Ajoutez cette commande dans vos **Build Steps** (avant la Post-build Action) :

```bash
cd hellocucumber
npm install
npm run test:jenkins

# Vérifier que le fichier existe
ls -la reports/cucumber_report.json
echo "Chemin absolu: $(pwd)/reports/cucumber_report.json"
```

#### Solution 3 : Utiliser un pattern avec wildcards

Dans Jenkins, au lieu d'un chemin exact, vous pouvez utiliser un pattern :
```
**/cucumber_report.json
```
Cela cherchera le fichier dans tous les sous-dossiers.

#### Solution 4 : Vérifier les permissions

Assurez-vous que Jenkins a les permissions de lecture sur le fichier :
```bash
chmod 644 reports/cucumber_report.json
```

#### Solution 5 : Script de diagnostic

Utilisez le script `verify-reports.sh` pour diagnostiquer :
```bash
cd hellocucumber
./verify-reports.sh
```

### Le rapport n'apparaît pas dans Jenkins

1. Vérifiez que le fichier JSON est bien généré dans `hellocucumber/reports/cucumber_report.json`
2. Vérifiez le chemin dans la configuration Jenkins (doit correspondre au chemin relatif depuis la racine du workspace)
3. Vérifiez les logs du build pour voir s'il y a des erreurs
4. **Important** : Le chemin doit être relatif au workspace, pas absolu

### Le format JSON n'est pas reconnu

- Assurez-vous d'utiliser la version récente de `@cucumber/cucumber` (>= 7.0.0)
- Vérifiez que le plugin Cucumber Reports est à jour dans Jenkins
- Vérifiez que le fichier JSON est valide (pas vide, format correct)

## Test local

Pour tester la génération du rapport localement :

```bash
cd hellocucumber
npm install
npm run test:jenkins
```

Le fichier `reports/cucumber_report.json` devrait être créé.

