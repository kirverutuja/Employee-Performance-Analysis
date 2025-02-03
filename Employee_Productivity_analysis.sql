-- Step 1: Create Database
CREATE DATABASE EmployeeProductivityDB;
USE EmployeeProductivityDB;

-- Step 2: Create Tables

-- Employees Table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    department VARCHAR(50),
    hire_date DATE
);

-- Projects Table
CREATE TABLE projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(100),
    start_date DATE,
    end_date DATE
);

-- Tasks Table
CREATE TABLE tasks (
    task_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT,
    employee_id INT,
    task_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Attendance Table
CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    date DATE,
    status VARCHAR(10), -- Present or Absent
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Step 3: Insert Sample Data

-- Employees
DELIMITER $$
CREATE PROCEDURE InsertEmployees()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 1000 DO
        INSERT INTO employees (name, department, hire_date) VALUES 
        (CONCAT('Employee ', i), ELT(FLOOR(1 + (RAND() * 4)), 'Marketing', 'IT', 'HR', 'Finance'), DATE_ADD('2018-01-01', INTERVAL FLOOR(RAND() * 2000) DAY));
        SET i = i + 1;
    END WHILE;
END $$
DELIMITER ;

CALL InsertEmployees();

-- Projects
INSERT INTO projects (project_name, start_date, end_date) VALUES
('Website Redesign', '2023-01-01', '2023-06-30'),
('Employee Onboarding System', '2023-02-15', '2023-08-15');

-- Tasks
DELIMITER $$
CREATE PROCEDURE InsertTasks()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 5000 DO
        INSERT INTO tasks (project_id, employee_id, task_name, start_date, end_date, status) VALUES 
        (ELT(FLOOR(1 + (RAND() * 2)), 1, 2), FLOOR(1 + (RAND() * 1000)), CONCAT('Task ', i), DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 180) DAY), DATE_ADD('2023-07-01', INTERVAL FLOOR(RAND() * 180) DAY), ELT(FLOOR(1 + (RAND() * 2)), 'Completed', 'In Progress'));
        SET i = i + 1;
    END WHILE;
END $$
DELIMITER ;

CALL InsertTasks();

-- Attendance
DELIMITER $$
CREATE PROCEDURE InsertAttendance()
BEGIN
    DECLARE emp_id INT DEFAULT 1;
    DECLARE d DATE;
    SET d = '2023-01-01';
    WHILE emp_id <= 1000 DO
        WHILE d <= '2023-12-31' DO
            INSERT INTO attendance (employee_id, date, status) VALUES 
            (emp_id, d, ELT(FLOOR(1 + (RAND() * 2)), 'Present', 'Absent'));
            SET d = DATE_ADD(d, INTERVAL 1 DAY);
        END WHILE;
        SET emp_id = emp_id + 1;
        SET d = '2023-01-01';
    END WHILE;
END $$
DELIMITER ;

CALL InsertAttendance();

-- Step 4: Key Performance Queries

-- 1. Task Completion Rate Per Employee
SELECT 
    e.name AS Employee,
    COUNT(t.task_id) AS Total_Tasks,
    SUM(CASE WHEN t.status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Tasks,
    ROUND((SUM(CASE WHEN t.status = 'Completed' THEN 1 ELSE 0 END) / COUNT(t.task_id)) * 100, 2) AS Completion_Rate
FROM employees e
LEFT JOIN tasks t ON e.employee_id = t.employee_id
GROUP BY e.name;

-- 2. Attendance Impact on Productivity
SELECT 
    e.name AS Employee,
    COUNT(a.attendance_id) AS Total_Days,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS Days_Present,
    ROUND((SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) / COUNT(a.attendance_id)) * 100, 2) AS Attendance_Rate
FROM employees e
LEFT JOIN attendance a ON e.employee_id = a.employee_id
GROUP BY e.name;

-- 3. Productivity Gaps: Employees with Low Completion Rates
SELECT 
    e.name AS Employee,
    ROUND((SUM(CASE WHEN t.status = 'Completed' THEN 1 ELSE 0 END) / COUNT(t.task_id)) * 100, 2) AS Completion_Rate
FROM employees e
LEFT JOIN tasks t ON e.employee_id = t.employee_id
GROUP BY e.name
HAVING Completion_Rate < 70; -- Identify employees below 70% completion rate
