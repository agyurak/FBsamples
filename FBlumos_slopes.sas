/*reading IDs from the menlo park group*/
proc import datafile= 'C:\project\emotionreg\IGNITE\cloitre\IDs_toSAS.xls'
out=work.IDS replace;
run;
data ids;
set ids;
if id = ' ' then delete;
if emailaddress = '.' then delete;
run;
proc sort;
by emailaddress;
run;
/*reading in server dump from Lumos*/
proc import datafile= 'C:\project\emotionreg\IGNITE\cloitre\Lumos_cloitre.csv'
out=work.lumosity replace;
run;

proc contents position short;
run;
proc freq;
table gamename;
run;

proc sort data = lumosity;
by  emailaddress game Gamenth;
run;
/*subsetting only the games used in the study*/
data lumosity;
set lumosity;
if game ne 4 & game ne 8 & game ne 19 & game ne 20 & game ne 26 & game ne 46 then delete;
run;
/*
|  4 | Raindrops
|  8 | Lost in Migration
| 19 | Memory Match Overload
| 20 | Playing Koi
| 26 | Brain Shift Overdrive
| 46 | Disconnection
group (1: Active ; 2: Control)


/*calculating number of logins per user as performance metric*/
proc sort data= lumosity;
by emailaddress;
run;
proc means data = lumosity noprint;
var gamenth;
by  emailaddress;
output out= numoflogins;
run;

data numoflogins;
set numoflogins;
if _STAT_ = 'N' or _STAT_ = 'MIN' or _STAT_ = 'MEAN' or _STAT_ = 'STD' then delete;
keep emailaddress gamenth;
run;
data numoflogins;
set numoflogins;
numoflogins = gamenth ;
run;
data numoflogins;
set numoflogins;
drop gamenth;
run;
proc sort;
by emailaddress;
run;



/*subsetting raindrops game only for calculation of individual number of plays per day and learning slopes*/
data raindrops;
set lumosity;
if game ne 4 then delete;
day = gamenth;
run;
proc sort data= raindrops;
by emailaddress gamenth;
run;

proc means data = raindrops noprint;
var score;
by  emailaddress day;
output out= raindrops_byday;
run;
data raindrops_byday;
set raindrops_byday;
if _STAT_ = 'N' or _STAT_ = 'MIN' or _STAT_ = 'MAX' or _STAT_ = 'STD' then delete;
keep emailaddress score day;
run;
data raindrops_byday;
set raindrops_byday;
time = day;
run;
proc sort data= raindrops_byday;
by day;
run;
proc means data = raindrops_byday noprint;
var score;
by  day;
output out= raindrops_day;
run;

data raindrops_day;
set raindrops_day;
if _STAT_ ne 'MEAN' then delete;
run;
data raindrops_day;
set raindrops_day;
keep day score;
run;
/*calculation of slopes*/
proc mixed data=raindrops_byday;
         class emailaddress;
         model score = day /  solution;
         random int time / type=un subject=emailaddress solution;
         run;

		 proc mixed data=raindrops_byday;
         class emailaddress;
         model score=time / ddfm=kr solution;
         random int time / type=un subject=emailaddress solution;
         ods output solutionf=sf(keep=effect estimate  
                                 rename=(estimate=overall));
         ods output solutionr=sr(keep=effect emailaddress estimate
                                 rename=(estimate=ssdev));
         run;

      proc sort data=sf; 
         by effect; 
         run;
      
      proc sort data=sr; 
         by effect; 
         run;

      data raindrops_final;
         merge sf sr;
         by effect;
         sscoeff = overall + ssdev;
         run;      

     proc sort data=raindrops_final; 
         by emailaddress effect; 
         run;

      proc print data=raindrops_final noobs; 
        var effect emailaddress overall ssdev sscoeff;
        run;

data raindrops_final;
set raindrops_final;
if effect ne 'time' then delete;
raindrops_slope = sscoeff ;
drop overall effect sscoeff ssdev;
run;
proc sort;
by emailaddress;
run;



