corner_radius = 4;
thickness = 10;
base_width = 30;

module base() {
	hull() {
		translate([0, - corner_radius])
			circle(r=0.01, $fn=50);
		translate([0, corner_radius])
			circle(r=0.01, $fn=50);
		translate([base_width - corner_radius, 0])
			circle(r=corner_radius, $fn=50);
	};
};

module halfbase() {
	intersection() {
		base();
		square([999, 999]);
	}
}

linear_extrude(thickness) halfbase();