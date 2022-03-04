

###### (Automatically generated documentation)

# NrcRenameNodes

## Description
This measure loops through a model and update the node names based on the component type before it in all of the supply side of plant loops , air loops and air Loop outdoor air systems.

## Modeler Description
The measure loops through the plant/air loops, and for each loop extracts the supply side.
            Then the measure would identify the nodes and the component before it in the supply side branch, and
            rename the nodes name as 'Plant/Air/OutdoorAir LoopName'-'Supply'-ComponentName'-'Leaving' 

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Rename nodes of the supply side of plant loops and air loops.

**Name:** rename_nodes,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false






## Automated Testing
A summary of the arguments and values used in the automated testing of this measure is [here](./tests/README.md).
