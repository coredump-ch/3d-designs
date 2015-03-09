corner_radius = 4;
thickness = 10;
base_width = 30;
nail_radius = 1;
nail_head_depth = 1;
nail_head_radius = 2;

module base_raw() {
	hull() {
		translate([0, - corner_radius])
			circle(r=0.01, $fn=50);
		translate([0, corner_radius])
			circle(r=0.01, $fn=50);
		translate([base_width - corner_radius, 0])
			circle(r=corner_radius, $fn=50);
	};
};

// Covers the LED strip
module base() {
	linear_extrude(thickness) intersection() {
		base_raw();
		square([999, 999]);
	}
};

// Nail goes in here
module nail_socket() {
	difference() {
		cube([thickness, thickness, thickness]);
		rotate(a=[270, 0, 0]) translate([thickness/2, -thickness/2])
			cylinder(h=thickness, r=nail_radius, $fn=50);
	};
	cylinder(h=nail_head_depth, r=nail_radius, $fn=50);
};

// This is the final stuff
union() {
	base();
	nail_socket();
}