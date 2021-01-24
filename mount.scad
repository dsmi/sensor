
// Segments in a circle, increase for the final render
$fn = 120;

// My Anet A8, which I use to debug this
//  Nozzle diameter: 0.4mm
//  Layer thickness: 0.08, 0.12, 0.16... in increments of 0.04mm

// Units are mm!
outer_r   = 25.5/2; // outer disk radius
outer_h   = 2.76+0.12*50; // outer disk height
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

// lips
lip_top = -1.2; // top, relative to support_h
lip_r0 = 7.5;  // inner radius
lip_r1 = 10.0; // outer radius
lips = [ [ 45+8, 45-8, 1.2 ], [ 225+16, 225-16, 2.16 ] ]; // angles and thickness

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

module support_disk( )
{
   // support normal angle at support_r from center
   supa = asin( support_r/support_s );

   outz = outer_h + support_s*cos(supa); // z of the outer rounding sphere
   difference( )
   {
      cylinder( h=outer_h, r=outer_r );
      translate( [ 0, 0, outz ] ) sphere( r=support_s, $fn=400 );
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
      translate( [ 0, 0, supz ] ) sphere( r=support_s, $fn=400 );

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

difference( )
{
   support_disk( );
   plug_cone( );
}

difference( )
{
   for ( lip = lips )
   {
      lz = lip_top + outer_h + support_h - lip[2]/2;
      translate( [ 0, 0, lz ] )
      {
         pie( lip[2], lip_r1, lip[0], lip[1] );
      } 
   }
   cylinder( r=lip_r0, h=outer_h*10, center=true );
}

