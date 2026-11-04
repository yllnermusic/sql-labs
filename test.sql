CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    programme VARCHAR(100)
);


INSERT INTO students (name, programme)
VALUES ('Anna', 'Interaktion och design');


SELECT *
FROM students;


UPDATE students
SET programme = 'Datavetenskap'
WHERE name = 'Anna';

SELECT *
FROM students;

DELETE FROM students
WHERE name = 'Anna';

DROP TABLE students;




SELECT product_id, product_name, unit_price
FROM products
ORDER BY product_name
LIMIT 10;

SELECT products.product_name, categories.category_name
FROM products
JOIN categories ON products.category_id = categories.category_id
ORDER BY products.product_name;