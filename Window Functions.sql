use employees;

# 1. Write a query that upon execution, assigns a row number to all managers we have information for in the "employees" database (regardless of their department).
#    Let the numbering disregard the department the managers have worked in. Also, let it start from the value of 1. Assign that value to the manager with the lowest 
#    employee number.

SELECT 
	emp_no, 
    dept_no, 
    ROW_NUMBER() OVER (ORDER BY emp_no) AS num
FROM
    dept_manager;
    
# 2. Write a query that upon execution, assigns a sequential number for each employee number registered in the "employees" table. 
#    Partition the data by the employee's first name and order it by their last name in ascending order (for each partition).
SELECT 
    emp_no, first_name, last_name, ROW_NUMBER() OVER (PARTITION BY first_name ORDER BY last_name)
FROM
    employees;
    
/* Exercise #1:

Obtain a result set containing the salary values each manager has signed a contract for. To obtain the data, refer to the "employees" database.

Use window functions to add the following two columns to the final output:

- a column containing the row number of each row from the obtained dataset, starting from 1.

- a column containing the sequential row numbers associated to the rows for each manager, where their highest salary has been given a number 
equal to the number of rows in the given partition, and their lowest - the number 1.

Finally, while presenting the output, make sure that the data has been ordered by the values in the first of the row number columns, 
and then by the salary values for each partition in ascending order. */

select dm.emp_no, 
	s.salary, 
    row_number() over(partition by dm.emp_no order by s.salary) as row_1,
	row_number() over(partition by dm.emp_no order by s.salary desc) as row_2
from 
	dept_manager dm
join salaries s on s.emp_no = dm.emp_no
order by dm.emp_no, row_1;

/* Write a query that provides row numbers for all workers from the "employees" table, partitioning the data by their first names 
   and ordering each partition by their employee number in ascending order. */
   
SELECT 
    ROW_NUMBER() OVER win AS row_num,
    emp_no,
    first_name
FROM
    employees
WINDOW win AS (PARTITION BY first_name ORDER BY emp_no);

/*
Exercise #1:
Find out the lowest salary value each employee has ever signed a contract for. 
To obtain the desired output, use a subquery containing a window function, as well as a window specification introduced with the help of the WINDOW keyword.
*/
SELECT a.emp_no,
       MIN(salary) AS min_salary FROM (
SELECT
emp_no, salary, ROW_NUMBER() OVER w AS row_num
FROM
salaries
WINDOW w AS (PARTITION BY emp_no ORDER BY salary)) a
GROUP BY emp_no;

/*
Exercise #2:
Again, find out the lowest salary value each employee has ever signed a contract for. 
Once again, to obtain the desired output, use a subquery containing a window function. 
This time, however, introduce the window specification in the field list of the given subquery.
To obtain the desired result set, refer only to data from the “salaries” table.
*/
SELECT a.emp_no,
       MIN(salary) AS min_salary FROM (
SELECT
emp_no, salary, ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salary) AS row_num
FROM
salaries) a
GROUP BY emp_no;

/*
Exercise #3:
Once again, find out the lowest salary value each employee has ever signed a contract for. 
This time, to obtain the desired output, avoid using a window function. Just use an aggregate function and a subquery.
To obtain the desired result set, refer only to data from the “salaries” table.
*/
SELECT 
    a.emp_no, MIN(salary) AS min_salary
FROM
    (SELECT 
        emp_no, salary
    FROM
        salaries) a
GROUP BY emp_no;

/*
Exercise #4:
Once more, find out the lowest salary value each employee has ever signed a contract for. 
To obtain the desired output, use a subquery containing a window function, as well as a window specification introduced with the help of the WINDOW keyword. 
Moreover, obtain the output without using a GROUP BY clause in the outer query.
To obtain the desired result set, refer only to data from the “salaries” table.
*/
SELECT 
	a.emp_no, a.salary FROM (
    select 
		emp_no, salary, ROW_NUMBER() OVER w as row_num
	from salaries
	WINDOW w AS (partition by emp_no order by salary)
    ) a
WHERE a.row_num = 1;

