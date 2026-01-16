CREATE DATABASE libraryR;
USE libraryR;

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
   date_emprunt DATE NOT NULL DEFAULT (CURRENT_DATE),
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

-- Insertion dans RAYON
INSERT INTO rayon (nom) VALUES 
('Informatique'), 
('Science-Fiction'), 
('Développement Personnel');

-- Insertion dans AUTEUR
INSERT INTO auteur (nom, prenom) VALUES 
('Martin', 'Robert'), 
('Herbert', 'Frank'), 
('Clear', 'James');

INSERT INTO rayon (nom) VALUES ('Histoire'), ('Littérature Classique'), ('Poésie');

INSERT INTO auteur (nom, prenom) VALUES 
('Hugo', 'Victor'), 
('Asimov', 'Isaac'), 
('Orwell', 'George'),
('Zola', 'Émile');

-- Ajout d'ouvrages
select * from ouvrage;
INSERT INTO ouvrage (titre, annee_publication, rayon_id) VALUES 
('1984', 1949, 2),
('Les Misérables', 1962, 5),
('Le Cycle de Fondation', 1951, 2),
('Data Science pour tous', 2023, 1);

-- Association Ouvrage/Auteur (Cas de co-auteurs)
-- Imaginons que 'Data Science pour tous' (ID 7) soit écrit par James Clear (ID 3) et Robert Martin (ID 1)
INSERT INTO ouvrage_auteur (ouvrage_id, auteur_id) VALUES (7, 1), (7, 3);

-- Association classique pour les autres
INSERT INTO ouvrage_auteur (ouvrage_id, auteur_id) VALUES (4, 6), (5, 4), (6, 5);



INSERT INTO lecteur (nom, prenom, email, tel, cin) VALUES 
('Tazi', 'Kenza', 'kenza@email.com', '0622334455', 'JK99887'), -- Lectrice active
('Mansouri', 'Omar', 'omar@email.com', '0655667788', 'LM11223'), -- Lecteur fantôme (aucun emprunt)
('Bennani', 'Sami', 'sami@email.com', '0644332211', 'ZZ55667'); -- Lecteur avec retard





INSERT INTO emprunt (date_emprunt, date_retour_prevue, date_retour_effective, lecteur_id, ouvrage_id) 
VALUES ('2025-12-01', '2025-12-15', '2025-12-14', 1, 3);

-- Rendu en retard
INSERT INTO emprunt (date_emprunt, date_retour_prevue, date_retour_effective, lecteur_id, ouvrage_id) 
VALUES ('2025-11-20', '2025-12-04', '2025-12-10', 4, 4);

--  En cours (dans les délais)
INSERT INTO emprunt (date_emprunt, date_retour_prevue, date_retour_effective, lecteur_id, ouvrage_id) 
VALUES (CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY), NULL, 3, 5);

--  EN RETARD (Toujours pas rendu)
INSERT INTO emprunt (date_emprunt, date_retour_prevue, date_retour_effective, lecteur_id, ouvrage_id) 
VALUES ('2025-12-20', '2026-01-03', NULL, 6, 6);

-- Insertion dans LECTEUR
INSERT INTO lecteur (nom, prenom, email, tel, cin) VALUES 
('Alaoui', 'Ahmed', 'ahmed@email.com', '0601020304', 'AB12345'),
('Dupont', 'Marie', 'marie@email.com', '0611223344', 'CD67890');
INSERT INTO lecteur (nom, prenom, email, tel, cin) VALUES 
('Asaas', 'soukaina', 'Soukaina@email.com', '0897643', 'AB2345');

-- Insertion dans OUVRAGE (Lié au rayon_id)
INSERT INTO ouvrage (titre, annee_publication, rayon_id) VALUES 
('Clean Code', 2008, 1),      -- 1 = Informatique
('Dune', 1965, 2),            -- 2 = Science-Fiction
('Atomic Habits', 2018, 3);   -- 3 = Dév Personnel


