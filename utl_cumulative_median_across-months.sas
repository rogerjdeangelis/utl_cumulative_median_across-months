Cumulative median across months

  SAS and WPS gave the same results after working around DOSUBL and  median(of mat[*]);

github
https://github.com/rogerjdeangelis/utl_cumulative_median_across-months

SAS forum
https://tinyurl.com/https-communities-sas-com-t5
https://communities.sas.com/t5/SAS-Visual-Analytics/How-do-I-create-a-cumulative-median-field-in-SAS-VA-7-4-Designer/m-p/461680

INPUT
-----

Sample Data
-------------
Account ID    Month            #patients
----------   -------            ----------
1            Jan2017            5
2            Jan2017            3
3            Feb2017            7
4            Feb2017            6
5            Feb2017            2
6            Mar2017            4
7            Apr2017            1
8            Apr2017            10
9            Apr2017            9
10           Apr2017            3



Typical calculation in SAS VA 7.4
-----------------------------------
Monthly Median (Easy using median function)
-------------------------------------------
Month            Median Patients
---------      ---------------
Jan2017            4            ( 5+3 ) /2
Feb2017            6            middle of ( 2,6,7 )
Mar2017            4
Apr2017            6            middle of ( 1,3,9,10 )  = (3+9)/2 = 6



Cumulative Monthly Median (Desired in SAS VA 7.4) Any idea how to calculate this assuming this is in a List Table with only two fields (Month and Median Patients)?
------------------------------------------------------------------------------------------------------------------------------------------------------------
Month            Median Patients
--------      -----------------
Jan2017            4            ( 5+3 ) /2
Feb2017            5            middle of ( 2,3,5,6,7 )       = 5
Mar2017            5            middle of ( 2,3,4,5,6,7 )       = (4+5) /2 = 4.5(approx. 5 when rounded)
Apr2017            5            middle of(1,2,3,3,4,5,6,7,9,10) = (4+5) /2 = 4.5(approx. 5 when rounded)


PROCESS
=======

data want;

  * all this to get the dimension for an array to hold all obs;
  if _n_=0 then do;
    %let rc=%sysfunc(dosubl('
        data _null_;
          set have nobs=obs;
          call symputx('obs',obs);
        run;quit;
    '));

  array mat[&obs] _temporary_;
  set have;
  by mth notsorted;
  * accumulate data in an array that will hold all obs;
  mat[_n_]=val;
  if last.mth then do;
      * keep computing median at array fills missing ar ignored;
      med=median(of mat[*]);
      output;
   end;

run;quit;


OUTPUT
======

 WORK.WANT total obs=4

   Obs     MTH      VAL    MED

    1    Jan2017     3     4.0
    2    Feb2017     2     5.0
    3    Mar2017     4     4.5
    4    Apr2017     3     4.5

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data have;
input mth $ val;
cards4;
Jan2017 5
Jan2017 3
Feb2017 7
Feb2017 6
Feb2017 2
Mar2017 4
Apr2017 1
Apr2017 10
Apr2017 9
Apr2017 3
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

for SAS see process

*WPS;
%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
data wrk.want;
  retain a1-a10;
  array mat[&obs] a1-a&obs;
  set wrk.have;
  by mth notsorted;
  mat[_n_]=val;
  if last.mth then do;
      med=median(of a:);
      output;
   end;
run;quit;
');



