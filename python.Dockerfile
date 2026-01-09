FROM python:3.9-slim

# Créer un utilisateur non-root pour la sécurité
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /server

# Copier et installer les dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code de l'application
COPY app/ ./app/

# Changer le propriétaire des fichiers
RUN chown -R appuser:appgroup /server

# Utiliser l'utilisateur non-root
USER appuser

EXPOSE 8000

# Commande par défaut
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]