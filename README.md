# Australian Savanna Water Resource Model
Savanna model introduced in Strickland, Liedloff, Cook, 
Dangelmayr, and Shipman (2016), Journal of Ecology. Functionality includes:
- Water resource dynamics based on soil properties and daily rainfall history
- Stand size-structure dynamics using (long) vector of basal area size classes
- Continuous-time solution of underlying mathematical model available
- Stochastic (Markov-Gamma) rainfall generation available given data
- Discrete-time model for longer simulations
- Object-oriented fire disturbance mechanism, including many possible regimes
- Dry season analysis for length and severity as a function of total basal area

**Author:** Christopher Strickland  
**Email:** wcstrick@email.unc.edu  
**Developed at:** Colorado State University; the University of North Carolina, Chapel Hill;
    CSIRO; and Statistical and Applied Mathematical Sciences Institute.  
**GitHub:** https://github.com/mountaindust  

Copyright (c) 2016, Christopher Strickland. All rights reserved.  
This software is licensed under the GNU GPLv3 (license.txt). Please contact 
Christopher Strickland (wcstrick@email.unc.edu) to inquire after other licensing.  
A few plotting routines utilize subplotplus.m, provided by Alon Geva and used
with permission (see license_subplotplus.txt).

AusSavanna2.m is the main file for running simulations. All model paramters are
specified by editing this file, including different run options. It should not
be necessary to edit any other file to run the model. The output will automatically
be saved (.mat file) and plotted at the end of the simulation using 
AusSavanna2_plot.m. Previous simulations may then be plotted again by simply
calling AusSavanna2_plot.m with the .mat file as the sole argument.

Additional plotting routines are provided in separate m-files for viewing
simulations side-by-side and the like. These were used to generate the plots in
our publication.

AusSavanna2ContModel.m is the main file for running continuous-time solution
simulations that directly solve the ODEs making up the model (Runge-Kutta). 
This provides results that include day-to-day soil water dynamics, which are
automatically saved (.mat file) and plotted using AusSavanna2ContModel_plot.m. 
Previous simulations may then be plotted again by simply calling
AusSavanna2ContModel_plot.mwith the .mat file as the sole argument.

The BucketsMarkov directory includes everything needed to run the dry season
analysis for dry length and water stress as a function of total basal area.
MarkovRun.m is a script file for examining the probability of stand stress and
different dry season lengths given the stand's total basal area (TBA). TBA and 
other constants are specified at the top of the script, along with a file
containing parameters for stocastic generation of rainfall. Simulations are then
run for a number of realizations of the rainfall to obtain an approximate
probability distribution for stress and length of dry season. These distributions
are then plotted.

Parameter (TBA) sweeps of this analysis were performed in parallel (parfor) using 
the function version of this script file, MarkovFunc.m. These have been included 
as .mat files with the suffix "_long". DispResults.m will interactively plot the 
data in these .mat files - specify the location at the top of DispResults.m. 
DispResultsJournal.m and DispResultsJournalBW.m can be used to plot multiple 
parameter sweeps in the same plot.