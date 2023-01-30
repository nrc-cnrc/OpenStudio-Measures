# Summary Of Test Cases for 'NRCTEMPLATEREPORTINGMEASURE' Measure
 
The following describe the parameter tests that are conducted on the measure. Note some of the 
tests are designed to return a fail and some a success. The report below contains all the tests that 
have the correct response. For example the argument range limit tests are expected to fail. 
 
## 1 - test argument ranges
 
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
 
## 2 - test argument ranges--1
 
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
 
## 3 - test argument ranges--2
 
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
 
## 4 - test argument ranges--3
 
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
 
## 5 - test argument ranges--4
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| json_input |{
  "a_string_argument": "MyString",
  "a_double_argument": 50.0,
  "an_integer_argument": 5,
  "a_string_double_argument": "18d1265a-a37b-4ad4-8fff-afedf87d3416",
  "a_choice_argument": "choice_1",
  "a_bool_argument": true
} |
 
## 6 - test argument ranges--5
 
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
 
## 7 - test argument ranges--6
 
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
 
## 8 - test argument ranges--7
 
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
 
## 9 - test argument ranges--8
 
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
 
## 10 - test argument ranges--9
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |101.0 |
| an_integer_argument |5 |
| a_string_double_argument |50.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 11 - test argument ranges--10
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |-1.0 |
| an_integer_argument |5 |
| a_string_double_argument |50.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 12 - test argument ranges--11
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |50.0 |
| an_integer_argument |5 |
| a_string_double_argument |101.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 13 - test argument ranges--12
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |50.0 |
| an_integer_argument |5 |
| a_string_double_argument |101.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 14 - test argument ranges--13
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |50.0 |
| an_integer_argument |5 |
| a_string_double_argument |8f36e0bb-c51f-41c9-9e73-4a4b569eb31d |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 15 - test argument ranges--14
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |101.0 |
| an_integer_argument |5 |
| a_string_double_argument |50.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 16 - test argument ranges--15
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |-1.0 |
| an_integer_argument |5 |
| a_string_double_argument |50.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 17 - test argument ranges--16
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| a_string_argument |MyString |
| a_double_argument |50.0 |
| an_integer_argument |5 |
| a_string_double_argument |101.0 |
| a_choice_argument |choice_1 |
| a_bool_argument |true |
 
## 18 - test argument ranges--17
 
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
 
