# Summary Of Test Cases for 'REPORT UTILITY COSTS' Measure
 
The following describe the parameter tests that are conducted on the measure. Note some of the 
tests are designed to return a fail and some a success. The report below contains all the tests that 
have the correct response. For example the argument range limit tests are expected to fail. 
 
## 1 - smallOffice
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |20.0 |
| gas_cost |30.0 |
 
## 2 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": 101.0,
  "gas_cost": 30.0
} |
 
## 3 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": -1.0,
  "gas_cost": 30.0
} |
 
## 4 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": 20.0,
  "gas_cost": 101.0
} |
 
## 5 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": 20.0,
  "gas_cost": -1.0
} |
 
## 6 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": 101.0,
  "gas_cost": 30.0
} |
 
## 7 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": -1.0,
  "gas_cost": 30.0
} |
 
## 8 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": 20.0,
  "gas_cost": 101.0
} |
 
## 9 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "calc_choice": "Nova Scotia rates 2021",
  "electricity_cost": 20.0,
  "gas_cost": -1.0
} |
 
## 10 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |101.0 |
| gas_cost |30.0 |
 
## 11 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |-1.0 |
| gas_cost |30.0 |
 
## 12 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |20.0 |
| gas_cost |101.0 |
 
## 13 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |20.0 |
| gas_cost |-1.0 |
 
## 14 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |101.0 |
| gas_cost |30.0 |
 
## 15 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |-1.0 |
| gas_cost |30.0 |
 
## 16 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |20.0 |
| gas_cost |101.0 |
 
## 17 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| calc_choice |Nova Scotia rates 2021 |
| electricity_cost |20.0 |
| gas_cost |-1.0 |
 
