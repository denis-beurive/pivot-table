Introduction

This article is an attempt to illustrate the use of pivot tables for IT engineers who know SQL.

Just like pivot tables, databases are used to manipulate data.
I already knew how to use databases, and I asked myself: is it necessary to learn a new tool?
What are the differences between a database and a pivot table?

The preparation

First of all, I began to create a script that generates sample data.
You can find this script here, along with the generated data. 

The previously given link points to a document that contains the following files:
The script "data-generator.pl" is used to generate the sample data. The result of the script's execution are the files "data.csv" and "data.sql".
The file "data.csv" contains the data, and it can be loaded into the spreadsheet.
The file "data.sql" contains the data, and it can be loaded into a MySql database.
The file "model.sql" contains the model of the MySql database use to store the data.
The file "data.ods" contains the spreadsheet's document.

The figure below represents the database's structure (given in the SQL file "model.sql").

Please note that this image has been generated with the DBVIEW utility, which can be downloaded here.

dbview.sh export -exporter dot-medium -db-adaptor mysql -host localhost -user root -password '' -dbname sales -port 3306 > dots/graph.dot

The content of the file "data.csv", that will be loaded into the spreadsheet, looks something like:

Date;Total;Sales;Cb;Check;Category;Region;Employee;Chief
20/01/2015;6011;8;99;1;Sport;south;Adrian;Denis
20/01/2015;6127;33;2;98;Kitchen;south;Adrian;Denis
20/01/2015;9983;4;12;88;Phone;south;Adrian;Denis
20/01/2015;3132;91;79;21;Sport;south;Agnes;Denis
...

Please note that I use Open Office Calc (4.1.2) since this spreadsheet is free. It is not as complete as Microsoft's spreadsheet, but it is more than adequate to start with.

Loading data into the spreadsheet

First, start by loading data into the spreadsheet.
Start Open Office.
Select "Spreadsheet".
Click on "File" &gt; "Open...".
Select the file "data.csv".
Then select the character set "Unicode (UTF-8)".
Then select the language "Default - French (France)".
And Click "OK".

Creating the pivot table

Select all the lines and columns that appear on the document named "sheet1". You should select 307 lines and 9 columns.
Click on "Data" &gt; "Pivot table..." &gt; "Create...".
Keep the default setting "Current selection", and click "OK".
Drag and drop "Region" into the area "Page fields".
Drag and drop "Chief", "Employee" and "Category" into the area "Column fields".
Drag and drop "Chief", "Employee" and "Category" into the area "Column fields".
Drag and drop "Date" and "Cb" into the area "Row fields".
Drag and drop "Total" and "Sales" into the area "Data fields".
Then click "OK".

The pivot table appears below the data.

Each column is a combination of three fields: a chief, an employee and a category.
Each row is a combination of two fields: the date and the number of payment by credit card.
Each data's cell contains two values:
The total number of sales for an employee, for a given category, at a given date, and for a given number of credit-card transactions.   
The total amount of sales for an employee, for a given category, at a given date, and for a given number of credit-card transactions.   

Linking the spreadsheet with the database

In this section, I try to move the database closer to the spreadsheet.

The columns

Each column is a combination of three fields: a chief, an employee and a category.

Let's select all the combinations from the database, using SQL.

Please note that, because an employee can have only one chief, some combinations between chiefs and employees are impossible. 
For example, the combination (Arnaud, Adrian) is impossible since Adrian's chief is Denis.
Therefore, due to the organisations' constraints, we cannot perform a cross join between the tables "employee" and "chief".
We must respect the following constraint: an employee has one, and only one, chief. This constraint is expressed by the foreign key between the tables "employee" and "chief".

Thus, in order to get all the possible combinations between employees and chiefs, the right SQL request is:   

SELECT     
    chief.name,
    employee.name
FROM 
    employee
INNER JOIN
    chief ON employee.fk_chief = chief.id;

There is no constraint between employees and catégories and between chiefs and categories.
Thus, in order to get all the possible combinations between chiefs, employees and categories, we can perform a cross join between the result of the previous request and the table "category".

SELECT
    chief.name,
    employee.name,
    category.name
FROM
    employee
INNER JOIN 
    chief ON employee.fk_chief = chief.id
CROSS JOIN
    category;

Please note that the request above is equivalent to the following construct (it may be clearer):

CREATE TABLE chief_employee AS 
SELECT
    chief.name AS 'chief',
    employee.name AS 'employee'
FROM
    employee
INNER JOIN
    chief ON employee.fk_chief = chief.id;

SELECT
    chief,
    employee,
    category.name AS 'category'
FROM
    chief_employee
CROSS JOIN
    category;

The rows

Each row is a combination of two fields: the date and the number of payment by credit card.
To get the list of all possible combinations, we can execute the following request:

Let's select all combinations from the database, using SQL.

SELECT DISTINCT
    dateSale,
    cb
FROM
    sales
ORDER BY
    dateSale, cb;

The data

If we want to produce exactly the same result that the spreadsheet, then SQL is not the right tool. We can combine SQL with a programming language. Alternatively, we could write a stored procedure.
However, the point of this article is not about SQL. Therefore, we will just concentrate on a single row.

Now that we have all the rows and all the columns, we can fill the table with data.
We said that we wanted to show the total amount of sales and the total number of sales.
Thus, for each possible couples (chief, employee, category), (date of sale, number of payment by credit card), we calculate the total number of sales and the total amount of sales.

Let's calculate the data for the second line of the table (date=20/01/2015 and cb=3).

SELECT
    chief.name AS 'Chief',
    employee.name AS 'Employee',
    category.name AS 'Category',
    sales.salesNumber AS 'Number of sales',
    sales.totalSale AS 'Total'    
FROM
    sales
INNER JOIN
    employee ON sales.fk_employee = employee.id
INNER JOIN
    chief ON employee.fk_chief = chief.id
INNER JOIN
    category ON sales.fk_category = category.id
WHERE
    dateSale='2015-01-20'
    AND
    cb=3
ORDER BY `Chief`, `Employee`, `Category`;

+----------+-----------+----------+-----------------+-------+
| Chief    | Employee  | Category | Number of sales | Total |
+----------+-----------+----------+-----------------+-------+
| Arnaud   | Adam      | Sport    |               6 |  9431 |
| Mathieux | Elisabeth | Phone    |              13 |  8719 |
+----------+-----------+----------+-----------------+-------+

Conclusion

Obviously, pivot tables are not equivalent to databases in terms of operations on the data.

Here are some differences:

Everything that can be done with a pivot table can be done with SQL, or a mix between SQL and a programming language. However, for simple data analysis, pivot tables may be easier to use, since SQL and programming require a much steeper learning curve.   
Everything that can be done with SQL and programming can't be done using pivot tables.
The use of pivot tables is limited to a small amount of data (in comparison to databases).









# pivot-table
