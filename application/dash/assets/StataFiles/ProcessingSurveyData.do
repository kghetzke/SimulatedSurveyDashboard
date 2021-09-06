****************************************
* Processing Survey Data for Dashboard *
****************************************

* Here I want to demonstrate how a respondent level data-file should be processed to load in a dashboard.  The process is divided into the following sections:
	
	* PART ONE: Weighting each N=300 sample to be nationally representative on Age, Gender, and Region
	* PART TWO: Reshaping and Collapsing our Data-File into summary statistics by audience
		* 2.1 -> Reshape respondent file from wide to long
		* 2.2 -> Define Sub-Audiences that I want to rehape over
		* 2.2 -> Recode survey questions as dichotomous nets to take means for summary stats
		* 2.3 -> Collapse weighted means into the various sub-audiences we'll want to display in the dashboard

use "SimulatedSurveyData.dta", clear	
	
***************************************
* PART ONE: Weighting the Survey Data *
***************************************

* There is a simple STATA package called "ipfweight" that uses a raking algorithm to set weights given certain optimization parameters

* Store census target values in locals:
local age_target = "11.8 18 16.3 16 16.6 12.3"
local gender_target = "49 51"
local region_target = "17 21 38 24"

* Loop through each month, and weight each month's sample to nat-rep targets. 
* I don't want to count any given respondent more than 5 times, or fewer than 0.2 times
gen weight = .
la var weight "Survey Weighting Variable"
foreach x of numlist 1/12{
	ipfweight S1_RECODE S2 S3_RECODE if month==`x', gen(weight`x') val(`age_target' `gender_target' `region_target') tol(0.1) maxiter(10) up(5) lo(0.2)
	replace weight = weight`x' if month==`x'
}
drop weight1-weight12

**********************************************************************************************
* PART TWO: Reshape and Collapse the survey-data to be smaller/easier to read in a dashboard *
**********************************************************************************************

*** Part 2.1: Reshape file from wide to long ***

reshape long Q1r Q2r, i(record) j(company)
order month, a(record)

la var company "Company ID"
la def company 1 "Dunder Mifflin" 2 "Skynet" 3 "Cable Town" 4 "Paddy's Pub" 5 "Paunch Burger"
la val company company

rename *r *
la var Q1 "How familiar are you with the following companies?"
la var Q2 "How likely are you to recommend [COMPANY] to a friend?"

*** Part 2.2: Define Sub-Audience to Collapse over, and Reshape one more time

* Total audinece
gen aud1 = 1

* One for each age range
foreach x of numlist 1/6{
	gen aud`=`x'+1'=S1_RECODE==`x'
}

* One for each gender
gen aud8=S2==1
gen aud9=S2==2

* One for each region
foreach x of numlist 1/4{
	gen aud`=`x'+9'=S3_RECODE==`x'
}


* Drop the Screener variables I don't need anymore, and then reshape again
drop S1 S1_RECODE S2 S3 S3_RECODE

gen new_id = string(record) + "_" + string(company)

reshape long aud, i(new_id) j(audience)
la var audience "Audience ID"
la def audience  1 "Total Sample" 2 "18-24" 3 "25-34" 4 "35-44" 5 "45-54" 6 "55-64" 7 "65-74" 8 "Male" 9 "Female" 10 "Northeast" 11 "Midwest" 12 "South" 13 "West"
la val audience audience

drop if aud==0
drop new_id aud
order record month company audience, first

*** Part 2.3: Recode Q1 and Q2 into dichotomous nets for summary statistics
gen Q1_1 = Q1==1 if Q1!=.
gen Q1_2 = inrange(Q1,2,5) if Q1!=.
gen Q1_3 = inrange(Q1,4,5) if Q1!=.
gen Q1_N = Q1!=.

gen Q2_1 = inrange(Q2,0,6) if Q2!=.
gen Q2_2 = inrange(Q2,7,8) if Q2!=.
gen Q2_3 = inrange(Q2,9,10) if Q2!=.
recode Q2 (0=-1) (1=-1) (2=-1) (3=-1) (4=-1) (5=-1) (6=-1) (7=0) (8=0) (9=1) (10=1), gen(Q2_4)
gen Q2_N = Q2!=.

drop Q1 Q2

*** Part 2.4: Collapse the DataFile by Sub-Audiences, Companies, and Month of survey ***
gsort month company audience

collapse  (sum) Q1_N Q2_N (mean) Q1_1 Q1_2 Q1_3 Q2_1 Q2_2 Q2_3 Q2_4 [aweight=weight], by(month company audience) fast

la var Q1_1 "Never Heard Of"
la var Q1_2 "Heard of (T4B)"
la var Q1_3 "Very Familar (T2B)"

la var Q2_1 "NPS: Detractors"
la var Q2_2 "NPS: Neutrals"
la var Q2_3 "NPS: Promoters"
la var Q2_4 "NPS: Net Promoter Score"

la var Q1_N "N-Answering Q1"
la var Q2_N "N-Answering Q2"

*** Save the Processed File ***

save "ProcessedSurveyData.dta", replace