/*
Exercise #5:
Find out the second-lowest salary value each employee has ever signed a contract for. 
To obtain the desired output, use a subquery containing a window function, as well as a window specification introduced with the help of the WINDOW keyword. 
Moreover, obtain the desired result set without using a GROUP BY clause in the outer query.
To obtain the desired result set, refer only to data from the “salaries” table.
*/
SELECT 
	a.emp_no, a.salary FROM (
    select 
		emp_no, salary, ROW_NUMBER() OVER w as row_num
	from salaries
	WINDOW w AS (partition by emp_no order by salary)
    ) a
WHERE a.row_num = 2;
        
/*
Exercise #1:
Write a query containing a window function to obtain all salary values that employee number 10560 has ever signed a contract for.
Order and display the obtained salary values from highest to lowest.
*/
SELECT 
	ROW_NUMBER() OVER w AS row_num, 
    emp_no, 
    salary
FROM salaries
	WHERE emp_no = 10560
WINDOW W as (PARTITION BY emp_no ORDER BY salary);

/*
Exercise #2:
Write a query that upon execution, displays the number of salary contracts that each manager has ever signed while working in the company.
*/
SELECT 
    d.emp_no, COUNT(s.salary) AS no_of_salary_contracts
FROM
    dept_manager d
        JOIN
    salaries s ON s.emp_no = d.emp_no
GROUP BY d.emp_no
ORDER BY d.emp_no;


/*
Exercise #3:
Write a query that upon execution retrieves a result set containing all salary values that employee 10560 has ever signed a contract for. 
Use a window function to rank all salary values from highest to lowest in a way that equal salary values bear the same rank and that gaps 
in the obtained ranks for subsequent rows are allowed.
*/
SELECT 
	RANK() OVER w AS row_num, 
    emp_no, 
    salary
FROM salaries
	WHERE emp_no = 10560
WINDOW W as (PARTITION BY emp_no ORDER BY salary DESC);

/*
Exercise #4:
Write a query that upon execution retrieves a result set containing all salary values that employee 10560 has ever signed a contract for. 
Use a window function to rank all salary values from highest to lowest in a way that equal salary values bear the same rank and that gaps in the obtained ranks for subsequent rows are not allowed.
*/
SELECT 
	DENSE_RANK() OVER w AS row_num, 
    emp_no, 
    salary
FROM salaries
	WHERE emp_no = 10560
WINDOW W as (PARTITION BY emp_no ORDER BY salary DESC);

/*
Exercise #1:
Write a query that can extract the following information from the "employees" database:

- the salary values (in ascending order) of the contracts signed by all employees numbered between 10500 and 10600 inclusive
- a column showing the previous salary from the given ordered list
- a column showing the subsequent salary from the given ordered list
- a column displaying the difference between the current salary of a certain employee and their previous salary
- a column displaying the difference between the next salary of a certain employee and their current salary

Limit the output to salary values higher than $80,000 only.
Also, to obtain a meaningful result, partition the data by employee number.
*/
SELECT 
    emp_no, salary, 
    LAG(salary) OVER w AS previous_salary, 
    LEAD(salary) OVER w AS next_salary, 
    salary - LAG(salary) OVER w AS diff_current_previous_salary, 
    LEAD(salary) OVER w - salary AS diff_next_current_salary
FROM
    salaries
WHERE
    emp_no BETWEEN 10500 AND 10600
        AND salary > 80000
WINDOW w AS (PARTITION BY emp_no);

/*
Exercise #2:
The MySQL LAG() and LEAD() value window functions can have a second argument, designating how many rows/steps back (for LAG()) or forth (for LEAD()) 
we'd like to refer to with respect to a given record. With that in mind, create a query whose result set contains data arranged by the salary values 
associated to each employee number (in ascending order). Let the output contain the following six columns:
- the employee number
- the salary value of an employee's contract (i.e. which we’ll consider as the employee's current salary)
- the employee's previous salary
- the employee's contract salary value preceding their previous salary
- the employee's next salary
- the employee's contract salary value subsequent to their next salary
Restrict the output to the first 1000 records you can obtain.
*/
SELECT 
    emp_no, salary, 
    LAG(salary, 2) OVER w AS previous_2_salary, 
    LAG(salary) OVER w AS previous_salary, 
    LEAD(salary) OVER w AS next_salary,
    LEAD(salary, 2) OVER w AS next_2_salary
