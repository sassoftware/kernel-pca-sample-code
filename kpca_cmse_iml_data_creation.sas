/*  Create a default CAS session and create SAS librefs for existing caslibs */

cas; 
caslib _all_ assign;

/*Generate Data for the Inner Torus*/

data Torus1;
R = 8;       /* radius to center of tube */
A = 3;       /* radius of tube */
pi = constant('pi');
step = 2*pi/50;
/* create torus as parametric image of [0, 2*pi] x [0,2*pi] */
do theta = 0 to 2*pi-step by step;
   do phi = 0 to 2*pi-step by 2*pi/50;
      x = (R + A*cos(phi)) * cos(theta);
      y = (R + A*cos(phi)) * sin(theta);
      z =      A*sin(phi);
      output;
   end;
end;
group=1;
keep x y z group;
run;

/*Generate Data for the Outer Torus*/

data Torus2;
R = 20;       /* radius to center of tube */
A = 3;       /* radius of tube */
pi = constant('pi');
step = 2*pi/50;
/* create torus as parametric image of [0, 2*pi] x [0,2*pi] */
do theta = 0 to 2*pi-step by step;
   do phi = 0 to 2*pi-step by 2*pi/50;
      x = (R + A*cos(phi)) * cos(theta);
      y = (R + A*cos(phi)) * sin(theta);
      z =      A*sin(phi);
      output;
   end;
end;
group=2;
keep x y z group;
run;

/*Stack or certically concatenate the data for
  each torus in a single data set*/

data torus;
set torus1 torus2;
run;
 

/*Rotate the tori and form different
  coordinates for visualization
  in a scatter plot matrix. */ 
 
proc iml;
start RotPlane(a, i, j);
   R = I(3);  
   c = cos(a); s = sin(a);
   R[i,i] = c;  R[i,j] = -s;
   R[j,i] = s;  R[j,j] =  c;
   return R;
finish;
 
start Rot3D(a, axis);   /* rotation in plane perpendicular to axis */
   if upcase(axis)="X" then       
      return RotPlane(a, 2, 3);
   else if upcase(axis)="Y" then
      return RotPlane(a, 1, 3);
   else if upcase(axis)="Z" then
      return RotPlane(a, 1, 2);
   else return I(3);
finish;

pi = constant('pi');
Rz = Rot3D(-pi/6, "Z");    /* rotation matrix for (x,y) plane */
Rx = Rot3D(-pi/3, "X");    /* rotation matrix for (y,z) plane */ 
Ry = Rot3D( pi/6, "Y");    /* rotation matrix for (x,z) plane */
P = Rx*Ry*Rz;              /* cumulative rotation */
 
use Torus;                 /* read data (points on a torus) */
read all var {x y z} into M;
close Torus;
 
Rot = M * P`;              /* apply rotation and write to data set */
create RotTorus from Rot[colname={"Px" "Py" "Pz"}];
append from Rot;
close;
QUIT;

/*Merge/Join the rotated coordinates(Px Py Pz)
  back to the original coordinates*/

data Coords;
merge Torus RotTorus;
run;

/*Identify the inner torus as group=1 
  and outer torus as group=2
  and load the data into the CASUSER library.*/

data CASUSER.TWO_TORUS;
   set coords;
   if _n_<=2500 then group=1;
   else group=2;
run;
 
