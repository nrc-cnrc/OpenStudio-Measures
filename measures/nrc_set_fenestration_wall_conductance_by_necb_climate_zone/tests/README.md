# Summary Of Test Cases for 'SET FENESTRATION (WALL) CONDUCTANCE BY NECB CLIMATE ZONE' Measure
 
The following describe the parameter tests that are conducted on the measure. Note some of the 
tests are designed to return a fail and some a success. The report below contains all the tests that 
have the correct response. For example the argument range limit tests are expected to fail. 
 
## 1 - OutputTestFolder zone5--1
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 2 - test argument ranges
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |6.0 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 3 - test argument ranges--1
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |-1.0 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 4 - test argument ranges--2
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |6.0 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 5 - test argument ranges--3
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |-1.0 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 6 - test argument ranges--4
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |6.0 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 7 - test argument ranges--5
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |-1.0 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 8 - test argument ranges--6
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |6.0 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 9 - test argument ranges--7
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |-1.0 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 10 - test argument ranges--8
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |6.0 |
| zone8_u_value |1.3 |
 
## 11 - test argument ranges--9
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |-1.0 |
| zone8_u_value |1.3 |
 
## 12 - test argument ranges--10
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |6.0 |
 
## 13 - test argument ranges--11
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |-1.0 |
 
## 14 - test argument ranges--12
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |6.0 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 15 - test argument ranges--13
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |-1.0 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 16 - test argument ranges--14
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |6.0 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 17 - test argument ranges--15
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |-1.0 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 18 - test argument ranges--16
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |6.0 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 19 - test argument ranges--17
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |-1.0 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 20 - test argument ranges--18
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |6.0 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 21 - test argument ranges--19
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |-1.0 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 22 - test argument ranges--20
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |6.0 |
| zone8_u_value |1.3 |
 
## 23 - test argument ranges--21
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |-1.0 |
| zone8_u_value |1.3 |
 
## 24 - test argument ranges--22
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |6.0 |
 
## 25 - test argument ranges--23
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |-1.0 |
 
## 26 - test argument ranges--24
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |6.0 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 27 - test argument ranges--25
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |-1.0 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 28 - test argument ranges--26
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |6.0 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 29 - test argument ranges--27
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |-1.0 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 30 - test argument ranges--28
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |6.0 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 31 - test argument ranges--29
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |-1.0 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 32 - test argument ranges--30
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |6.0 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 33 - test argument ranges--31
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |-1.0 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 34 - test argument ranges--32
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |6.0 |
| zone8_u_value |1.3 |
 
## 35 - test argument ranges--33
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |-1.0 |
| zone8_u_value |1.3 |
 
## 36 - test argument ranges--34
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |6.0 |
 
## 37 - test argument ranges--35
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |-1.0 |
 
## 38 - test argument ranges--36
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |6.0 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 39 - test argument ranges--37
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |-1.0 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 40 - test argument ranges--38
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |6.0 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 41 - test argument ranges--39
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |-1.0 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 42 - test argument ranges--40
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |6.0 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 43 - test argument ranges--41
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |-1.0 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 44 - test argument ranges--42
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |6.0 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 45 - test argument ranges--43
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |-1.0 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 46 - test argument ranges--44
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |6.0 |
| zone8_u_value |1.3 |
 
## 47 - test argument ranges--45
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |-1.0 |
| zone8_u_value |1.3 |
 
## 48 - test argument ranges--46
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |6.0 |
 
## 49 - test argument ranges--47
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |-1.0 |
 
## 50 - OutputTestFolder zone4--1
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 51 - OutputTestFolder zone7a--1
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 52 - OutputTestFolder zone7b--1
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 53 - OutputTestFolder zone8--1
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
## 54 - OutputTestFolder zone6--1
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| necb_template |NECB2017 |
| zone4_u_value |1.9 |
| zone5_u_value |1.8 |
| zone6_u_value |1.7 |
| zone7A_u_value |1.5 |
| zone7B_u_value |1.4 |
| zone8_u_value |1.3 |
 
