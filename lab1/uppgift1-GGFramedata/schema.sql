--CREATE DATABASE ggxxacr_framedata;

Create TABLE characters (
    
    character_id SERIAL PRIMARY KEY,
    character_name VARCHAR(100) NOT NULL,
    abbreviation CHAR(2) NOT NULL UNIQUE
); 

--VALUES 

insert INTO characters (character_name, abbreviation)
VALUES ('Sol Badguy', 'SO'),
       ('Ky Kiske', 'KY');

--======================================================================


Create Table move_levels (
    level int PRIMARY KEY CHECK (level >= 1 AND level <= 5),
    hitstun INT NOT NULL,
    blockstun INT NOT NULL
);

-- VALUES

INSERT INTO move_levels (level, hitstun, blockstun)
VALUES (1, 9, 10),
       (2, 11, 12),
       (3, 13, 14),
       (4, 16, 17),
       (5, 18, 19);



select * from move_levels;

-- Hitstun and blockstun values seems to be switched. Correcting them to match the actual game data.

Update move_levels set hitstun = blockstun, blockstun = hitstun;

--======================================================================
Create Table moves (
    move_id SERIAL PRIMARY KEY,
    move_name VARCHAR(100) NOT NULL,
    character_id INT NOT NULL REFERENCES characters(character_id),
    move_version varCHAR(10) NOT NULL,
    damage int NOT NULL,
    guard varchar(20) not null,
    startup int not null,
    active int not null,
    recovery int not null,
    on_block int not null,
    move_level int not null,
    invuln varchar(20) not null

);

-- REMOVING "GUARD" since it got its own table with guard types and move guard types

ALTER TABLE moves DROP COLUMN guard;

-- MAKING MOVE_LEVEL A FOREIGN KEY TO MOVE_LEVELS TABLE

ALTER TABLE moves
ADD CONSTRAINT moves_move_level_fkey FOREIGN KEY (move_level) REFERENCES move_levels(level);


-- Changing "damage" column to VARCHAR to accommodate values like '14x2' because direct damage comparisons isnt always possible with moves that have multiple hits or special damage calculations.

ALTER TABLE moves
ALTER COLUMN damage TYPE VARCHAR(20);

-- Changing active to VARCHAR to accommodate values like '2,6' for moves that have multiple active frames.
ALTER TABLE moves
ALTER COLUMN active TYPE VARCHAR(20);

-- recovery has to be text too, because of multiple recovery frames and special cases like "5+11 after landing" for certain moves.
ALTER TABLE moves ALTER COLUMN recovery TYPE VARCHAR(20);

-- VALUES
-- ============================================
-- 5p and 5k – Sol
-- ============================================
insert INTO moves (move_name, character_id, move_version, damage, startup, active, recovery, on_block, move_level, invuln)
VALUES ('5P', '1', '5p', 10, 4, 4, 6, 0, 1, 'None');


insert INTO moves (move_name, character_id, move_version, damage, startup, active, recovery, on_block, move_level, invuln)
VALUES       ('5k', '1', '5k', '14x2', 3,'2,6', 13, -7, 2, 'None');



-- ============================================
-- 5k and greed sever – Ky
-- ============================================

INSERT INTO moves (move_name, character_id, move_version, damage, startup, active, recovery, on_block, move_level, invuln)
VALUES
    ('5K',
     (SELECT character_id FROM characters WHERE abbreviation = 'KY'),
     '5K', '12', 5, '8', '7', -5, 1, 'None'),

    ('Greed Sever',
     (SELECT character_id FROM characters WHERE abbreviation = 'KY'),
     '214K', '30', 18, '15', '5+11 after landing', -14, 4, '4~17F Feet');

-- ============================================
-- 5H – Ky and Sol
-- ============================================
INSERT INTO moves (move_name, character_id, move_version, damage, startup, active, recovery, on_block, move_level, invuln)
VALUES
    ('5H',
     (SELECT character_id FROM characters WHERE abbreviation = 'KY'),
     '5H', '32', 10, '6', '12', 1, 5, 'None'),

    ('5H',
     (SELECT character_id FROM characters WHERE abbreviation = 'SO'),
     '5H', '40', 21, '2', '26', -9, 5, 'None');

-- UPDATES

-- Wrong damage number on ky 5h

UPDATE moves
SET damage = '42'
WHERE move_id = 7;

-- Wrong startup number on sol 5h

