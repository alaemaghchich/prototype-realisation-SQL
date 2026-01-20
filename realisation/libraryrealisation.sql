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

--PARTIE 1 : AJOUT DES RÈGLES MÉTIER VIA DES CONTRAINTES CHECK
ALTER TABLE personnel
ADD cin VARCHAR(8) NOT NULL UNIQUE;

ALTER TABLE ouvrage
ADD CONSTRAINT chk_annee
CHECK (annee_publication BETWEEN 1900 AND YEAR(CURRENT_DATE));

ALTER TABLE personnel
ADD CONSTRAINT chk_tel
CHECK (LENGTH(tel) >= 10);
ALTER TABLE lecteur
ADD CONSTRAINT chk_tel
CHECK (LENGTH(tel) >= 10);

ALTER TABLE emprunt
ADD CONSTRAINT chk_date_emprunt
CHECK (date_emprunt <= CURRENT_DATE);

ALTER TABLE emprunt
ADD CONSTRAINT chk_duree_emprunt
CHECK (DATEDIFF(date_retour_prevue, date_emprunt) <= 30);

ALTER TABLE rayon
ADD CONSTRAINT chk_nom_rayon
CHECK (nom IN ('math', 'Informatique', 'Histoire', 'Cuisine', 'Roman'));


--PARTIE 2 : AJOUT DES RÈGLES MÉTIER VIA DES TRIGGERS
CREATE TRIGGER max_3_emprunts
BEFORE INSERT ON emprunt
FOR EACH ROW
BEGIN
    DECLARE nb_emprunts INT;
    SELECT COUNT(*)
    INTO nb_emprunts
    FROM emprunt
    WHERE lecteur_id = NEW.lecteur_id
      AND date_retour_effective IS NULL;

    IF nb_emprunts >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'errore : lecture cant take more than 3 ovrage';
    END IF;
END;




CREATE TRIGGER  ouvrage_allready_emprunte
BEFORE INSERT ON emprunts
FOR EACH ROW 
BEGIN
  DECLARE deja_emprunte INT;
  SELECT COUNT(*) INTO allready_emprunte
  FROM emprunts
  WHERE id_ouvrage = NEW.id_ouvrage
    AND date_retour_reelle IS NULL;

  IF deja_emprunte > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'error : this ouvrage is allready emprute';
  END IF;
END;




CREATE TRIGGER check_return_date
BEFORE UPDATE ON emprunt
FOR EACH ROW
BEGIN
    IF NEW.date_retour_effective IS NOT NULL
       AND NEW.date_retour_effective < OLD.date_emprunt THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You cant return the book before empronte';
    END IF;
END;

CREATE TRIGGER prevent_delete_borrowed_book
BEFORE DELETE ON ouvrage
FOR EACH ROW
BEGIN
    DECLARE nb INT;
    SELECT COUNT(*) INTO nb
    FROM emprunt
    WHERE ouvrage_id = OLD.ouvrage_id
      AND date_retour_effective IS NULL;
    IF nb > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur: impossible de supprimer un ouvrage actuellement emprunté.';
    END IF;
END;



CREATE TRIGGER prevent_delete_historical_book
BEFORE DELETE ON ouvrage
FOR EACH ROW
BEGIN
    DECLARE nb INT;
    SELECT COUNT(*) INTO nb
    FROM emprunt
    WHERE ouvrage_id = OLD.ouvrage_id;
    IF nb > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur: impossible de supprimer un ouvrage lié à un historique d’emprunts.';
    END IF;
END;



--PARTIE 3 : REPORTING – REQUÊTES SELECT AVANCÉES

SELECT o.titre, COUNT(e.emprunt_id) AS nb_emprunts
FROM emprunt e
JOIN ouvrage o ON e.ouvrage_id = o.ouvrage_id
GROUP BY o.ouvrage_id, o.titre
ORDER BY nb_emprunts DESC
LIMIT 5;


SELECT l.nom, l.prenom, COUNT(e.emprunt_id) AS nb_emprunts
FROM lecteur l
JOIN emprunt e ON l.lecteur_id = e.lecteur_id
GROUP BY l.lecteur_id, l.nom, l.prenom
HAVING COUNT(e.emprunt_id) > 3;


SELECT r.nom AS rayon, COUNT(e.emprunt_id) AS nb_emprunts
FROM rayon r
JOIN ouvrage o ON r.rayon_id = o.rayon_id
JOIN emprunt e ON o.ouvrage_id = e.ouvrage_id
GROUP BY r.rayon_id, r.nom
ORDER BY nb_emprunts DESC;


SELECT AVG(DATEDIFF(e.date_retour_effective, e.date_emprunt)) AS duree_moyenne_jours
FROM emprunt e
WHERE e.date_retour_effective IS NOT NULL;


SELECT 
    DATE_FORMAT(e.date_emprunt, '%Y-%m') AS mois,
    COUNT(e.emprunt_id) AS nb_emprunts
FROM emprunt e
GROUP BY mois
ORDER BY mois;


SELECT a.nom, COUNT(e.emprunt_id) AS nb_emprunts
FROM auteur a
JOIN ouvrage o ON a.auteur_id = o.auteur_id
JOIN emprunt e ON o.ouvrage_id = e.ouvrage_id
GROUP BY a.auteur_id, a.nom
ORDER BY nb_emprunts DESC
LIMIT 1;
