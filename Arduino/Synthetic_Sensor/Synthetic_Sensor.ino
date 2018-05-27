
#include <I2Cdev.h>
#include <MPU6050_6Axis_MotionApps20.h>
#include <Wire.h>
#include <Adafruit_AMG88xx.h>
#include <DHT.h> // library for AM2302 sensor
#include <math.h>

Adafruit_AMG88xx amg;

#define DHTPIN 7 //humidity_temperature connetced to pin 7
#define DHTTYPE DHT22 // AM2302
#define S0 8 //color sensor S0 to pin 8
#define S1 9 //color sensor S1 to pin 9
#define S2 12//color sensor S2 to pin 12
#define S3 11//color sensor S3 to pin 11
#define color_out 10 // color sensor OUT to pin 10

float pixels[AMG88xx_PIXEL_ARRAY_SIZE];
int r, g, b; // color sensor variables for Red, Green, Blue
int sound=A0; // sound sensor connected pin: analog A0
const int sampleTime = 50; 
int micOut;
int light=A1; // light sensor connected pin: analog A2
int pir=13; // pir sensor connected pin: digital 13
long accelX, accelY, accelZ;
float accX, accY, accZ;
int temp_cnt[2]={0, 0};
int temp_val[2]={0 ,0};
int err_val[2]={0, 0};
float err_val2[2] = {0, 0};
float temp_val2[2] = {0, 0};
int temp_cnt2[2] = {0, 0};

  
int y = 1;
int phone_ring = 2;
int tissue = 3;
int door_close = 4;
int vacuum = 5;
int faucet = 6;
int lights_on = 7;
int lights_off = 8;
int stove = 9;
int phone_lighton = 10;
int phone_lightoff = 11;
int phone_stove = 12;
int stove_lighton = 13;
int stove_lightoff = 14;
int vacuum_lighton = 15;
int vacuum_lightoff = 16;
int vacuum_stove = 17;
int grid_row_cnt[8]={0, 0, 0, 0, 0, 0, 0, 0};
int grid_col_cnt[8]={0, 0, 0, 0, 0, 0, 0, 0};

DHT dht(DHTPIN, DHTTYPE);
// initialize DHT sensor for normal 16mhz Arduino

void setup()
{
  
  pinMode(S0, OUTPUT);
  pinMode(S1, OUTPUT);
  pinMode(S2, OUTPUT);
  pinMode(S3, OUTPUT);
  pinMode(color_out, INPUT);
  digitalWrite(S0, HIGH);
  digitalWrite(S1, LOW);
  //set fequency scaling to 20%

  Wire.begin(); // initialize Wire library  
  dht.begin();
  Serial.begin(19200);
  bool status = amg.begin();
  setupMPU();
  
}


// Find the Peak-to-Peak Amplitude Function
int findPTPAmp(){
   // Time variables to find the peak-to-peak amplitude
   unsigned long startTime= millis();  // Start of sample window
   unsigned int PTPAmp = 0; 

   // Signal variables to find the peak-to-peak amplitude
   unsigned int maxAmp = 0;
   unsigned int minAmp = 1023;

   // Find the max and min of the mic output within the 50 ms timeframe
   while(millis() - startTime < sampleTime) 
   {
      micOut = analogRead(sound);
      if( micOut < 1023) //prevent erroneous readings
      {
        if (micOut > maxAmp)
        {
          maxAmp = micOut; //save only the max reading
        }
        else if (micOut < minAmp)
        {
          minAmp = micOut; //save only the min reading
        }
      }
   }

  PTPAmp = maxAmp - minAmp; // (max amp) - (min amp) = peak-to-peak amplitude
  return PTPAmp;   
}



void setupMPU()
 {
  Wire.beginTransmission(0b1101000); // I2C address of the MPU (b1101000/b1101001 for AC0 low/high datasheet)
  Wire.write(0x6B); // accessing the register 6B - Power Management
  Wire.write(0b00000000); // setting SLEEP register to 0.
  Wire.endTransmission();
  Wire.beginTransmission(0b1101000); // I2C address of the MPU
  Wire.write(0x1B); // accessing the register 1B - Gyroscope configuration
  Wire.write(0x00000000); // setting the gyro to full scale +/- 250deg
  Wire.endTransmission();
  Wire.beginTransmission(0b1101000); // I2C address of the MPU
  Wire.write(0x1C); // accessing the register 1C - Acccelerometer Configuration
  Wire.write(0b00000000); // setting the accel to +/- 2g
  Wire.endTransmission();
 }

