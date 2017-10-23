// electronics casing

d_pcb=75; // PCB diameter
t_pcb=1.6; // PCB thickness
h_spacer=6; // space below PCB
h_parts=12; // space above PCB
d_parts=60; // parts placement big diameter
d1_part=12; // part diameter
n_parts=4;

connector_w=8; // along circle
connector_l=6; // towards center
connector_h=6; // height
connector_r=34; // connector position radius 

n_screws=8; // number of screws
d_screws=62; // screw center holes diameter
d_hole=3; // each screw hole
d_nut=1.8; // plastic "nut" hole
angle_hole=20; // deg hole angle relative to the connector

// the levitator magnetic core

h1_core=7.35;
d1_core=33;
d2_core=24;
h2_core=4;


module pcb()
{
  screw_angle=360/n_screws;
  difference()
  {
    cylinder(d=d_pcb,h=t_pcb,center=true);
    for(i=[0:n_screws-1])
      rotate([0,0,screw_angle*i+angle_hole])
      translate([d_screws/2,0,0])
      cylinder(d=d_hole,h=t_pcb+0.1,center=true,$fn=6);
  }
  // connector
  translate([0,connector_r,connector_h/2+t_pcb/2])
  cube([connector_w,connector_l,connector_h],center=true);
  // parts (magnets)
  parts_angle=360/n_parts;
  for(i=[0:n_parts-1])
      rotate([0,0,parts_angle*i+angle_hole+screw_angle/2])
      translate([d_parts/2,0,h_parts/2+t_pcb/2])
      cylinder(d=d1_part,h=h_parts,center=true,$fn=16);

}


%pcb();
