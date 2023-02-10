# Summary Of Test Cases for 'SET FDWR' Measure
 
The following describe the parameter tests that are conducted on the measure. Note some of the 
tests are designed to return a fail and some a success. The report below contains all the tests that 
have the correct response. For example the argument range limit tests are expected to fail. 
 
## 1 - Remove the windows
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| fdwr_options |Remove the windows |
| fdwr |0.6 |
 
## 2 - Set windows to match max FDWR from NECB
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| fdwr_options |Set windows to match max FDWR from NECB |
| fdwr |0.6 |
 
## 3 - Don't change windows
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| fdwr_options |Don't change windows |
| fdwr |0.6 |
 
## 4 - Reduce existing window size to meet maximum NECB FDWR limit
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| fdwr_options |Reduce existing window size to meet maximum NECB FDWR limit |
| fdwr |0.6 |
 
## 5 - Set specific FDWR
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| fdwr_options |Set specific FDWR |
| fdwr |0.6 |
 
## 6 - test argument ranges
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| fdwr_options |Set specific FDWR |
| fdwr |2.0 |
 
## 7 - test argument ranges--1
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| fdwr_options |Set specific FDWR |
| fdwr |-1.0 |
 
## 8 - test argument ranges--2
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| fdwr_options |Set specific FDWR |
| fdwr |2.0 |
 
## 9 - test argument ranges--3
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| fdwr_options |Set specific FDWR |
| fdwr |-1.0 |
 
## 10 - test argument ranges--4
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| fdwr_options |Set specific FDWR |
| fdwr |2.0 |
 
## 11 - test argument ranges--5
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| fdwr_options |Set specific FDWR |
| fdwr |-1.0 |
 
## 12 - test argument ranges--6
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| fdwr_options |Set specific FDWR |
| fdwr |2.0 |
 
## 13 - test argument ranges--7
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| fdwr_options |Set specific FDWR |
| fdwr |-1.0 |
 