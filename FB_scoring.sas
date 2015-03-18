/*The goal of this task was to see if there is an effect of a previous trial  on the current trial - esentially to see
the effects of serial exposure. The code here shows calculation of lag variables and some ways I use these. */

data processed;
set impexp;

/* Adding 1000 to combined RT if RT was submitted during fixation */
if CombinedSource = 'fixation' then CombinedRT = CombinedRT+1000;

/* Creating lag variable for a variable that denotes accuracy on a certain trials.
This is necessary because I will be creating new values that need to decode what the current
row and the preceding row's value were. Bringing over the value from the previous row to the current row. */
/* creating lag variable to code for post-error correct. I use the same logic for creating other lag variables, so that 
we can look at the effects of the previous trial on the current trial on other variables too. I am not showing the syntax for those
as it becomes repetitive, and the logic is the same. */
lagcorrect = lag(CombinedACC);

/* First observation of lag set to missing in order to preserve the sequence. we need to set the first obs 
after every interruption to . too*/
if block = 1 or block = 47 or block = 93 or block = 139 then lagcorrect = .;

/* Calculating a variable called purecorrect that encodes current correct trials (CombinedACC = 1) but excludes error (CombinedACC = 0) and post-error trials (lagcorrect = 0).
Missing values from the post-error trials (lagcorrect = .) are set to missing here too. */
purecorrect = .;
if CombinedACC = 1 and lagcorrect = 0 then purecorrect = 0; 
else purecorrect = CombinedACC;
if lagcorrect = . then purecorrect = .;
run;

/* Using the frequency function to create a count of subject's incorrect and correct responses (purecorrect = 0/1) in a certain condition 'c'.
Outputs results into a table called 'correcCon'. */
proc freq data = impexp noprint;
table subject*purecorrect /out = correctCon;
where condition = 'c';
run;


data mcc;
set merged1;

/* Here I am calculating a bound variable that I will later use to flag outlier trials. Using a previously calculated standard
deviation valuee for a certain trial type (code not shown for that as you saw MEAN calculations in another sample, this uses
the same proc means syntax only I kept the standard deviation). */
highcutoffcc = meanRTcc + STDcc*2;
lowcutoffcc = meanRTcc - STDcc*2;

/* Flagging items for further deletion based on SD cutoff*/
flagcc  = .;
where congruency = 'cc';
if lowcutoffcc > CombinedRT or highcutoffcc < CombinedRT  or CombinedRT < 30  then flagcc = 1; 
else flagcc  = 0;
run;
