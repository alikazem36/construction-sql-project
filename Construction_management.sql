-- Construction Management Database Schema
-- Create Tables

CREATE TABLE Projects (
    project_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(15,2)
);

select * from Projects;

CREATE TABLE Employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(100),
    salary DECIMAL(10,2),
    project_id INT REFERENCES Projects(project_id)
);

CREATE TABLE Contractors (
    contractor_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255),
    project_id INT REFERENCES Projects(project_id)
);

CREATE TABLE Materials (
    material_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    cost DECIMAL(10,2),
    project_id INT REFERENCES Projects(project_id)
);

CREATE TABLE Tasks (
    task_id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    status VARCHAR(50),
    assigned_to INT REFERENCES Employees(employee_id),
    project_id INT REFERENCES Projects(project_id)
);

ALTER TABLE Projects ADD CONSTRAINT chk_budget CHECK (budget >= 0);

-- Aggregate queries
SELECT project_id, SUM(salary) AS total_salary FROM Employees GROUP BY project_id;
SELECT project_id, COUNT(*) AS total_tasks FROM Tasks WHERE status = 'Completed' GROUP BY project_id;

-- Subquery Example
SELECT name FROM Employees WHERE employee_id IN (
    SELECT assigned_to FROM Tasks WHERE status = 'Pending'
);

-- Stored Procedure to Calculate Total Cost of a Project
DELIMITER $$
CREATE PROCEDURE calculate_total_cost(IN p_id INT, OUT total DECIMAL(15,2))
BEGIN
    SELECT SUM(cost) INTO total FROM Materials WHERE project_id = p_id;
END $$
DELIMITER ;

CREATE INDEX idx_project_id ON Employees(project_id);

-- View for Project Summary
CREATE VIEW ProjectSummary AS
SELECT p.project_id, p.name, p.budget, COUNT(e.employee_id) AS total_employees
FROM Projects p
LEFT JOIN Employees e ON p.project_id = e.project_id
GROUP BY p.project_id;

-- Role-based Access Control
CREATE ROLE site_manager;
GRANT SELECT, INSERT, UPDATE ON Employees TO site_manager;
GRANT SELECT ON Projects TO site_manager;

-- Performance Optimization Example
EXPLAIN ANALYZE SELECT * FROM Employees WHERE salary > 50000;






