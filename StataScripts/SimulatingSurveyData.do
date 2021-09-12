**************************
* Simulating survey data *
**************************

* I want to simulate 12 monthly surveys of US Nationally-Representative samples, with N=300 in each month
* I want this file to be labeled in a way that mimics a well-programmed survey, hosted on a platform like Decipher by FocusVision

clear all
set obs 3600

* Generate an ID variable (record) plus a month-ID (first 300 Observations are from month 1, ten 301 to 600 are month 2, etc.)
egen record = seq(), from(1) to(3600) block(1)
egen month = seq(), from(1) to(12) block(300)

	*define variable and value labels for each variable we create (it will be important later when we read the meta-data of the STATA file into a dashboard)
	la var record "Participant Record"
	la var month "Month of Survey"
	la def month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	la val month month

	
***********************************************************	
* Next, let's simulate an Age, Gender, and State question *
***********************************************************

* For Age, I'll use STATA's function to return a random value from a uniform integer sample 
set seed 42
gen S1 = runiformint(18,74)
la var S1 "How old are you?"

* Recode into census age breaks to later use for weighting
gen S1_RECODE=.
replace S1_RECODE=1 if inrange(S1,18,24)
replace S1_RECODE=2 if inrange(S1,25,34)
replace S1_RECODE=3 if inrange(S1,35,44)
replace S1_RECODE=4 if inrange(S1,45,54)
replace S1_RECODE=5 if inrange(S1,55,64)
replace S1_RECODE=6 if inrange(S1,65,74)
la var S1_RECODE "RECODE: Census Age Brackets"
la def S1_RECODE 1 "18-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65-74"
la val S1_RECODE S1_RECODE 


* For discrete variable simulations, it will be better to run these in Python, as I can set the probabilities of each choice
* STATA 16+ has a built-in python module, and a stata-functional-interface package (sfi) that I can set values into a variable in the current dataset
gen S2=.
la var S2 "What best describes your gender?"
la def S2 1 "Male" 2 "Female"
la val S2 S2

gen S3=.
la var S3 "What state do you currently live in?"
la def S3 1 "Alabama" 2 "Alaska" 3 "Arizona" 4 "Arkansas" 5 "California" 6 "Colorado" 7 "Connecticut" 8 "Delaware" 9 "District of Columbia" 10 "Florida" 11 "Georgia" 12 "Hawaii" 13 "Idaho" 14 "Illinois" 15 "Indiana" 16 "Iowa" 17 "Kansas" 18 "Kentucky" 19 "Louisiana" 20 "Maine" 21 "Maryland" 22 "Massachusetts" 23 "Michigan" 24 "Minnesota" 25 "Mississippi" 26 "Missouri" 27 "Montana" 28 "Nebraska" 29 "Nevada" 30 "New Hampshire" 31 "New Jersey" 32 "New Mexico" 33 "New York" 34 "North Carolina" 35 "North Dakota" 36 "Ohio" 37 "Oklahoma" 38 "Oregon" 39 "Pennsylvania" 40 "Rhode Island" 41 "South Carolina" 42 "South Dakota" 43 "Tennessee" 44 "Texas" 45 "Utah" 46 "Vermont" 47 "Virginia" 48 "Washington" 49 "West Virginia" 50 "Wisconsin" 51 "Wyoming"
la val S3 S3

python
import numpy as np
from sfi import Data

gender_array = np.random.choice(np.arange(1, 3), size = 3600, p=[0.49,0.51])
Data.store("S2",None,gender_array)

state_array = np.random.choice(np.arange(1,52),size=3600,p=[0.0149378263628539, 0.00222869261237624, 0.0221750169920884, 0.00919390807181986, 0.120376189432861, 0.0175443101652326, 0.0108618455432011, 0.00296662629503029, 0.00215010366073436, 0.0654331227504251, 0.0323465708911599, 0.00431353295623696, 0.00544439311776602, 0.0386054088922131, 0.0205100803781024, 0.00961209659081792, 0.00887557346346741, 0.0136110147832502, 0.0141628100038398, 0.00409521677253961, 0.0184185010529643, 0.0209983945169211, 0.0304255164299639, 0.0171814531914245, 0.00906700379283698, 0.0186980164481899, 0.00325609174127395, 0.00589328177886732, 0.00938386691477126, 0.00414243533981738, 0.0270600868500531, 0.00638810640728356, 0.05926635775668, 0.031952532419443, 0.00232166435362508, 0.0356114945974985, 0.012055132678218, 0.0128495708300185, 0.0390019729586312, 0.00322740232595329, 0.0156858441449782, 0.00269516294660226, 0.0208054591890203, 0.0883375674415661, 0.00976712971886691, 0.00190101726415195, 0.0260039343281644, 0.0231991959115783, 0.00545987571399194, 0.0177383696721982, 0.00176322154843005])
Data.store("S3",None,state_array)
end

* Many surveys have a state-to-region recode, which I will do here because I need to weight the data later:
gen S3_RECODE=.
replace S3_RECODE=1 if inlist(S3,7, 20, 22, 30, 31, 33, 39, 40, 46)
replace S3_RECODE=2 if inlist(S3,14, 15, 16, 17, 23, 24, 26, 28, 35, 36, 42, 50)
replace S3_RECODE=3 if inlist(S3,1, 4, 8, 9, 10, 11, 18, 19, 21, 25, 34, 37, 41, 43, 44, 47, 49)
replace S3_RECODE=4 if inlist(S3,2, 3, 5, 6, 12, 13, 27, 29, 32, 38, 45, 48, 51)
la var S3_RECODE "RECODE: Census Region Divisions"
la def S3_RECODE 1 "Northeast" 2 "Midwest" 3 "South" 4 "West"
la val S3_RECODE S3_RECODE

**************************************************************************
* Finally here, let's simulate survey data for NPS on fictional companies*
**************************************************************************

* Store company names in locals to make labeling easier
local nom1 = "Dunder Mifflin"
local nom2 = "Skynet"
local nom3 = "Cable Town"
local nom4 = "Paddy's Pub"
local nom5 = "Paunch Burger"

la def Q1 1 "Never heard of before" 2 "Slightly familiar (heard the name before)" 3 "Moderately familiar" 4 "Very familiar" 5 "Extremely familiar"
la def Q2 0 "0 - Not at all likely" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10 - Extemely likely"

foreach x of numlist 1/5{
    gen Q1r`x'=runiformint(1,5)
	la var Q1r`x' "`nom`x'' - How familiar are you with the following companies?"
	la val Q1r`x' Q1
	* For Q2, only show to respondents who are at least slightly familiar with the company
	gen Q2r`x'=runiformint(0,10) if Q1r`x'>=2 & Q1r`x'<=5
	la var Q2r`x' "`nom`x'' - How likely are you to recommend `nom`x'' to a friend?"
	la val Q2r`x' Q2
}

order Q1r* Q2r*, last

* Save the file
save "application\dash\assets\StataFiles\SimulatedSurveyData.dta", replace
