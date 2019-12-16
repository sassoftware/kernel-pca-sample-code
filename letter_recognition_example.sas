/****************************************************************************************
                      KPCA IML Letter Recognition Example                                
In this example, we investigate the performance of fast KPCA, which is based on a low-rank 
approximation method. The letter recognition data set that is used in this example is from UCI 
Machine Learning Repository. The goal is to identify each of a large number of black-and-white 
rectangular pixel displays as one of the 26 capital letters in the English alphabet. The 
KPCA extract nonlinear principal component scores and these scores are then fed into a 
multi-label linear discriminant analysis for classification.


Copyright © 2019, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*****************************************************************************************/


/* Fetch data */
%let url=https://archive.ics.uci.edu/ml/machine-learning-databases/letter-recognition/letter-recognition.data;
filename cc url "&url";


data letter;
	infile cc delimiter=',';
	input capital $ var1-var16;
	obsid = _n_;
run;


/* Split dataset into training set (16000) and test set (4000) */
proc surveyselect data=letter
      method=srs n=16000
      seed=100 out=letter_train;
run;

proc sql;
	create table letter_test as
	select * from letter
	where obsid not in (select obsid from letter_train);
quit;

proc iml;
varNames = ("var1":"var16");
use letter_train;
   read all var varNames into X_train[c=varName];
   read all var "capital" into group_train;
close;


use letter_test;
   read all var varNames into X_test[c=varName];
   read all var "capital" into group_test;
close;



/**************************************************
   Kernel PCA exact training step 
   
   Please note here the exact traning code 
   is commented out because it takes too long to
   run (about 600s). But if you want to try it
   you can uncomment it and run the code for exact
   training.
   
   Exact training option vector value:
  
      eigenvalue cutoff=default 
      Gaussian kernel=2
      kernel parameter=7.071 
      exact method for KPCA=1
      number of principal components=200
   
 **************************************************/


/*opt = {.,         */
/*       2,        */
/*       7.071,     */
/*       1,         */
/*       200};      */

/*Calculate training time */

/*t0=time();*/
/*call KPCATrain(eigenVal, eigenVec, centroids, RowMeans, score_train,*/
/*               X_train, opt);*/
/*t_exact=time()-t0;*/
/*c={"exact training time"};*/
/*print t_exact[colname=c format=12.2];*/

/*Kernel PCA scoring step */

/*opt= {200, 2, 7.071};*/
/*score_test=KPCAScore(eigenVec, X_train, RowMeans, X_test, opt);*/

/*Save score values to SAS dataset */

/*valname="group";*/

/*create score_train_exact from score_train;*/
/*append from score_train;*/
/*close score_train_exact;*/

/*create group_train from group_train [colname=valname];*/
/*append from group_train;*/
/*close group_train;*/

/*create score_test_exact from score_test;*/
/*append from score_test;*/
/*close score_test_exact;*/

/*create group_test from group_test [colname=valname];*/
/*append from group_test;*/
/*close group_test;*/


/* Kernel PCA traning step with low-rank approximation*/
opt = {.,         /* eigenvalue cutoff (default) */
       2,         /* Gaussian kernel */
       7.071,         /* kernel parameter=7.071 */
       0,         /* low-rank approximation for KPCA */
       190};        /* project on 190 PCs */


optCluster={2,      /* use kmeans++ to select initial centroids */
            190,    /* use 190 centroids in low-rank approximation */
			618,    /* use 618 as the random seed for centroid initilization */
			.,
			.,
			.};

/* Calculate approximate training time */
t0=time();
call KPCATrain(eigenVal, eigenVec, centroids, RowMeans, score_train,
               X_train, opt, optCluster);
t_approx=time()-t0;
c={"approximate training time"};
print t_approx[colname=c format=12.2];


/* Kernel PCA scoring step */
opt= {190, 2, 7.071};
score_test=KPCAScore(eigenVec, X_train, RowMeans, X_test, opt);

/* Save score values to SAS dataset */
create score_train_approx from score_train;
append from score_train;
close score_train_approx;

create score_test_approx from score_test;
append from score_test;
close score_test_approx;

quit;


/* Merge score data and group variable */
/*data score_train_exact;*/
/*   merge score_train_exact group_train;*/
/*run;*/
/**/
/*data score_test_exact;*/
/*   merge score_test_exact group_test;*/
/*run;*/

/* Multi-label linear discriminant analysis of exact KPCA scores*/
/*proc discrim data=score_train_exact method=normal pool=yes short*/
/*	testdata=score_test_exact;  */
/*	class group;*/
/*	testclass group;*/
/*run;*/

/* Merge score data and group variable */
data score_train_approx;
   merge score_train_approx group_train;
run;

data score_test_approx;
   merge score_test_approx group_test;
run;

/* Multi-label linear discriminant analysis of approximate KPCA scores*/
proc discrim data=score_train_approx method=normal pool=yes short 
	testdata=score_test_approx;  
	class group;
	testclass group;
run;

/****************************************************************************************

You will observe that the classification errors obtained by fast KPCA and exact KPCA are
close: 0.1629 for fast KPCA and 0.1596 for exact KPCA. However, the running time of fast KPCA is 
only about 3 seconds compared to about 600 seconds for exact KPCA. This example demonstrates the 
efficiency of fast KPCA in significantly reducing the running time while not compromising very much
on the quality of the principal components it generates. In this example, we also apply PCA on
the data and extract all 16 components to use in multi-label LDA. We find that even when all 
components are used, PCA achieves a misclassification rate of 0.3011, which is much higher 
than that of KPCA.            
                                                                                    
*****************************************************************************************/
