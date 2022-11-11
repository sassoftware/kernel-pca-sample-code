# Kernel PCA Sample Code

## Overview
Kernel PCA (KPCA) is a powerful machine learning technique which has
been used for visualization, dimension reduction, and novelty detection. The
[folllowing](#ref) [1] SAS technical report contains various applications of KPCA on publicly available datasets
available from the [University of California Irvine machine learning repository](#uci) [2]. This project contains code
for the examples in the the technical report.

## What is Kernel Principal Components Analysis?
Kernel Principal Components Analysis is a non-linear extension of 
Principal Components Analysis (PCA) using kernel functions. Unlike
PCA which can only detect linear dependencies in the data, KPCA can detect non-linear structures in the data. The ability to detect non-linear structures in the data makes KPCA suitable for many kinds of analysis for which PCA may be inadequate. 

Despite its many advantages, the use of KPCA is inhibited by the huge computational cost. The traditional implementation of KPCA requires construction of a n x n kernel matrix where n is the number of observations in the data. The construction of this large matrix is computationally expensive and makes the use of KPCA infeasible for large datasets.

The SAS implementation of KPCA optionally allows the use a low rank approximation that bypasses the need to create a large kernel matrix. This will allow you to use KPCA for large data datasets in a fraction of the time of the conventional method without a noticeable change in the quality of the results.

## List of examples
| File|Application|
|-----------------------|------------------|
|visualization_example.sas| We use KPCA for visualization and compare the visualization results with those from PCA. <br /> The data set that is used for this example is the Statistical Control Chart Time Series data available in the UCI Machine Learning Repository [3].|
| radardata_classification_example.sas |  We demonstrate the effectiveness of KPCA in dimension reduction for classification and compare it with PCA . We apply KPCA and PCA to dimention reduction, and then use linear discriminant analysis (LDA) on the reduced dimension scores to classify the radar returns as Good or Bad. <br />The data set that is used for this example is the  Ionosphere data set from the UCI Machine Learning Repository [4].
|novelty_detection_example.sas| We use KPCA for novelty detection. The data set used in this example is the Breast Cancer Wisconsin data (Original) [5] available at the UCI Machine Learning Repository. We train the KPCA-based novelty detector on 200 benign samples and then test it on 244 benign and 239 malignant samples. As a novelty measure, we calculate the reconstruction  error in the high dimensional feature space.|
| letter_recognition_example.sas| We use fast KPCA, a low-rank approximation method, to analyze the letter recognition data set from the UCI Machine Learning Repository [6]. The goal is to identify each of a large number of black-and-white rectangular pixel displays as one of the 26 capital letters in the English alphabet. We extract the nonlinear KPCA principal component scores and feed them into a multi-label linear discriminant analysis for classification.|
| kpca_cmse_bandwidth_selection_example.sas| This example is from the Data Science BLOG article: Efficient and Automated Bandwidth Selection in SAS® PROC KPCA. It illusrates the use of the random CMSE to automatically and efficiently identify the optimal bandwith for identifying a linearly separable space.|
| kpca_cmse_iml_data_creation.sas| This example is a supplementary program that creates the data for the Data Science BLOG article: Efficient and Automated Bandwidth Selection in SAS® PROC KPCA. It illusrates the use SAS/IML to create two tori in three dimensions.|



## Installation
Required software offered as part of [**SAS Analytics for IoT**](https://www.sas.com/en_us/solutions/iot.html):
*  **SAS IML** version 15.1 or above.  

## Contributing
We are not accepting any contributions to this project.


## License
This project is licensed under the [Apache 2.0 License](LICENSE).

## <a name="ref"> </a> References
[1] Kernel Principal Component Analysis Using SAS: Kai Shen and Zohreh Asgharzadeh, SAS Institute Inc., URL: https://support.sas.com/content/dam/SAS/support/en/technical-papers/kpca-technical-report.pdf

[2] <a name="uci"> </a> UCI Machine Learning repository : https://archive.ics.uci.edu/ml/index.

[3] Statistical Control Chart Time Series Data Set : https://archive.ics.uci.edu/ml/datasets/synthetic+control+chart+time+series

[4] Ionosphere Data Set : https://archive.ics.uci.edu/ml/datasets/ionosphere

[5] Breast Cancer Wisconsin (Original) Data Set : https://archive.ics.uci.edu/ml/datasets/breast+cancer+wisconsin+(original)

[6] Letter Recognition Data Set : https://archive.ics.uci.edu/ml/datasets/Letter+Recognition
