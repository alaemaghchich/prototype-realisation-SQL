CREATE DATABASE library;
USE library;

-- =====================
-- TABLE RAYON
-- =====================
CREATE TABLE rayon (
    rayon_id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL
);

-- =====================
-- TABLE AUTEUR
-- =====================
CREATE TABLE auteur (
    auteur_id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL
);

-- =====================
-- TABLE LECTEUR
-- =====================
CREATE TABLE lecteur (
    lecteur_id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    tel VARCHAR(15) NOT NULL UNIQUE,
    cin VARCHAR(8) NOT NULL UNIQUE
);

-- =====================
-- TABLE OUVRAGE
-- =====================
CREATE TABLE ouvrage (
    ouvrage_id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(200) NOT NULL,
    annee_publication YEAR NOT NULL,
    rayon_id INT NOT NULL,
    FOREIGN KEY (rayon_id) REFERENCES rayon(rayon_id)
);

-- =====================
-- TABLE ASSOCIATION OUVRAGE / AUTEUR
-- =====================
CREATE TABLE ouvrage_auteur (
    ouvrage_id INT,
    auteur_id INT,
    PRIMARY KEY (ouvrage_id, auteur_id),
    FOREIGN KEY (ouvrage_id) REFERENCES ouvrage(ouvrage_id),
    FOREIGN KEY (auteur_id) REFERENCES auteur(auteur_id)
);

-- =====================
-- TABLE EMPRUNT
-- =====================
CREATE TABLE emprunt (
    emprunt_id INT AUTO_INCREMENT PRIMARY KEY,
    date_emprunt DATE NOT NULL DEFAULT CURRENT_DATE,
    date_retour_prevue DATE NOT NULL,
    date_retour_effective DATE NULL,
    lecteur_id INT NOT NULL,
    ouvrage_id INT NOT NULL,
    FOREIGN KEY (lecteur_id) REFERENCES lecteur(lecteur_id),
    FOREIGN KEY (ouvrage_id) REFERENCES ouvrage(ouvrage_id)
);

-- =====================
-- TABLE PERSONNEL
-- =====================
CREATE TABLE personnel (
    personnel_id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    tel VARCHAR(15) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL,
    chef_id INT NULL,
    FOREIGN KEY (chef_id) REFERENCES personnel(personnel_id)
);


--PARTIE 1 : requêtes SELECT
SELECT * FROM rayon
SELECT nom, prenom FROM auteur
SELECT titre, annee_publication FROM ouvrage
SELECT nom, prenom, email FROM lecteur

SELECT  titre, annee_publication FROM ouvrage 
WHERE annee_publication >= 1950

SELECT * FROM lecteur WHERE nom LIKE 'M%';

SELECT titre, annee_publication FROM ouvrage
ORDER BY  annee_publication DESC;

SELECT o.titre, e.date_retour_effective
FROM emprunt AS e
INNER JOIN ouvrage AS o ON e.ouvrage_id = o.ouvrage_id
WHERE e.date_retour_effective IS NULL;

SELECT o.titre, r.nom FROM ouvrage AS o
INNER JOIN rayon AS r
ON o.rayon_id = r.rayon_id;

SELECT o.titre, a.nom, a.prenom
FROM ouvrage AS o
INNER JOIN ouvrage_auteur AS oa ON o.ouvrage_id = oa.ouvrage_id
INNER JOIN auteur AS a ON oa.auteur_id = a.auteur_id;

SELECT DISTINCT l.lecteur_id, l.nom, l.prenom
FROM lecteur AS l
INNER JOIN emprunt AS e ON l.lecteur_id = e.lecteur_id;

SELECT r.nom AS rayon, COUNT(o.ouvrage_id) AS nombre_ouvrages
FROM rayon AS r
LEFT JOIN ouvrage AS o ON r.rayon_id = o.rayon_id
GROUP BY r.rayon_id;



--PARTIE 2 : requêtes UPDATE
UPDATE lecteur SET email = "alaemaghchich2004@gmail.com"
WHERE lecteur_id = 1;

UPDATE lecteur SET tel = "0655454642"
WHERE cin = "K123456";

SELECT * FROM LECTEUR;

UPDATE ouvrage
SET rayon_id = 2
WHERE ouvrage_id = 1;

SELECT * FROM ouvrage;

UPDATE emprunt SET date_retour_effective = CURRENT_DATE
WHERE emprunt_id = 3;

SELECT * FROM emprunt

UPDATE personnel SET chef_id = 1
WHERE personnel_id = 1;

SELECT * FROM personnel

--PARTIE 3 : requête DELETE
DELETE FROM emprunt WHERE emprunt_id = 2;

DELETE FROM lecteur l
WHERE NOT EXISTS (
    SELECT 1
    FROM emprunt e
    WHERE e.lecteur_id = l.lecteur_id
);


DELETE FROM ouvrage o
WHERE NOT EXISTS (
    SELECT 1
    FROM emprunt e
    WHERE e.ouvrage_id = o.ouvrage_id
);
