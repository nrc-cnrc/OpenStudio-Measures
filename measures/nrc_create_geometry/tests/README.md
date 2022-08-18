# Summary Of Test Cases for 'NRCCREATEGEOMETRY' Measure
 
The following describe the parameter tests that are conducted on the measure. Note some of the 
tests are designed to return a fail and some a success. The report below contains all the tests that 
have the correct response. For example the argument range limit tests are expected to fail. 
 
## 1 - test argument ranges
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 2 - test argument ranges--1
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 3 - test argument ranges--2
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 4 - test argument ranges--3
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 5 - test argument ranges--4
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 6 - test argument ranges--5
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 7 - test argument ranges--6
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 8 - test argument ranges--7
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 9 - test argument ranges--8
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 10 - test argument ranges--9
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 11 - test argument ranges--10
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 12 - test argument ranges--11
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 13 - test argument ranges--12
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 14 - test argument ranges--13
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 15 - test argument ranges--14
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 16 - test argument ranges--15
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 17 - test argument ranges--16
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 18 - test argument ranges--17
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 19 - test argument ranges--18
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 20 - test argument ranges--19
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 21 - test argument ranges--20
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 22 - test argument ranges--21
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 23 - test argument ranges--22
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 24 - test argument ranges--23
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 25 - test argument ranges--24
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 26 - test argument ranges--25
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 27 - test argument ranges--26
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 28 - test argument ranges--27
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 29 - test argument ranges--28
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 30 - test argument ranges--29
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 31 - test argument ranges--30
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 32 - test argument ranges--31
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 33 - test argument ranges--32
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 34 - test argument ranges--33
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 35 - test argument ranges--34
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 36 - test argument ranges--35
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 37 - test argument ranges--36
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 38 - test argument ranges--37
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 39 - test argument ranges--38
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 40 - test argument ranges--39
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 41 - test argument ranges--40
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 42 - test argument ranges--41
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 43 - test argument ranges--42
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 44 - test argument ranges--43
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 45 - test argument ranges--44
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 46 - test argument ranges--45
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 47 - test argument ranges--46
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 48 - test argument ranges--47
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
# Summary Of Test Cases for 'NRCCREATEGEOMETRY' Measure
 
The following describe the parameter tests that are conducted on the measure. Note some of the 
tests are designed to return a fail and some a success. The report below contains all the tests that 
have the correct response. For example the argument range limit tests are expected to fail. 
 
## 1 - Courtyard-RetailStandalone-NECB2011-90-Yellowknife-1-20000-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Courtyard |
| template |NECB2011 |
| building_type |RetailStandalone |
| epw_file |CAN_NT_Yellowknife.AP.719360_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 2 - Courtyard-RetailStandalone-NECB2011-90-Montreal-Trudeau-1-20000-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Courtyard |
| template |NECB2011 |
| building_type |RetailStandalone |
| epw_file |CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
# Summary Of Test Cases for 'NRCCREATEGEOMETRY' Measure
 
The following describe the parameter tests that are conducted on the measure. Note some of the 
tests are designed to return a fail and some a success. The report below contains all the tests that 
have the correct response. For example the argument range limit tests are expected to fail. 
 
## 1 - Courtyard-RetailStripmall-NECB2015-10-Ottawa-Macdonald-Cartier-1-20000-1.0
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Courtyard |
| template |NECB2015 |
| building_type |RetailStripmall |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.0 |
| rotation |10.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
# Summary Of Test Cases for 'NRCCREATEGEOMETRY' Measure
 
The following describe the parameter tests that are conducted on the measure. Note some of the 
tests are designed to return a fail and some a success. The report below contains all the tests that 
have the correct response. For example the argument range limit tests are expected to fail. 
 
