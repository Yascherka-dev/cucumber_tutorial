# Guide de dépannage - Erreur "No JSON report file was found!"

## Étape 1 : Diagnostic dans Jenkins

Ajoutez ces commandes dans vos **Build Steps** (avant la Post-build Action) pour diagnostiquer :

```bash
# Afficher où vous êtes
echo "=== RÉPERTOIRE DE TRAVAIL ==="
pwd
echo ""

# Lister le contenu
echo "=== CONTENU DU RÉPERTOIRE ==="
ls -la
echo ""

# Si vous êtes à la racine, aller dans hellocucumber
if [ -d "hellocucumber" ]; then
    echo "=== ALLER DANS HELLOCUCUMBER ==="
    cd hellocucumber
    pwd
    ls -la
    echo ""
fi

# Installer les dépendances
echo "=== INSTALLATION DES DÉPENDANCES ==="
npm install
echo ""

# Exécuter les tests
echo "=== EXÉCUTION DES TESTS ==="
npm run test:jenkins
echo ""

# Vérifier que le fichier existe
echo "=== VÉRIFICATION DU FICHIER JSON ==="
echo "Recherche du fichier cucumber_report.json..."
find . -name "cucumber_report.json" -type f
echo ""

# Afficher le chemin exact
if [ -f "reports/cucumber_report.json" ]; then
    echo "✓ Fichier trouvé: reports/cucumber_report.json"
    echo "Chemin depuis $(pwd): reports/cucumber_report.json"
    ls -lh reports/cucumber_report.json
elif [ -f "hellocucumber/reports/cucumber_report.json" ]; then
    echo "✓ Fichier trouvé: hellocucumber/reports/cucumber_report.json"
    echo "Chemin depuis $(pwd): hellocucumber/reports/cucumber_report.json"
    ls -lh hellocucumber/reports/cucumber_report.json
else
    echo "✗ Fichier non trouvé!"
    echo "Recherche dans tous les sous-dossiers:"
    find . -name "*.json" -type f
fi
```

## Étape 2 : Configurer le bon chemin

Après avoir exécuté le diagnostic, utilisez le chemin exact affiché dans la section "Post-build Actions" :

### Si le diagnostic affiche :
- `reports/cucumber_report.json` → Utilisez : `reports/cucumber_report.json` (si workspace dans hellocucumber)
- `hellocucumber/reports/cucumber_report.json` → Utilisez : `hellocucumber/reports/cucumber_report.json` (si workspace à la racine)

### Solution universelle (recommandée) :
Utilisez le pattern avec wildcards :
```
**/cucumber_report.json
```

## Étape 3 : Configuration complète du Job Jenkins

### Build Steps (dans l'ordre) :

1. **Source Code Management** (si Git)
   - Configurez votre dépôt Git

2. **Build Steps - Execute shell** :
   ```bash
   # Aller dans le dossier du projet
   cd hellocucumber
   
   # Installer les dépendances
   npm install
   
   # Exécuter les tests et générer le rapport
   npm run test:jenkins
   
   # Vérifier que le fichier existe (pour debug)
   ls -la reports/cucumber_report.json || echo "ERREUR: Fichier non trouvé!"
   ```

3. **Post-build Actions** :
   - Cochez "Publish Cucumber Test Result Reports"
   - **JSON Reports Path** : `hellocucumber/reports/cucumber_report.json` OU `**/cucumber_report.json`

## Étape 4 : Vérifications supplémentaires

### Vérifier que le fichier JSON est valide

Ajoutez cette commande dans vos Build Steps :
```bash
cd hellocucumber
if [ -f "reports/cucumber_report.json" ]; then
    echo "Fichier trouvé, vérification du format JSON..."
    node -e "JSON.parse(require('fs').readFileSync('reports/cucumber_report.json', 'utf8')); console.log('✓ JSON valide')"
else
    echo "✗ Fichier non trouvé!"
    exit 1
fi
```

### Vérifier les permissions

```bash
chmod 644 reports/cucumber_report.json
```

## Solutions alternatives

### Solution A : Utiliser un chemin absolu (non recommandé mais peut fonctionner)

Dans Jenkins, vous pouvez essayer de spécifier le chemin complet dans la configuration, mais cela dépend de votre setup Jenkins.

### Solution B : Copier le fichier à un emplacement standard

Ajoutez cette étape après les tests :
```bash
# Créer un dossier standard pour les rapports
mkdir -p target/cucumber-reports

# Copier le fichier
cp reports/cucumber_report.json target/cucumber-reports/CucumberTestReport.json
```

Puis dans Jenkins, utilisez : `target/cucumber-reports/CucumberTestReport.json`

### Solution C : Utiliser plusieurs fichiers JSON

Si vous avez plusieurs fichiers, vous pouvez utiliser un pattern :
```
**/reports/*.json
```

## Checklist de vérification

- [ ] Les tests s'exécutent sans erreur dans Jenkins
- [ ] Le fichier `cucumber_report.json` est généré (vérifié avec `ls` ou `find`)
- [ ] Le chemin dans Jenkins correspond exactement à l'emplacement du fichier
- [ ] Le fichier JSON est valide (pas vide, format correct)
- [ ] Jenkins a les permissions de lecture sur le fichier
- [ ] Le chemin est relatif au workspace Jenkins (pas absolu)

## Si rien ne fonctionne

1. **Vérifiez les logs du build Jenkins** : Regardez la sortie complète du build pour voir où le fichier est créé
2. **Testez localement** : Exécutez `npm run test:jenkins` localement et vérifiez où le fichier est créé
3. **Vérifiez la version du plugin** : Assurez-vous d'avoir la dernière version du plugin Cucumber Reports
4. **Essayez avec un chemin simple** : Créez un dossier `target` à la racine et copiez le fichier dedans

