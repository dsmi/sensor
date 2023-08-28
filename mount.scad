
// Segments in a circle, increase for the final render
$fn = 600;

// My Anet A8, which I use to debug this
//  Nozzle diameter: 0.4mm
//  Layer thickness: 0.08, 0.12, 0.16... in increments of 0.04mm

// Units are mm!
outer_r   = 30/2; // outer disk radius
outer_h   = 1.2;//2.76; // outer disk height
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

// Trap door dimensions
tdw = 27.5;  // width
tdh = 25.5;  // height
tdd = 27.5;  // distance between the diagonal bevels
tdl = 3.6;   // length (depth)
a   = 45;    // diagonal bevels angle
tow = 23.5;  // width of the opening
toh = 21.5;  // height of the opening

// Trap door cutout to place the grips in
tdcw = 10;
tdch = 8;

// Clips
cth = 1.6;   // thickness of a clip
cl  = 7;     // full length of a clip
c2b = 5.15; // clip-2-base distance
ct2 = 2.4;  // clip thickness at the bottom
cl2 = 1.2;  // length of the thick part above tongue
cto = 2.4;  // length of the tongue of the clip (minus cth)
cw1 = 8;    // width of the first (wider) clip
cw2 = 6;    // width of the second (narrower) clip
cwr = 0.8;  // width of the rests which touch the trap door

// Supports of the clips which touch the sensor
sw = 0.8;
st = 4;  // top of the supports
sb = 7;  // bottom of the supports
ss = 14; // separation between the opposite supports

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

module support_disk_cutout( )
{
   // Length of the cutting box, we just need some large
   // enough value
   l = outer_r;

   // Distance from the center to cutout
   r = tdh/2; // same where the trap door starts

   // Height of the cutting box, some value > disk h
   h = outer_h*3;

   translate( [ 0, r+l/2, 0 ] )
   {
      cube( [ dcw, l, h ], center = true );
   }
}


// Trap door which has the shape of hexagonal prism
module trap_door( w, h, d, l )
{
   intersection( )
   {
      cube( [ w, h, l ], true );
      rotate( [ 0, 0, a ] )
      {
         cube( [ d,   d*2, l ], true );
      }
      rotate( [ 0, 0, -a ] )
      {
         cube( [ d,   d*2, l ], true );
      }
   }
}

// Makes x-parallel clip, zero y is where it touches
// the edge of the trap door opening.
module clip( w )
{
   translate( [ 0, -ct2, 0 ] )
   {
      translate( [ -w/2, cth, -cl ] )
      {
         l = cto;      // tongue length
         t = cl - c2b; // tongue thickness
         ra = atan( t/l );
         difference( )
         {
            cube( [ w, l, t ] );
            rotate( [ ra, 0, 0 ] )
            {
               translate( [ 0, 0, -t ] ) cube( [ w, 2*l, t ] );
            }
         }
      }

      translate( [ -w/2, 0, -c2b ] )
      {
         difference( )
         {
            cube( [ w, ct2, cl2 ] );
            translate( [ cwr, 0, 0 ] )
            {
               cube( [ w - 2*cwr, ct2, cl2 ] );
            }
         }
      }

      translate( [ -w/2, 0, -cl ] )
      {
         cube( [ w, cth, cl ] );
      }
   }
}

// Supporting structure which is inside the grip.
module support_inner( )
{
   translate( [ 0, 0, -tdl/2 ] )
   {
      difference( )
      {
         trap_door( tdw, tdh, tdd, tdl );
         
         union( )
         {
            cube( [ tdcw, tdh,  tdl ], center = true );
            cube( [ tdw,  tdch, tdl ], center = true );
         }
      }
   }

   translate( [ 0, toh/2, 0 ] )
   {
      clip( cw1 );
   }

   translate( [ 0, -toh/2, 0 ] )
   {
      rotate( [ 0, 0, 180 ] )
      {
         clip( cw1 );
      }
   }

   translate( [ -tow/2, 0, 0 ] )
   {
      rotate( [ 0, 0, 90 ] )
      {
         clip( cw2 );
      }
   }

   translate( [ tow/2, 0, 0 ] )
   {
      rotate( [ 0, 0, -90 ] )
      {
         clip( cw2 );
      }
   }

   // Height of the clip supports
   sh = sb - st; 

   translate( [ 0, 0, -sb/2 - st/2 ] )
   {
      difference( )
      {
         cube( [ tow - ct2*2, sw, sh ], center = true );
         cube( [ ss,          sw, sh ], center = true );
      }

      difference( )
      {
         cube( [ sw, toh - ct2*2, sh ], center = true );
         cube( [ sw, ss,          sh ], center = true );
      }
   }
}

difference( )
{
   union( )
   {
      difference( )
      {
         support_disk( );
         support_disk_cutout( );
      }
      support_inner( );
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
   cylinder( r=tongue_r0, h=outer_h*10, center=true );
}
