// Demo script showing different periodic table box types
// This demonstrates how the different configurations work together

include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

// Include the main box script (assumes it's in same directory)
// include <periodic_table_boxes_bosl2.scad>

// For demonstration, let's show a few key box types arranged to show how they connect

// Demo function to create a box with specific parameters
module demo_box(
    box_length=40, box_width=40, box_height=40,
    wall=1.5, floor=2,
    north_open=false, south_open=false,
    suppress_female=false, suppress_male=false,
    card_slot=true, card_side=1,
    show_label=""
) {
    
    // Dovetail parameters
    dt_width = 2;
    dt_height = 2; 
    dt_slide = 1.5;
    dt_slope = 6;
    dt_chamfer = 0.1;
    dt_slop = 0.1;
    epsilon = 0.01;
    
    diff("remove dovetails card_slots") {
        cuboid([box_length, box_width, box_height], anchor=BOTTOM) {
            
            // Interior space
            tag("remove") 
            attach(TOP, BOTTOM, overlap=0)
            cuboid([box_length - 2*wall, box_width - 2*wall, box_height - floor + epsilon]);
            
            // Wall openings
            if (north_open) {
                tag("remove")
                attach(TOP+BACK, BOTTOM, overlap=0)
                cuboid([box_length - 2*wall, wall + epsilon, box_height - floor + epsilon]);
            }
            
            if (south_open) {
                tag("remove")
                attach(TOP+FRONT, BOTTOM, overlap=0)
                cuboid([box_length - 2*wall, wall + epsilon, box_height - floor + epsilon]);
            }
            
            // Male dovetails
            if (!suppress_male) {
                // East side
                tag("dovetails")
                attach(RIGHT, BOTTOM, overlap=0)
                translate([0, 0, box_height/2])
                dovetail("male", width=dt_width, height=dt_height, slide=dt_slide,
                        slope=dt_slope, chamfer=dt_chamfer, $slop=dt_slop, orient=RIGHT);
                
                // North side (if not open)
                if (!north_open) {
                    tag("dovetails")
                    attach(BACK, BOTTOM, overlap=0)
                    translate([0, 0, box_height/2])
                    dovetail("male", width=dt_width, height=dt_height, slide=dt_slide,
                            slope=dt_slope, chamfer=dt_chamfer, $slop=dt_slop, orient=BACK);
                }
            }
            
            // Female dovetails  
            if (!suppress_female) {
                // West side
                tag("remove")
                attach(LEFT, BOTTOM, overlap=0)
                translate([0, 0, box_height/2])
                dovetail("female", width=dt_width, height=dt_height, slide=dt_slide + epsilon,
                        slope=dt_slope, chamfer=dt_chamfer, $slop=dt_slop, orient=LEFT);
                
                // South side (if not open)
                if (!south_open) {
                    tag("remove")
                    attach(FRONT, BOTTOM, overlap=0)
                    translate([0, 0, box_height/2])
                    dovetail("female", width=dt_width, height=dt_height, slide=dt_slide + epsilon,
                            slope=dt_slope, chamfer=dt_chamfer, $slop=dt_slop, orient=FRONT);
                }
            }
            
            // Card slot
            if (card_slot && card_side == 1) {
                tag("card_slots")
                attach(FRONT, BACK, overlap=0)
                translate([0, 0, 15 - box_height/2])  // 10mm from bottom + half slot height
                cuboid([30, 15, 2]) {
                    attach(BACK, FRONT, overlap=0)
                    cuboid([30, wall + epsilon, 2]);
                }
            }
            
            // Label on bottom
            if (show_label != "") {
                attach(BOTTOM, TOP, overlap=-0.5)
                linear_extrude(1)
                text(show_label, halign="center", valign="center", size=6);
            }
        }
    }
}

// Demonstration layout showing different box types
module periodic_table_demo() {
    grid_spacing = 45;
    
    // Top row demonstration
    translate([0 * grid_spacing, 1 * grid_spacing, 0]) 
        demo_box(north_open=true, suppress_female=true, suppress_male=false, show_label="H");
        
    translate([1 * grid_spacing, 1 * grid_spacing, 0])
        demo_box(suppress_female=false, suppress_male=false, show_label="He");
        
    translate([2 * grid_spacing, 1 * grid_spacing, 0])
        demo_box(north_open=true, suppress_female=false, suppress_male=true, show_label="T2");
    
    // Middle row 
    translate([0 * grid_spacing, 0 * grid_spacing, 0])
        demo_box(suppress_female=true, suppress_male=false, show_label="Li");
        
    translate([1 * grid_spacing, 0 * grid_spacing, 0])
        demo_box(suppress_female=false, suppress_male=false, show_label="Be");
        
    translate([2 * grid_spacing, 0 * grid_spacing, 0])
        demo_box(suppress_female=false, suppress_male=true, show_label="Ne");
    
    // Bottom row
    translate([0 * grid_spacing, -1 * grid_spacing, 0])
        demo_box(south_open=true, suppress_female=true, suppress_male=false, show_label="Fr");
        
    translate([1 * grid_spacing, -1 * grid_spacing, 0])
        demo_box(south_open=true, suppress_female=false, suppress_male=false, show_label="Ra");
        
    translate([2 * grid_spacing, -1 * grid_spacing, 0])
        demo_box(south_open=true, suppress_female=false, suppress_male=true, show_label="Og");
    
    // Lanthanide row (separate, below)
    translate([0 * grid_spacing, -2.5 * grid_spacing, 0])
        demo_box(south_open=true, suppress_female=true, suppress_male=false, show_label="La");
        
    translate([1 * grid_spacing, -2.5 * grid_spacing, 0])
        demo_box(south_open=true, suppress_female=false, suppress_male=false, show_label="Ce");
        
    translate([2 * grid_spacing, -2.5 * grid_spacing, 0])
        demo_box(south_open=true, suppress_female=false, suppress_male=true, show_label="Lu");
}

// Create the demonstration
periodic_table_demo();

// Add some explanatory text
translate([0, 120, 0]) {
    linear_extrude(1) 
    text("Periodic Table Box Demo", halign="center", size=8);
    
    translate([0, -15, 0])
    linear_extrude(1)
    text("Red = Male dovetails, Blue = Female dovetails", halign="center", size=4);
    
    translate([0, -25, 0])
    linear_extrude(1)
    text("Open walls shown as gaps", halign="center", size=4);
}