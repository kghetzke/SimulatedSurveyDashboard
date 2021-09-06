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

*** Part 2.2: Define Sub-Audience to Collapse over

gen audience = .
la var audience "Audience ID"
order audience, a(company)

scalar k = 0
foreach x of numlist 1/6{
	local val_age: label S1_RECODE `x'
	foreach y of numlist 1/2{
		local val_gender: label S2 `y'
		foreach z of numlist 1/4{
			local val_region: label S3_RECODE `z'
			scalar k = k+1
			replace audience = k if S1_RECODE==`x' & S2==`y' & S3_RECODE==`z'
			la def audience `=k' "`val_age', `val_gender', `val_region'", modify
		}
	}
}
la val audience audience

drop S1 S1_RECODE S2 S3 S3_RECODE

*** Part 2.3: Recode Q1 and Q2 into dichotomous nets for summary statistics
gen Q1_1 = Q1==1 if Q1!=.
gen Q1_2 = inrange(Q1,2,5) if Q1!=.
gen Q1_3 = inrange(Q1,4,5) if Q1!=.
la var Q1_1 "Never Heard Of"
la var Q1_2 "Heard of (T4B)"
la var Q1_3 "Very Familar (T2B)"

gen Q1_N = Q1!=.
la var Q1_N "Answering Q1"

gen Q2_1 = inrange(Q2,0,6) if Q2!=.
gen Q2_2 = inrange(Q2,7,8) if Q2!=.
gen Q2_3 = inrange(Q2,9,10) if Q2!=.
recode Q2 (0=-1) (1=-1) (2=-1) (3=-1) (4=-1) (5=-1) (6=-1) (7=0) (8=0) (9=1) (10=1), gen(Q2_4)
la var Q2_1 "NPS: Detractors"
la var Q2_2 "NPS: Neutrals"
la var Q2_3 "NPS: Promoters"
la var Q2_4 "NPS: Net Promoter Score"

gen Q2_N = Q2!=.
la var Q2_N "Answering Q2"

drop Q1 Q2

*** Part 2.4: Collapse the DataFile by Sub-Audiences, Companies, and Month of survey
gsort month company audience

collapse (mean) Q1_1 Q1_2 Q1_3 Q2_1 Q2_2 Q2_3 Q2_4 (sum) Q1_N Q2_N [aweight=weight], by(month company audience)



