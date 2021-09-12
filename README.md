# SimulatedSurveyDashboard

I'm publishing this repository to highlight my skills as a Python developer and STATA user. The final app is hosted by Heroku, and can be explored [here](https://tracker-survey-dashboard.herokuapp.com/)

First, the script-file SimululatingSurveyData.do in the StataScripts folder shows how I used STATA to simulate 12 months of survey data for 5 fictional companies.

Second, the script-file ProcessingSurveyData.do shows how I collapsed the simulated respondent-level data into summary statistics for various sub-audiences over time, and prepared the STATA file with sufficient meta-data so that question text and variable labels could be read into the final dashboard application.

Finally, I created the full repository here to highlight a few features of Dash, Pandas, and Py-PPTX that I think are particularly useful for any project managers in agency or business intelligence roles:

- I wanted to demonstrate how survey-trackers can be transformed into multiple time-series and shared. Dash allows data managers to share simple query systems internally and externally; the app I've created is intended partially as a clone of the FRED economic database that allows users to search and query time series data published by the Federal Reserve. 
- I wanted to show how Python can be used to automate deck-creation using custom office templates (here I've only used a few of the default Microsoft templates), allowing for designers to collaborate with developers so an organization can build well designed and branded decks that are also automated and easy to fill with data.
