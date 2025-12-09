# 🥒 Tutorial Cucumber - "Is it Friday yet?"

Ce projet est un tutoriel d'introduction à Cucumber.js, un framework de test BDD (Behavior-Driven Development) pour Node.js. Il démontre comment écrire des tests en langage naturel (Gherkin) et les exécuter avec JavaScript.

## 📋 Table des matières

- [Description du projet](#description-du-projet)
- [Structure du projet](#structure-du-projet)
- [Installation](#installation)
- [Exécution des tests](#exécution-des-tests)
- [Explication du code](#explication-du-code)
- [Intégration Jenkins](#intégration-jenkins)
- [Sources et références](#sources-et-références)
- [Wiki](#wiki)

## 📖 Description du projet

Ce projet implémente un exemple classique de Cucumber : "Is it Friday yet?" (Est-ce que c'est vendredi ?). 

**Scénario** : Le système doit répondre "TGIF" (Thank God It's Friday) si c'est vendredi, sinon "Nope".

### Fonctionnalités

- ✅ Tests BDD avec Cucumber.js
- ✅ Scénarios écrits en Gherkin (langage naturel)
- ✅ Génération de rapports JSON pour l'intégration CI/CD
- ✅ Configuration pour Jenkins avec plugin Cucumber Reports

## 📁 Structure du projet

```
cucumber-tuto/
├── hellocucumber/
│   ├── features/
│   │   ├── is_it_friday_yet.feature    # Scénarios Gherkin
│   │   └── step_definitions/
│   │       └── stepdefs.js              # Implémentation des steps
│   ├── reports/                         # Rapports générés (gitignored)
│   ├── cucumber.json                    # Configuration Cucumber
│   ├── package.json                     # Dépendances Node.js
│   └── jenkins-build-fixed.sh          # Script pour Jenkins
└── README.md                            # Ce fichier
```

## 🚀 Installation

### Prérequis

- Node.js (version 18 ou supérieure)
- npm (généralement inclus avec Node.js)

### Étapes d'installation

1. **Cloner le dépôt** (si applicable) :
   ```bash
   git clone <url-du-repo>
   cd cucumber-tuto
   ```

2. **Installer les dépendances** :
   ```bash
   cd hellocucumber
   npm install
   ```

## 🧪 Exécution des tests

### Exécution locale

```bash
cd hellocucumber
npm test
```

Ou directement avec Cucumber :

```bash
npx cucumber-js
```

### Exécution avec génération de rapport

```bash
npm run test:jenkins
```

Les rapports sont générés dans le dossier `reports/` :
- `cucumber_report.json` : Rapport JSON pour l'intégration CI/CD
- `cucumber_report.ndjson` : Rapport au format NDJSON

### Résultat attendu

```
.........

3 scenarios (3 passed)
9 steps (9 passed)
0m00.008s (executing steps: 0m00.001s)
```

## 💡 Explication du code

### 1. Fichier Feature (Gherkin)

**Fichier** : `features/is_it_friday_yet.feature`

```gherkin
Feature: Is it Friday yet?
  Everybody wants to know when it's Friday

  Scenario Outline: Today is or is not Friday
    Given today is "<day>"
    When I ask whether it's Friday yet
    Then I should be told "<answer>"

  Examples:
    | day            | answer |
    | Friday         | TGIF   |
    | Sunday         | Nope   |
    | anything else! | Nope   |
```

**Explication** :
- `Feature` : Décrit la fonctionnalité testée
- `Scenario Outline` : Permet de tester plusieurs cas avec des données différentes
- `Given/When/Then` : Étapes du scénario (Given = précondition, When = action, Then = vérification)
- `Examples` : Table de données pour le Scenario Outline

### 2. Step Definitions (Implémentation)

**Fichier** : `features/step_definitions/stepdefs.js`

```javascript
const assert = require('assert');
const { Given, When, Then } = require('@cucumber/cucumber');

function isItFriday(today) {
  if (today === "Friday") {
    return "TGIF";
  } else {
    return "Nope";
  }
}

Given('today is {string}', function (givenDay) {
  this.today = givenDay;
});

When('I ask whether it\'s Friday yet', function () {
  this.actualAnswer = isItFriday(this.today);
});

Then('I should be told {string}', function (expectedAnswer) {
  assert.strictEqual(this.actualAnswer, expectedAnswer);
});
```

**Explication** :
- `Given` : Stocke le jour dans le contexte (`this.today`)
- `When` : Exécute la logique métier (`isItFriday`)
- `Then` : Vérifie que la réponse correspond à l'attente
- `{string}` : Paramètre capturé depuis le scénario Gherkin

### 3. Configuration Cucumber

**Fichier** : `cucumber.json`

```json
{
    "default": {
        "formatOptions": {
            "snippetInterface": "synchronous"
        },
        "format": [
            "json:reports/cucumber_report.json",
            "message:reports/cucumber_report.ndjson"
        ]
    }
}
```

**Explication** :
- `format` : Définit les formats de sortie des rapports
- `json` : Format JSON pour l'intégration CI/CD
- `message` : Format NDJSON (Newline Delimited JSON)

## 🔧 Intégration Jenkins

### Configuration Jenkins

Ce projet est configuré pour fonctionner avec Jenkins et le plugin **Cucumber Reports**.

#### 1. Script de build

Le script `jenkins-build-fixed.sh` :
- Installe Node.js automatiquement (via nvm)
- Détecte automatiquement le `package.json`
- Exécute les tests
- Crée un répertoire `cucumber-reports/` pour le plugin

#### 2. Configuration du Job Jenkins

**Build Steps** → **Execute shell** :
```bash
#!/bin/sh
set -e

# Installation Node.js
if ! command -v node >/dev/null 2>&1; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || {
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    }
    nvm install 20
    nvm use 20
fi

# Trouver package.json
if [ -f "package.json" ]; then
    PROJECT_DIR=$(pwd)
elif [ -f "hellocucumber/package.json" ]; then
    cd hellocucumber
    PROJECT_DIR=$(pwd)
else
    echo "✗ package.json non trouvé!"
    exit 1
fi

# Nettoyer
rm -rf reports/ cucumber-reports/

# Installer et tester
npm install
npm run test:jenkins

# CRÉER RÉPERTOIRE POUR LE PLUGIN
WORKSPACE="/var/jenkins_home/workspace/hellocucumber"
mkdir -p "$WORKSPACE/cucumber-reports"
cp reports/cucumber_report.json "$WORKSPACE/cucumber-reports/cucumber_report.json"

echo "✓ Rapport dans: $WORKSPACE/cucumber-reports/"
```

**Post-build Actions** → **Publish Cucumber Test Result Reports** :
- **JSON Reports Path** : `cucumber-reports/` (⚠️ répertoire, pas fichier)

### Points importants

- Le plugin Cucumber Reports attend un **répertoire** contenant des fichiers JSON, pas un fichier unique
- Le script crée automatiquement le répertoire `cucumber-reports/` à la racine du workspace
- Node.js est installé automatiquement via nvm si nécessaire

## 📚 Sources et références

### Documentation officielle

- **Cucumber.js** : https://github.com/cucumber/cucumber-js
- **Gherkin** : https://cucumber.io/docs/gherkin/
- **BDD** : https://cucumber.io/docs/bdd/

### Tutoriels

- **Cucumber.js Getting Started** : https://github.com/cucumber/cucumber-js/blob/main/docs/getting_started.md
- **Cucumber School** : https://school.cucumber.io/

### Plugins et outils

- **Jenkins Cucumber Reports Plugin** : https://plugins.jenkins.io/cucumber-reports/
- **Node.js** : https://nodejs.org/
- **npm** : https://www.npmjs.com/

## 📖 Wiki

### Qu'est-ce que BDD ?

**BDD (Behavior-Driven Development)** est une méthodologie de développement qui encourage la collaboration entre développeurs, testeurs et parties prenantes non techniques. Les tests sont écrits en langage naturel (Gherkin) pour être compréhensibles par tous.

### Concepts clés

#### Gherkin

Langage structuré pour décrire le comportement d'une application :

- **Feature** : Fonctionnalité testée
- **Scenario** : Cas de test spécifique
- **Given** : Précondition (état initial)
- **When** : Action déclenchante
- **Then** : Résultat attendu
- **And/But** : Conjonctions pour chaîner les étapes

#### Step Definitions

Implémentations JavaScript des étapes Gherkin. Chaque étape du scénario doit avoir une step definition correspondante.

#### Scenario Outline

Permet de tester plusieurs cas avec des données différentes en utilisant une table d'exemples.

### Bonnes pratiques

1. **Écrire des scénarios clairs** : Utiliser un langage simple et compréhensible
2. **Éviter les détails techniques** : Se concentrer sur le comportement, pas l'implémentation
3. **Réutiliser les steps** : Créer des steps génériques réutilisables
4. **Organiser les features** : Grouper les scénarios par fonctionnalité

### Dépannage

#### Les tests ne s'exécutent pas

- Vérifier que Node.js est installé : `node --version`
- Vérifier les dépendances : `npm install`
- Vérifier la syntaxe Gherkin dans le fichier `.feature`

#### Les steps ne sont pas trouvés

- Vérifier que les step definitions correspondent exactement au texte Gherkin
- Vérifier que les fichiers sont dans `features/step_definitions/`
- Utiliser `--dry-run` pour voir les steps manquants

#### Les rapports ne sont pas générés

- Vérifier que le dossier `reports/` existe ou est créé
- Vérifier la configuration dans `cucumber.json`
- Vérifier les permissions d'écriture

## 📝 Licence

ISC

## 👤 Auteur

Projet d'apprentissage Cucumber.js

---

**Note** : Ce projet est un tutoriel éducatif. Pour des projets de production, adaptez la configuration selon vos besoins.
