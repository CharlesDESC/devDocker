import psycopg2
import os
import redis
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# Configuration Redis
REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))

# Configuration Postgres
POSTGRES_HOST = os.getenv("POSTGRES_HOST", "db")
POSTGRES_PORT = int(os.getenv("POSTGRES_PORT", 5432))
POSTGRES_USER = os.getenv("POSTGRES_USER", "postgres")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
POSTGRES_DB = os.getenv("POSTGRES_DB", "postgres")


def get_db_connection():
    """Crée une nouvelle connexion à la base de données"""
    return psycopg2.connect(
        host=POSTGRES_HOST,
        port=POSTGRES_PORT,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD,
        database=POSTGRES_DB
    )


def get_redis_client():
    """Crée un client Redis avec gestion d'erreur"""
    try:
        client = redis.Redis(
            host=REDIS_HOST,
            port=REDIS_PORT,
            decode_responses=True,
            socket_connect_timeout=2
        )
        client.ping()
        return client
    except (redis.ConnectionError, redis.TimeoutError):
        return None


@app.get('/')
async def get_students():
    """
    Récupère la liste des étudiants depuis Postgres
    et incrémente le compteur de vues dans Redis.
    Graceful Degradation: si Redis est down, retourne views=null
    """
    # Connexion à Postgres
    conn = get_db_connection()
    cur = conn.cursor()

    # Récupérer les étudiants
    cur.execute("SELECT id, nom, promo FROM students;")
    rows = cur.fetchall()

    cur.close()
    conn.close()

    # Gestion Redis avec Graceful Degradation
    redis_client = get_redis_client()
    views = None

    if redis_client:
        try:
            # Incrémenter le compteur atomique
            views = redis_client.incr("dashboard:views")
        except (redis.ConnectionError, redis.TimeoutError):
            views = None

    # Construire la réponse
    students = []
    for row in rows:
        students.append({
            "id": row[0],
            "nom": row[1],
            "promo": row[2],
            "views": views
        })

    return students


@app.get('/health')
async def health_check():
    """Endpoint de health check"""
    return {"status": "healthy"}
