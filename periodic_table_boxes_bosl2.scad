// Periodic Table Storage Boxes using BOSL2 Joiners
// Version 1.0 - Conversion from custom dovetails to BOSL2 system

include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

echo(version=version(1.0));

/* [Size] */
// Box unit size in mm. This defines the size of 1 'unit' for your box.
BoxUnits = 40;
// Box Height in mm
BoxHeight = 40;
// Box Wall Thickness in mm
BoxWall = 1.5;
// Box Floor Thickness in mm
BoxFloor = 2;
// Box Width in units
BoxWidthUnits = 1;
BoxWidth = BoxWidthUnits * BoxUnits;
// Box Length in units
BoxLengthUnits = 1;
BoxLength = BoxLengthUnits * BoxUnits;

/* [Walls] */
// North Wall open or closed
NorthWallOpen = 0; // [0:Closed, 1:Open]
// South Wall open or closed
SouthWallOpen = 0; // [0:Closed, 1:Open]

/* [BOSL2 Dovetail Settings] */
// Set True to suppress female dovetails
SuppressFemaleDT = 0; // [1:True, 0:False]
// Set True to suppress male dovetails
SuppressMaleDT = 0; // [1:True, 0:False]
// Dovetail width (at wider end) in mm
DTWidth = 2;
// Dovetail height (projection) in mm
DTHeight = 2;
// Dovetail slide length (thickness) in mm
DTSlide = 1.5;
// Dovetail slope (4, 6, or 8 are standard woodworking slopes)
DTSlope = 6;
// Dovetail chamfer amount
DTChamfer = 0.1;
// Printer slop for fit adjustment
DTSlop = 0.1;

/* [Card Slot] */
// Enable card slot for label or identification
EnableCardSlot = true; // [true:Enabled, false:Disabled]
// Width of the card to insert (mm)
CardWidth = 30;
// Height of the card slot (mm)
CardSlotHeight = 2;
// Depth of the card slot (how far it extends into the box) (mm)
CardSlotDepth = 15;
// Clearance for the card (makes the slot slightly larger) (mm)
CardClearance = 0.5;
// Vertical position of the card slot from bottom (mm)
CardSlotYPos = 10;
// Which side to place the card slot (0=None, 1=South, 2=North, 3=Both)
CardSlotSide = 1; // [0:None, 1:South, 2:North, 3:Both]

/* [Hidden] */
// Small value for ensuring proper differences and unions
epsilon = 0.01;

// Build text for bottom
DTTxt = str("BOSL2 DT:", DTWidth, "x", DTHeight);
SizeTxt = str(BoxUnits, "x", BoxHeight, "x", BoxWall);

