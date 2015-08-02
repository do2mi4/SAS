proc contents data=sashelp.cars;
run;


proc summary data=sashelp.cars;
output out=cars_summary;

run;
proc print data=cars_summary;
run;

/* ----------- */

/*
proc summary data = sashelp.cars;
class Origin Make;
var MSRP;
output out=MSRP mean(MSRP) = average_msrp;
run;
*/

proc summary data = sashelp.cars nway;
class origin make;
var msrp;
output out = msrp mean(msrp) = average_msrp;
run;

/*
proc summary data=sashelp.cars;
clas origin make;
var msrp;
types origin origin*make;
output out = msrp mean(msrp) = average_msrp;
run;
*/

/*Get means of whelbase and weight */
proc summary data = sashelp.cars;
	var wheelbase weight;
	output out = WW_means mean(WheelBase Weight) = mean_wheelbase mean_weight;
run;

/*append the means to the original data*/
data cars;
	set sashelp.cars;
	if (_n_ eq 1) then set ww_means;
	x_dev = wheelbase - mean_wheelbase;
	y_dev = weight - mean_weight;
	xy_dev = x_dev = y_dev;
	output;
run;

proc summary data = cars;
	var x_dev y_dev xy_dev;
	output out = dev uss(x_dev y_dev) = x_ss y_ss sum(xy_dev) = xy_ss;
run;

data dev;
	set dev;
	PearsonCorrelation = xy_ss/(sqrt(x_ss) *sqrt(y_ss));
run;

/* Get correlation of WheelBase and Weight */
proc corr data = sashelp.cars;
   var WheelBase Weight;
run;

proc reg data=sashelp.cars;
model weight=wheelbase;
run;
