// electronics casing
d_pcb=75; // PCB diameter
t_pcb=1.6+0.3; // PCB thickness + some clearance
h_spacer=6; // space below PCB
d_spacer=8; // spacer diameter
h_parts=12; // space above PCB
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


ufo_main_d=90;
ufo_top_h=14;
ufo_top_d=40;
ufo_cut_h=5;
ufo_cut_t=0.1;
ufo_thick=0.8;
ufo_d2_clr=0.5; // core holder clearance

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
      translate([d_screws/2,0,t_pcb/2+(h_feet_above+clr_above)/2])
      difference()
      {
        cylinder(d=d_spacer,h=h_feet_above+clr_above,center=true,$fn=16);
        cylinder(d=d_nut,h=h_feet_above+clr_above+0.01,center=true,$fn=16);
      }
    }
    // the casing
    d_case_out=d_pcb+2*clr_r+2*thick;
    h_case_out=t_pcb+h_spacer+h_feet_above+2*thick+clr_above;
    d_case_in=d_pcb+2*clr_r;
    h_case_in=h_case_out-2*thick;
    n_fine=128;
    difference()
    {
    translate([0,0,h_case_out/2-h_spacer-thick-t_pcb/2])
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

module screw_hole(h_head=5,d_screw_head=5,h_screw_transition=2,l_thru=2,d_nut=1.8,l_nut=3,d_thru=2.5)
{
    h=h_head;
    translate([0,0,-l_thru/2-h_head-h_screw_transition])
    union()
    {
      // nut hole
      //cylinder(d=d_nut,h=
      translate([0,0,-l_thru/2-l_nut/2])
      cylinder(d=d_nut,h=l_nut+0.01,$fn=6,center=true);

      // bigger hole, no contact
          cylinder(d=d_thru,h=l_thru+0.01,$fn=6,center=true);
          // head
          translate([0,0,h/2+l_thru/2+h_screw_transition])
            cylinder(d=d_screw_head,h=h,$fn=16,center=true);
          // transition
          translate([0,0,h_screw_transition/2+l_thru/2])
            cylinder(d2=d_screw_head,d1=2.5,h=h_screw_transition+0.01,$fn=16,center=true);
    }
}

module ufo(up=1,down=1)
{
  nseg=8;
  n_ft=4;
  a_ft=360/n_ft;
  a_ft_start=a_ft/4;
  x_ft=25;
  difference()
  {
  union()
  {
  difference()
  {
    // main
    cylinder(d1=ufo_main_d,d2=ufo_top_d,h=ufo_top_h,$fn=nseg,center=true);
    // cut interior
    a_hull=atan(ufo_top_h/(ufo_main_d-ufo_top_d)/2);
    inter_main_d=ufo_main_d*cos(a_hull)*0.93; // dirty fix
    inter_top_d=ufo_top_d*cos(a_hull);
    cylinder(d1=inter_main_d,d2=inter_top_d-2*ufo_thick,h=ufo_top_h-ufo_thick*2,$fn=nseg,center=true);
  }
  // feet
  intersection()
  {
      // trim off enclosing shape
      cylinder(d1=ufo_main_d,d2=ufo_top_d,h=ufo_top_h,$fn=nseg,center=true);
      // the feet
      for(i=[0:n_ft-1])
        rotate([0,0,a_ft*i+a_ft_start])
          translate([x_ft,0,0])
            cylinder(d=8,h=20,$fn=16,center=true);
  }
  // core holder
  translate([0,0,-ufo_top_h/2+ufo_thick+(h2_core-ufo_d2_clr)/2-0.01])
  difference()
  {
    cylinder(d=d2_core+ufo_d2_clr+2*ufo_thick,h=h2_core-ufo_d2_clr,$fn=64,center=true);
    cylinder(d=d2_core+ufo_d2_clr+0*ufo_thick,h=h2_core,$fn=64,center=true);
  }
  }
    // 2-parts cut
    translate([0,0,-ufo_top_h/2+ufo_cut_h])
      cylinder(d=ufo_main_d,h=ufo_cut_t,$fn=nseg,center=true);
    // cut down part if disabled
    if(down < 0.5)
    translate([0,0,-ufo_top_h/2+ufo_cut_h-ufo_top_h/2])
      cylinder(d=ufo_main_d,h=ufo_top_h,$fn=nseg,center=true);
    // cut up part if disabled
    if(up < 0.5)
    translate([0,0,-ufo_top_h/2+ufo_cut_h+ufo_top_h/2])
      cylinder(d=ufo_main_d,h=ufo_top_h,$fn=nseg,center=true);

    // the screw holes
      for(i=[0:n_ft-1])
        rotate([0,0,a_ft*i+a_ft_start])
          translate([x_ft,0,-ufo_top_h/2-0.01])
            rotate([180,0,0])
            screw_hole(h_head=2,l_thru=1,l_nut=4.6);        
  }

}


// assembly
if(1)
{
    %pcb();
  difference()
  {
  casing(up=1,down=1);
  rotate([0,0,15])
  translate([0,-100,0])
    cube([200,200,40],center=true);    
  }

  translate([0,0,35])
  {
        difference()
  {
    ufo();
    if(1)
    translate([0,-100,0])
      cube([100,200,100],center=true);
  }

    translate([0,0,-ufo_top_h/2+ufo_thick+h2_core])
      %core();
  }
}

// test adjustment holes by
// printing on paper
if(0)
  projection()
    casing(up=0,down=1);

if(0) // base UP
  rotate([180,0,0])
  casing(up=1,down=0);

if(0) // base DOWN
  casing(up=0,down=1);

if(0) // UFO UP
  rotate([180,0,0])
  ufo(up=1,down=0);

if(0) // base DOWN
  ufo(up=0,down=1);

