# Student Dashboard - M2 DevOps - Zero Touch Deployment

Stack Docker complète avec déploiement automatisé "Zero Touch" sur AWS via GitHub Actions.

## 🏗️ Architecture

### Architecture Applicative

```
┌─────────────────┐     ┌─────────────────┐
│    Frontend     │────▶│      API        │
│  (Nginx:8080)   │     │  (FastAPI:8000) │
└─────────────────┘     └────────┬────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
              ┌─────▼─────┐           ┌───────▼───────┐
              │  Postgres │           │     Redis     │
              │   (DB)    │           │    (Cache)    │
              └───────────┘           └───────────────┘
```

### Architecture du Pipeline CI/CD

```mermaid
graph LR
    A[Push Code] --> B[Build & Publish]
    B --> C[Provision Infrastructure]
    C --> D[Deploy Application]

    B --> E[GHCR]
    C --> F[AWS EC2]
    D --> G[Application Running]

    style B fill:#4CAF50
    style C fill:#2196F3
    style D fill:#FF9800
```

**Pipeline en 3 phases** :

1. **Build & Publish** : Construction et publication des images Docker sur GHCR
2. **Provision Infrastructure** : Création de l'infrastructure AWS avec Terraform
3. **Deploy Application** : Configuration et déploiement avec Ansible

---

## 📋 Prérequis

### Pour le développement local

- Docker & Docker Compose
- Git

### Pour le déploiement automatisé

- Compte GitHub avec accès au repository
- Compte AWS avec Free Tier disponible
- GitHub Secrets configurés (voir section ci-dessous)

---

## 🚀 Lancement Local (Développement)

### 1. Cloner le repository

```bash
git clone https://github.com/CharlesDESC/devDocker.git
cd devDocker
```

### 2. Configurer les variables d'environnement

```bash
cp .env.example .env
# Éditer .env et définir POSTGRES_PASSWORD
```

### 3. Lancer la stack

```bash
docker-compose up --build -d
```

### 4. Accéder à l'application

- 🌐 **Dashboard** : http://localhost:8080
- 🔌 **API** : http://localhost:8000
- 🗄️ **Adminer** (dev) : `docker-compose --profile dev up adminer` puis http://localhost:8081

---

## ☁️ Déploiement Automatisé sur AWS

### Configuration des GitHub Secrets

Avant de lancer le déploiement, configurez les secrets suivants dans votre repository GitHub :

**Settings → Secrets and variables → Actions → New repository secret**

| Secret Name             | Description                        | Exemple                                    |
| ----------------------- | ---------------------------------- | ------------------------------------------ |
| `AWS_ACCESS_KEY_ID`     | Clé d'accès AWS IAM                | `AKIAIOSFODNN7EXAMPLE`                     |
| `AWS_SECRET_ACCESS_KEY` | Clé secrète AWS IAM                | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `POSTGRES_PASSWORD`     | Mot de passe PostgreSQL production | `MySecureP@ssw0rd123!`                     |

> [!WARNING]
> **Sécurité** : Ne jamais committer ces secrets dans le code. Utilisez uniquement GitHub Secrets.

### Lancer le Déploiement

1. **Aller dans l'onglet Actions** de votre repository GitHub
2. **Sélectionner le workflow** "Deploy to AWS"
3. **Cliquer sur "Run workflow"**
4. **Sélectionner la branche** `main`
5. **Cliquer sur "Run workflow"** (bouton vert)

### Suivre le Déploiement

Le pipeline s'exécute en 3 jobs séquentiels :

```
✅ Build & Publish Images (2-3 min)
   └─> Construction et push vers GHCR

✅ Provision AWS Infrastructure (3-4 min)
   └─> Création EC2, Security Groups, SSH Keys

✅ Deploy Application (2-3 min)
   └─> Installation Docker, déploiement stack
```

**Durée totale** : ~8-10 minutes

### Accéder à l'Application Déployée

Une fois le workflow terminé :

1. **Consulter le résumé du déploiement** dans l'onglet "Summary" du workflow
2. **Récupérer l'IP publique** affichée dans les logs
3. **Accéder aux URLs** :
   - Frontend : `http://<IP_PUBLIQUE>:8080`
   - API : `http://<IP_PUBLIQUE>:8000`

> [!TIP]
> L'IP publique est également visible dans les outputs Terraform et dans le résumé du job "Deploy Application".

---

## 🗂️ Structure du Projet

```
/devDocker
├── .github/
│   └── workflows/
│       ├── main.yml          # CI/CD pour PR (tests)
│       └── deploy.yml        # Déploiement automatisé AWS
├── infra/
│   └── main.tf               # Infrastructure as Code (Terraform)
├── ansible/
│   └── deploy-app.yml        # Configuration Management (Ansible)
├── app/
│   └── main.py               # API FastAPI
├── frontend/
│   └── index.html            # SPA Dashboard
├── nginx/
│   └── nginx.conf            # Configuration reverse proxy
├── sqlfiles/
│   ├── migration-v001.sql    # Table utilisateur
│   └── migration-v002-students.sql  # Table students
├── docker-compose.yml        # Stack locale (dev)
├── docker-compose.prod.yml   # Stack production (GHCR)
├── python.Dockerfile         # Image API
├── requirements.txt          # Dépendances Python
└── README.md                 # Ce fichier
```

