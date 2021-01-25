
// Segments in a circle, increase for the final render
$fn = 120;

// My Anet A8, which I use to debug this
//  Nozzle diameter: 0.4mm
//  Layer thickness: 0.08, 0.12, 0.16... in increments of 0.04mm

// Units are mm!
hplug = 7.68;   // Height of the bottom 'plug'
r1    = 7.85; // Bottom radius of the plug
r2    = 9.2; // Upper radius of the plug
rcut  = 7.3; // radius of the cuts in the plug
rr = 2.0;  // rounding at the bottom
ru = 0.2;  // rounding at the top
hc = 0.96; // start height for both cuts
h1 = 2.40; // first cut height
h2 = 1.44;  // second cut height
cc = 0.6;  // cut corner
hd = 1.20;  // supporting disk height
rd = 25.6/2; // supporting disk radius
support_d = 11.0; // supporting distance -- const h when varying rounding
support_r = rd*12; // rounding of the supporting disk
sh = 3.60; // skirt height
skirt_r = 11.7; // skirt radius (11.7 is measured, 0.05 oversintering)
skirt_inr = skirt_r - 0.6; // inner radius (0.6 measured, 0.5 oversintering)
skirt_top = 4.56; // = -z of the skirt top
skirt_cham = 0.12*4; // skirt chamfer height (not used now)

// Cutout angles
c1a0 = 0;
c1a1 = -36;
c1a2 = -66;
c2a0 = 171;
c2a1 = 150;
c2a2 = 125;

// Lock crests (initial angles [ -120, 104, 14 ])
lock_a  = [ -120, 105, 14 ]; // angles of the lock 'crests'
lock_r  = 0.6;  // lock crests radius
lock_h  = 0.72; // heigth of each crest, including radius
lock_r1 = 8.5;  // lock crests start
lock_r2 = rd;   // lock crests end

// Bottom cutouts
cut_o = 5; // offset, where the cutouts start
cut_l = 2; // length of the cutouts
cut_r  = 4;  // radius of the cutout itself
cut_d = 0.36; // depth of the cutouts
cut_a  = [ -64, -153, 118, 27 ]; // angles

// Skirt cuts, angle and depth for each
skirt_cuts = [ [ 13.0, 1.0 ], [ 42.0, 2.2 ], [ 79.0, 2.2 ],
               [ 136, 1.0 ], [ 162.5, 2.2 ],
               [ -13.0, 1.0 ], [ -42.0, 2.2 ], [ -79.0, 2.2 ],
               [ -136, 1.0 ], [ -162.5, 2.2 ] ];
/* skirt_cuts = [ ]; */
skirt_cut_w = 0.8; // width of each cut

// skirt grip height, thickness and angles
skirt_grip_h = 0.8;
skirt_grip_t = 0.6;
skirt_grip_angles = [ [ 42.0-180.0, 79.0-180.0 ],
                      [ -79.0-180.0, -42.0-180.0 ],
                      [ 162.5-180.0, -162.5-180.0 ] ];
/* skirt_grip_angles = [ ]; */

// scirt cutouts for the board assembly grips, [ angle width ]
board_cuts = [ [ -25.5, 3.0 ], [ -125.5, 3.0 ],
               [  25.5, 3.0 ], [  125.5, 3.0 ],];
board_cut_d = 2.5; // 'depth' from the top of the skirt
board_cut_h = 0.6; // height of the cuts



// board assembly directors, angle and h to the skirt top
board_dirs = [ [ 0.0, 0.0 ], [ 205.0-0.5, 0.0 ] ];
dir_width = 0.8; // width of each director
dir_r0 = skirt_inr - 0.8; // starting r of each director

// board assembly supports, angle, width, len
board_sups = [ [ 0.0, 3.0, 1.0 ], [ 112.5, 1.6, 1.6 ],
               [ 190.0, 1.0, 2.0 ], [ -59.5, 1.0, 2.0 ] ];
board_sup_h = 2.1; // height from top of the skirt

// contacts and cradles
cont_r0 = 9.0;
cont_r1 = 10.6;
ccrad_d = 0.36; // contact cradle depth
ccrad_r0 = 8.1; // contact cradle start
ccrad_r1 = 11.0; // contact cradle end

contact_angles = [ [ -72.9, -108.5 ], [ 71.2, 34.6  ] ];
cradle_xangle = 8;
cradle_angles = [ [ -72.9+cradle_xangle, -108.5-+cradle_xangle ],
                  [ 71.2+cradle_xangle, 34.6-cradle_xangle  ] ];

// battery bay
batr = 6.7;  // radius
bath = 7.08; // height

// Sagging of the battery bay
sag_h = 1.0; // height
sag_r = 1.0; // radius increase
sag_r2 = 3.3; // partial sagging radius
sag_a0 = -5.0; // partial sagging start angle
sag_a1 = -55.0; // partial sagging end angle

