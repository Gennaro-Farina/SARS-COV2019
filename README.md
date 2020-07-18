# Implementation of a SIR model for the predictions of coronavirus spreads
This repo will contain:

1) data preprocess and cleaning
2) the code for a dynamical model for the evolution of the pandemy
3) a numerical integrator of the dynamical equations for the SIR model
4) prediction up to septmeber 2020
5) containment measures:

   - a model that take into account quarantine measures

   - a cost function which could represent the economic cost for institutions to enforcing quarantine measures and the economic cost per infected person

   - optimal strategies to minimize the total economic cost of the epidemic.


# SARS-COV2019

In 2020 our world met a disastrous pandemic known as coronavirus disease 2019 (COVID-19). 
A subset of the people who get infected unfortunately have some severe respiratory phenomenae. 
The COVID-19 disease in fact is caused by severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2).
Former episodes was identified in Wuhan, Hubei, China in December 2019.
To contain its spread nations adopted worldwide interventions. The former country whose adopt these policies was the China, which chose large-scale quarantine, strict controls on travel and extensive monitoring of suspected cases. *SIR* model is one of the simplest epidemic models, and many models are derivations of this basic form. The population is divided into three compartments, with the assumption that every individual in the same compartment has the same characteristics: 
- S: the number of susceptible
- I: the number of infected
- R: the number recovered (or immune) individuals.

The model is described by the following Differential Equatiions:

- <img src="https://latex.codecogs.com/gif.latex?\frac{dS}{dt}=-\frac{{\beta}IS}{N}" /> 
- <img src="https://latex.codecogs.com/gif.latex?\frac{dI}{dt}=-\frac{{\beta}IS}{N}-{\gamma}I" /> 
- <img src="https://latex.codecogs.com/gif.latex?\frac{dR}{dt}=-{\gamma}I" /> 

where:
- <img src="https://latex.codecogs.com/gif.latex?{\beta}"/> is the transmition rate constant representingthe average number of transmissive contacts per day.
- <img src="https://latex.codecogs.com/gif.latex?\frac{1}{\gamma}"/>  is the mean infection time and <img src="https://latex.codecogs.com/gif.latex?N"/>  is the total population size

# sources:
[1] Yang Z, Zeng Z, Wang K, et al. Modified SEIR and AI prediction of the epidemics trend of COVID-19 in China under public health interventions. J Thorac Dis. 2020;12(3):165-174. doi:10.21037/jtd.2020.02.64
