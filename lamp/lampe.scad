/**
 * Jessy, 2016.
 * CC BY-SA.
 */
AUSSEN_RADIUS = 34.93;
INNEN_RADIUS = 20;
SEITEN = 6;
AUSSEN_HOEHE = 140;
BODEN_RADIUS = AUSSEN_RADIUS - 0.8;
BODEN_HOEHE = 35;
BODEN_VERBINDUNG_RADIUS = INNEN_RADIUS - 0.8;
BODEN_VERBINDUNG_HOEHE = 30;
SCHALTER_DIMENSIONEN = [9.5, 4, 4];
BAT_HALTER_RADIUS = 27/2;
BAT_HALTER_BODENABSTAND = 12;
INNEN_HOEHE = AUSSEN_HOEHE - BODEN_HOEHE - 1.5;
INNEN_DICKE = 0.8;
LED_RADIUS = 3.2 / 2;
LED_ANZAHL = 4;

module aussen() {
	linear_extrude(AUSSEN_HOEHE, twist=360/6, slices=200)
		circle(r=AUSSEN_RADIUS, $fn=SEITEN);
}

// Basisform des Bodens.
module boden_basis() {
	// Unterer Teil
	linear_extrude(BODEN_HOEHE,
			twist=(360/6)*(BODEN_HOEHE/AUSSEN_HOEHE),
			slices=200*(BODEN_HOEHE/AUSSEN_HOEHE))
		circle(r=BODEN_RADIUS, $fn=SEITEN);

	// Zylinder für Verbindungsstück
	cylinder(r=BODEN_VERBINDUNG_RADIUS, 
			h=BODEN_HOEHE+BODEN_VERBINDUNG_HOEHE, $fn=130);
	
}

// Der Schalter inklusive Kanäle für die Pins.
module schalter() {
	union(){
		translate([-SCHALTER_DIMENSIONEN[0]/2, -SCHALTER_DIMENSIONEN[1]/2, 0])
			cube(SCHALTER_DIMENSIONEN);

		translate([-2.5, 0, 0])
			cylinder(r=0.8,h=50, $fn=50);
		cylinder(r=0.8,h=50, $fn=50);
		translate([2.5, 0, 0])
			cylinder(r=0.8,h=50, $fn=50);
	}
}

// Zylinderförmiger Raum für den Batteriehalter.
module bat_halter(){
	translate([0, 0, BAT_HALTER_BODENABSTAND])
		cylinder(r=BAT_HALTER_RADIUS, h=60, $fn=80);
}

module bodenkerbe() {
	translate([-2.5,10, 0]) 
		rotate([-45, 0, 0])
			cube([5, 2.5, 10]);
		
}
// Alle Teile die vom Boden abgezogen werden.
module boden() {
	difference(){
		boden_basis();
		schalter();
		bat_halter();
		bodenkerbe();
	}
}

// led zylinder
module innen_basis() {
	translate([0, 0, BODEN_HOEHE]) {
		difference(){
			cylinder(r=INNEN_RADIUS+INNEN_DICKE, h=INNEN_HOEHE, $fn=130);
			cylinder(r=INNEN_RADIUS, h=INNEN_HOEHE-INNEN_DICKE, $fn=130);
		}	
	}
}

// LED einzeln
module led(verschiebung=0, rotation=0){
	rotate([0, 0, rotation])
		translate([INNEN_RADIUS-1, 0, BODEN_HOEHE+BODEN_VERBINDUNG_HOEHE+verschiebung])
			rotate([0, 90, 0])
				cylinder(r=LED_RADIUS, h=8, $fn=60);
}

// Alle LEDs zusammen und rotiert
module leds(){
	led(verschiebung=0, rotation=0);
	led(verschiebung=20, rotation=90);
	led(verschiebung=40, rotation=180);
	led(verschiebung=60, rotation=270);
}

// Das innere Rohr mit LED-Löchern
module innen(){
	difference(){
		innen_basis();
		leds();
	}
}


// Hälfte (seite 0 oder 1)
module innen_haelfte(seite) {
	intersection() {
		rotate([0, 0, 45])
			translate([-200, -400*seite, 0])
			cube([400, 400, 400]);
		innen();
	}
}

%aussen();
color("orangered") boden();
innen_haelfte(0);
innen_haelfte(1);
