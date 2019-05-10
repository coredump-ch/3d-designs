/**
 * Spray nozzle.
 */

$fn=150;

// Total diameter of the base
d_total = 14;
// Diameter of the base hole (diameter of tube)
d_hole = 10;
// Diameter of the nozzle hole
d_output_inner = 0.4;
// Diameter of the nozzle output
d_output_outer = 3;
// Height of the base
h_base = 10;
// Height of the top part
h_top = 5;

module base() {
    difference() {
        cylinder(d=d_total, h=h_base);
        cylinder(d=d_hole, h=h_base);
    }
}

module top() {
    difference() {
        // Outer cone
        cylinder(d1=d_total, d2=d_output_outer, h=h_top);
        // Inner cone
        cylinder(d1=d_hole, d2=d_output_inner, h=h_top-1);
        translate([0, 0, h_top-1])
            cylinder(d1=d_output_inner, d2=d_output_outer, h=1); // Nozzle
    }
}

union() {
    base();
    translate([0, 0, h_base]) {
        top();
    }
}