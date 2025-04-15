# 🌱 Perovskite Agrivoltaic Greenhouse Life Cycle Assessment (LCA)

This repository contains the complete dataset, simulation files, and statistical analyses supporting our study on semi-transparent perovskite (STP) agrivoltaic (AgV) greenhouses. Our work evaluates the energy savings, carbon footprint, and water use impacts of integrating STP photovoltaic glazing into greenhouse systems across diverse U.S. climates.

---

## 🔧 Folder & File Overview

### **1. EnergyPlus Input Files**
- **AgV greenhouse with electric dehumidification (.idf)**  
  Configuration file for AgV greenhouses using electric dehumidification.
- **AgV greenhouse with ventilation (.idf)**  
  Configuration file for AgV greenhouses using passive ventilation.

### **2. MATLAB Co-Simulation Scripts**
- **AgV_Electric_Dehum.m**  
  MATLAB script for running EnergyPlus co-simulation on AgV with electric dehumidification.
- **AgV_Ventilation.m**  
  MATLAB script for AgV with ventilation-based dehumidification.
- **Greenhouse_Electric_Dehum.m**  
  Conventional greenhouse simulation with electric dehumidification.
- **Greenhouse_Ventilation.m**  
  Conventional greenhouse with ventilation-based dehumidification.

---

## 📊 Life Cycle Assessment Data (Excel)

- **Life Cycle Inventory.xlsx**  
  Detailed inventory of material, energy, and resource flows for all greenhouse configurations.
- **Characterization Factor.xlsx**  
  Midpoint impact factors used for water, carbon, and energy characterization (based on ecoinvent and AWARE).
- **Carbon Footprint.xlsx**  
  LCA results for life cycle GHG emissions (kg CO₂-eq per kg of lettuce).
- **Water Footprint.xlsx**  
  LCA results for water scarcity footprint (m³ world-eq per kg of lettuce).
- **Impact of lifetime.xlsx**
  Extended data quantifying the impact of solar device lifetime on carbon and water scarcity footprints.  

---

## 📈 Statistical Analyses

- **One-Way ANOVA Carbon Footprint.xlsx**  
  Statistical comparison of carbon emissions across greenhouse types using one-way ANOVA.
- **One-Way ANOVA Water Footprint.xlsx**  
  One-way ANOVA on water footprint across technologies.
- **Two-Way ANOVA Electricity.xlsx**  
  Two-way ANOVA assessing net electricity consumption across PV type and dehumidification strategy.
- **Two-Way ANOVA Heat.xlsx**  
  Two-way ANOVA for thermal energy use.

---

## 🔬 Research Context

This analysis is part of the first holistic *farm-to-fork* LCA evaluating the integration of STP PV into CEA systems. By simulating 925 U.S. deployment sites, we quantify environmental trade-offs and highlight the regional benefits of perovskite AgV technologies.

---

## 📎 Citation

If you use this dataset or code, please cite the corresponding publication (TBD upon acceptance).


## 🧾 Abstract

Climate change, resource scarcity, and growing demand for high-quality produce pose major challenges to global food security and sustainability. Controlled environment agriculture offers resilience but is constrained by its high energy intensity, a challenge that can be addressed by integrating advanced photovoltaic (PV) technologies such as semi-transparent perovskites (STP). Here, we present the first holistic, “farm-to-fork” life cycle assessment investigating the synergy of STP PV and greenhouse horticulture. Using high-fidelity simulations across diverse U.S. climates, we show that STP agrivoltaic (AgV) greenhouses offer a transformative solution for sustainable food production, achieving up to 360.5 MWh/year energy savings in hot-humid climates and enabling widespread emission reductions of up to 38.9%. In arid regions, achieving substantial water savings of 0.447 m3/kg is contingent upon continued advancements in the power conversion efficiency. Despite concerns about stability, the substantial baseline consumption and resource savings outweigh additional impacts due to multi-round recycling of end-of-life solar devices. STP AgVs offer a scalable, near-term solution for perovskite solar deployment, with potential applicability across thousands of hectares of U.S. greenhouse area in global agri-food systems.
