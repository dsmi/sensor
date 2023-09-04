// Sony tennis sensor mount optimized for FDM printing.

// Segments in a circle, increase for the final render
$fn = 600;

// My Anet A8, which I use to debug this
//  Nozzle diameter: 0.4mm
//  Layer thickness: 0.08, 0.12, 0.16... in increments of 0.04mm

// Units are mm!
outer_r   = 30/2; // outer disk radius
outer_h   = 0.2;//2.76; // outer disk height
support_r = 25.5/2; // supporting disk radius
support_h = 0.6;  // distance from support to base at support_r
support_s = 25.6/2*12; // rounding of the supporting disk
hplug = 7.44+support_h; // Height of the bottom 'plug'
r1    = 8.2; // Bottom radius of the plug
r2    = 9.2; // Upper radius of the plug
rr = 2.0;  // rounding at the bottom
ru = 0.2;  // rounding at the top

lock_a = [ 180+120, 180-105, 180-14 ]; // angles of the lock 'crests'
lock_ea0 = 36; // lock entrance start angle
lock_ea1 = 8; // lock entrance end angle

// tongues which hold the sensor
tongue_top = -1.2; // top, relative to support_h
tongue_r0 = 7.5;  // inner radius
tongue_r1 = 12.0; // outer radius
tongues = [ [ 45+8, 45-8, 1.2 ], // start-end angles and thickness
            [ 225+16, 225-16, 2.16 ] ]; 

// Trap door, opening, clips
tdw = 27.5;  // width
tdh = 25.5;  // height
tdd = 27.5;  // distance between the diagonal bevels
tdl = 3.6;   // length (depth)
a   = 45;    // diagonal bevels angle
tow = 22.5;  // width of the opening
toh = 20.5;  // height of the opening
tod = 22.5;  // distance between diagonals of the opening
tol = 1.25;   // length/depth of the opening (where the clips start)
tcl = 1.6;   // length/depth of the trap door clips
tcx = 1.2;   // how much to the clips exapnd

// support disc cutout (to remove the sensor) width
dcw = 2.8;

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

module plug_cone( )
{
   translate( [ 0, 0, outer_h + support_h ] )
   {
      rotate( [ 180, 0, 0 ] )
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
   }
}

// Disk that the sensor lies on
module support_disk( )
{
   // support normal angle at support_r from center
   supa = asin( support_r/support_s );

   outz = outer_h + support_s*cos(supa); // z of the outer rounding sphere
   difference( )
   {
      cylinder( h=outer_h, r=outer_r );
      translate( [ 0, 0, outz ] ) sphere( r=support_s/*, $fn=400*/ );
   }

   suph = outer_h+support_h/cos(supa); // support disk edge height above z=0
   supz = suph + support_s*cos(supa); // z of the rounding sphere

   // cut box dimensions
   cbox_side = sqrt( 2*pow(2*support_h,2) );
   cbox_size = [ cbox_side, support_r, cbox_side ]; 

   // entrance cut box dimensions
   ebox_width = support_r * sin( (lock_ea0-lock_ea1)/2.0 );
   ebox_size = [ ebox_width, support_r, ebox_width*2 ];
   
   difference( )
   {
      cylinder( h=suph*2.0, r=support_r );
      translate( [ 0, 0, supz ] ) sphere( r=support_s/*, $fn=400*/ );

      for ( ang = lock_a )
      {
         rotate( [ 0, 0, ang ] )
         {
            translate( [ 0, support_r, outer_h + 1.9*support_h ] )
            {
               rotate( [ supa, 0, 0 ] ) rotate( [ 0, 45, 0 ] )
               {
                  cube( cbox_size, center=true );
               }
            }
         }
      }

      for ( ang = lock_a )
      {
         rotate( [ 0, 0, ang+lock_ea0 ] )
         {
            translate( [ 0, support_r, outer_h + support_h ] )
            {
               rotate( [ supa, 0, 0 ] )
               {
                  translate( [ ebox_width/2, 0, 0 ] )
                  {
                     cube( ebox_size, center=true );
                  }
               }
            }
         }
      }
      
      for ( ang = lock_a )
      {
         rotate( [ 0, 0, ang+lock_ea1 ] )
         {
            translate( [ 0, support_r, outer_h + support_h ] )
            {
               rotate( [ supa, 0, 0 ] ) rotate( [ 0, 60, 0 ] )
               {
                  translate( [ -ebox_width/2, 0, 0 ] )
                  {
                     cube( ebox_size, center=true );
                  }
               }
            }
         }
      }
   }
}

module trap_door_cutout( )
{
   // Length of the cutting box, we just need some large
   // enough value
   l = outer_r;

   // Distance from the center to cutout
   r = tdh/2 - 1;

   // Height of the cutting box, some value > door h
   h = tdh*5;

   translate( [ 0, r+l/2, 0 ] )
   {
      cube( [ dcw, l, h ], center = true );
   }
}

module trap_door_diagonal_edges( d, l )
{
   intersection( )
   {
      rotate( [ 0, 0, a ] )
      {
         cube( [ d, d*2, l ], true );
      }
      rotate( [ 0, 0, -a ] )
      {
         cube( [ d, d*2, l ], true );
      }
   }
}

// Trap door which has the shape of hexagonal prism
module trap_door( w, h, d, l )
{
   intersection( )
   {
      cube( [ w, h, l ], true );
      trap_door_diagonal_edges( d, l );
   }
}

module trap_door_clips( w, h, d, l, x )
{
   intersection( )
   {
      wl = 0.08; // length of the wide part of the clips
      hull( )
      {
         translate( [ 0, 0, l/2 - wl/2 ] )
         {
            cube( [ w+x, h+x, wl ], true );
         }
         cube( [ w, h, l ] , true );
      }
      trap_door_diagonal_edges( d, l );
   }
}


// Supporting structure which is inside the grip.
module support_inner( )
{
   translate( [ 0, 0, -tdl/2 ] )
   {
      trap_door( tdw, tdh, tdd, tdl );
   }
   translate( [ 0, 0, -(tdl + tol/2) ] )
   {
      trap_door( tow, toh, tod, tol );
   }
   translate( [ 0, 0, -(tdl + tol + tcl/2) ] )
   {
      trap_door_clips( tow, toh, tod, tcl, tcx );
   }
}

difference( )
{
   difference( )
   {
      union( )
      {
         intersection( )
         {
            support_disk( );
            trap_door( tdw, tdh, tdd, support_h*5 );
         }
         support_inner( );
      }
      trap_door_cutout( );
   }
   plug_cone( );
}

difference( )
{
   for ( tongue = tongues )
   {
      lz = tongue_top + outer_h + support_h - tongue[2]/2;
      translate( [ 0, 0, lz ] )
      {
         pie( tongue[2], tongue_r1, tongue[0], tongue[1] );
      } 
   }
   cylinder( r=tongue_r0, h=hplug, center=true );
}
