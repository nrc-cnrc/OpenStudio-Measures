# Summary Of Test Cases for 'NRCTEMPLATEREPORTINGMEASURE' Measure
 
The following describe the parameter tests that are conducted on the measure. Note some of the 
tests are designed to return a fail and some a success. The report below contains all the tests that 
have the correct response. For example the argument range limit tests are expected to fail. 
 
## 1 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "a_string_argument": "MyString",
  "a_double_argument": 101.0,
  "an_integer_argument": 5,
  "a_string_double_argument": "50.0",
  "a_choice_argument": "choice_1",
  "a_bool_argument": true
} |
 
## 2 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "a_string_argument": "MyString",
  "a_double_argument": -1.0,
  "an_integer_argument": 5,
  "a_string_double_argument": "50.0",
  "a_choice_argument": "choice_1",
  "a_bool_argument": true
} |
 
## 3 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "a_string_argument": "MyString",
  "a_double_argument": 50.0,
  "an_integer_argument": 5,
  "a_string_double_argument": "101.0",
  "a_choice_argument": "choice_1",
  "a_bool_argument": true
} |
 
## 4 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "a_string_argument": "MyString",
  "a_double_argument": 50.0,
  "an_integer_argument": 5,
  "a_string_double_argument": "101.0",
  "a_choice_argument": "choice_1",
  "a_bool_argument": true
} |
 
## 5 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "a_string_argument": "MyString",
  "a_double_argument": 50.0,
  "an_integer_argument": 5,
  "a_string_double_argument": "be76f55a-d492-46e0-9efe-8c7c170b9889",
  "a_choice_argument": "choice_1",
  "a_bool_argument": true
} |
 
## 6 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "a_string_argument": "MyString",
  "a_double_argument": 101.0,
  "an_integer_argument": 5,
  "a_string_double_argument": "50.0",
  "a_choice_argument": "choice_1",
  "a_bool_argument": true
} |
 
## 7 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "a_string_argument": "MyString",
  "a_double_argument": -1.0,
  "an_integer_argument": 5,
  "a_string_double_argument": "50.0",
  "a_choice_argument": "choice_1",
  "a_bool_argument": true
} |
 
## 8 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "a_string_argument": "MyString",
  "a_double_argument": 50.0,
  "an_integer_argument": 5,
  "a_string_double_argument": "101.0",
  "a_choice_argument": "choice_1",
  "a_bool_argument": true
} |
 
## 9 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "a_string_argument": "MyString",
  "a_double_argument": 50.0,
  "an_integer_argument": 5,
  "a_string_double_argument": "101.0",
  "a_choice_argument": "choice_1",
  "a_bool_argument": true
} |
 
## 10 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |101.0 |
| an_integer_argument |5 |
| a_string_double_argument |50.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 11 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |-1.0 |
| an_integer_argument |5 |
| a_string_double_argument |50.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 12 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |50.0 |
| an_integer_argument |5 |
| a_string_double_argument |101.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 13 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |50.0 |
| an_integer_argument |5 |
| a_string_double_argument |101.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 14 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |50.0 |
| an_integer_argument |5 |
| a_string_double_argument |d3459797-18e4-42b0-94c4-e2a8645f9308 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 15 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |101.0 |
| an_integer_argument |5 |
| a_string_double_argument |50.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 16 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |-1.0 |
| an_integer_argument |5 |
| a_string_double_argument |50.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 17 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |50.0 |
| an_integer_argument |5 |
| a_string_double_argument |101.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 18 - oscli
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |50.0 |
| an_integer_argument |5 |
| a_string_double_argument |101.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 19 - smallOffice
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
 
