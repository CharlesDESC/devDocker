-- Migration v002: Création de la table students
CREATE TABLE IF NOT EXISTS students
(
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    promo VARCHAR(50) NOT NULL
);

-- Insertion de données de test
INSERT INTO students (nom, promo) VALUES
    ('Alice Martin', 'M2 Info 2026'),
    ('Bob Dupont', 'M2 Info 2026'),
    ('Charlie Durand', 'M2 Info 2026'),
    ('Diana Bernard', 'M2 Info 2026'),
    ('Eve Petit', 'M2 Info 2026');