// reset button hole
reset_a = -138.5; // angle
reset_r = 9.7; // distance from center
reset_hr = 0.7; // hole radius


/**
 * Plug cone
 */
module plug_cone( )
{
  hull()
  {
    rotate_extrude()
    {
      translate([r2-ru, 0]) circle(ru, $fn=8);
      translate([r1-rr, (hplug-rr)]) circle(rr, $fn=24);
    }
  }
}

/**
 * Shape to cut a pie slice, angles a1-a2.
 */
module pie_cut( h, r, a1, a2 )
{
  rotate( [ 0, 0, a1 ] )
  {
    translate( [ -r, 0, 0 ] )
    {
      cube( [ r*2, r*2, h*1.1 ], center = true );
    }
  }
  rotate( [ 0, 0, a2 ] )
  {
    translate( [ r, 0, 0 ] )
    {
      cube( [ r*2, r*2, h*1.1 ], center = true );
    }
  }
}

/**
 * Pie slice of thickness h, radius r, angles a1-a2
 */
module pie( h, r, a1, a2 )
{
  difference( )
    {
      cylinder( h=h, r=r, center = true );
      pie_cut( h, r, a1, a2 );
    }
}

/**
 * Disk on top of the plug
 */
module supporting_disk( )
{
  sr2 = support_r*support_r;
  sd2 = support_d*support_d;
  so = sd2 < 1e5 ? support_r - sqrt( sr2 - sd2 ) : 0.0; // keep support h
  intersection( )
  {
    translate( [ 0, 0, -hd ] ) { cylinder( h=hd+so, r=rd ); }
    if ( support_r < 1e3 )
    {
      translate( [ 0, 0, -(support_r-so) ] ) { sphere( r=support_r, $fn=400 ); }
    }
  }
}

/**
 * Cutout in the plug
 */
module cutout( h, hc, h1, a0, a1, a2 )
{
  difference( )
    {
      union( )
        {
          translate( [ 0, 0, h1/2+hc ] )
          {
            pie( h1, r2, a0, a2 );
          }
          translate( [ 0, 0, h/2+hc ] )
          {
            pie( h, r2, a0, a1 );
          }
          translate( [ 0, 0, h1+hc ] )
          {
            rotate( [ 0, 0, a1 ] )
            {
              translate( [ 0, rcut, 0 ] )
              {
                rotate( [ 0, 45, 0 ] )
                {
                  cube( [ cc*2, cc*5, cc*2 ], center = true );
                }
              }
            }
          }
        }
      translate( [ 0, 0, h/2+hc ] )
        {
          cylinder( h=h*1.1, r=rcut, center = true );
        }
    }
}

// cutouts in the bottom of the plug (remove?)
module bottom_cutouts( )
{
  for ( ang = cut_a )
  {
    rotate( [ 0, 0, ang ] )
    {
      translate( [ 0, cut_o + cut_l/2, hplug + cut_r - cut_d ] )
      {
        rotate( [ 90, 0, 0 ] )
        {
          cylinder( h=cut_l, r=cut_r, center = true );
        }
      }
    }
  }
}

// lock crests on the supporting disk
module lock_crests( )
{
  for ( ang = lock_a )
  {
    rotate( [ 0, 0, ang ] )
    {
      // Rotate crests in accordance with the rounding
      crest_a = asin( support_d / support_r ); // angle
      rotc = [ 0, support_d, 0 ]; // center of rotation
    
      translate ( rotc ) rotate( [ -crest_a, 0, 0 ] ) translate ( -rotc )
      {
        hull( )
        {
          lr = lock_r;
          lh = lock_h - lock_r;
          translate( [ 0, lock_r1 + lr, 0  ] ) { sphere( lr, $fn = 24 ); }
          translate( [ 0, lock_r1 + lr, lh ] ) { sphere( lr, $fn = 24 ); }
          translate( [ 0, lock_r2 - lr, 0  ] ) { sphere( lr, $fn = 24 ); }
          translate( [ 0, lock_r2 - lr, lh ] ) { sphere( lr, $fn = 24 ); }
        }
      }
    }
  }
}

module bottom_plug( )
{
  difference( )
  {
    plug_cone( );

    union( )
    {
      cutout( hplug, hc, h1, c1a0, c1a1, c1a2 );
      cutout( hplug, hc, h2, c2a0, c2a1, c2a2 );
      bottom_cutouts( );
    }
  }
}

// Grips which hold skirt in the upper part
module skirt_grip( )
{
  for ( gangs = skirt_grip_angles )
  {
    difference( )
    {
      cylinder(h = skirt_grip_h,
               r1 = skirt_r,
               r2 = skirt_r+skirt_grip_t );

      pie_cut( skirt_grip_h*2.0, skirt_r*2.0,
               gangs[0], gangs[1] );
    }
  }
}