---

## 🔒 Sécurité

- ✅ **Conteneurs non-root** (utilisateur `appuser`)
- ✅ **Isolation réseau** (frontend-network / backend-network)
- ✅ **Secrets via GitHub Secrets** (jamais en clair dans le code)
- ✅ **Clés SSH générées dynamiquement** (pas de clés statiques)
- ✅ **Images privées sur GHCR** (authentification requise)
- ✅ **Security Groups AWS** (ports strictement limités)

---

## 📊 Fonctionnalités

| Fonctionnalité               | Status |
| ---------------------------- | ------ |
| Frontend Nginx               | ✅     |
| API FastAPI                  | ✅     |
| PostgreSQL avec persistance  | ✅     |
| Redis avec persistance       | ✅     |
| Healthchecks                 | ✅     |
| Graceful Degradation         | ✅     |
| Sécurité non-root            | ✅     |
| Isolation réseau             | ✅     |
| **Déploiement Zero Touch**   | ✅     |
| **Infrastructure as Code**   | ✅     |
| **Configuration Management** | ✅     |

---

## 🛠️ Gestion de l'Infrastructure

### Vérifier l'état de l'infrastructure

```bash
cd infra
terraform init
terraform show
```

### Détruire l'infrastructure (nettoyage)

> [!CAUTION]
> Cette commande supprime définitivement l'instance EC2 et toutes les données associées.

```bash
cd infra
terraform destroy -auto-approve
```

### Coût estimé

- **Instance** : t3.micro (Free Tier eligible)
- **Stockage** : 20 GB gp3 (~$1.60/mois)
- **Réseau** : Gratuit (Free Tier : 100 GB/mois)

**Coût mensuel estimé** : $0-2 (selon Free Tier)

---

## 🧪 Tests de Résilience

### Test Graceful Degradation (Redis down)

```bash
# Couper Redis
docker-compose stop redis

# Vérifier que le dashboard s'affiche toujours (views = null)
curl http://localhost:8000/

# Relancer Redis
docker-compose start redis
```

### Test Health Checks

```bash
# Vérifier l'état des services
docker-compose ps

# Logs en temps réel
docker-compose logs -f
```

---

## 🔧 Commandes Utiles

### Développement Local

```bash
# Rebuild complet
docker-compose down -v && docker-compose up --build -d

# Voir les logs
docker-compose logs -f api

# Accéder au conteneur
docker-compose exec api sh

# Vérifier la base de données
docker-compose exec db psql -U postgres -c "SELECT * FROM students;"
```

### Production (sur le serveur AWS)

```bash
# Se connecter au serveur (récupérer l'IP depuis Terraform outputs)
ssh -i infra/devdocker_key_terraform.pem ubuntu@<IP_PUBLIQUE>

# Vérifier les conteneurs
docker ps

# Voir les logs
cd /home/ubuntu/devdocker
docker compose logs -f

# Redémarrer la stack
docker compose restart
```

---

## 🐛 Troubleshooting

### Le workflow échoue au job "Build & Publish"

**Problème** : Erreur d'authentification GHCR

**Solution** :

1. Vérifier que le repository est public OU que `GITHUB_TOKEN` a les permissions `write:packages`
2. Aller dans Settings → Actions → General → Workflow permissions → Cocher "Read and write permissions"

### Le workflow échoue au job "Provision Infrastructure"

**Problème** : Erreur AWS credentials

**Solution** :

1. Vérifier que les secrets `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY` sont bien configurés
2. Vérifier que l'utilisateur IAM a les permissions EC2, VPC, et KeyPair

### L'application n'est pas accessible après le déploiement

**Problème** : Security Group ou conteneurs non démarrés

**Solution** :

1. Vérifier les Security Groups dans AWS Console (ports 8080, 8000, 22 ouverts)
2. Se connecter au serveur et vérifier : `docker ps`
3. Vérifier les logs : `docker compose logs`

### Erreur "No space left on device"

**Problème** : Espace disque insuffisant

**Solution** :

```bash
# Nettoyer les images inutilisées
docker system prune -a -f

# Augmenter la taille du volume dans infra/main.tf
# root_block_device { volume_size = 30 }
```

---

## 📚 Ressources

- [Documentation Docker](https://docs.docker.com/)
- [Documentation Terraform](https://www.terraform.io/docs)
- [Documentation Ansible](https://docs.ansible.com/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [AWS Free Tier](https://aws.amazon.com/free/)

---

## 👥 Auteurs

Projet réalisé dans le cadre du TP Noté M2 DevOps - Ynov

---

## 📝 Licence

Ce projet est à usage éducatif.
