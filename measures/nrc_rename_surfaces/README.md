

###### (Automatically generated documentation)

# NrcRenameSurfaces

## Description
New measure to go through a model and update the names of surfaces and sub surfaces based on their connection type and orientation.

## Modeler Description
Replace surfaces and sub surfaces with new names as follows :
            Walls
            Exterior walls -> ExtWall-Orientation (where Orientation is N, S, E, W)
            Basement walls -> BasementWall-Orientation (where Orientation is N, S, E, W and the wall is below grade)
            Interior walls -> IntWall-OtherZone (where OtherZone is the name of the space on the other side)
            Windows
            Exterior windows -> ExtWindow-Orientation (where Orientation is N, S, E, W)
            Skylights -> ExtSkylight
            Roof/Floors
            Roof -> Roof (horizontal surface connected to the outside)
            Interior Floor -> Floor-OtherZone (where OtherZone is the name of the space on the other side)
            Interior Ceiling -> Ceiling-OtherZone (where OtherZone is the name of the space on the other side)
            Ground floor -> GroundFloor (i.e. the floor surface connected to the ground not a space below)

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Rename all surfaces and sub surfaces of the model.

**Name:** rename_all_surfaces,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false




