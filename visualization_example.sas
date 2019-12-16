/********************************************************************************
                      KPCA IML Visualization Example                                
 In this example, we illustrate how to use KPCA for visualization and we            
 compare the visualization results with those of PCA. The data set that is          
 used for this example is the Statistical Control Chart Time Series data available  
 in the UCI Machine Learning Repository.                                            
                                                                                    

Copyright © 2019, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
**********************************************************************************/

/* Fetch the dataset */
%let url=https://archive.ics.uci.edu/ml/machine-learning-databases/synthetic_control-mld/synthetic_control.data;
filename cc url "&url";

/* Generate type variable, 6 types in total */
data scct_test;
infile cc;
input var1-var60;
length type $20;
obsid = _n_;
select;
when( 1 <= _n_ <= 100 )    type = "Normal";
when( 101 <= _n_ <= 200 )  type = "Cyclic";
when( 201 <= _n_ <= 300 )  type = "Increasing Trend";
when( 301 <= _n_ <= 400 )  type = "Decreasing Trend";
when( 401 <= _n_ <= 500 )  type = "Upward Shift";
when( 501 <= _n_ <= 600 )  type = "Downward Shift";
end;
run;

filename cc clear;

proc sort data=scct_test;
by type obsid;
run;

/* Split the dataset into training set and test set */
proc surveyselect data=scct_test
      method=srs n=50
      seed=100 out=scct_train;
   strata type;
run;


proc iml;
varName = "var1":"var60";

use scct_train;
   read all var (varName) into X_train[c=varName];
close;

use scct_test;
   read all var (varName) into X_test[c=varName];
close;

/*Standardization*/
std=std(X_test);
mean=mean(X_test);

X_train=(X_train-mean)/std;
X_test=(X_test-mean)/std;


/* Kernel PCA */
opt = {.,         /* eigenvalue cutoff (default) */
       2,         /* Gaussian kernel */
       4,         /* kernel parameter=4 */
       1,         /* exact method for KPCA */
       2};        /* project on 2 PCs */
call KPCATrain(eigenVal, eigenVec, centroids, RowMeans, score,
               X_train, opt);
opt= {2, 2, 4};
score=KPCAScore(eigenVec, X_train, RowMeans, X_test, opt);

varNames = {"score_1" "score_2"};
create score_kpca from score [colname=varNames];
append from score;
close score_kpca;


/* PCA */
opt = {.,         /* eigenvalue cutoff (default) */
       0,         /* linear kernel */
       .,         /* no kernel parameter */
       1,         /* exact method for PCA */
       2};        /* project on 2 PCs */
call KPCATrain(eigenVal, eigenVec, centroids, RowMeans, score,
               X_train, opt);
opt= {2, 0, .};
score=KPCAScore(eigenVec, X_train, RowMeans, X_test, opt);

varNames = {"score_1" "score_2"};
create score_pca from score [colname=varNames];
append from score;
close score_pca;

quit;

data scoreByID;
   merge score_kpca scct_test(keep=type);
run;


/* Plot the first two KPCA scores */
ods graphics on / attrpriority=none;
proc sgplot data=scoreByID;
	title "Score Plot: Kernel PCA";
	styleattrs datasymbols=(circlefilled squarefilled starfilled X Triangle Asterisk);
	scatter x=score_1 y=score_2 /group=type markerattrs=(size=6px);
run;
ods graphics / reset;

data scoreByID;
   merge score_pca scct_test(keep=type);
run;


/* Plot the first two PCA scores */
proc sgplot data=scoreByID;
	title "Score Plot: PCA";
	styleattrs datasymbols=(circlefilled squarefilled starfilled X Triangle Asterisk);
	scatter x=score_1 y=score_2 /group=type markerattrs=(size=6px);
run;


title;

/*********************************************************************************

The sgplot procedure will give you the projections plot of the data in 2D by using 
the first two principal components of KPCA and the first two principal components of PCA.
You can clearly observe that the projections that use KPCA result in a better separation of 
the classes, whereas the projections that use PCA are heavily overlapped.
                                                                                    
**********************************************************************************/


