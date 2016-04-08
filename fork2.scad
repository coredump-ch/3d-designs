LENGTH = 110;
RADIUS = 15;
TIP_LENGTH = 5;
RUBBERBAND_OFFSET = 10;
RUBBERBAND_WIDTH_OUTER = 5;
RUBBERBAND_WIDTH_INNER = 0.6;
RUBBERBAND_DEPTH = 2;
FORK_WIDTH_1 = 10;
FORK_WIDTH_2 = 20;
FORK_BASE_LENGTH = 104;
FORK_TIP_LENGTH = 18;
FORK_TIP_ANGLE = 10;
FORK_THICKNESS = 3;
CONNECTOR_THICKNESS = 2;
CONNECTOR_LENGTH = 5;
CONNECTOR_TOLERANCE = 0.4;

EXPLODE = 10;
SHOW_TOP = true;
SHOW_BOTTOM = true;

module body() {
	linear_extrude(height=LENGTH, twist=60)
		circle(r=RADIUS, $fn=6);
}

module wedge() {
	rotate_extrude($fn=100)
	translate([RADIUS-RUBBERBAND_DEPTH,0,0])
	polygon(points=[
		[RUBBERBAND_DEPTH,0],
		[RUBBERBAND_DEPTH,RUBBERBAND_WIDTH_OUTER],
		[0,RUBBERBAND_WIDTH_OUTER/2+RUBBERBAND_WIDTH_INNER/2],
		[0,RUBBERBAND_WIDTH_OUTER/2-RUBBERBAND_WIDTH_INNER/2]
	]);
}

module handle() {
    difference() {
        body();
        translate([0, 0, RUBBERBAND_OFFSET])
            wedge();
        translate([0, 0, LENGTH-RUBBERBAND_OFFSET])
            wedge();
    };
    intersection() {
        translate([0,0,LENGTH])
            body();
        translate([0,0,LENGTH-RADIUS*2+TIP_LENGTH])
            sphere(r=RADIUS*2);
    }
}

module fork() {
    // The base
    linear_extrude(height=FORK_THICKNESS)
    polygon(points=[
        [-FORK_WIDTH_1/2,0],
        [-FORK_WIDTH_2/2,FORK_BASE_LENGTH],
        [FORK_WIDTH_2/2,FORK_BASE_LENGTH],
        [FORK_WIDTH_1/2,0],
    ]);

    // The tip
    //
    // Because the rotation is anchored at the zero point,
    // we need to translate the tip to the zero point, then
    // rotate and then translate it back to the original place.
    translate([0,FORK_BASE_LENGTH,0])
    rotate(a=FORK_TIP_ANGLE, v=[1,0,0])
    translate([0,-FORK_BASE_LENGTH,0])
    linear_extrude(height=FORK_THICKNESS)
    polygon(points=[
        [-FORK_WIDTH_2/2,FORK_BASE_LENGTH],
        [-FORK_WIDTH_2/2-0.5,FORK_BASE_LENGTH+FORK_TIP_LENGTH/2],
        [-FORK_WIDTH_2/3,FORK_BASE_LENGTH+FORK_TIP_LENGTH*0.85],
        [0,FORK_BASE_LENGTH+FORK_TIP_LENGTH],
        [FORK_WIDTH_2/3,FORK_BASE_LENGTH+FORK_TIP_LENGTH*0.85],
        [FORK_WIDTH_2/2+0.5,FORK_BASE_LENGTH+FORK_TIP_LENGTH/2],
        [FORK_WIDTH_2/2,FORK_BASE_LENGTH],
    ]);
}

module combined() {
    difference() {
        handle();
        translate([0,FORK_THICKNESS/2,0])
            rotate(a=90, v=[1,0,0])
            fork();
    }
}

module divider() {
    rotate(a=90, v=[1,0,0]) {
        // Straight
        translate([-100,0,-20])
        linear_extrude(height=20)
        square([200,FORK_BASE_LENGTH+50]);
    
        // Angled
        translate([0,FORK_BASE_LENGTH,0])
        rotate(a=FORK_TIP_ANGLE, v=[1,0,0])
        translate([-100,0,-20])
        linear_extrude(height=20)
        square([200,FORK_TIP_LENGTH+50]);
    }
}

module connectors(tolerance) {
    rotate(a=180, v=[0,0,1]) {
        translate([RADIUS/2+1,0,RADIUS])
            rotate(a=35, v=[1,0,0])
            cube([
                CONNECTOR_THICKNESS+tolerance,
                CONNECTOR_LENGTH,
                CONNECTOR_THICKNESS+tolerance
            ], center=true);
        translate([-RADIUS/2-2,0,RADIUS*3])
          rotate(a=35, v=[1,0,0])
            cube([
                CONNECTOR_THICKNESS+tolerance,
                CONNECTOR_LENGTH,
                CONNECTOR_THICKNESS+tolerance
            ], center=true);
        translate([RADIUS/2+2.7,0,RADIUS*5])
            rotate(a=35, v=[1,0,0])
            cube([
                CONNECTOR_THICKNESS+tolerance,
                CONNECTOR_LENGTH,
                CONNECTOR_THICKNESS+tolerance
            ], center=true);
    }
}

if (SHOW_BOTTOM) {
translate([0,-EXPLODE,0]) {
    difference() {
        combined();
        divider();
        connectors(CONNECTOR_TOLERANCE);
    }
}
}

if (SHOW_TOP) {
translate([0,EXPLODE,0]) {
    intersection() {
        combined();
        divider();
    }
    connectors(0);
}
}