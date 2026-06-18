USE classicmodels;

CREATE VIEW notPaymentClient as SELECT c.customerNumber
FROM customers c
RIGHT JOIN payments p ON p.customerNumber = c.customerNumber;

SELECT FROM classicmodels.customers c 
;