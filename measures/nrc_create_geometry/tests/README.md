# Summary Of Test Cases for 'NRCCREATEGEOMETRY' Measure
 
The following describe the parameter tests that are conducted on the measure. Note some of the 
tests are designed to return a fail and some a success. The report below contains all the tests that 
have the correct response. For example the argument range limit tests are expected to fail. 
 
## 1 - L-Shape-HighriseApartment-NECB2020-10-12-40000-2.0 Saint.John TMY 3
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |L-Shape |
| template |NECB2020 |
| building_type |HighriseApartment |
| location |Saint.John |
| weather_file_type |TMY |
| global_warming |3.0 |
| total_floor_area |40000.0 |
| aspect_ratio |2.0 |
| rotation |10.0 |
| above_grade_floors |12 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 2 - L-Shape-HighriseApartment-NECB2020-10-12-40000-2.0 Edmonton TMY 3
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |L-Shape |
| template |NECB2020 |
| building_type |HighriseApartment |
| location |Edmonton |
| weather_file_type |TMY |
| global_warming |3.0 |
| total_floor_area |40000.0 |
| aspect_ratio |2.0 |
| rotation |10.0 |
| above_grade_floors |12 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 3 - Rectangular-HighriseApartment-NECB2020-10-12-40000-2.0 Saint.John TMY 3
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2020 |
| building_type |HighriseApartment |
| location |Saint.John |
| weather_file_type |TMY |
| global_warming |3.0 |
| total_floor_area |40000.0 |
| aspect_ratio |2.0 |
| rotation |10.0 |
| above_grade_floors |12 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 4 - Rectangular-HighriseApartment-NECB2020-10-12-40000-2.0 Edmonton TMY 3
 
This test was expected to pass and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2020 |
| building_type |HighriseApartment |
| location |Edmonton |
| weather_file_type |TMY |
| global_warming |3.0 |
| total_floor_area |40000.0 |
| aspect_ratio |2.0 |
| rotation |10.0 |
| above_grade_floors |12 |
| floor_to_floor_height |3.2 |
| plenum_height |0.0 |
| sideload |false |
 
## 5 - test argument ranges
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 6 - test argument ranges--1
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 7 - test argument ranges--2
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 8 - test argument ranges--3
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 9 - test argument ranges--4
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 10 - test argument ranges--5
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 11 - test argument ranges--6
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 12 - test argument ranges--7
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 13 - test argument ranges--8
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 14 - test argument ranges--9
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 15 - test argument ranges--10
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 16 - test argument ranges--11
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 17 - test argument ranges--12
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 18 - test argument ranges--13
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 19 - test argument ranges--14
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 20 - test argument ranges--15
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 21 - test argument ranges--16
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 22 - test argument ranges--17
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 23 - test argument ranges--18
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 24 - test argument ranges--19
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 25 - test argument ranges--20
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 26 - test argument ranges--21
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 27 - test argument ranges--22
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 28 - test argument ranges--23
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 29 - test argument ranges--24
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 30 - test argument ranges--25
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 31 - test argument ranges--26
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 32 - test argument ranges--27
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 33 - test argument ranges--28
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 34 - test argument ranges--29
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 35 - test argument ranges--30
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 36 - test argument ranges--31
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 37 - test argument ranges--32
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 38 - test argument ranges--33
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 39 - test argument ranges--34
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 40 - test argument ranges--35
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
## 41 - test argument ranges--36
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |10000001.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 42 - test argument ranges--37
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |9.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 43 - test argument ranges--38
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |11.0 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 44 - test argument ranges--39
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |-0.9 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 45 - test argument ranges--40
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |361.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 46 - test argument ranges--41
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |-1.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 47 - test argument ranges--42
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 48 - test argument ranges--43
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |201 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 49 - test argument ranges--44
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |0 |
| floor_to_floor_height |3.2 |
| plenum_height |1.0 |
| sideload |false |
 
## 50 - test argument ranges--45
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |11.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 51 - test argument ranges--46
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |1.0 |
| plenum_height |1.0 |
| sideload |false |
 
## 52 - test argument ranges--47
 
This test was expected to generate an error and it did.
 
| Test Argument | Test Value |
| ------------- | ---------- |
| building_shape |Rectangular |
| template |NECB2017 |
| building_type |SmallOffice |
| location |Calgary |
| weather_file_type |ECY |
| global_warming |0.0 |
| total_floor_area |50000.0 |
| aspect_ratio |0.5 |
| rotation |30.0 |
| above_grade_floors |2 |
| floor_to_floor_height |3.2 |
| plenum_height |3.0 |
| sideload |false |
 
