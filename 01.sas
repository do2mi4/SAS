/* This is a comment */
/* Change mllam to your CNET ID */

%let MyData = /;

libname MyData "&MyData.";

/* You must first create a folder images under the Statistical Analysis folder */
ods html path = "&MyData."
         gpath = "&MyData./images"; 
ods graphics on;

/* Import Chicago Pothole Excel file */
proc import datafile="&MyData./311_Service_Requests_-_Pot_Holes_Reported.xlsx"
            out = MyData.CHicagoPotHole dbms=xlsx replace;
run;

/* Vertical bar chart of the STATUS column */
proc sgplot data = MyData.ChicagoPotHole;
   vbar STATUS;
   yaxis grid;
run;

/* Create two new columns: CREATION_MONTH and CREATION_YEAR from CREATION DATE */
/* Since the field: CREATION DATE contains a space, we need to specify it as a named literal: 'CREATION DATE'n */
data MyData.ChicagoPotHole;
   set MyData.ChicagoPotHole;
   CREATION_MONTH = month('CREATION DATE'n);
   CREATION_YEAR = year('CREATION DATE'n);
run;

/* Vertical bar chart of the STATUS column, break down by CREATION_MONTH */
proc sgplot data = MyData.ChicagoPotHole;
   vbar status
   / group = CREATION_MONTH
     grouporder = ascending;
   yaxis grid;
run;

/* Vertical line chart of the STATUS column, break down by CREATION_MONTH */
proc sgplot data = MyData.ChicagoPotHole;
   vline CREATION_MONTH
   / group = STATUS
     grouporder = ascending;
   yaxis grid;
run;

/* Vertical bar chart of the WARD column, show values on x-axis in stagger style */
proc sgplot data = MyData.ChicagoPotHole;
   vbar WARD;
   xaxis fitpolicy = stagger;
   yaxis grid;
run;

/* Vertical bar chart of the WARD column, bars in descending frequency, show values on x-axis in stagger style */
proc sgplot data = MyData.ChicagoPotHole;
   where (1 <= ward and ward <= 50); 
   vbar ward /
      categoryorder = respdesc
      stat = freq;
   xaxis fitpolicy = stagger;
   yaxis grid;
run;

/* Create a graph template for doing pie chart */
proc template;
   define statgraph MyPieChart;
      begingraph;
         entrytitle "Pie Chart of Percents Pothole Reports";
         layout region;
            piechart category = creation_month
               / datalabellocation=callout
                 categorydirection=clockwise
                 start=90 stat=pct
                 othersliceopts=(type=percent percent=5 label="Other Months");
         endlayout;
      endgraph;
   end;
run;

/* Render the pie chart using the graph template */
proc sgrender data = MyData.ChicagoPotHole
              template = MyPieChart;
   where (1 <= Ward and Ward <= 50);
   title "All Wards";
run;

/* Render the pie chart using the graph template, for Ward 41 only */
proc sgrender data = MyData.ChicagoPotHole
              template = MyPieChart;
   where (Ward = 41);
   title "Ward 41";
run;

/* Render the pie chart using the graph template, for Ward 46 only */
proc sgrender data = MyData.ChicagoPotHole
              template = MyPieChart;
   where (Ward = 46);
   title "Ward 46";
run;

/* Histogram of CREATION DATE for years in 2012, 2013, 2014 */
proc sgplot data = MyData.ChicagoPotHole;
   where (1 <= ward and ward <= 50 and CREATION_YEAR in (2012, 2013,2014)); 
   histogram 'CREATION DATE'n / scale = count;
   yaxis grid;
run;

/* Histogram of CREATION DATE for years in 2012, 2013, 2014, imposed kernel and normal density */
proc sgplot data = MyData.ChicagoPotHole;
   where (1 <= ward and ward <= 50 and CREATION_YEAR in (2012, 2013,2014)); 
   histogram 'CREATION DATE'n / scale = count;
   density 'CREATION DATE'n / scale = count type=kernel;
   density 'CREATION DATE'n / scale = count type=normal;
   yaxis grid;
run;

/* Dot graph of CREATION DATE for years in 2012, 2013, 2014 */
proc sgplot data = MyData.ChicagoPotHole;
   where (1 <= ward and ward <= 50 and CREATION_YEAR in (2012, 2013, 2014)); 
   dot 'CREATION DATE'n;
   xaxis grid;
run;

/* Horizontal boxplots CREATION_MONTH */
proc sgplot data = MyData.ChicagoPotHole;
   where (1 <= ward and ward <= 50); 
   hbox CREATION_MONTH;
   xaxis grid values=(1 to 12 by 1);
run;

/* Create a graph template for heat map */
proc template;
   define statgraph HeatMap;
   begingraph / designwidth=800 designheight= 400;
      entrytitle "Status by Ward";
      layout overlay /
        xaxisopts = (type = linear
                     linearopts = (integer=true tickvaluesequence=(start=1 end=50 increment=1))
                     label = "Ward")
        yaxisopts = (label = "Status");
        heatmapparm x = Ward y = Status colorresponse = N_Report /
                    name = "heatmapparm"
                    xbinaxis = false
                    ybinaxis = false;
        continuouslegend "heatmapparm" /
                         orient = vertical location = outside
                         halign = center valign = center;
      endlayout;
   endgraph;
   end;
run;

/* Aggregate data to obtain count for each ward and status combination */
proc summary data = MyData.ChicagoPotHole nway;
   where (1 <= ward and ward <= 50);
   class ward status;
   output out = NReport_Ward_Status (rename = _FREQ_ = N_Report);
run;

/* Render the heat map */
proc sgrender data = NReport_Ward_Status 
              template = HeatMap;
run;

/* Present histogram of CREATION DATE in 2 x 2 panels defined by STATUS */
proc sgpanel data = MyData.ChicagoPotHole;
   where ('01JUL2013'd <= 'CREATION DATE'n and 'CREATION DATE'n <= '30JUN2014'd);
   panelby status / rows=2 columns=2;
   histogram 'CREATION DATE'n;
run;

/* Present horizontal boxplot of CREATION DATE grouped by STATUS */
proc sgplot data = MyData.ChicagoPotHole;
   where ('01JUL2013'd <= 'CREATION DATE'n and 'CREATION DATE'n <= '30JUN2014'd);
   hbox 'CREATION DATE'n / group = Status;
   xaxis grid;
run;

/* Scatterplot of LATITUDE by LONGITUDE */
proc sgplot data = MyData.ChicagoPotHole;
   where ('01JUL2013'd <= 'CREATION DATE'n and 'CREATION DATE'n <= '30JUN2014'd);
   scatter x = LONGITUDE y = LATITUDE;
   xaxis grid;
   yaxis grid;
run;
