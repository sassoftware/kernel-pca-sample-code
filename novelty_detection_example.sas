/**********************************************************************************************
                      KPCA IML Novelty Detection Example                                
In this example, we demonstrate a case where we use KPCA for novelty detection. The data set
used in this example is the Breast Cancer Wisconsin data (Original) available at the UCI Machine
Learning Repository. We train the KPCA-based novelty detector on 200 benign samples and then test 
it on 244 benign and 239 malignant samples. As a novelty measure, we calculate the reconstruction 
error in the high dimensional feature space.
                                                                                    

Copyright © 2019, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
************************************************************************************************/



/* Fetch data */
%let url=https://archive.ics.uci.edu/ml/machine-learning-databases/breast-cancer-wisconsin/breast-cancer-wisconsin.data;
filename cc url "&url";


data wdbc;
	infile cc delimiter=',';
	input var1-var10 group;
	obsid = _n_;
run;

/* Delete observations with missing value */
data wdbc;
	set wdbc;
	if cmiss(of _all_) then delete;
run;


/* Split dataset into training set (200 all benign) and test set (483 benign and malignant) */
proc surveyselect data=wdbc (where=(group=2))
	method=srs n=200
	seed=100 out=wdbc_train;
run;

proc sql;
	create table wdbc_test as
	select * from wdbc
	where obsid not in (select obsid from wdbc_train);
quit;


proc iml;

varNames = ("var2":"var10");
use wdbc_train;
   read all var varNames into wdbc_train[c=varName];
   read all var "group" into class_train;
close;

use wdbc_test;
   read all var varNames into wdbc_test[c=varName];
   read all var "group" into class_test;
close;

 /* Scale data*/ 
std=std(wdbc_train//wdbc_test);
wdbc_train=wdbc_train/std;
wdbc_test=wdbc_test/std;

/* Add uniform noise */
wdbc_train= wdbc_train+randfun({200, 9}, "Uniform", -0.05, 0.05);
wdbc_test= wdbc_test+randfun({483, 9}, "Uniform", -0.05, 0.05);


/* Kernel PCA */
opt = {1E-15,        
       2,         /* Gaussian kernel */
       2,         /* kernel parameter=2 */
       1,         /* exact method for PCA */
       190};        /* project on 190 PCs */
call KPCATrain(eigenVal, eigenVec, centroids, RowMeans, score_train,
               wdbc_train, opt);

eigenVec=eigenVec[,1:190];

opt_score= {190, 2, 2};

/* Distance function */
start sqdist(a,b);
    c=a`; d=b`;
    aa = (c#c)[+,]; bb = (d#d)[+,]; ab = c`*d; 
    d = abs(repeat(aa`,1,ncol(bb))+ repeat(bb,ncol(aa),1) - 2*ab);
    return(d);
finish;

/* Reconstruction error function */
start recerr(eigenVec, test, train, RowMeans, opt);
    sigma=opt[3];
	K_sum=mean(Rowmeans);
    score_test=KPCAScore(eigenVec, train, RowMeans, test, opt);
    dist_1=sqdist(test,test);
    K1=exp(-dist_1#(1/(2*sigma##2)));
	dist_2=sqdist(test,train);
	K2=exp(-dist_2#(1/(2*sigma##2)));
	K2_sum=K2[ ,+];
	err=K1-2*K2_sum/nrow(train)+K_sum-score_test*score_test`;
    return(err);
finish;

ntest=nrow(wdbc_test);
error=j(ntest, 1);

/* Calculate reconstruction error */
do i = 1 to ntest;
    test=wdbc_test[i,];
    err=recerr(eigenVec, test, wdbc_train, RowMeans, opt_score);
	error[i,]=err;
end;


create error from error [colname="error"];
append from error;
close error;

create group_test from class_test [colname="group_t"];
append from class_test;
close group_test;

quit;

/* Assign points with reconstruction error larger than threshold to malignant */
data error;
 set error;
 if error>=0.0834 then group_p=4;
 else group_p=2;
run;

data compare;
   merge error group_test;
run;

/* Calculate TP, FN, FP */
 proc freq data=compare;
     table group_p*group_t/ out=CellCounts;
 run;

/**********************************************************************************************

From the output of proc freq you can calculate F1 score to compare novelty detector performance.
Here the novelty detector based on KPCA achieves an F1 score of 0.9726. We also applied another 
commonly used novelty detector method, Support Vector Data Description (SVDD), on this data set. 
SVDD achieved an F1 score of 0.9530. We can see that the two methods have comparable performances.
For multi-form variance data, the novelty detector based on KPCA can in fact achieve a tighter 
decision boundary than SVDD can achieve.

************************************************************************************************/





