/* The oveall goal of this file is to 1. rename variables in an input file 2. rearrange wide into long format 3. generate string
names for subsequent use in imaging analyses which will then be read back in. 3. merge together for later statistical analyses.*/


/* This step reads in a csv file that contains data for more participants than I need for the current analysis. It also has 
timepoint1 and timepoint2 (pre and post assessment) set up in the wide format. I will need to transpose these. Showing 
steps for this for dealing with the timepoint1 data. I repeat the same for timpoint2 and then merge together by the primary key */
proc import datafile= 'C:\project\emotionreg\GAD_MDDtraining\data\fmri\resting_graph\all_g7_degree.csv'
out=work.graph_network replace;
run;

/* Subsetting for those individuals in our current analyses. */
data ignite_graph_network;
set graph_network;
if sid < 500 then delete;
run;

/* This step activates a macro for later renaming variables to add a suffix. I will end the suffix for 
timepoint1 or baseline assessment as the data that I read up above was set up in the long format and I wanted to 
rearrange it for the wide format. */
%macro renamesuffix(oldvarlist, suffix);
  %let k=1;
  %let old = %scan(&oldvarlist, &k);
     %do %while("&old" NE "");
      rename &old = &old.&suffix;
	  %let k = %eval(&k + 1);
      %let old = %scan(&oldvarlist, &k);
  %end;
%mend;


/* Data setup in long format, we just need baseline timpoint 1 data for this round. */
data ignite_graph_networkTP1;
set ignite_graph_network;
if timepoint ne 'tp1' then delete;
drop timepoint;
run;

/* Adding the _tp1 suffix to organize the variables in the wide format instead of long format. The macro 
renames the variables in a batch for example n8_LECN_01 becomes n8_LECN_01_tp1. */
data ignite_graph_networkTP1;
set ignite_graph_networkTP1;

 %renamesuffix
(n8_LECN_01 
n9_LECN_02
n10_LECN_03
n11_LECN_04
n13_LECN_06
n31_RECN_01
n32_RECN_02
n33_RECN_03
n34_RECN_04
n35_RECN_05
n36_RECN_06
n37_Salience_01
n38_Salience_02
n39_Salience_03
n40_Salience_04
n41_Salience_05
n42_Salience_06
n43_Salience_07
n44_Visuospatial_01
n45_Visuospatial_02
n46_Visuospatial_03
n47_Visuospatial_04
n48_Visuospatial_05
n49_Visuospatial_06
n50_Visuospatial_07
n51_Visuospatial_08
n54_Visuospatial_11
n59_dDMN_01
n60_dDMN_02
n61_dDMN_03
n62_dDMN_04
n63_dDMN_05
n64_dDMN_06
n65_dDMN_07
n66_dDMN_08
n67_dDMN_09, _tp1);
run;


/* This is a code sample to show that I use SAS to generate strings.

I was given a file where the column names were encoded in 2 rows. For example:
x = 0 0 0 1 1 2 2 2 2 2...
y = 0 1 3 2 1 4 5 5 1 0...
The numerical values run 0-54.
These pairs of values xy map onto strings that need to be paired up according to the pattern in xy.
This step reads in a file and will generate variable names.  I then map these xy pairs (see concatenate below) 
as variable names (called ROIs = brain Regions Of Interest) in a later step (not included) into a brain imaging software
in MATLAB called SPM. The new variable names serve as an input to a brain imaging function.
There were 1485 xy combinations and I wanted to use this code to make sure there are no 
mistakes in the variable names. The MATLAB/SPM output is then read back in later (not included). */
proc import datafile= 'C:\project\ispotd\data\vars.xls'
out=work.vars; 
run;

/*adding variable names to column names*/
data recoded;
set vars;
length xs $400 ys $400 ROI $800;

