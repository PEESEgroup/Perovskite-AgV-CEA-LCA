# Perovskite Agrivoltaic Greenhouse Life Cycle Assessment (LCA)
This repository contains the complete dataset, simulation files, and statistical analyses supporting our study on semi-transparent perovskite (STP) agrivoltaic (AgV) greenhouses. Our work evaluates the energy savings, carbon footprint, and water use impacts of integrating STP photovoltaic glazing into greenhouse systems across diverse U.S. climates.

🔧 Folder & File Overview
1. EnergyPlus Input Files
AgV greenhouse with electric dehumidification (.idf)
Configuration file for AgV greenhouses using electric dehumidification.

AgV greenhouse with ventilation (.idf)
Configuration file for AgV greenhouses using passive ventilation.

2. MATLAB Co-Simulation Scripts
AgV_Electric_Dehum.m
MATLAB script for running EnergyPlus co-simulation on AgV with electric dehumidification.

AgV_Ventilation.m
MATLAB script for AgV with ventilation-based dehumidification.

Greenhouse_Electric_Dehum.m
Conventional greenhouse simulation with electric dehumidification.

Greenhouse_Ventilation.m
Conventional greenhouse with passive ventilation.

📊 Life Cycle Assessment Data (Excel)
Life Cycle Inventory.xlsx
Detailed inventory of material, energy, and resource flows for all greenhouse configurations.

Characterization Factor.xlsx
Midpoint impact factors used for water, carbon, and energy characterization (based on ecoinvent and AWARE).

Carbon Footprint.xlsx
LCA results for life cycle GHG emissions (kg CO₂-eq per kg of lettuce).

Water Footprint.xlsx
LCA results for water scarcity footprint (m³ world-eq per kg of lettuce).

📈 Statistical Analyses
One-Way ANOVA Carbon Footprint.xlsx
Statistical comparison of carbon emissions across greenhouse types using one-way ANOVA.

One-Way ANOVA Water Footprint.xlsx
One-way ANOVA on water footprint across technologies.

Two-Way ANOVA Electricity.xlsx
Two-way ANOVA assessing net electricity consumption across PV type and dehumidification strategy.

Two-Way ANOVA Heat.xlsx
Two-way ANOVA for thermal energy use.

🔬 Research Context
This analysis is part of the first holistic "farm-to-fork" LCA evaluating the integration of STP PV into CEA systems. By simulating 925 U.S. deployment sites, we quantify environmental trade-offs and highlight the regional benefits of perovskite AgV technologies.

Citation
If you use this dataset or code, please cite the corresponding publication (TBD upon acceptance).