/*lostinmig game plays by user and SD*/
data lostinmig;
set lumosity;
if game ne 8 then delete;
day = gamenth;
run;
proc sort data= lostinmig;
by emailaddress gamenth;
run;

proc means data = lostinmig noprint;
var score;
by  emailaddress day;
output out= lostinmig_byday;
run;
data lostinmig_byday;
set lostinmig_byday;
if _STAT_ = 'N' or _STAT_ = 'MIN' or _STAT_ = 'MAX' or _STAT_ = 'STD' then delete;
keep emailaddress score day;
run;
data lostinmig_byday;
set lostinmig_byday;
time = day;
run;
proc sort data= lostinmig_byday;
by day;
run;
proc means data = lostinmig_byday noprint;
var score;
by  day;
output out= lostinmig_day;
run;

data lostinmig_day;
set lostinmig_day;
if _STAT_ ne 'MEAN' then delete;
run;
data lostinmig_day;
set lostinmig_day;
keep day score;
run;
/*calculation of slopes*/
proc mixed data=lostinmig_byday;
         class emailaddress;
         model score = day /  solution;
         random int time / type=un subject=emailaddress solution;
         run;

		 proc mixed data=lostinmig_byday;
         class emailaddress;
         model score=time / ddfm=kr solution;
         random int time / type=un subject=emailaddress solution;
         ods output solutionf=sf(keep=effect estimate  
                                 rename=(estimate=overall));
         ods output solutionr=sr(keep=effect emailaddress estimate
                                 rename=(estimate=ssdev));
         run;

      proc sort data=sf; 
         by effect; 
         run;
      
      proc sort data=sr; 
         by effect; 
         run;

      data lostinmig_final;
         merge sf sr;
         by effect;
         sscoeff = overall + ssdev;
         run;      

     proc sort data=lostinmig_final; 
         by emailaddress effect; 
         run;

      proc print data=lostinmig_final noobs; 
        var effect emailaddress overall ssdev sscoeff;
        run;

data lostinmig_final;
set lostinmig_final;
if effect ne 'time' then delete;
lostinmig_slope = sscoeff ;
drop overall effect sscoeff ssdev;
run;
proc sort;
by emailaddress;
run;



/*memmatchov*/
data memmatchov;
set lumosity;
if game ne 19 then delete;
day = gamenth;
run;
proc sort data= memmatchov;
by emailaddress gamenth;
run;

proc means data = memmatchov noprint;
var score;
by  emailaddress day;
output out= memmatchov_byday;
run;
data memmatchov_byday;
set memmatchov_byday;
if _STAT_ = 'N' or _STAT_ = 'MIN' or _STAT_ = 'MAX' or _STAT_ = 'STD' then delete;
keep emailaddress score day;
run;
data memmatchov_byday;
set memmatchov_byday;
time = day;
run;
proc sort data= memmatchov_byday;
by day;
run;
proc means data = memmatchov_byday noprint;
var score;
by  day;
output out= memmatchov_day;
run;

data memmatchov_day;
set memmatchov_day;
if _STAT_ ne 'MEAN' then delete;
run;
data memmatchov_day;
set memmatchov_day;
keep day score;
run;
/*calculation of slopes*/
proc mixed data=memmatchov_byday;
         class emailaddress;
         model score = day /  solution;
         random int time / type=un subject=emailaddress solution;
         run;

		 proc mixed data=memmatchov_byday;
         class emailaddress;
         model score=time / ddfm=kr solution;
         random int time / type=un subject=emailaddress solution;
         ods output solutionf=sf(keep=effect estimate  
                                 rename=(estimate=overall));
         ods output solutionr=sr(keep=effect emailaddress estimate
                                 rename=(estimate=ssdev));
         run;

      proc sort data=sf; 
         by effect; 
         run;
      
      proc sort data=sr; 
         by effect; 
         run;

      data memmatchov_final;
         merge sf sr;
         by effect;
         sscoeff = overall + ssdev;
         run;      

     proc sort data=memmatchov_final; 
         by emailaddress effect; 
         run;

      proc print data=memmatchov_final noobs; 
        var effect emailaddress overall ssdev sscoeff;
        run;