if	x=	0	then 	xs=	'LECN1'	;
if	x=	1	then 	xs=	'LECN2'	;
if	x=	2	then 	xs=	'LECN3'	;
if	x=	3	then 	xs=	'LECN4'	;
if	x=	4	then 	xs=	'LECN5'	;
if	x=	5	then 	xs=	'LECN6'	;
if	x=	6	then 	xs=	'RECN1'	;
if	x=	7	then 	xs=	'RECN2'	;
if	x=	8	then 	xs=	'RECN3'	;
if	x=	9	then 	xs=	'RECN4'	;
if	x=	10	then 	xs=	'RECN5'	;
if	x=	11	then 	xs=	'RECN6'	;
if	x=	12	then 	xs=	'Salience1'	;
if	x=	13	then 	xs=	'Salience2'	;
if	x=	14	then 	xs=	'Salience3'	;
if	x=	15	then 	xs=	'Salience4'	;
if	x=	16	then 	xs=	'Salience5'	;
if	x=	17	then 	xs=	'Salience6'	;
if	x=	18	then 	xs=	'Salience7'	;
if	x=	19	then 	xs=	'dDMN1'	;
if	x=	20	then 	xs=	'dDMN2'	;
if	x=	21	then 	xs=	'dDMN3'	;
if	x=	22	then 	xs=	'dDMN4'	;
if	x=	23	then 	xs=	'dDMN5'	;
if	x=	24	then 	xs=	'dDMN6'	;
if	x=	25	then 	xs=	'dDMN7'	;
if	x=	26	then 	xs=	'dDMN8'	;
if	x=	27	then 	xs=	'dDMN9'	;
if	x=	28	then 	xs=	'vDMN1'	;
if	x=	29	then 	xs=	'vDMN2'	;
if	x=	30	then 	xs=	'vDMN3'	;
if	x=	31	then 	xs=	'vDMN4'	;
if	x=	32	then 	xs=	'vDMN5'	;
if	x=	33	then 	xs=	'vDMN6'	;
if	x=	34	then 	xs=	'vDMN7'	;
if	x=	35	then 	xs=	'vDMN8'	;
if	x=	36	then 	xs=	'vDMN9'	;
if	x=	37	then 	xs=	'vDMN10'	;
if	x=	38	then 	xs=	'post_Salience1'	;
if	x=	39	then 	xs=	'post_Salience2'	;
if	x=	40	then 	xs=	'post_Salience3'	;
if	x=	41	then 	xs=	'post_Salience4'	;
if	x=	42	then 	xs=	'post_Salience5'	;
if	x=	43	then 	xs=	'post_Salience6'	;
if	x=	44	then 	xs=	'post_Salience7'	;
if	x=	45	then 	xs=	'post_Salience8'	;
if	x=	46	then 	xs=	'post_Salience9'	;
if	x=	47	then 	xs=	'post_Salience10'	;
if	x=	48	then 	xs=	'post_Salience11'	;
if	x=	49	then 	xs=	'post_Salience12'	;
if	x=	50	then 	xs=	'mayberg'	;
if	x=	51	then 	xs=	'dacc'	;
if	x=	52	then 	xs=	'vacc'	;
if	x=	53	then 	xs=	'L_amy'	;
if	x=	54	then 	xs=	'R_amy'	;

/*recoding*/
if	y=	0	then 	ys=	'LECN1'	;
if	y=	1	then 	ys=	'LECN2'	;
if	y=	2	then 	ys=	'LECN3'	;
if	y=	3	then 	ys=	'LECN4'	;
if	y=	4	then 	ys=	'LECN5'	;
if	y=	5	then 	ys=	'LECN6'	;
if	y=	6	then 	ys=	'RECN1'	;
if	y=	7	then 	ys=	'RECN2'	;
if	y=	8	then 	ys=	'RECN3'	;
if	y=	9	then 	ys=	'RECN4'	;
if	y=	10	then 	ys=	'RECN5'	;
if	y=	11	then 	ys=	'RECN6'	;
if	y=	12	then 	ys=	'Salience1'	;
if	y=	13	then 	ys=	'Salience2'	;
if	y=	14	then 	ys=	'Salience3'	;
if	y=	15	then 	ys=	'Salience4'	;
if	y=	16	then 	ys=	'Salience5'	;
if	y=	17	then 	ys=	'Salience6'	;
if	y=	18	then 	ys=	'Salience7'	;
if	y=	19	then 	ys=	'dDMN1'	;
if	y=	20	then 	ys=	'dDMN2'	;
if	y=	21	then 	ys=	'dDMN3'	;
if	y=	22	then 	ys=	'dDMN4'	;
if	y=	23	then 	ys=	'dDMN5'	;
if	y=	24	then 	ys=	'dDMN6'	;
if	y=	25	then 	ys=	'dDMN7'	;
if	y=	26	then 	ys=	'dDMN8'	;
if	y=	27	then 	ys=	'dDMN9'	;
if	y=	28	then 	ys=	'vDMN1'	;
if	y=	29	then 	ys=	'vDMN2'	;
if	y=	30	then 	ys=	'vDMN3'	;
if	y=	31	then 	ys=	'vDMN4'	;
if	y=	32	then 	ys=	'vDMN5'	;
if	y=	33	then 	ys=	'vDMN6'	;
if	y=	34	then 	ys=	'vDMN7'	;
if	y=	35	then 	ys=	'vDMN8'	;
if	y=	36	then 	ys=	'vDMN9'	;
if	y=	37	then 	ys=	'vDMN10'	;
if	y=	38	then 	ys=	'post_Salience1'	;
if	y=	39	then 	ys=	'post_Salience2'	;
if	y=	40	then 	ys=	'post_Salience3'	;
if	y=	41	then 	ys=	'post_Salience4'	;
if	y=	42	then 	ys=	'post_Salience5'	;
if	y=	43	then 	ys=	'post_Salience6'	;
if	y=	44	then 	ys=	'post_Salience7'	;
if	y=	45	then 	ys=	'post_Salience8'	;
if	y=	46	then 	ys=	'post_Salience9'	;
if	y=	47	then 	ys=	'post_Salience10'	;
if	y=	48	then 	ys=	'post_Salience11'	;
if	y=	49	then 	ys=	'post_Salience12'	;
if	y=	50	then 	ys=	'mayberg'	;
if	y=	51	then 	ys=	'dacc'	;
if	y=	52	then 	ys=	'vacc'	;
if	y=	53	then 	ys=	'L_amy'	;
if	y=	54	then 	ys=	'R_amy'	;
/*cats function removes trailing and leading blanks*/
ROI = cats (of xs ys);
run;



/* In a series of datasteps I merge together timpoint 1, timpeoint 2 data and the imaging input from MATLAB/SPM. */