FROM
    salaries
WINDOW w AS (PARTITION BY emp_no ORDER BY salary)
LIMIT 1000;


/*Exercise #1:
Write a query that ranks the salary values in descending order of all contracts signed by employees numbered between 10500 and 10600 inclusive. 
Let equal salary values for one and the same employee bear the same rank. Also, allow gaps in the ranks obtained for their subsequent rows.
Use a join on the “employees” and “salaries” tables to obtain the desired result.
*/
SELECT 
    emp_no, salary, RANK() OVER w AS rank_sal
FROM
    salaries
WHERE
    emp_no BETWEEN 10500 AND 10600
WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC);

/*
Exercise #2:
Write a query that ranks the salary values in descending order of the following contracts from the "employees" database:
- contracts that have been signed by employees numbered between 10500 and 10600 inclusive.
- contracts that have been signed at least 4 full-years after the date when the given employee was hired in the company for the first time.
In addition, let equal salary values of a certain employee bear the same rank. Do not allow gaps in the ranks obtained for their subsequent rows.
Use a join on the “employees” and “salaries” tables to obtain the desired result.
*/
SELECT 
    s.emp_no, s.salary, DENSE_RANK() OVER w as sal_rank
FROM
    salaries s
        JOIN
    employees e ON e.emp_no = s.emp_no
        AND TIMESTAMPDIFF(YEAR,
        e.hire_date,
        s.from_date) > 4
        AND s.emp_no BETWEEN 10500 AND 10600
WINDOW w AS (PARTITION BY s.emp_no ORDER BY s.salary DESC);

/*
Create a query that upon execution returns a result set containing the employee numbers, contract salary values, start, and end dates of the first ever contracts 
that each employee signed for the company.
*/

set @@global.sql_mode := replace(@@global.sql_mode, 'ONLY_FULL_GROUP_BY', '');

SELECT 
    s.emp_no, s.salary, s.from_date
FROM
    salaries s
        JOIN
    (SELECT 
        emp_no, MIN(from_date) AS from_date
    FROM
        salaries
    GROUP BY emp_no) s1 ON s1.emp_no = s.emp_no
        AND s1.from_date = s.from_date; 
 
/*
Exercise #1:

Consider the employees' contracts that have been signed after the 1st of January 2000 and terminated before the 1st of January 2002 
(as registered in the "dept_emp" table).
Create a MySQL query that will extract the following information about these employees:

- Their employee number
- The salary values of the latest contracts they have signed during the suggested time period
- The department they have been working in (as specified in the latest contract they've signed during the suggested time period)
- Use a window function to create a fourth field containing the average salary paid in the department the employee was last working in during the suggested time period. Name that field "average_salary_per_department".
*/
SELECT 
    de1.emp_no, s.salary, de1.dept_no, de1.from_date, de1.to_date
FROM
    dept_emp de1
        JOIN
    (SELECT 
        emp_no, MAX(from_date) AS from_date
    FROM
        dept_emp
    GROUP BY emp_no) de2 ON de1.emp_no = de2.emp_no 
		AND de1.from_date = de2.from_date
	JOIN (SELECT 
        s.emp_no, s.salary
    FROM
        salaries s
    JOIN (SELECT 
        emp_no, MAX(from_date) AS from_date
    FROM
        salaries
    GROUP BY emp_no) s1 ON s1.emp_no = s.emp_no
        AND s1.from_date = s.from_date) s ON s.emp_no = de1.emp_no
	JOIN (SELECT 
        s.emp_no, avg(s.salary) over w as avg_salary
    FROM
        salaries s
	JOIN dept_emp d ON s.emp_no = d.emp_no
    WHERE
        s.from_date > '2000-01-01'
            AND s.to_date < '2002-01-01'
            AND d.from_date > '2000-01-01'
            AND d.to_date < '2002-01-01'
	WINDOW w AS (PARTITION BY d.dept_no)
	) s1 ON s1.emp_no = de1.emp_no
WHERE
    de1.from_date > '2000-01-01'
        AND de1.to_date < '2002-01-01';
