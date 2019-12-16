/********************************************************************************************************
                      KPCA IML Classification Example                                
In this example, we demonstrate the effectiveness of KPCA in dimension reduction for classification
and compare it with that of PCA. We use the Ionosphere data set from the UCI Machine Learning Repository. 
The goal is to apply KPCA and PCA to dimention reduction, and then use linear discriminant analysis (LDA) 
on the reduced dimension scores to classify the radar returns as Good or Bad.


Copyright © 2019, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
**********************************************************************************************************/

/* Fetch Data */
%let url=https://archive.ics.uci.edu/ml/machine-learning-databases/ionosphere/ionosphere.data;
filename cc url "&url";

data ionosphere;
	infile cc delimiter=',';
	input var1 +1 var2-var33 group $;
	obsid = _n_;
run;


/* Generate binary group variable */
data ionosphere;
	set ionosphere;
	if group="g" then group_n=1;
	else if group="b" then group_n=0;
run;

/* Split data set into training set (280) and test set (71) */
proc surveyselect data=ionosphere
	method=srs n=280
	seed=100 out=ionosphere_train;
run;

proc sql;
	create table ionosphere_test as
	select * from ionosphere 
	where obsid not in (select obsid from ionosphere_train);
quit;



proc iml;
varNames = ("var1":"var33"); 
use ionosphere_train;
   read all var varNames into X_train[c=varName];
   read all var "group_n" into group_train;
close;


use ionosphere_test;
   read all var varNames into X_test[c=varName];
   read all var "group_n" into group_test;
close;


/* Kernel PCA */
opt = {.,         /* eigenvalue cutoff (default) */
       2,         /* Gaussian kernel */
       2,         /* kernel parameter=2 */
       1,         /* exact method for PCA */
       18};        /* project on 18 PCs */
call KPCATrain(eigenVal, eigenVec, centroids, RowMeans, score_train,
               X_train, opt);
opt= {18, 2, 2};
score_test=KPCAScore(eigenVec, X_train, RowMeans, X_test, opt);

/* Save score values to SAS dataset */
varNames = ("var_1":"var_19");

score_train=score_train||group_train;
create score_train_kpca from score_train [colname=varNames];
append from score_train;
close score_train_kpca;

score_test=score_test||group_test;
create score_test_kpca from score_test [colname=varNames];
append from score_test;
close score_test_kpca;

/*PCA */
opt = {.,         /* eigenvalue cutoff (default) */
       0,         /* linear kernel */
       .,        
       1,         /* exact method */
       18};        /* project on 18 PCs */
call KPCATrain(eigenVal, eigenVec, centroids, RowMeans, score_train,
               X_train, opt);
opt= {18, 0, .};
score_test=KPCAScore(eigenVec, X_train, RowMeans, X_test, opt);

/* Save score values to SAS dataset */

score_train=score_train||group_train;
create score_train_PCA from score_train [colname=varNames];
append from score_train;
close score_train_PCA;

score_test=score_test||group_test;
create score_test_PCA from score_test [colname=varNames];
append from score_test;
close score_test_PCA;

quit;

/* LDA of KPCA scores */
proc discrim data=score_train_KPCA method=normal pool=yes
testdata=score_test_KPCA;  
class var_19;                /* var_19 is group varaible */
testclass var_19;
run;

/* LDA of PCA scores */
proc discrim data=score_train_PCA method=normal pool=yes
testdata=score_test_PCA;  
class var_19;
testclass var_19;
run;

/* LDA of original data */
proc discrim data=ionosphere_train method=normal pool=yes
testdata=ionosphere_test;  
var var1-var33;
class group;
testclass group;
run;

/**********************************************************************************************************

You will see the misclassification rate that resulted from applying linear discriminant analysis (LDA) on the
kernel principal components is 3%, which is significantly better than the 15% that resulted from applying LDA 
on principal components. Clearly, KPCA performs better than PCA in dimension reduction in this example, because 
it can capture the nonlinear relationship among attributes.   
                                                                                    
**********************************************************************************************************/

