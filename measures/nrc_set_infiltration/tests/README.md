# Summary Of Test Cases for 'SET INFILTRATION RATE' Measure
 
The following describe the parameter tests that are conducted on the measure. Note some of the 
tests are designed to return a fail and some a success. The report below contains all the tests that 
have the correct response. For example the argument range limit tests are expected to fail. 
 
## 1 - Warehouse Good
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 2 - test argument ranges
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |31.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 3 - test argument ranges--1
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |-0.95 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 4 - test argument ranges--2
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |101.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 5 - test argument ranges--3
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |-1.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 6 - test argument ranges--4
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |2.0 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 7 - test argument ranges--5
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |-0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 8 - test argument ranges--6
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |10000001.0 |
| above_grade_wall_surface_area |0.0 |
 
## 9 - test argument ranges--7
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |-1.0 |
| above_grade_wall_surface_area |0.0 |
 
## 10 - test argument ranges--8
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |10000001.0 |
 
## 11 - test argument ranges--9
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |-1.0 |
 
## 12 - test argument ranges--10
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |31.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 13 - test argument ranges--11
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |-0.95 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 14 - test argument ranges--12
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |101.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 15 - test argument ranges--13
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |-1.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 16 - test argument ranges--14
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |2.0 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 17 - test argument ranges--15
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |-0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 18 - test argument ranges--16
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |10000001.0 |
| above_grade_wall_surface_area |0.0 |
 
## 19 - test argument ranges--17
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |-1.0 |
| above_grade_wall_surface_area |0.0 |
 
## 20 - test argument ranges--18
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |10000001.0 |
 
## 21 - test argument ranges--19
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |-1.0 |
 
## 22 - test argument ranges--20
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |31.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 23 - test argument ranges--21
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |-0.95 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 24 - test argument ranges--22
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |101.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 25 - test argument ranges--23
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |-1.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 26 - test argument ranges--24
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |2.0 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 27 - test argument ranges--25
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |-0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 28 - test argument ranges--26
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |10000001.0 |
| above_grade_wall_surface_area |0.0 |
 
## 29 - test argument ranges--27
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |-1.0 |
| above_grade_wall_surface_area |0.0 |
 
## 30 - test argument ranges--28
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |10000001.0 |
 
## 31 - test argument ranges--29
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |-1.0 |
 
## 32 - test argument ranges--30
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |31.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 33 - test argument ranges--31
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |-0.95 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 34 - test argument ranges--32
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |101.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 35 - test argument ranges--33
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |-1.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 36 - test argument ranges--34
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |2.0 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 37 - test argument ranges--35
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |-0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 38 - test argument ranges--36
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |10000001.0 |
| above_grade_wall_surface_area |0.0 |
 
## 39 - test argument ranges--37
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |-1.0 |
| above_grade_wall_surface_area |0.0 |
 
## 40 - test argument ranges--38
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |10000001.0 |
 
## 41 - test argument ranges--39
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |2.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |-1.0 |
 
## 42 - WarehouseNoChange
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |0.25 |
| reference_pressure |5.0 |
| flow_exponent |0.6 |
| total_surface_area |100.0 |
| above_grade_wall_surface_area |100.0 |
 
