% M053M716  Project with scripts for visualizing synaptophysin pixel fluorescent intensity distributions and statistics.
%
% Packages
%   +default                - Package to return default versions of objects I like
%
% Scripts
%   main                    - Main script for exporting stats on AA synaptophysin (round 2)
%   mfr_stats_trends        - Main script for exporting GLME statistical models for MFR
%
% Functions (graphics)
%   exportBarChart          - Export bar chart for Figure 4 by-area comparisons
%   exportGroupedHistograms - EXPORTBARCHART Export bar chart for Figure 4 by-area comparisons
%   exportHistogram         - Export histograms for Alberto's data.
%   exportStats             - Function to compartmentalize scraping of Command Window output and generation of *.txt stats report
%   exportSwarmChart        - Export swarm chart for Figure 4 by-area comparisons
%   plotFittedResiduals     - Generate fitted residuals plot for `fitglme` result
%   plotInputDistribution   - Plot input distribution of x
%
% Functions (data i/o)
%   extractMetadata         - Get metadata from file name "header"
%   getExportName           - Checks this path for file, to prevent over-write of data
%   getMaskedPixelData      - Get pixels masked by ROIs of interest
%   ReadImageJROI           - ReadImageJROI - FUNCTION Read an ImageJ ROI into a matlab structure
%   readJP2                 - READ JP2 FILE AND GET DIMENSIONS
%   ROIs2Regions            - ROIs2Regions - FUNCTION Convert a set of imported ImageJ ROIs into a Matlab regions structure
%
% Functions (java stuff for command window & stats export)
%   command_window_text     - Function for returning the text in the command window
%   findjobj                - findjobj Find java objects contained within a specified java container or Matlab GUI handle
