/**
 * Fork handle.
 *
 * Made by coredump hackerspace in Rapperswil, Switzerland.
 * CC BY-SA 3.0.
 *
 * Originally published at https://www.youmagine.com/designs/fork-handle
 *
 */
LENGTH = 110;
RADIUS = 15;
TIP_LENGTH = 5;
RUBBERBAND_OFFSET = 10;
RUBBERBAND_WIDTH_OUTER = 6;
RUBBERBAND_WIDTH_INNER = 0.6;
RUBBERBAND_DEPTH = 3;
FORK_WIDTH_1 = 9.2;
FORK_WIDTH_2 = 19.5;
FORK_BASE_LENGTH = 88;
FORK_MID_LENGTH = 9;
FORK_MID_ANGLE = 6;
FORK_TIP_LENGTH = 9;
FORK_TIP_ANGLE = 13;
FORK_THICKNESS = 3;
CONNECTOR_THICKNESS = 3;
CONNECTOR_LENGTH = 7;
CONNECTOR_TOLERANCE = 0.4;

EXPLODE = 20;
SHOW_RIGHT = true;
SHOW_LEFT = true;

// Calculate FORK_WIDTH_3 using the intercept theorem.
FORK_WIDTH_3 = (
    (FORK_BASE_LENGTH + FORK_MID_LENGTH) * (FORK_WIDTH_2 - FORK_WIDTH_1)
) / FORK_BASE_LENGTH + FORK_WIDTH_1;

// Calculate FORK_MID_OFFSET using basic trigonometry.
FORK_MID_OFFSET = sin(FORK_MID_ANGLE) * FORK_MID_LENGTH;


module body() {
	linear_extrude(height=LENGTH, twist=60, slices=10)
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
            sphere(r=RADIUS*2, $fn=150);
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

    base_length = FORK_BASE_LENGTH;
    base_mid_length = FORK_BASE_LENGTH + FORK_MID_LENGTH;

    // The mid part
    //
    // Because the rotation is anchored at the zero point,
    // we need to translate the mid part to the zero point, then
    // rotate and then translate it back to the original place.
    translate([0,base_length,0])
    rotate(a=FORK_MID_ANGLE, v=[1,0,0])
    translate([0,-base_length,0])
    linear_extrude(height=FORK_THICKNESS)
    polygon(points=[
        [-FORK_WIDTH_2/2,base_length],
        [-FORK_WIDTH_3/2,base_mid_length],
        [FORK_WIDTH_3/2,base_mid_length],
        [FORK_WIDTH_2/2,base_length],
    ]);

    // The tip
    //
    // Same thing again, but now plus some trigonometry
    // to get the horizontal offset that was introduce
    // by putting the mid part at an angle.
    translate([0,0,FORK_MID_OFFSET])
    translate([0,base_mid_length,0])
    rotate(a=FORK_TIP_ANGLE, v=[1,0,0])
    translate([0,-base_mid_length,0])
    linear_extrude(height=FORK_THICKNESS)
    polygon(points=[
        [-FORK_WIDTH_2/2,base_mid_length],
        [-FORK_WIDTH_2/2-0.5,base_mid_length+FORK_TIP_LENGTH/2],
        [-FORK_WIDTH_2/3,base_mid_length+FORK_TIP_LENGTH*0.85],
        [0,base_mid_length+FORK_TIP_LENGTH],
        [FORK_WIDTH_2/3,base_mid_length+FORK_TIP_LENGTH*0.85],
        [FORK_WIDTH_2/2+0.5,base_mid_length+FORK_TIP_LENGTH/2],
        [FORK_WIDTH_2/2,base_mid_length],
    ]);
}

module bottom_rounding() {
    rotate_extrude(angle = 360, $fn=100)
        polygon([[RADIUS/3*2,0], [RADIUS,0], [RADIUS,RADIUS/3*2]]);
}

module combined() {
    difference() {
        handle();
        translate([0,FORK_THICKNESS/2,0])
            rotate(a=90, v=[1,0,0])
            fork();
        bottom_rounding();
    }
}

module divider() {
    base_mid_length = FORK_BASE_LENGTH + FORK_MID_LENGTH;

    rotate(a=90, v=[0,0,1])
    rotate(a=90, v=[1,0,0]) {
        // Base
        translate([-100,0,-20])
        linear_extrude(height=20)
        square([200,150]);
    }
}

module connector(tolerance) {
    rotate(a=-35, v=[0,1,0])
    cube([
        CONNECTOR_LENGTH,
        CONNECTOR_THICKNESS+tolerance,
        CONNECTOR_THICKNESS+tolerance
    ], center=true);
}

module connectors(tolerance) {
    translate([0,RADIUS/2-1,RADIUS])
        connector(tolerance);
    translate([0,-RADIUS/2+1,RADIUS])
        connector(tolerance);
    translate([0,RADIUS/2-1,FORK_BASE_LENGTH-RADIUS])
        connector(tolerance);
    translate([0,-RADIUS/2+1,FORK_BASE_LENGTH-RADIUS])
        connector(tolerance);
}

if (SHOW_LEFT) {
translate([EXPLODE,0,0]) {
    difference() {
        combined();
        divider();
        connectors(CONNECTOR_TOLERANCE);
    }
}
}

if (SHOW_RIGHT) {
translate([-EXPLODE,0,0]) {
    intersection() {
        combined();
        divider();
    }
    connectors(0);
}
}
