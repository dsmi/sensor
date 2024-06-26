// Sony tennis sensor mount optimized for FDM printing.

// Segments in a circle, increase for the final render
$fn = 600;

// My Anet A8, which I use to debug this
//  Nozzle diameter: 0.4mm
//  Layer thickness: 0.08, 0.12, 0.16... in increments of 0.04mm

// Units are mm!
outer_r   = 25.5/2; // outer disk radius (same as support here)
outer_h   = 0.0; // outer disk height. Level with the trap door top
support_r = 25.5/2; // supporting disk radius
support_h = 0.6;  // distance from support to base at support_r
support_s = 25.6/2*12; // rounding of the supporting disk
hplug = 7.44+support_h; // Height of the bottom 'plug'
r1    = 8.1; // Bottom radius of the plug
r2    = 9.4; // Upper radius of the plug
rr = 2.0;  // rounding at the bottom
ru = 0.2;  // rounding at the top

lock_a = [ 180+120, 180-105, 180-14 ]; // angles of the lock 'crests'
lock_ea0 = 36; // lock entrance start angle
lock_ea1 = 8; // lock entrance end angle

// tongues which hold the sensor
tongue_r0 = 7.5;  // inner radius
tongue_r1 = 10.3; // outer radius
//
// Fields are: start-end angles; thickness; top relative to support_h
tongue_bodies  = [ [ 45+10,   45-10,   1.2, -1.2 ], 
                   [ 225+18, 225-18, 1.2, -(1.2+0.96) ] ];

tongue_cutouts = [ [ 45+15,   45-15, 12, 0 ], 
                   [ 225+23, 225-23, 12, 0 ] ];

tongue_holes =   [ [ 225+8, 225-8, 6, 0 ] ];

tongue_holes_r0 = 8.7;  // inner radius

// Trap door, opening, clips
tdw = 27.5;  // width
tdh = 25.5;  // height
tdd = 27.5;  // distance between the diagonal bevels
tdl = 3.6;   // length (depth)
a   = 45;    // diagonal bevels angle
tow = 23.2;  // width of the opening
toh = 21.2;  // height of the opening
tod = 23.2;  // distance between diagonals of the opening
tol = 1.1;   // length/depth of the opening (where the clips start)
tcl = 1.6;   // length/depth of the trap door clips
tcx = 0.6;   // how much to the clips exapnd

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

   // bottom of the outer disk, lowest point of the outer sphere
   outb = outz - support_s;
   
   difference( )
   {
      translate( [ 0, 0, outb ] ) cylinder( h=support_r, r=outer_r );
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
      translate( [ 0, 0, outb ] ) cylinder( h=support_r, r=support_r );
      
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
   l = tdh;

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
         // offset by x/2 to make upper edge 45 degrees so it
         // can be printed wo support
         translate( [ 0, 0, l/2 - wl/2 - x/2 ] )
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

module tongues( tongue_dimensions, r0 )
{
   difference( )
   {
      for ( tongue = tongue_dimensions )
      {
         tongue_top = tongue[3];
         tongue_thickness = tongue[2];
         lz = outer_h + support_h + tongue_top - tongue_thickness/2;
         translate( [ 0, 0, lz ] )
         {
            pie( tongue_thickness, tongue_r1, tongue[0], tongue[1] );
         } 
      }
      cylinder( r=r0, h=hplug, center=true );
   }
}

module mount( )
{
   difference( )
   {
      difference( )
      {
         difference( )
         {
            union( )
            {
               // Support disk, bounded by the trap door
               intersection( )
               {
                  support_disk( );
                  trap_door( tdw, tdh, tdd, support_h*5 );
               }
               
               // Inner part of the support. Subtract (convex hull of)
               // supporting disk from it so we can lower the disk
               difference( )
               {
                  support_inner( );
                  hull( ) { support_disk( ); }
               }
            }
            // prying cutout
            trap_door_cutout( );
         }
         plug_cone( );
      }
      tongues( tongue_cutouts, tongue_r0 );
   }

   difference( )
   {
      tongues( tongue_bodies,   tongue_r0    );
      tongues( tongue_holes, tongue_holes_r0 );
   }
}


// // where we clip it if printing by parts
// clipcs = tdw*3;
// clipz  = support_h + outer_h + tongue_bodies[0][3];

// difference( )
// {
//    mount( );

//    translate( [ 0, 0, clipcs/2 + clipz ] ) { cube( clipcs, center=true ); }
// }

// this renders the entire thing
mount( );