data memmatchov_final;
set memmatchov_final;
if effect ne 'time' then delete;
memmatchov_slope = sscoeff ;
drop overall effect sscoeff ssdev;
run;
proc sort;
by emailaddress;
run;




/*playkoi*/
data playkoi;
set lumosity;
if game ne 20 then delete;
day = gamenth;
run;
proc sort data= playkoi;
by emailaddress gamenth;
run;

proc means data = playkoi noprint;
var score;
by  emailaddress day;
output out= playkoi_byday;
run;
data playkoi_byday;
set playkoi_byday;
if _STAT_ = 'N' or _STAT_ = 'MIN' or _STAT_ = 'MAX' or _STAT_ = 'STD' then delete;
keep emailaddress score day;
run;
data playkoi_byday;
set playkoi_byday;
time = day;
run;
proc sort data= playkoi_byday;
by day;
run;
proc means data = playkoi_byday noprint;
var score;
by  day;
output out= playkoi_day;
run;

data playkoi_day;
set playkoi_day;
if _STAT_ ne 'MEAN' then delete;
run;
data playkoi_day;
set playkoi_day;
keep day score;
run;
/*calculation of slopes*/
proc mixed data=playkoi_byday;
         class emailaddress;
         model score = day /  solution;
         random int time / type=un subject=emailaddress solution;
         run;

		 proc mixed data=playkoi_byday;
         class emailaddress;
         model score=time / ddfm=kr solution;
         random int time / type=un subject=emailaddress solution;
         ods output solutionf=sf(keep=effect estimate  
                                 rename=(estimate=overall));
         ods output solutionr=sr(keep=effect emailaddress estimate
                                 rename=(estimate=ssdev));
         run;

      proc sort data=sf; 
         by effect; 
         run;
      
      proc sort data=sr; 
         by effect; 
         run;

      data playkoi_final;
         merge sf sr;
         by effect;
         sscoeff = overall + ssdev;
         run;      

     proc sort data=playkoi_final; 
         by emailaddress effect; 
         run;

      proc print data=playkoi_final noobs; 
        var effect emailaddress overall ssdev sscoeff;
        run;

data playkoi_final;
set playkoi_final;
if effect ne 'time' then delete;
playkoi_slope = sscoeff ;
drop overall effect sscoeff ssdev;
run;
proc sort;
by emailaddress;
run;





/*bshiftoverd*/
data bshiftoverd;
set lumosity;
if game ne 26 then delete;
day = gamenth;
run;
proc sort data= bshiftoverd;
by emailaddress gamenth;
run;

proc means data = bshiftoverd noprint;
var score;
by  emailaddress day;
output out= bshiftoverd_byday;
run;
data bshiftoverd_byday;
set bshiftoverd_byday;
if _STAT_ = 'N' or _STAT_ = 'MIN' or _STAT_ = 'MAX' or _STAT_ = 'STD' then delete;
keep emailaddress score day;
run;
data bshiftoverd_byday;
set bshiftoverd_byday;
time = day;
run;
proc sort data= bshiftoverd_byday;
by day;
run;
proc means data = bshiftoverd_byday noprint;
var score;
by  day;
output out= bshiftoverd_day;
run;

data bshiftoverd_day;
set bshiftoverd_day;
if _STAT_ ne 'MEAN' then delete;
run;
data bshiftoverd_day;
set bshiftoverd_day;
keep day score;
run;
/*calculation of slopes*/
proc mixed data=bshiftoverd_byday;
         class emailaddress;
         model score = day /  solution;
         random int time / type=un subject=emailaddress solution;
         run;

		 proc mixed data=bshiftoverd_byday;
         class emailaddress;
         model score=time / ddfm=kr solution;
         random int time / type=un subject=emailaddress solution;
         ods output solutionf=sf(keep=effect estimate  
                                 rename=(estimate=overall));
         ods output solutionr=sr(keep=effect emailaddress estimate
                                 rename=(estimate=ssdev));
         run;

      proc sort data=sf; 
         by effect; 
         run;
      
      proc sort data=sr; 
         by effect; 
         run;

      data bshiftoverd_final;
         merge sf sr;
         by effect;
         sscoeff = overall + ssdev;
         run;      

     proc sort data=bshiftoverd_final; 
         by emailaddress effect; 
         run;

      proc print data=bshiftoverd_final noobs; 
        var effect emailaddress overall ssdev sscoeff;
        run;

