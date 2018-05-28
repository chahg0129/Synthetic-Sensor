# Synthetic_Sensor
  Synthetic Sensor is a program of a combination of general-purposing sensors. There are seven kinds of sensors, light(Flying-Fish), sound(ADMP401), temperature & humidity(AM2302), gyro & accelerometor(MPU6050), PIR(HC-SR501), color(TCS3200) and infrared heat ray detectoor(Grideye AMG8833). They are installed on an Arduino board and interact each other and enable various event kinds detection.

  Data are standardized with some various ways to minimize sensored noise. For the light and sound data, as it acts notable role, it returns its current value and the error value with the just previous one. However for the temperature and humidity, as the data range is not large, it returns its current value and the error value with 15th previous one. Sound sensor collects data for 50ms and it returns the frequency of the range(max-min). The color sensor collects data for ten times and returns the average value of R,G,B. As Grideye is composed of 64 pixels, the averages of each row and column are calculated and returned.

  The basic machine learning method used for this project is neural network and multi-classification and it is supervised. Data are collected under controlled conditions. It finds the deep learning model in which data are not overfitted and cost is minimized at the same time. The neural network model has two hidden layers of 30 and 25 nodes. The lambda factor for the regularization is set to five. The number of currently tested data is 17478. The overall learning accuracy is 96.22%


# Project Progress
  2017 September : 필요 장비 및 센서 탐구
  2017 Octover : 아두이노 및 센서 주문
  2017 November : 아두이노 기기, 센서별 기능 및 header files 연구
  2017 December : 아두이노 기기, 센서별 기능 및 header files 연구
  2018 January : 센서별 최적 Sampling Rate 및 머신러닝기법 연구(Coursera Machine Learning- Stanford University 강의 수강)
  2018 February : 데이터 정형화 방법 연구, 데이터 수집 및 최적 머신러닝 기법 탐구 - SVM vs. Neural Network
  2018 March : 데이터 정형화 방법 연구 및 데이터 수집
  2018 April : 데이터 수집 및 머신러닝
  2018 May : program GUI 작성 및 실험
  
  
 
