-- DB Prep Begins --
use employees;

# if you don’t currently have ‘departments_dup’ set up
DROP TABLE IF EXISTS departments_dup;
CREATE TABLE departments_dup (
    dept_no CHAR(4) NULL,
    dept_name VARCHAR(40) NULL
); 

INSERT INTO departments_dup
(
    dept_no,
    dept_name
)SELECT * FROM departments;

INSERT INTO departments_dup (dept_name) VALUES ('Public Relations');

SET SQL_SAFE_UPDATES = 0;

DELETE FROM departments_dup 
WHERE
    dept_no = 'd002'; 

INSERT INTO departments_dup(dept_no) VALUES ('d010'), ('d011');

DROP TABLE IF EXISTS dept_manager_dup;
CREATE TABLE dept_manager_dup (
    emp_no INT(11) NOT NULL,
    dept_no CHAR(4) NULL,
    from_date DATE NOT NULL,
    to_date DATE NULL
);

INSERT INTO dept_manager_dup
select * from dept_manager;

INSERT INTO dept_manager_dup (emp_no, from_date) VALUES (999904, '2017-01-01'), (999905, '2017-01-01'), (999906, '2017-01-01'), (999907, '2017-01-01');

DELETE FROM dept_manager_dup 
WHERE
    dept_no = 'd001';
    
SET SQL_SAFE_UPDATES = 1;
-- DB Prep Ends --

-- Join Queries Begin--
# 1. Extract a list containing information about all managers’ employee number, first and last name, department number, and hire date. 
SELECT 
    dm.emp_no,
    e.first_name,
    e.last_name,
    dm.dept_no,
    e.hire_date
FROM
    dept_manager dm
        JOIN
    employees e ON e.emp_no = dm.emp_no;
    
# 2. Join the 'employees' and the 'dept_manager' tables to return a subset of all the employees whose last name is Markovitch. 
#    See if the output contains a manager with that name.  

SELECT 
    e.first_name, e.last_name, dm.dept_no, dm.from_date
FROM
    employees e
        LEFT JOIN
    dept_manager dm ON dm.emp_no = e.emp_no
WHERE
    e.last_name = 'Markovitch'
ORDER BY dm.dept_no DESC , e.emp_no;

# 3. Select the first and last name, the hire date, and the job title of all employees whose first name is “Margareta” and have the last name “Markovitch”.
select e.first_name, e.last_name, e.hire_date, t.title
from employees e
join titles t on t.emp_no = e.emp_no
where e.first_name = 'Margareta' and e.last_name = 'Markovitch';

#4. Use a CROSS JOIN to return a list with all possible combinations between managers from the dept_manager table and department number 9.
SELECT 
    *
FROM
    departments d
        CROSS JOIN
    dept_manager dm
WHERE
    d.dept_no = 'd009'
order by dm.dept_no;

# 5. Return a list with the first 10 employees with all the departments they can be assigned to.
SELECT 
    *
FROM
    employees e
        CROSS JOIN
    departments d
WHERE
    e.emp_no < 10011
ORDER BY e.emp_no, d.dept_no; 

# 6. Select all managers’ first and last name, hire date, job title, start date, and department name.
SELECT 
    e.first_name,
    e.last_name,
    e.hire_date,
    t.title,
    m.from_date,
    d.dept_name
FROM
    dept_manager m
        JOIN
    employees e ON e.emp_no = m.emp_no
        JOIN
    departments d ON d.dept_no = m.dept_no
        JOIN
    titles t ON t.emp_no = e.emp_no and t.title = 'Manager'
ORDER BY d.dept_no , e.emp_no;

# 7. Determine what the '-' signifies ()
SELECT 
    *
FROM
    (SELECT 
        e.emp_no,
            e.first_name,
            e.last_name,
            NULL AS dept_no,
            NULL AS from_date
    FROM
        employees e
    WHERE
        last_name = 'Denis' UNION SELECT 
        NULL AS emp_no,
            NULL AS first_name,
            NULL AS last_name,
            dm.dept_no,
            dm.from_date
    FROM
        dept_manager dm) AS a
ORDER BY - a.emp_no DESC;
-- Join Queries End --


set @@global.sql_mode := replace(@@global.sql_mode, 'ONLY_FULL_GROUP_BY', '');



