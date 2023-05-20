<h1 align="center"> Battery Design</h1>

## Summary
An optimal lithium-sulfur battery design for solar cell, drone, and cellphone applications are presented. For the drone application, optimal design values for cathode, separator, and anode thicknesses are 64.78 µm 123.17 µm, and 54.99 µm, respectively. Optimum cathode and separator porosities, and sulfur mass composition were 0.8805, 0.8978, and 0.7872, respectively, resulting in a max specific energy of 62.29 Wh/kg.

## Lithium-sulfur battery

A simple schematic of a battery is presented in Figure 1. The cathode of a lithium-sulfur battery is often a mix of three primary components: conductive carbon, sulfur, and a polymer binder (to hold the battery together). In this model, an assumption of 10% binder in the cathode (by wt.) was assumed. Sulfur composition (Scomp) was chosen as one design variable, causing carbon composition (Ccomp) to vary linearly with it, as follows:

![image](https://github.com/josedavid2101/Optimization_techniques/assets/8882222/8229be94-e073-4fba-a504-54d58f1823b8)

where binder composition (Bcomp) is 10%. As the thickness and porosity of the cathode, catht and cathP, respectively, are adjusted (two other design variables), the total amount of sulfur in the battery will change, and with it, the ratios of other components in the battery to the amount of sulfur (see Specific Capacity of the Battery).

![image](https://github.com/josedavid2101/Optimization_techniques/assets/8882222/d7abe756-1b2f-488e-94f2-4e9ebf78b6c1)

## Optimized functions

The function to optimize was chosen depending on the application. Three different applications with different metrics of success were considered for the battery design; therefore, a different objective function was optimized in each case. 

### Drone application: 
The first application was to design a battery that will supply power to an unmanned aerial vehicle (UAV) or drone. In this case, we maximize specific energy, energy per mass (Wh/kg) because this will help to maximize flight time of the drone. Because of the large power demands for drone applications, the specific capacity function was reduced to 0.3 times its original values.
### Cellphone application:
The second application was to design a battery for a cellphone. In this case, we maximize volume Energy Density (Wh/L). For a cellphone, the volume the battery is one of the main constraints. Because of the moderate power demands, specific capacity was reduced to 0.85 times its original values.
### Solar battery application:
The last application was to design a battery to store energy from renewable energy sources such as solar. In this case, we minimize energy cost ($/kWh). Specific capacity was left at the original values of the model because some solar energy storage applications have low power demands. Other solar energy storage applications with higher power requirements would need to take this into account when determining specific capacity.

## Design Variables

![image](https://github.com/josedavid2101/Optimization_techniques/assets/8882222/2daafeba-6111-498b-a787-ffbdb61a0e2d)

## Results and Discussion

Results for optimizing the various objective functions are shown in the table beloew. We see from the table that there are very few binding constraints in this problem, and that each application results in very different optimums. The maximum specific energy for the drone application is lower than that of the cellphone or solar energy applications because the power requirements of the drone application are more demanding than the cellphone or solar energy storage cases, thus reducing specific energy.

![image](https://github.com/josedavid2101/Optimization_techniques/assets/8882222/1dcbe8b5-fb78-4311-b485-e59df612636e)

Three contour plots are shown, one each for volumetric energy density (Figure 2), specific energy (Figure 3), and energy cost  (Figure 4). Two more contour plots are included in Appendix A that explore at least one permutation of each of the other four design variables (Figure 7 and Figure 8). Thus, we can compare across application types and for several different slices of the design space. It is interesting to note the similarity of shape between volumetric energy density and specific energy despite having shifted optimums.

![image](https://github.com/josedavid2101/Optimization_techniques/assets/8882222/6a7de8ea-8199-4333-808a-69ac153495a1)

![image](https://github.com/josedavid2101/Optimization_techniques/assets/8882222/97bc9069-6e30-46ba-a4f7-1a7694ceb36d)

![image](https://github.com/josedavid2101/Optimization_techniques/assets/8882222/a040bbba-0272-4b46-9344-f07d5c6b8a59)

## Observations and Recommendations

Table 2 shows the optimal solution values for each objective case. The initial guess gave a volumetric energy density, specific energy, and energy cost of 20.07 Wh/L, 22.54 Wh/kg, and 803.66 $ /kWh, respectively. For the volumetric energy density case, the optimization improved the initial design by 146.93 Wh/L. For the specific energy case it improved by 39.75 Wh/kg. For energy cost, it decreased total cost by 731.36 $ /kWh. In these cases, the design also seems realistic when compared to other experimental data, but the optimum porosities may make manufacturing difficult in the volumetric and specific energy cases. In future work, the assumption that the electrolyte volume is set equal to the total free volume within each of the battery components could be relaxed. Then, more electrolyte could be accommodated without needing to drive the porosities to their limits (e.g. the battery components need not be stacked one directly on top of the other, or there could be free volume along the sides of the battery).

We believe the optimums obtained are likely the global solutions because multiple starting points were tested, and the contour plots usually show smooth contours converging towards an optimal value. The design also seems reasonable in that variables such as ELS seem to be in the same ballpark as values obtained in commercially competitive technologies in several lithium-sulfur papers (e.g. DOI: 10.1016/j.nanoen.2017.07.002), despite differing in battery design. However, the model for specific capacity may need to be refined and further validated. It is interesting to note that in most cases, the optimal design is bounded by only a few constraints. For this model, a specific battery structure was chosen and optimal values would likely change if a different electrolyte, different materials for the cathode, or a non-planar geometry were used. If the model were expanded to include other materials and geometries, a more general optimum will likely be found.