UPDATE moves
SET startup = 11    
WHERE move_id = 8;


SELECT move_id, move_name, damage FROM moves WHERE move_id = 7;

SELECT move_id, move_name, startup FROM moves WHERE move_id = 8;

-- DELETING THE DUPLICATE 5H MOVE FOR SOL and ky

DELETE FROM moves
WHERE move_id IN (9, 10);





--==========================================================================
Create Table guard_types (
    guard_type_id SERIAL PRIMARY KEY,
    guard_type_name VARCHAR(20) NOT NULL UNIQUE
);

-- VALUES 

INSERT INTO guard_types (guard_type_name)
VALUES ('High'),
       ('Mid'),
       ('Low'),
       ('Overhead'),
       ('Throw'),
       ('Unblockable');


Create Table move_guard_types (
    move_id INT NOT NULL REFERENCES moves(move_id),
    guard_type_id INT NOT NULL REFERENCES guard_types(guard_type_id),
    PRIMARY KEY (move_id, guard_type_id)
);


-- VALUES
Insert INTO move_guard_types (move_id, guard_type_id)
VALUES (1, 2); -- as move_id 1 corresponds to '5P' and guard_type_id 2 corresponds to 'Mid'

Insert INTO move_guard_types (move_id, guard_type_id)
VALUES (2, 2); -- as move_id 2 corresponds to '5k' and guard_type_id 2 corresponds to 'Mid' 

Insert INTO move_guard_types (move_id, guard_type_id)
VALUES (3, 3); -- as move_id 3 corresponds to '5k' and guard_type_id 3 corresponds to 'Low'

Insert INTO move_guard_types (move_id, guard_type_id)
VALUES (4, 1); -- as move_id 4 corresponds to 'GREEDSEVER' and guard_type_id 1 corresponds to 'High'

INSERT INTO move_guard_types (move_id, guard_type_id)
VALUES (7, 2); -- as move_id 5 corresponds to '5H' and guard_type_id 2 corresponds to 'Mid'

INSERT INTO move_guard_types (move_id, guard_type_id)
VALUES (8, 2); -- as move_id 6 corresponds to '5H' and guard_type_id 2 corresponds to 'Mid'

-- TESTING

SELECT move_id, move_name, character_id FROM moves ORDER BY move_id;

--REMOVING 5h DOUBLES IN MOVES ID 9 and 10 (check row 118) AND CORRECTING the insert values to 7 and 8 for move_guard_types

SELECT moves.move_id,
       characters.character_name,
       moves.move_name,
       guard_types.guard_type_name
FROM move_guard_types
JOIN moves ON move_guard_types.move_id = moves.move_id
JOIN characters ON moves.character_id = characters.character_id
JOIN guard_types ON move_guard_types.guard_type_id = guard_types.guard_type_id
ORDER BY moves.move_id;

--GOOD



--==========================================================================
Create TABLE properties (
    
    property_id SERIAL PRIMARY KEY,
    property_name VARCHAR(30) NOT NULL UNIQUE
);

Create Table move_properties (
    move_id INT NOT NULL REFERENCES moves(move_id),
    property_id INT NOT NULL REFERENCES properties(property_id),
    PRIMARY KEY (move_id, property_id)
);

-- VALUES

INSERT INTO properties (property_name) VALUES ('Ground Bounce');

INSERT INTO move_properties (move_id, property_id)
VALUES (
    (SELECT move_id FROM moves WHERE move_name = 'Greed Sever'),
    (SELECT property_id FROM properties WHERE property_name = 'Ground Bounce')
);


--==========================================================================





-- TESTS/CHECKS


Select * from move_levels;



--==========================================================================

SELECT characters.character_name,
       moves.*,
       move_levels.blockstun,
       move_levels.hitstun,
       guard_types.guard_type_name
FROM moves
JOIN characters ON moves.character_id = characters.character_id
JOIN move_levels ON moves.move_level = move_levels.level
LEFT JOIN move_guard_types ON moves.move_id = move_guard_types.move_id
LEFT JOIN guard_types ON move_guard_types.guard_type_id = guard_types.guard_type_id
WHERE moves.move_name = 'Greed Sever';

--=====================================================================================


SELECT moves.move_name, properties.property_name
FROM moves
JOIN move_properties ON moves.move_id = move_properties.move_id
JOIN properties ON move_properties.property_id = properties.property_id;



--=====================================================================================