INSERT IGNORE INTO ouvrage_auteur (ouvrage_id, auteur_id) VALUES (1, 1), (2, 2), (3, 3), (4, 1);
select * from ouvrage_auteur;
-- Insertion dans EMPRUNT (Lecteur 1 emprunte l'ouvrage 1)
INSERT INTO emprunt (date_emprunt, date_retour_prevue, lecteur_id, ouvrage_id) VALUES 
('2026-01-05', '2026-01-19', 1, 1),('2026-02-05', '2028-01-19', 2, 2);
INSERT INTO emprunt (date_emprunt, date_retour_prevue, lecteur_id, ouvrage_id) VALUES 
('2026-02-05', '2028-01-19', 2, 2);

-- Insertion dans PERSONNEL (Gestion de la hiérarchie)
-- On crée d'abord le chef (chef_id est NULL)
INSERT INTO personnel (nom, email, tel, mot_de_passe, chef_id) VALUES 
('Admin Principal', 'admin@library.com', '0522001122', 'hash_mdp_123', NULL);

-- On crée un employé dont le chef est l'ID 1
INSERT INTO personnel (nom, email, tel, mot_de_passe, chef_id) VALUES 
('Agent Accueil', 'accueil@library.com', '0522445566', 'hash_mdp_456', 1);

 


select * from lecteur;
ALTER TABLE lecteur
ADD CONSTRAINT email_unique UNIQUE (email);
select * from personnel;
ALTER TABLE personnel
ADD cin VARCHAR(10)  unique;

alter table ouvrage
add constraint uq_ouvrage unique (titre,annee_publication);

alter table auteur
add constraint uq_auteur unique (nom,prenom);

ALTER TABLE ouvrage
ADD CONSTRAINT chk_annee 
CHECK (annee_publication between 1900 and 2026);

UPDATE lecteur 
SET tel = '0689764300' 
WHERE CHAR_LENGTH(tel) < 10;

ALTER TABLE lecteur 
ADD CONSTRAINT chk_tel_longueur 
CHECK (CHAR_LENGTH(tel) >= 10);

ALTER TABLE personnel
ADD CONSTRAINT chk_per_longueur 
CHECK (CHAR_LENGTH(tel) >= 10);


UPDATE emprunt
SET date_emprunt = '2026-01-08' 
WHERE date_emprunt > curdate();
-- probleme
ALTER TABLE emprunt
ADD CONSTRAINT chk_emprunt
CHECK (date_emprunt <= curdate());

UPDATE emprunt 
SET date_retour_prevue = DATE_ADD(date_emprunt, INTERVAL 30 DAY)
WHERE DATEDIFF(date_retour_prevue, date_emprunt) > 30;


ALTER TABLE emprunt
ADD CONSTRAINT chk_duree_emprunt
CHECK (DATEDIFF(date_retour_prevue, date_emprunt) <= 30);


ALTER TABLE rayon
ADD CONSTRAINT chk_nom_rayon
CHECK (nom IN ('Science-Fiction','Informatique', 'Littérature Classique', 'Développement Personnel', 'Histoire', 'Poésie'));



DELIMITER //

CREATE TRIGGER TrgMaxEmprunt 
BEFORE INSERT ON emprunt
FOR EACH ROW
BEGIN
    DECLARE total INT;

    -- Correction : Ajout du point (.) après NEW
    SELECT COUNT(*) INTO total
    FROM emprunt
    WHERE lecteur_id = NEW.lecteur_id 
    AND date_retour_effective IS NULL;

    -- Correction : Utilisation de MESSAGE_TEXT au lieu de MESSAGE
    IF total >= 3 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : Ce lecteur a déjà 3 emprunts en cours !';
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER interdit 
BEFORE INSERT ON emprunt 
FOR EACH ROW 
BEGIN   
    DECLARE disponibilite INT;

  
    SELECT COUNT(*) INTO disponibilite
    FROM emprunt
    WHERE ouvrage_id = NEW.ouvrage_id 
    AND date_retour_effective IS NULL;

    
    IF disponibilite > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : Cet ouvrage n''est pas disponible (déjà emprunté).';
    END IF;
END //

DELIMITER ;


DELIMITER //

create trigger  miseajour
before update on Emprunt
FOR EACH ROW
begin
IF NEW.date_retour_effective IS NOT NULL 
       AND NEW.date_retour_effective < NEW.date_emprunt THEN
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : La date de retour effective ne peut pas être avant la date d''emprunt.';
        
    END IF;

END //
DELIMITER ;



DELIMITER //

create trigger  Interdet_Suprimer
BEFORE DELETE on ouvrage
FOR EACH ROW
BEGIN
    DECLARE nb_emprunts_en_cours INT;

    SELECT COUNT(*) INTO nb_emprunts_en_cours
    FROM emprunt
    WHERE ouvrage_id = OLD.ouvrage_id 
      AND date_retour_effective IS NULL;

    
    IF nb_emprunts_en_cours > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'interdite : Cet ouvrage est actuellement emprunté et doit être rendu avant suppression.';
    END IF;
END //																																																												
DELIMITER ;





DELIMITER //

CREATE TRIGGER bloquer_suppression_ouvrage
BEFORE DELETE ON ouvrage
FOR EACH ROW
BEGIN
    DECLARE nb_emprunts INT;

  
    SELECT COUNT(*) INTO nb_emprunts
    FROM emprunt
    WHERE ouvrage_id = OLD.ouvrage_id;

    
    IF nb_emprunts > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossible de supprimer .';
    END IF;
END //

DELIMITER ;
                                                           
show triggers;

select o.titre,count(*) as nombreEmprunt from ouvrage o join Emprunt e on o.ouvrage_id=e.ouvrage_id
group by o.titre  ORDER BY o.titre DESC LIMIT 5;

select l.nom from Emprunt e join lecteur l on e.lecteur_id=l.lecteur_id 
group by l.nom having count(*) >1;

select nom , count(*) as totale from rayon r join ouvrage o on r.rayon_id=o.rayon_id
join Emprunt e on o.ouvrage_id=e.ouvrage_id
group by r.nom order by totale desc;

select avg(DATEDIFF(date_retour_effective, date_emprunt)) from Emprunt where date_retour_effective is not null;

-- fin 
SELECT nom, COUNT(*) as totale from auteur GROUP BY nom ORDER BY totale asc LIMIT 1;


SELECT MONTH(date_emprunt) AS mois, 
       YEAR(date_emprunt) AS annee, 
       COUNT(*) AS total
FROM emprunt
GROUP BY annee, mois
ORDER BY annee DESC, mois DESC;


 


select * from rayon;

select * from ouvrage ;
select * from personnel;
select * from emprunt;
select * from lecteur;
select * from auteur;