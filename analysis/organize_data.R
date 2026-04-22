# organize_data.R

# This script will load the raw data and then clean it up and organize it into
# an analytical dataset. If the local data version is behind the remote, the
# most recent data will be downloaded from an external source.

# Load packages ---------------------------------------------------------------

source("check_packages.R")


# Download data ---------------------------------------------------------------

# This script is for use when the data will be downloaded from an external
# source like Google Drive to each collaborator's local machine. This script
# checks if the data version on the remote repo matches the local and if not
# it downloads the required data and then updates the local version. If you are 
# not using external data, then this code chunk can be removed.

# get latest data version from repo
repo_version <- read_yaml(here("data", "data_raw", "data_version.yml"))$version

# get local data version
local_version_path <- here("data", "data_raw", "data_version_local.yml")
if (file_exists(local_version_path)) {
  local_version <- read_yaml(local_version_path)$version
} else {
  local_version <- "none"
}

if(local_version != repo_version) {
  
  # deauthorize google drive to avoid interactive authentication
  drive_deauth()
  
  # where the downloaded data will live
  file_path <- here("data", "data_raw", "fake_wage_data.csv")
  
  # download the data file - update based on the UUID found in the shared link
  # to file on google drive 
  drive_download(as_id("1C7FuY6lcLpWiaYUrwA7L0dli29CHc2Rn"), path=file_path, 
                 overwrite = TRUE)
  
  # update local to repo version
  write_yaml(list(version = repo_version), 
             here("data", "data_raw", "data_version_local.yml"))
}


# Read in data ----------------------------------------------------------------

data_wages <- read_csv(here("data", "data_raw", "fake_wage_data.csv"))


# Calculate hourly wages --------------------------------------------------

#adjust some variables for decimal places
data_wages$earningwt <- data_wages$earningwt/10000
data_wages$hourwage <- data_wages$hourwage/100
data_wages$earnweek <- data_wages$earnweek/100

#use hourly wage if provided
data_wages$wages <- ifelse(data_wages$hourwage==99.99, NA, data_wages$hourwage)
summary(data_wages$wages)
tapply(is.na(data_wages$wages), data_wages$paidhour, mean)

#use earnings last week and hours worked in a typical week for cases paidhour==1
data_wages$ahrsworkt <- ifelse(data_wages$ahrsworkt==999, NA, 
                               data_wages$ahrsworkt)
tapply(is.na(data_wages$ahrsworkt), data_wages$paidhour, sum)
data_wages$wages <- ifelse(data_wages$paidhour==1, 
                           data_wages$earnweek/data_wages$ahrsworkt, 
                           data_wages$wages)
summary(data_wages$wages)
tapply(data_wages$wages, data_wages$paidhour, summary)

#how many wages below $1?
sum(data_wages$wages<1, na.rm=TRUE)

#remove all missing wages and wages less than $1
data_wages <- subset(data_wages, !is.na(wages) & wages>=1)

#top-code wages from salary at $99.99/hour
data_wages$wages <- ifelse(data_wages$wages>99.99, 99.99, data_wages$wages)
summary(data_wages$wages)

# whats the distribution of hourly wages look like?
ggplot(data_wages, aes(x=wages, y=..density..))+
  geom_histogram(fill="grey", color="black")+
  geom_density(alpha=0.5, fill="grey")+
  theme_bw()


# Code other variables ----------------------------------------------------

data_wages <- data_wages |>
  mutate(gender=factor(sex, levels=1:2, labels=c("Male","Female")),
         racecombo=factor(case_when(
           hispan > 0 ~ "Latino",
           race==100 ~ "White",
           race==200 ~ "Black",
           race==300 | race==652 ~ "Indigenous",
           race==651 ~ "Asian",
           TRUE ~ "Other/Multiple"),
           levels=c("White","Black","Latino","Asian","Indigenous",
                    "Other/Multiple")),
         marstat=factor(case_when(
           marst==1 | marst==2 ~ "Married",
           marst==3 | marst==4 ~ "Divorced/Separated",
           marst==5 ~ "Widowed",
           marst==6 ~ "Never Married"),
           levels=c("Never Married","Married","Divorced/Separated","Widowed")),
         foreign_born=factor(ifelse(nativity==0, NA,
                                    ifelse(nativity==5, "Yes", "No")),
                             levels=c("No","Yes")),
         education=factor(case_when(
           educ==999 ~ NA_character_,
           educ<73 ~ "No HS Diploma",
           educ<90 ~ "HS Diploma",
           educ<111 ~ "AA Degree",
           educ<123 ~ "Bachelors Degree",
           TRUE ~ "Graduate Degree"),
           levels=c("No HS Diploma","HS Diploma","AA Degree","Bachelors Degree",
                    "Graduate Degree")),
         earn_type=factor(ifelse(paidhour==1, "Salary",
                                 ifelse(paidhour==2, "Wage", NA))),
         occup=factor(case_when(
           occ2010<430 ~ "Manager",
           occ2010<1000 ~ "Business/Finance Specialist",
           occ2010<2000 ~ "STEM",
           occ2010<2100 ~ "Social Services",
           occ2010<2200 ~ "Legal",
           occ2010<2600 ~ "Education",
           occ2010<3000 ~ "Arts, Design, and Media",
           occ2010<=3120 & occ2010!=3110 ~ "Doctors",
           occ2010<3600 ~ "Other Healthcare",
           occ2010<4700 ~ "Service",
           occ2010<5000 ~ "Sales",
           occ2010<6000 ~ "Administrative Support",
           TRUE ~ "Manual"),
           levels=c("Manual","Administrative Support", "Sales", "Service",
                    "Social Services", "Other Healthcare",
                    "Arts, Design, and Media", "Education","Legal","Doctors",
                    "STEM","Business/Finance Specialist","Manager"))
  )

# checks
table(data_wages$gender, data_wages$sex, exclude=NULL)
table(data_wages$race, data_wages$racecombo, exclude=NULL)
table(data_wages$hispan, data_wages$racecombo, exclude=NULL)
table(data_wages$marst, data_wages$marstat, exclude=NULL)
table(data_wages$nativity, data_wages$foreign_born, exclude=NULL)
table(data_wages$educ, data_wages$education, exclude=NULL)
table(data_wages$earn_type, data_wages$paidhour, exclude=NULL)
table(data_wages$occup, exclude=NULL)

# Finalize Dataset --------------------------------------------------------

#limit this to ages 18 to 65
#only a few missing values for foreign born so just drop

earnings <- data_wages |>
  filter(age>=18 & age<65 & !is.na(foreign_born)) |>
  mutate(race=racecombo) %>%
  select(wages, age, gender, race, marstat, education, occup, nchild,
         foreign_born, earn_type, earningwt)


save(earnings, file=here("data", "data_constructed","earnings.RData"))

#add changes here to test update
