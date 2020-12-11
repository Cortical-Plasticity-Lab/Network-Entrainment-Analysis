# m053m716 #
This folder contains Matlab scripts (R2020b) related to statistics and figures included in Figure 4 (Synaptophysin expression analyses), as well as generalized linear mixed-effects models pertaining to longitudinal analyses tracking changes in mean firing rate (MFR).

## Instructions ##

Initially this was only going to hold scripts related to [**Figure 4**](#figure-4). Therefore, `main.m` relates to **Figure 4**. However, out of laziness, the code for [**Mean Firing Rate Statistics**](#mfr-statistics) (GLME for tracking longitudinal changes in MFR) was also included in this repository. The relevant script for these analyses is in `mfr_stat_trends.m`. 

### Figure 4 ###

The only main configuration variable that needs to be setup locally in `main.m` is `DIR`. 

* It should point to wherever the data lives.

### MFR Statistics ###

As long as `MFR_SPREADSHEET_LONG_NAME` points to the spreadsheet containing "MFR" column by "Name", "Stim" (Treatment), "Day", "Time" (Epoch), and with "nPulses" columns as well, then the script should be able to handle the rest. The main parameters that could be changed on an *ad hoc* basis are emphasized at the top of the code, but to expand here:

* `MFR_THRESH` : This two-element vector sets the [lower, upper) bounds for the range of acceptable mean-firing rates (spikes/sec). The default value is currently [0.1, 10], so that the included values are in the range 0.1 <= MFR < 10 spikes/sec.
  * ***Note 1***. *If an observation for a given epoch is excluded, then all epochs for that recording session/unit combination are removed from further consideration.*
* `MFR_GLME_MODEL_SPEC` : This is given in [**Wilkinson Notation**](https://www.mathworks.com/help/stats/wilkinson-notation.html "A shorthand that makes it easier to express the statistical model."). 
  *  **Model formulation.** In considering model formulae, fundamentally the question we want to answer is:
    *"Does ADS treatment (by comparison to RS and C, and accounting for the total amount of stimuli delivered) correlate with longitudinal changes in unit activity rates for a given animal?"*
    * To answer this question, we use the following **fixed-effect** terms:
      * **`Intercept`**. There should be some bias expected particularly due to the exclusion step.
      * **`Treatment`**. Was activity-dependent stimulation (ADS), random-stimulation (RS), or control/sham (C) stimulation used?
      * **`Day`**. What postoperative day, relative to the implant was this recording taken from?
      * **`Epoch`**. Was this activity from the 30-minutes preceding stimulation ("Pre"), the 80-minute stimulation epoch ("Stim"), or the 90-minute post-stimulation epoch ("Post")?
    * We also can include some **random-effect** terms grouped by **`Rat_ID`** to account for expected random covariates of the total overall excitability in units we are recording from. Namely, on the basis that each Rat will have a slightly different "environment" around the electrodes, which are more or less fixed in place once they have been implanted, there should be an **`Intercept`** term in that grouping. There should also be:
      * **`Day_Sigmoid`**. Each rat might experience a slightly different day-to-day fluctuation in rate. We can fit a sigmoidal transformation on Day that causes the largest changes to occur in the middle, while "flattening" values at either tail. By using a sigmoidal `Day_Sigmoid` term in the random effect, we can prevent over-or-underestimation of values related to extrema of `Day` from the fixed effect in the main model. The `Day_Sigmoid` term can be thought of as "within-animal" trends, which could be different for different animals within a group; however, if there is an overall tendency for a Treatment regime to influence or bias activity to be higher within day (even for animals with overall decreasing trends according to the Sigmoid), then the fixed-effect term captures that feature while this term captures the within-animal trend.
      * **`nPulses`**
* `MFR_GLME_MODEL_RESPONSE`:  The import function automatically generates the following possible "response" variates as columns (variables) in the table `T`: 
  * `MFR`: The number of spikes from a sorted unit during a given epoch of time, divided by the number of seconds in that epoch.
  * `SMFR`: square-root transformed mean firing rate. This is a common transformation that accounts for heteroscedasticity due to variance scaling with the mean typically in unit activity. The perk of doing it this way is that you don't have to worry about "zero values" because those just stay as zero (unlike log-transforms).
  * `LMFR`: log-transformed mean firing rate. The most-common assumption about point processes used to describe cortical spike trains is that they are Poisson-distributed. Therefore, the appropriate transformation is the log transformation, assuming we are not applying a GLME with a log link function. Because of the thresholding step, there should not be any `MFR` values of zero to worry about so this transformation is safe; however, if using a `Gamma` distribution in the GLME then just leave the values in terms of `MFR`. 
  * `N`: extrapolated (integer) spike counts under the assumption that mean firing rate is held for a fixed period of one hour. Not recommended, but included because to fit the Poisson or Binomial distribution using GLME in Matlab, integer count values are required.

