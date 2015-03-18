/* This is reading in a file that is set up for longitudinal data modeling nested. */

proc import
 datafile='C:\project\implicit\IrisMauss study\data\diary_mixed.dat'
 dbms=TAB out=diary replace;
run;
data diary;
set diary;
run;

/* This is sorting by the nested structure */
proc sort;
by subject_num day;
run;

data merged;
merge t1t2 diary;
by subject_num;

/* Calculating composite scores from certain raw variables. */
neg_moodx = mean (of EMO_2_gen EMO_3_gen EMO_4_gen EMO_6_gen EMO_7_gen EMO_8_gen EMO_10_gen EMO_12_gen EMO_14_gen EMO_15_gen
EMO_17_gen EMO_18_gen);
pos_moodx = mean (of EMO_1_gen EMO_5_gen EMO_9_gen EMO_11_gen EMO_13_gen EMO_16_gen);

/* This step here uses a loop to reverse score a batch of variables. */
array pos  EMO_1_gen  EMO_5_gen  EMO_9_gen  EMO_11_gen  EMO_13_gen  EMO_16_gen;
array posr EMO_1_genR EMO_5_genR EMO_9_genR EMO_11_genR EMO_13_genR EMO_16_genR;
do over pos;
posr = 6-pos;
end;

negposx = mean (of EMO_2_gen EMO_3_gen EMO_4_gen EMO_6_gen EMO_7_gen EMO_8_gen EMO_10_gen EMO_12_gen EMO_14_gen EMO_15_gen
EMO_17_gen EMO_18_gen EMO_1_genR EMO_5_genR EMO_9_genR EMO_11_genR EMO_13_genR EMO_16_genR);

/* Creating a lagged variable of current day's negative mood (neg_mod)
so that I can use it in a longitudinal model. The below model tests to see if a certain performance variable on a reaction time task
(calculated elsewhere; adaptationC) moderates the effect of the number of stressors on a day on negative mood even after 
controlling for previous day's negative mood (lneg_modx). Here totstress is the number of stressful events
the participant reported on a particular day. */
lneg_moodx = lag (of neg_moodx);

run;

proc mixed covtest method=mivque0;
class subject_num day;
model neg_moodx = lneg_moodx adaptationC|totstress /s ddf = 106,106,106;
random intercept lneg_moodx ltotstress /subject=subject_num type=un g gcorr;
repeated day/subject=subject_num  type=ar(1);
where  Nincorrect < 61;
run;