## 1 - U-Shape-PrimarySchool-NECB2017-40-Whitehorse-1-20000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |PrimarySchool |
| epw_file |CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 3 - Courtyard-RetailStandalone-NECB2011-90-Yellowknife-1-1500-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Courtyard |
| template |NECB2011 |
| building_type |RetailStandalone |
| epw_file |CAN_NT_Yellowknife.AP.719360_CWEC2016.epw |
| total_floor_area |1500.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 2 - Courtyard-RetailStripmall-NECB2015-10-Windsor-1-20000-1.0
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Courtyard |
| template |NECB2015 |
| building_type |RetailStripmall |
| epw_file |CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.0 |
| rotation |10.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 2 - U-Shape-PrimarySchool-NECB2017-40-Vancouver-1-20000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |PrimarySchool |
| epw_file |CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 4 - Courtyard-RetailStandalone-NECB2011-90-Montreal-Trudeau-1-1500-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Courtyard |
| template |NECB2011 |
| building_type |RetailStandalone |
| epw_file |CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw |
| total_floor_area |1500.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 3 - Rectangular-RetailStripmall-NECB2015-10-Ottawa-Macdonald-Cartier-1-20000-1.0
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2015 |
| building_type |RetailStripmall |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.0 |
| rotation |10.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 5 - H-Shape-RetailStandalone-NECB2011-90-Yellowknife-1-20000-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |H-Shape |
| template |NECB2011 |
| building_type |RetailStandalone |
| epw_file |CAN_NT_Yellowknife.AP.719360_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 49 - L-Shape-LargeOffice-NECB2020-10-Montreal-Trudeau-12-40000-2.0
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |L-Shape |
| template |NECB2020 |
| building_type |LargeOffice |
| epw_file |CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw |
| total_floor_area |40000.0 |
| aspect_ratio |2.0 |
| rotation |10.0 |
| above_grade_floors |12 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 3 - U-Shape-PrimarySchool-NECB2017-40-Whitehorse-3-20000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |PrimarySchool |
| epw_file |CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |3 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 4 - Rectangular-RetailStripmall-NECB2015-10-Windsor-1-20000-1.0
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2015 |
| building_type |RetailStripmall |
| epw_file |CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.0 |
| rotation |10.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 6 - H-Shape-RetailStandalone-NECB2011-90-Montreal-Trudeau-1-20000-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |H-Shape |
| template |NECB2011 |
| building_type |RetailStandalone |
| epw_file |CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 7 - H-Shape-RetailStandalone-NECB2011-90-Yellowknife-1-1500-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |H-Shape |
| template |NECB2011 |
| building_type |RetailStandalone |
| epw_file |CAN_NT_Yellowknife.AP.719360_CWEC2016.epw |
| total_floor_area |1500.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 5 - Courtyard-QuickServiceRestaurant-NECB2015-10-Ottawa-Macdonald-Cartier-1-20000-1.0
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Courtyard |
| template |NECB2015 |
| building_type |QuickServiceRestaurant |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.0 |
| rotation |10.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 4 - U-Shape-PrimarySchool-NECB2017-40-Vancouver-3-20000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |PrimarySchool |
| epw_file |CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |3 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 50 - Rectangular-LargeOffice-NECB2020-10-Montreal-Trudeau-12-40000-2.0
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2020 |
| building_type |LargeOffice |
| epw_file |CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw |
| total_floor_area |40000.0 |
| aspect_ratio |2.0 |
| rotation |10.0 |
| above_grade_floors |12 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 8 - H-Shape-RetailStandalone-NECB2011-90-Montreal-Trudeau-1-1500-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |H-Shape |
| template |NECB2011 |
| building_type |RetailStandalone |
| epw_file |CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw |
| total_floor_area |1500.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 6 - Courtyard-QuickServiceRestaurant-NECB2015-10-Windsor-1-20000-1.0
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Courtyard |
| template |NECB2015 |
| building_type |QuickServiceRestaurant |
| epw_file |CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.0 |
| rotation |10.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 9 - Courtyard-SmallOffice-NECB2011-90-Yellowknife-1-20000-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Courtyard |
| template |NECB2011 |
| building_type |SmallOffice |
| epw_file |CAN_NT_Yellowknife.AP.719360_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 5 - U-Shape-PrimarySchool-NECB2017-40-Whitehorse-1-1000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |PrimarySchool |
| epw_file |CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw |
| total_floor_area |1000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 7 - Rectangular-QuickServiceRestaurant-NECB2015-10-Ottawa-Macdonald-Cartier-1-20000-1.0
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2015 |
| building_type |QuickServiceRestaurant |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.0 |
| rotation |10.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 10 - Courtyard-SmallOffice-NECB2011-90-Montreal-Trudeau-1-20000-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Courtyard |
| template |NECB2011 |
| building_type |SmallOffice |
| epw_file |CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 6 - U-Shape-PrimarySchool-NECB2017-40-Vancouver-1-1000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |PrimarySchool |
| epw_file |CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw |
| total_floor_area |1000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 11 - Courtyard-SmallOffice-NECB2011-90-Yellowknife-1-1500-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Courtyard |
| template |NECB2011 |
| building_type |SmallOffice |
| epw_file |CAN_NT_Yellowknife.AP.719360_CWEC2016.epw |
| total_floor_area |1500.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 8 - Rectangular-QuickServiceRestaurant-NECB2015-10-Windsor-1-20000-1.0
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2015 |
| building_type |QuickServiceRestaurant |
| epw_file |CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.0 |
| rotation |10.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 9 - test argument ranges--48
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 10 - test argument ranges--49
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 11 - test argument ranges--50
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 12 - test argument ranges--51
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 13 - test argument ranges--52
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 14 - test argument ranges--53
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 15 - test argument ranges--54
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 16 - test argument ranges--55
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 17 - test argument ranges--56
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 18 - test argument ranges--57
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 19 - test argument ranges--58
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 20 - test argument ranges--59
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 21 - test argument ranges--60
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 22 - test argument ranges--61
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 23 - test argument ranges--62
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 24 - test argument ranges--63
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 25 - test argument ranges--64
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 26 - test argument ranges--65
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 27 - test argument ranges--66
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 28 - test argument ranges--67
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 29 - test argument ranges--68
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 30 - test argument ranges--69
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 31 - test argument ranges--70
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 32 - test argument ranges--71
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 33 - test argument ranges--72
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 34 - test argument ranges--73
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 35 - test argument ranges--74
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 36 - test argument ranges--75
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 37 - test argument ranges--76
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 38 - test argument ranges--77
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 39 - test argument ranges--78
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 40 - test argument ranges--79
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 41 - test argument ranges--80
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 42 - test argument ranges--81
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 43 - test argument ranges--82
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 44 - test argument ranges--83
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 45 - test argument ranges--84
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 46 - test argument ranges--85
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 47 - test argument ranges--86
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 48 - test argument ranges--87
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 49 - test argument ranges--88
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 50 - test argument ranges--89
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 51 - test argument ranges--90
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 52 - test argument ranges--91
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 53 - test argument ranges--92
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 54 - test argument ranges--93
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 55 - test argument ranges--94
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 56 - test argument ranges--95
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 51 - L-Shape-HighriseApartment-NECB2020-10-Montreal-Trudeau-12-40000-2.0
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |L-Shape |
| template |NECB2020 |
| building_type |HighriseApartment |
| epw_file |CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw |
| total_floor_area |40000.0 |
| aspect_ratio |2.0 |
| rotation |10.0 |
| above_grade_floors |12 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 12 - Courtyard-SmallOffice-NECB2011-90-Montreal-Trudeau-1-1500-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Courtyard |
| template |NECB2011 |
| building_type |SmallOffice |
| epw_file |CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw |
| total_floor_area |1500.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 7 - U-Shape-PrimarySchool-NECB2017-40-Whitehorse-3-1000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |PrimarySchool |
| epw_file |CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw |
| total_floor_area |1000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |3 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 13 - H-Shape-SmallOffice-NECB2011-90-Yellowknife-1-20000-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |H-Shape |
| template |NECB2011 |
| building_type |SmallOffice |
| epw_file |CAN_NT_Yellowknife.AP.719360_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 14 - H-Shape-SmallOffice-NECB2011-90-Montreal-Trudeau-1-20000-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |H-Shape |
| template |NECB2011 |
| building_type |SmallOffice |
| epw_file |CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 8 - U-Shape-PrimarySchool-NECB2017-40-Vancouver-3-1000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |PrimarySchool |
| epw_file |CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw |
| total_floor_area |1000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |3 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 52 - Rectangular-HighriseApartment-NECB2020-10-Montreal-Trudeau-12-40000-2.0
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2020 |
| building_type |HighriseApartment |
| epw_file |CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw |
| total_floor_area |40000.0 |
| aspect_ratio |2.0 |
| rotation |10.0 |
| above_grade_floors |12 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 15 - H-Shape-SmallOffice-NECB2011-90-Yellowknife-1-1500-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |H-Shape |
| template |NECB2011 |
| building_type |SmallOffice |
| epw_file |CAN_NT_Yellowknife.AP.719360_CWEC2016.epw |
| total_floor_area |1500.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 9 - U-Shape-MediumOffice-NECB2017-40-Whitehorse-1-20000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |MediumOffice |
| epw_file |CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 16 - H-Shape-SmallOffice-NECB2011-90-Montreal-Trudeau-1-1500-1.25
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |H-Shape |
| template |NECB2011 |
| building_type |SmallOffice |
| epw_file |CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw |
| total_floor_area |1500.0 |
| aspect_ratio |1.25 |
| rotation |90.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 17 - test argument ranges--96
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 18 - test argument ranges--97
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 19 - test argument ranges--98
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 20 - test argument ranges--99
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 21 - test argument ranges--100
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 22 - test argument ranges--101
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 23 - test argument ranges--102
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 24 - test argument ranges--103
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 25 - test argument ranges--104
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 26 - test argument ranges--105
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 27 - test argument ranges--106
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 28 - test argument ranges--107
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 29 - test argument ranges--108
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 30 - test argument ranges--109
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 31 - test argument ranges--110
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 32 - test argument ranges--111
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 33 - test argument ranges--112
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 34 - test argument ranges--113
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 35 - test argument ranges--114
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 36 - test argument ranges--115
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 37 - test argument ranges--116
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 38 - test argument ranges--117
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 39 - test argument ranges--118
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 40 - test argument ranges--119
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 41 - test argument ranges--120
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 42 - test argument ranges--121
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 43 - test argument ranges--122
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 44 - test argument ranges--123
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 45 - test argument ranges--124
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 46 - test argument ranges--125
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 47 - test argument ranges--126
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 48 - test argument ranges--127
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 49 - test argument ranges--128
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 50 - test argument ranges--129
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 51 - test argument ranges--130
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 52 - test argument ranges--131
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 53 - test argument ranges--132
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 54 - test argument ranges--133
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 55 - test argument ranges--134
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 56 - test argument ranges--135
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 57 - test argument ranges--136
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 58 - test argument ranges--137
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 59 - test argument ranges--138
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 60 - test argument ranges--139
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 61 - test argument ranges--140
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 62 - test argument ranges--141
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 63 - test argument ranges--142
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 64 - test argument ranges--143
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 10 - U-Shape-MediumOffice-NECB2017-40-Vancouver-1-20000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |MediumOffice |
| epw_file |CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 11 - U-Shape-MediumOffice-NECB2017-40-Whitehorse-3-20000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |MediumOffice |
| epw_file |CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |3 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 12 - U-Shape-MediumOffice-NECB2017-40-Vancouver-3-20000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |MediumOffice |
| epw_file |CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw |
| total_floor_area |20000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |3 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 13 - U-Shape-MediumOffice-NECB2017-40-Whitehorse-1-1000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |MediumOffice |
| epw_file |CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw |
| total_floor_area |1000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 14 - U-Shape-MediumOffice-NECB2017-40-Vancouver-1-1000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |MediumOffice |
| epw_file |CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw |
| total_floor_area |1000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |1 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 15 - U-Shape-MediumOffice-NECB2017-40-Whitehorse-3-1000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |MediumOffice |
| epw_file |CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw |
| total_floor_area |1000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |3 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 16 - U-Shape-MediumOffice-NECB2017-40-Vancouver-3-1000-1.5
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |U-Shape |
| template |NECB2017 |
| building_type |MediumOffice |
| epw_file |CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw |
| total_floor_area |1000.0 |
| aspect_ratio |1.5 |
| rotation |40.0 |
| above_grade_floors |3 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 17 - test argument ranges--144
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 18 - test argument ranges--145
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 19 - test argument ranges--146
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 20 - test argument ranges--147
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 21 - test argument ranges--148
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 22 - test argument ranges--149
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 23 - test argument ranges--150
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 24 - test argument ranges--151
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 25 - test argument ranges--152
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 26 - test argument ranges--153
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 27 - test argument ranges--154
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 28 - test argument ranges--155
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 29 - test argument ranges--156
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 30 - test argument ranges--157
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 31 - test argument ranges--158
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 32 - test argument ranges--159
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 33 - test argument ranges--160
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 34 - test argument ranges--161
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 35 - test argument ranges--162
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 36 - test argument ranges--163
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 37 - test argument ranges--164
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 38 - test argument ranges--165
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 39 - test argument ranges--166
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 40 - test argument ranges--167
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 41 - test argument ranges--168
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 42 - test argument ranges--169
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 43 - test argument ranges--170
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 44 - test argument ranges--171
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 45 - test argument ranges--172
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 46 - test argument ranges--173
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 47 - test argument ranges--174
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 48 - test argument ranges--175
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 49 - test argument ranges--176
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 50 - test argument ranges--177
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 51 - test argument ranges--178
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 52 - test argument ranges--179
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 53 - test argument ranges--180
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 54 - test argument ranges--181
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 55 - test argument ranges--182
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 56 - test argument ranges--183
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 57 - test argument ranges--184
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 58 - test argument ranges--185
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 59 - test argument ranges--186
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 60 - test argument ranges--187
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 61 - test argument ranges--188
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 62 - test argument ranges--189
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 63 - test argument ranges--190
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 64 - test argument ranges--191
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| epw_file |CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
