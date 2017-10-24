// electronics casing
d_pcb=75; // PCB diameter
t_pcb=1.6+0.3; // PCB thickness + some clearance
h_spacer=6; // space below PCB
d_spacer=8; // spacer diameter
h_parts=12.0; // space above PCB
d_parts=60; // parts placement big diameter
d1_part=12; // part diameter
d_adjhole=4; // adjustment hole diameter
adj_holes=[[5,0],[5,6]];
n_parts=4;
clr_above=1; // clearance above parts
clr_r=1; // radial clearance to PCB
thick=1.5; // wall thickness
clr_halfs=0.5;

connector_w=8; // along circle
connector_l=6; // towards center
connector_h=6; // height
connector_r=34; // connector position radius 

n_screws=8; // number of screws
d_screws=62; // screw center holes diameter
d_hole=3; // each screw hole
d_nut=1.8; // plastic "nut" hole
angle_hole=20; // deg hole angle relative to the connector

d_cable=4; // cable dia
h_cable=12; // height above half
a_cable=-9; // cable position angle

// tight_cable=0.5; // tighten it

// the levitator magnetic core
h1_core=7.35;
d1_core=33;
d2_core=24;
h2_core=4;


ufo_main_d=80;
ufo_top_h=10;
ufo_top_d=24;


module core()
{
  translate([0,0,h1_core/2])
    cylinder(d=d1_core,h=h1_core,$fn=64,center=true);
  translate([0,0,-h2_core/2])
    cylinder(d=d2_core,h=h2_core,$fn=64,center=true);
}


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

module casing(up=1,down=1)
{
  screw_angle=360/n_screws;
  h_feet_above=h_parts+clr_above;
  cable_cut_angle=45;
  l_angular=h_cable/cos(cable_cut_angle);
  w_angular=h_cable*2-2*clr_halfs/cos(cable_cut_angle)*1.1;
  d_angular=clr_halfs/cos(cable_cut_angle);
  
  difference() // for the screw holes
  {
  union()
  {
      // the feet
  for(i=[0:n_screws-1])
    rotate([0,0,screw_angle*i+angle_hole])
    {
      // feet below
      if(down>0.5)
      translate([d_screws/2,0,-t_pcb/2-h_spacer/2])
      difference()
      {
        cylinder(d=d_spacer,h=h_spacer,center=true,$fn=16);
        cylinder(d=d_nut,h=h_spacer+0.01,center=true,$fn=16);
      }
      // feet above
      if(up>0.5)
      translate([d_screws/2,0,t_pcb/2+h_feet_above/2])
      difference()
      {
        cylinder(d=d_spacer,h=h_feet_above,center=true,$fn=16);
        cylinder(d=d_nut,h=h_feet_above+0.01,center=true,$fn=16);
      }
    }
    // the casing
    d_case_out=d_pcb+2*clr_r+2*thick;
    h_case_out=t_pcb+h_spacer+h_feet_above+2*thick;
    d_case_in=d_pcb+2*clr_r;
    h_case_in=t_pcb+h_spacer+h_feet_above;
    n_fine=64;
    difference()
    {
    translate([0,0,h_spacer/2+thick/2])
    difference()
    {
       cylinder(d=d_case_out,h=h_case_out,center=true,$fn=n_fine);
       // cut interior
       cylinder(d=d_case_in,h=h_case_in,center=true,$fn=n_fine);
       // cut adjustment holes
       for(a=[0:len(adj_holes)-1])
       {
         translate([0,0,-h_case_in])
         translate(adj_holes[a])
           cylinder(d=d_adjhole,h=h_case_out+1,center=true,$fn=16);
       }
    }
      // separate halfs
      cylinder(d=d_case_out+0.01,h=clr_halfs,$fn=n_fine,center=true);
      // cut down if not enabled
      if(down < 0.5)
      {
        translate([0,0,-h_case_out/2])
          cylinder(d=d_case_out+0.01,h=h_case_out,$fn=n_fine,center=true);
        rotate([0,0,a_cable])
        translate([0,d_case_out/2,h_cable-w_angular/2*1.1])
        rotate([90,0,0])
        cylinder(d=w_angular*1.1,h=d_case_out,$fn=4,center=true);
      }
      // cut up if not enabled
      if(up < 0.5)
      difference()
      {
        translate([0,0,h_case_out/2])
          cylinder(d=d_case_out+0.01,h=h_case_out,$fn=n_fine,center=true);
        // don't cut the cable holder
        rotate([0,0,a_cable])
        translate([0,d_case_out/2,h_cable-w_angular/2*1.1])
        rotate([90,0,0])
        cylinder(d=w_angular*1.1,h=d_case_out,$fn=4,center=true);
      }
      // cut cable slits, angular
      rotate([0,0,a_cable])
      union()
      {
      translate([0,d_case_out/2,h_cable])
        // translate([])
        for(r=[-1:2:1])
        rotate([0,cable_cut_angle*r,0])
        translate([0,0,-l_angular/2])
        cube([d_angular,d_case_out,l_angular],center=true);
      // cut cable hole
      translate([0,d_case_out/2,h_cable])
        rotate([90,0,0])
        cylinder(d=d_cable,h=h_cable,center=true,$fn=16);
      }
    }
    // connect the cable cut
    if(down>0.5)
    rotate([0,0,a_cable])
    intersection()
    {
      // limit to cable cut area
      translate([0,d_case_out/4,0])
        cube([w_angular,d_case_out/2,clr_halfs],center=true);
    difference()
    {
       cylinder(d=d_case_out,h=h_case_out,center=true,$fn=n_fine);
       // cut interior
       cylinder(d=d_case_in,h=h_case_in,center=true,$fn=n_fine);
    }
    }
  }
    // drill the screw holes
    if(1)
    for(i=[0:n_screws-1])
      rotate([0,0,screw_angle*i+angle_hole])
      {
      // cut holes for feet below
      translate([d_screws/2,0,-h_spacer-3])
          rotate([0,180,0])
          screw_hole();
      }
  }
}

module screw_hole(h_head=5,d_screw_head=5,h_screw_transition=2,l_screw=2)
{
    h=h_head;
    translate([0,0,-l_screw/2-h_head-h_screw_transition])
    union()
    {
      // bigger hole, no contact
          cylinder(d=2.5,h=l_screw+0.01,$fn=6,center=true);
          // head
          translate([0,0,h/2+l_screw/2+h_screw_transition])
            cylinder(d=d_screw_head,h=h,$fn=16,center=true);
          translate([0,0,h_screw_transition/2+l_screw/2])
            cylinder(d2=d_screw_head,d1=2.5,h=h_screw_transition+0.01,$fn=16,center=true);
    }
}

module ufo()
{

  // bottom
  cylinder(d1=ufo_main_d,d2=ufo_top_d,h=ufo_top_h,$fn=8,center=true);    
}


// assembly
if(1)
{
    %pcb();
difference()
{
  casing(up=1,down=1);
  translate([0,-100,0])
    cube([200,200,40],center=true);    
}

  translate([0,0,35])
    // %core();
    ufo();
}

// test adjustment holes by
// printing on paper
if(0)
  projection()
    casing(up=0,down=1);

if(0) // UP
  rotate([180,0,0])
  casing(up=1,down=0);

if(0) // DOWN
  casing(up=0,down=1);