int normalization(int color) // normalization of color values by averaging collected data
{
  int data[10]={0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  color=0;
  for(int i=0; i<10; i++)
  {
    data[i]=255-pulseIn(color_out, LOW);
    color+=data[i];
  }
  color/=10;
  return color;
}

 void recordAccelRegisters() // Accel recording for MPU
 {
  Wire.beginTransmission(0b1101000); //I2C address of the MPU
  Wire.write(0x3B); // starting register for Accel Readings
  Wire.endTransmission();
  Wire.requestFrom(0b1101000,6); //Request Accel Registers (3B - 40)
  while(Wire.available() < 6);
  accelX = Wire.read()<<8|Wire.read(); //Store first two bytes into accelX
  accelY = Wire.read()<<8|Wire.read(); //Store middle two bytes into accelY
  accelZ = Wire.read()<<8|Wire.read(); //Store last two bytes into accelZ
  processAccelData();
 }
 
 void processAccelData()
 {
  accX = accelX / 16384.0;
  accY = accelY / 16384.0;
  accZ = accelZ / 16384.0;
 }


void error_int(int sense_val, int i)
{
  if(temp_cnt[i]==1)
  {
    err_val[i] = sense_val-temp_val[i];
    temp_val[i]=sense_val;
  }
  else
  {
    temp_cnt[i]++;
    temp_val[i]=sense_val;
  }
}

void error_float(float sense_val, int i)
{
  if(temp_cnt2[i]==1)
  {
    err_val2[i] = sense_val-temp_val2[i];
    temp_val2[i]=sense_val;
  }
  else
  {
    temp_cnt2[i]++;
    temp_val2[i]=sense_val;
  }
}


void loop() 
{
  
  float hum=dht.readHumidity(); // read humidity from sensor
  float temp=dht.readTemperature(); // read temperature from sensor
  int micOutput = findPTPAmp();
  int lightpower = analogRead(light);
  float grideye_row[8]={0, 0, 0, 0, 0, 0, 0, 0};
  float grideye_col[8]={0, 0, 0, 0, 0, 0, 0, 0};
  int ind_row;
  int ind_col;
 
  error_float(hum, 0);
  error_float(temp, 1);
  error_int(micOutput, 0);
  error_int(lightpower, 1);
   
  recordAccelRegisters();
  
  // setting Red filtered photodiodes to be read
  digitalWrite(S2, LOW);
  digitalWrite(S3, LOW);
  r=normalization(r);
  // setting Green filtered photodiodes to be read
  digitalWrite(S2, HIGH);
  digitalWrite(S3, HIGH);
  g=normalization(g);
  // setting Blue filtered photodiodes to be read
  digitalWrite(S2, LOW);
  digitalWrite(S3, HIGH);
  b=normalization(b);
  
 
  amg.readPixels(pixels);
  
  for(int i=0; i<AMG88xx_PIXEL_ARRAY_SIZE; i++)
  {
    ind_row=i/8;
    ind_col=i%8;
    grideye_row[ind_row]+=pixels[i];
    grideye_col[ind_col]+=pixels[i];
  }
  for(int i=0; i<8; i++)
  {
    grideye_row[i]/=8;
    grideye_col[i]/=8;
  }
  
  Serial.print(err_val2[0]);
  Serial.print(" ");
  Serial.print(hum);
  Serial.print(" ");

  Serial.print(err_val2[1]);
  Serial.print(" ");
  Serial.print(temp);
  Serial.print(" ");
  
  Serial.print(err_val[0]);
  Serial.print(" ");
  Serial.print(micOutput);
  Serial.print(" ");
  
  Serial.print(err_val[1]);
  Serial.print(" ");
  Serial.print(lightpower);
  Serial.print(" ");
  
  Serial.print(digitalRead(pir));
  Serial.print(" ");

  Serial.print(r);
  Serial.print(" ");
  Serial.print(g);
  Serial.print(" ");
  Serial.print(b);
  Serial.print(" ");
  
  Serial.print(accX); // acc
  Serial.print(" ");
  Serial.print(accY);
  Serial.print(" ");
  Serial.print(accZ);
  Serial.print(" ");
 
  for(int i=0; i<8; i++)
  {
      Serial.print(grideye_row[i]);
      Serial.print(" ");   
  }
  
  for(int i=0; i<8; i++)
  {
      Serial.print(grideye_col[i]);
      Serial.print(" ");   
  }
  
  
  //Serial.print(y);
  Serial.println("");
  
}