data bshiftoverd_final;
set bshiftoverd_final;
if effect ne 'time' then delete;
bshiftoverd_slope = sscoeff ;
drop overall effect sscoeff ssdev;
run;
proc sort;
by emailaddress;
run;





/*disconnect*/
data disconnect;
set lumosity;
if game ne 46 then delete;
day = gamenth;
run;
proc sort data= disconnect;
by emailaddress gamenth;
run;

proc means data = disconnect noprint;
var score;
by  emailaddress day;
output out= disconnect_byday;
run;
data disconnect_byday;
set disconnect_byday;
if _STAT_ = 'N' or _STAT_ = 'MIN' or _STAT_ = 'MAX' or _STAT_ = 'STD' then delete;
keep emailaddress score day;
run;
data disconnect_byday;
set disconnect_byday;
time = day;
run;
proc sort data= disconnect_byday;
by day;
run;
proc means data = disconnect_byday noprint;
var score;
by  day;
output out= disconnect_day;
run;

data disconnect_day;
set disconnect_day;
if _STAT_ ne 'MEAN' then delete;
run;
data disconnect_day;
set disconnect_day;
keep day score;
run;
/*calculation of slopes*/
proc mixed data=disconnect_byday;
         class emailaddress;
         model score = day /  solution;
         random int time / type=un subject=emailaddress solution;
         run;

		 proc mixed data=disconnect_byday;
         class emailaddress;
         model score=time / ddfm=kr solution;
         random int time / type=un subject=emailaddress solution;
         ods output solutionf=sf(keep=effect estimate  
                                 rename=(estimate=overall));
         ods output solutionr=sr(keep=effect emailaddress estimate
                                 rename=(estimate=ssdev));
         run;

      proc sort data=sf; 
         by effect; 
         run;
      
      proc sort data=sr; 
         by effect; 
         run;

      data disconnect_final;
         merge sf sr;
         by effect;
         sscoeff = overall + ssdev;
         run;      

     proc sort data=disconnect_final; 
         by emailaddress effect; 
         run;

      proc print data=disconnect_final noobs; 
        var effect emailaddress overall ssdev sscoeff;
        run;

data disconnect_final;
set disconnect_final;
if effect ne 'time' then delete;
disconnect_slope = sscoeff ;
drop overall effect sscoeff ssdev;
run;
proc sort;
by emailaddress;
run;



/*combined files*/
data merged_gameimp;
merge disconnect_final bshiftoverd_final playkoi_final memmatchov_final raindrops_final lostinmig_final numoflogins ids;
by emailaddress;
if emailaddress = '.' then delete;
if pre-WN= 0 then delete;
run;

/*TODO: this needs to be redone after the final set of IDs is decided on as the standardization is done in the relative 
sample that we agree on*/
PROC STANDARD DATA=merged_gameimp MEAN=0 STD=1 OUT=std_EF;
  VAR disconnect_slope bshiftoverd_slope playkoi_slope memmatchov_slope raindrops_slope lostinmig_slope;
RUN;


data std_EF;
set std_EF;
EF_slope_ST = mean (of disconnect_slope bshiftoverd_slope playkoi_slope memmatchov_slope raindrops_slope lostinmig_slope);
/*data quality check to make sure there were no misassigned participants who were noted by menlo group as control but 
ended up using the games and were active treatment. also flagging those who logged in fewer than 5 times for menlo group to decide on*/
if group = 2 then flag  = 1;
if numoflogins = . or numoflogins < 5 then flag =  1;
run;