// Main box creation module
module create_box() {
    diff("remove dovetails card_slots") {
        // Main box structure
        cuboid([BoxLength, BoxWidth, BoxHeight], anchor=BOTTOM) {
            
            // Create interior space
            tag("remove") 
            attach(TOP, BOTTOM, overlap=0)
            cuboid([
                BoxLength - 2*BoxWall, 
                BoxWidth - 2*BoxWall, 
                BoxHeight - BoxFloor + epsilon
            ]);
            
            // North wall opening
            if (NorthWallOpen) {
                tag("remove")
                attach(TOP+BACK, BOTTOM, overlap=0)
                cuboid([
                    BoxLength - 2*BoxWall,
                    BoxWall + epsilon,
                    BoxHeight - BoxFloor + epsilon
                ]);
            }
            
            // South wall opening  
            if (SouthWallOpen) {
                tag("remove")
                attach(TOP+FRONT, BOTTOM, overlap=0)
                cuboid([
                    BoxLength - 2*BoxWall,
                    BoxWall + epsilon,
                    BoxHeight - BoxFloor + epsilon
                ]);
            }
            
            // Male dovetails on East (right) side
            if (!SuppressMaleDT && BoxLengthUnits > 0) {
                for (i = [0:BoxLengthUnits-1]) {
                    tag("dovetails")
                    attach(RIGHT, BOTTOM, overlap=0)
                    translate([0, (i - (BoxLengthUnits-1)/2) * BoxUnits, BoxHeight/2])
                    dovetail("male", 
                        width=DTWidth, 
                        height=DTHeight, 
                        slide=DTSlide,
                        slope=DTSlope,
                        chamfer=DTChamfer,
                        $slop=DTSlop,
                        orient=RIGHT
                    );
                }
            }
            
            // Male dovetails on North (back) side
            if (!SuppressMaleDT && BoxWidthUnits > 0) {
                for (i = [0:BoxWidthUnits-1]) {
                    tag("dovetails")
                    attach(BACK, BOTTOM, overlap=0)
                    translate([(i - (BoxWidthUnits-1)/2) * BoxUnits, 0, BoxHeight/2])
                    dovetail("male",
                        width=DTWidth,
                        height=DTHeight, 
                        slide=DTSlide,
                        slope=DTSlope,
                        chamfer=DTChamfer,
                        $slop=DTSlop,
                        orient=BACK
                    );
                }
            }
            
            // Female dovetails on West (left) side
            if (!SuppressFemaleDT && BoxLengthUnits > 0) {
                for (i = [0:BoxLengthUnits-1]) {
                    tag("remove")
                    attach(LEFT, BOTTOM, overlap=0)
                    translate([0, (i - (BoxLengthUnits-1)/2) * BoxUnits, BoxHeight/2])
                    dovetail("female",
                        width=DTWidth,
                        height=DTHeight,
                        slide=DTSlide + epsilon,
                        slope=DTSlope,
                        chamfer=DTChamfer,
                        $slop=DTSlop,
                        orient=LEFT
                    );
                }
            }
            
            // Female dovetails on South (front) side
            if (!SuppressFemaleDT && BoxWidthUnits > 0) {
                for (i = [0:BoxWidthUnits-1]) {
                    tag("remove")
                    attach(FRONT, BOTTOM, overlap=0)
                    translate([(i - (BoxWidthUnits-1)/2) * BoxUnits, 0, BoxHeight/2])
                    dovetail("female",
                        width=DTWidth,
                        height=DTHeight,
                        slide=DTSlide + epsilon,
                        slope=DTSlope,
                        chamfer=DTChamfer,
                        $slop=DTSlop,
                        orient=FRONT
                    );
                }
            }
            
            // Card slot on South wall
            if (EnableCardSlot && (CardSlotSide == 1 || CardSlotSide == 3)) {
                tag("card_slots")
                attach(FRONT, BACK, overlap=0)
                translate([0, 0, CardSlotYPos + CardSlotHeight/2 - BoxHeight/2])
                cuboid([
                    CardWidth + CardClearance * 2,
                    CardSlotDepth,
                    CardSlotHeight
                ]) {
                    // External slot opening
                    attach(BACK, FRONT, overlap=0)
                    cuboid([
                        CardWidth + CardClearance * 2,
                        BoxWall + epsilon,
                        CardSlotHeight
                    ]);
                }
            }
            
            // Card slot on North wall
            if (EnableCardSlot && (CardSlotSide == 2 || CardSlotSide == 3)) {
                tag("card_slots")
                attach(BACK, FRONT, overlap=0)
                translate([0, 0, CardSlotYPos + CardSlotHeight/2 - BoxHeight/2])
                cuboid([
                    CardWidth + CardClearance * 2,
                    CardSlotDepth,
                    CardSlotHeight
                ]) {
                    // External slot opening
                    attach(FRONT, BACK, overlap=0)
                    cuboid([
                        CardWidth + CardClearance * 2,
                        BoxWall + epsilon,
                        CardSlotHeight
                    ]);
                }
            }
            
            // Add info text to bottom
            attach(BOTTOM, TOP, overlap=-0.5)
            translate([0, BoxWidth/8, 0]) {
                linear_extrude(1)
                text(DTTxt, halign="center", valign="center", size=3);
                
                translate([0, -BoxWidth/4, 0])
                linear_extrude(1)
                text(SizeTxt, halign="center", valign="center", size=3);
            }
        }
    }
}

// Create the box
create_box();