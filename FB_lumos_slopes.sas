/* These sections from a larger code set that took in an identifier file that had information about study 
condition assignment and and a separate server dump that contained performance data for a set of ~150 participants who played 
6 Lumosity games for 45 days each. Broadly, here I use mixed linear model to calculate learning on each game over time and to 
merge these results together with the identifier file -- which in subsequent steps is then merged together with other data sources 
(not discussed here). The code is edited and I left out repetition so that it is easier to follow. */


/* Reading IDs from the menlo park group. This file contains condition assignments and primary keys. */
proc import datafile= 'C:\project\emotionreg\IGNITE\cloitre\IDs_toSAS.xls'
out=work.ids replace;
run;

data ids;
set ids;
if id = ' ' then delete;
if emailaddress = '.' then delete;
run;

proc sort;
by emailaddress;
run;

/* Reading in server dump from Lumos. These files contain timestamps and performance data for each of the 6 different games participants
played in the study over 45 days. The size of this file is 150 participants x 6 games x 45 days. Each game play contains about 5-10 
rows of data. */
proc import datafile= 'C:\project\emotionreg\IGNITE\cloitre\Lumos_cloitre.csv'
out=work.lumosity replace;
run;

/* This is printing the variable names in the file that was read in for data checkin purposes. */
proc contents position short;
run;

/*This is checking to make sure participants did not play any other game than the 6 they were assigned to. */
proc freq;
table gamename;
run;

proc sort data = lumosity;
by  emailaddress game Gamenth;
run;

/* subsetting only the games used in the study */
data lumosity;
set lumosity;
if game ne 4 & game ne 8 & game ne 19 & game ne 20 & game ne 26 & game ne 46 then delete;
run;

/* group (1: Active ; 2: Control) */
/* This is a sort opration so that the by function works below. */
proc sort data= lumosity;
by emailaddress;
run;

/* Calculating number of logins per user as performance metric and outputting the file for each user (emaialdress) */
proc means data = lumosity noprint;
var gamenth;
by  emailaddress;
output out= numoflogins;
run;

/* Deleting certain rows from the output. */
data numoflogins;
set numoflogins;
if _STAT_ = 'N' or _STAT_ = 'MIN' or _STAT_ = 'MEAN' or _STAT_ = 'STD' then delete;
keep emailaddress gamenth;
run;

/* renaming variable */
data numoflogins;
set numoflogins;
numoflogins = gamenth ;
run;

/* Dropping a variable, this has to be done in a separate data step in SAS! */
data numoflogins;
set numoflogins;
drop gamenth;
run;

/* This is subsetting the "raindrops" game only (game = 4) for calculation of individual number of plays per day and learning slopes */
data raindrops;
set lumosity;
if game ne 4 then delete;
day = gamenth;
run;

/* This is sorting by two variables because the data are nested in emailaddress and day and we want separate means for each user 
(=emailaddress) per each day (=gamenth, which the nth day since their enrollment in the study. */
proc sort data= raindrops;
by emailaddress gamenth;
run;

/* This step here calculates the mean for the variable score BY emailaddress and day and . */
proc means data = raindrops noprint;
var score;
by  emailaddress gamenth;
output out= raindrops_byday;
run;

/* Deleting extraneous output rows. */
data raindrops_byday;
set raindrops_byday;
if _STAT_ = 'N' or _STAT_ = 'MIN' or _STAT_ = 'MAX' or _STAT_ = 'STD' then delete;
keep emailaddress score day;
run;

/* Renaming a variable. */
data raindrops_byday;
set raindrops_byday;
time = day;
run;

proc sort data= raindrops_byday;
by day;
run;

/* calculation of slopes. This step uses a mixed linear modeling procedure to calculate linear slopes and 
deviation scores around that slope for each participant over the course of the study. 
This particular syntax here does this for one of the games, called raindrops. */
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

/* All games were processed similarly. The games were: disconnect, bshiftoverd playingkoi memmatchov raindrops lostinmig.
I am also merging in numoflogins which was calculated above, this indicates the number of times participants logged in over the 
course of the 45 days. Finally, ids is the set that links emailaddresses to other critical variables from the set 'ids'. */
/* This step combines the files together BY username = emailaddress. Also deletes certain missing rows. */
data merged_gameimp;
merge disconnect_final bshiftoverd_final playkoi_final memmatchov_final raindrops_final lostinmig_final numoflogins ids;
by emailaddress;
if emailaddress = '.' then delete;
if pre-WN = 0 then delete;
run;

/* This step creates a standard score for each slope variable (each game). */
PROC STANDARD DATA=merged_gameimp MEAN=0 STD=1 OUT=std_EF;
  VAR disconnect_slope bshiftoverd_slope playkoi_slope memmatchov_slope raindrops_slope lostinmig_slope;
RUN;

/* This steps creates a mean of the slopes */
data std_EF;
set std_EF;
EF_slope_ST = mean (of disconnect_slope bshiftoverd_slope playkoi_slope memmatchov_slope raindrops_slope lostinmig_slope);

/* This step is a data quality check to make sure there were no misassigned participants who were noted by menlo group as control but 
ended up using the games and were active treatment. also flagging those who logged in fewer than 5 times for menlo group to decide on */

if group = 2 then flag  = 1;
if numoflogins = . or numoflogins < 5 then flag =  1;
run;

