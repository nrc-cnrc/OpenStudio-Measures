#!/bin/bash
uuid="[[:alnum:]]8\-[[:alnum:]]4"
diff -y --suppress-common-lines NECB2015-Warehouse-Thompson_EWY_3.osm Warehouse-NECB2015-Thompson_EWY_3.osm | grep -o "[[:alnum:]]{8}"
#[[:alnum:]]4\-[[:alnum:]]4'
#[[:alnum:]]12'
