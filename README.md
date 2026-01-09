# Student Dashboard - M2 DevOps

Stack Docker complète pour le TP Noté : Orchestration, Résilience et Industrialisation Docker.

## 🏗️ Architecture

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

## 📋 Prérequis

- Docker & Docker Compose
- Git

## 🚀 Lancement rapide

1. **Cloner le repository**

   ```bash
   git clone <url-du-repo>
   cd dev_avec_docker-main
   ```

2. **Configurer les variables d'environnement**

   ```bash
   cp .env.example .env
   # Ou créer un fichier .env avec :
   echo "POSTGRES_PASSWORD=your_secure_password" > .env
   ```

3. **Lancer la stack**

   ```bash
   docker-compose up --build -d
   ```

4. **Accéder à l'application**
   - 🌐 **Dashboard** : http://localhost:8080
   - 🔌 **API** : http://localhost:8000
   - 🗄️ **Adminer** (dev) : `docker-compose --profile dev up adminer`

## 🧪 Tests de résilience

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

## 📁 Structure du projet

```
/project-root
├── docker-compose.yml      # Orchestration des services
├── python.Dockerfile       # Image API (non-root)
├── requirements.txt        # Dépendances Python
├── .env                    # Variables d'environnement (non versionné)
├── .gitignore              # Fichiers à ignorer
├── app/
│   └── main.py             # API FastAPI
├── frontend/
│   └── index.html          # SPA Dashboard
├── nginx/
│   └── nginx.conf          # Configuration reverse proxy
└── sqlfiles/
    ├── migration-v001.sql  # Table utilisateur
    └── migration-v002-students.sql  # Table students
```

## 🔒 Sécurité

- ✅ Conteneurs non-root (utilisateur `appuser`)
- ✅ Isolation réseau (frontend-network / backend-network)
- ✅ Seuls ports 8080 (frontend) et 8000 (API) exposés
- ✅ Base de données et cache uniquement accessibles en interne
- ✅ Secrets via variables d'environnement

## 📊 Fonctionnalités

| Fonctionnalité              | Status |
| --------------------------- | ------ |
| Frontend Nginx              | ✅     |
| API FastAPI                 | ✅     |
| PostgreSQL avec persistance | ✅     |
| Redis avec persistance      | ✅     |
| Healthchecks                | ✅     |
| Graceful Degradation        | ✅     |
| Sécurité non-root           | ✅     |
| Isolation réseau            | ✅     |

## 🛠️ Commandes utiles

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
