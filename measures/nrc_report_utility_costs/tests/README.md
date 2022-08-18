# Summary Of Test Cases for 'REPORT UTILITY COSTS' Measure
 
The following describe the parameter tests that are conducted on the measure. Note some of the 
tests are designed to return a fail and some a success. The report below contains all the tests that 
have the correct response. For example the argument range limit tests are expected to fail. 
 
## 1 - test argument ranges
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": 101.0,
  "gas_cost": 30.0
} |
 
## 2 - test argument ranges--1
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": -1.0,
  "gas_cost": 30.0
} |
 
## 3 - test argument ranges--2
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": 20.0,
  "gas_cost": 101.0
} |
 
## 4 - test argument ranges--3
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": 20.0,
  "gas_cost": -1.0
} |
 
## 5 - test argument ranges--4
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": 101.0,
  "gas_cost": 30.0
} |
 
## 6 - test argument ranges--5
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": -1.0,
  "gas_cost": 30.0
} |
 
## 7 - test argument ranges--6
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": 20.0,
  "gas_cost": 101.0
} |
 
## 8 - test argument ranges--7
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": 20.0,
  "gas_cost": -1.0
} |
 
## 9 - test argument ranges--8
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |101.0 |
| gas_cost |30.0 |
 
## 10 - test argument ranges--9
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |-1.0 |
| gas_cost |30.0 |
 
## 11 - test argument ranges--10
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |20.0 |
| gas_cost |101.0 |
 
## 12 - test argument ranges--11
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |20.0 |
| gas_cost |-1.0 |
 
## 13 - test argument ranges--12
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |101.0 |
| gas_cost |30.0 |
 
## 14 - test argument ranges--13
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |-1.0 |
| gas_cost |30.0 |
 
## 15 - test argument ranges--14
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |20.0 |
| gas_cost |101.0 |
 
## 16 - test argument ranges--15
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |20.0 |
| gas_cost |-1.0 |
 
## 17 - smallOffice
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |20.0 |
| gas_cost |30.0 |
 