// Skirt, top at z=0
module skirt( )
{
  difference( )
  {
    union( )
    {
      cylinder( h=sh, r=skirt_r );
      skirt_grip( );
    }
  
    union( )
    {
      // Inner 'hole'
      cylinder( h=sh*4, r=skirt_inr, center=true );
    
      // skirt cuts
      for ( cut = skirt_cuts )
      {
        rotate( [ 0, 0, cut[0] ] )
        {
          translate( [ 0, skirt_r, 0 ] )
          {
            cube( [ skirt_cut_w, skirt_r, cut[1]*2 ], center=true );
          }
        }
      }

      // cuts for the board assembly grips
      for ( cut = board_cuts )
      {
        rotate( [ 0, 0, cut[0] ] )
        {
          translate( [ 0, skirt_r, board_cut_d ] )
          {
            cube( [ cut[1], skirt_r, board_cut_h ], center=true );
          }
        }
      }
    }
  }
}

// board assembly directors
module board_directors( )
{
  for ( bdir = board_dirs )
  {
    dir_l = (skirt_inr+skirt_r)/2.0 - dir_r0; // box length
    dir_h = sh - bdir[1]; // box height
    rotate( [ 0, 0, bdir[0] ] )
    {
      translate( [ 0, dir_r0 + dir_l/2, dir_h/2+bdir[1] ] )
      {
        cube( [ dir_width, dir_l, dir_h ], center=true );
      }
    }
  }
}

// board assembly supports
module board_supports( )
{
  for ( bsup = board_sups )
  {
    sup_r0 = skirt_inr - bsup[2]; // starting r of support
    sup_l = (skirt_inr+skirt_r)/2.0 - sup_r0; // box length
    sup_h = sh - board_sup_h; // box height
    rotate( [ 0, 0, bsup[0] ] )
    {
      translate( [ 0, sup_r0 + sup_l/2, sup_h/2+board_sup_h ] )
      {
        cube( [ bsup[1], sup_l, sup_h ], center=true );
      }
    }
  }
}

// Makes the contact holes geometry, used for both
// holes and the contact cradles around the holes
module contact_holes( cangles, r0, r1, d )
{
  difference( )
  {
    for ( conta = cangles )
    {
      pie( d*2, r1, conta[0], conta[1] );
    }
    cylinder( d*4, r=r0, center=true );
  }
}

module supporting_disk_cutouts( )
{
  // Contact holes
  contact_holes( contact_angles, cont_r0, cont_r1, hd*4 );
  contact_holes( cradle_angles, ccrad_r0, ccrad_r1, ccrad_d );

  // Sagging of the battery bay
  cylinder( h=sag_h, r1=batr+sag_r, r2=batr );
  difference( )
  {
    cylinder( h=sag_h, r1=batr+sag_r2, r2=batr );
    pie_cut( sag_h*2, batr*2, sag_a0, sag_a1 );
  }

  // Skirt inner space
  translate( [ 0, 0, -sh ] )
  {
    cylinder( h=sh, r=skirt_inr );
  }

  // reset button hole
  rotate( [ 0, 0, reset_a ] )
  {
    translate( [ 0, reset_r, 0 ] )
    {
      cylinder( h=sh*2, r=reset_hr, center=true );
    }
  }
}

module battery_bay( )
{
  cylinder( h=bath, r=batr );
}


translate( [ 0, 0, -skirt_top ] )
{
  skirt( );
  board_directors( );
  board_supports( );
}

difference( )
{
  union( )
  {
    bottom_plug( );
    supporting_disk( );
    lock_crests( );

    /* // temporary plug&disk for test print */
    /* difference( ) */
    /* { */
    /*   cylinder( h=bath, r=batr+1.2 ); */
    /*   cylinder( h=bath*2, r=batr-0.12*28 ); */
    /* } */
    /* translate( [ 0, 0, -hd ] ) { cylinder( h=hd, r=rd ); } */
  }


  translate( [ 0, 0, sh-skirt_top ] )
  {
    union( )
    {
      supporting_disk_cutouts( );
      battery_bay( );
    }
  }
}

/* // temporary skirt stub for test print */
/* translate( [ 0, 0, -(sh+hd) ] ) */
/* { */
/*   difference( ) */
/*   { */
/*     cylinder( h=sh, r=rd-0.8 ); */
/*     union( ) */
/*       { */
/*         cube( [ 0.8*2, rd*2, 0.12*20 ], center = true ); */
/*         //contact_holes( contact_angles, cont_r0, cont_r1, hd*40 ); */
/*       } */
/*   } */
/* } */
