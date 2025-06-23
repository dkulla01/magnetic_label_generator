include <Round-Anything/polyround.scad>

labeltext = "placeholder";
textcolor = "white";
bordercolor = "white";
label_text_length = len(labeltext);
font = "Arial L:style=Bold";

letter_size = 13.333;
letter_height = 1;

text_metrics = textmetrics(text=labeltext, font=font, halign="center", valign="center", $fn=64);
label_side_padding = 6;
label_top_and_bottom_padding = 3;
label_base_thickness = 4;
label_base_width = ceil(text_metrics.size[0] + 2 * label_side_padding);
label_base_height = ceil(text_metrics.size[1] + 2 * label_top_and_bottom_padding);
label_base_radius = 3;

magnet_length = 10;
magnet_pocket_thickness = 2;
magnet_pocket_width = 5;
magnet_pocket_height_above_bottom = 0.5;
magnet_pin_push_diameter = 2;
magnet_pocket_inset_from_side = 5;
magnet_pocket_x_offset = label_base_width / 2 - magnet_pocket_width / 2 - magnet_pocket_inset_from_side;

magnet_pocket_min_spacing = 25;

$fn = 32;
magnet_pocket_count = max(
  3,
  1 + floor((label_base_width - 2 * label_side_padding) / magnet_pocket_min_spacing)
);

magnet_pocket_actual_spacing = 2 * magnet_pocket_x_offset / (magnet_pocket_count - 1);

magnet_pocket_indices = [for (i = [0:magnet_pocket_count - 1]) i * magnet_pocket_actual_spacing - magnet_pocket_x_offset];

// we want the magnet to be centered on the label base, so we need the
// magnet pocket to extend 1/2 magnet length past the midline of the base
magnet_pocket_length = label_base_height / 2 + magnet_length / 2;

// we want the pin push cylinder to extend from the end of the magnet pocket
// to the end of the base
magnet_pin_push_length = label_base_height - magnet_pocket_length;

base_radii_points = [
  [-label_base_width / 2, -label_base_height / 2, label_base_radius],
  [-label_base_width / 2, label_base_height / 2, label_base_radius],
  [label_base_width / 2, label_base_height / 2, label_base_radius],
  [label_base_width / 2, -label_base_height / 2, label_base_radius],
];

module magnet_pocket(xCoordOfCenter) {
  magnet_pocket_radii_points = [
    [-magnet_pocket_width / 2, -magnet_pocket_thickness / 2, 0.25],
    [-magnet_pocket_width / 2, magnet_pocket_thickness / 2, 0.25],
    [magnet_pocket_width / 2, magnet_pocket_thickness / 2, 0.25],
    [magnet_pocket_width / 2, -magnet_pocket_thickness / 2, 0.25],
  ];
  translate([xCoordOfCenter, -label_base_height / 2, magnet_pocket_height_above_bottom + magnet_pocket_thickness / 2]) {
    rotate([-90, 0, 0]) {
      union() {

        linear_extrude(magnet_pocket_length) {
          polygon(polyRound(magnet_pocket_radii_points));
        }

        translate([0, 0, magnet_pocket_length]) {
          linear_extrude(magnet_pin_push_length) {
            circle(magnet_pin_push_diameter / 2);
          }
        }
      }
    }
  }
}

module on_top_of_baseplate() {
  translate([0, 0, label_base_thickness]) children();
}

color(textcolor) on_top_of_baseplate() linear_extrude(letter_height) {
      text(text=labeltext, font=font, halign="center", valign="center", $fn=64);
    }
color(bordercolor) on_top_of_baseplate() linear_extrude(letter_height) {
      shell2d(-2, -1) { polygon(polyRound(base_radii_points)); }
    }

difference() {

  extrudeWithRadius(label_base_thickness, r1=0, r2=0.75) {
    polygon(polyRound(base_radii_points));
  }

  for (i = magnet_pocket_indices) {
    magnet_pocket(xCoordOfCenter=i);
  }
}
