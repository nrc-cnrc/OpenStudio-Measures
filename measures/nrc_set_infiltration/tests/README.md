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
 
## 2 - WarehouseNoChange
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |0.25 |
| reference_pressure |5.0 |
| flow_exponent |0.6 |
| total_surface_area |100.0 |
| above_grade_wall_surface_area |100.0 |
 
## 13 - test argument ranges--10
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |31.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 3 - test argument ranges
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |31.0 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 14 - test argument ranges--5
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |-0.95 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
## 4 - test argument ranges--6
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| flow_rate |-0.95 |
| reference_pressure |75.0 |
| flow_exponent |0.6 |
| total_surface_area |0.0 |
| above_grade_wall_surface_area |0.0 |
 
