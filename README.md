premise:
I'm not an epidemiologist, I'm a Computer Scientist, so I'll build on existing works in the literature eventually bring some coding contributions and insights that I think might be useful.

# Implementation of a SIR model for the predictions of coronavirus spreads
This repo contains:

1) data preprocess and cleaning
2) the code for a dynamical model for the evolution of the pandemy
3) a numerical integrator of the dynamical equations for the SIR model
4) prediction up to septmeber 2020
5) containment measures:

   - a model that take into account quarantine measures

   - a cost function which could represent the economic cost for institutions to enforcing quarantine measures and the economic cost per infected person

   <!-- - optimal strategies to minimize the total economic cost of the epidemic.-->


# SARS-COV2019

In 2020 our world met a disastrous pandemic known as coronavirus disease 2019 (COVID-19). 
A subset of the people who get infected unfortunately have some severe respiratory phenomenae. 
The COVID-19 disease in fact is caused by severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2).
The first episodes occurred in Wuhan, Hubei, China in December 2019.

To contain its spread nations adopted worldwide interventions. The former country whose adopt these policies was the China, which chose large-scale quarantine, strict controls on travel and extensive monitoring of suspected cases. 

# The Susceptible, Infectious, or Recovered mathematical model of epidemic

*SIR* model, introduced by _William Ogilvy Kermack_ and _Anderson Gray McKendrick_, is one of the simplest epidemic models, and many models are derivations of this basic form. The population is divided into three compartments, with the assumption that every individual in the same compartment has the same characteristics: 
- S: the number of susceptible
- I: the number of infected
- R: the number recovered (or immune) individuals.

These variables represent the number of people in each compartment at a particular time, it can be much easy to think at them as three functions of time:
<img src="https://latex.codecogs.com/gif.latex?{S(t),{\,}I(t),{\,}R(t)}" /> .

The deterministic model is described by the following Odrinary Differential Equations (ODE):

- <img src="https://latex.codecogs.com/gif.latex?\frac{dS}{dt}=-\frac{{\beta}IS}{N}" /> 
- <img src="https://latex.codecogs.com/gif.latex?\frac{dI}{dt}=\frac{{\beta}IS}{N}-{\gamma}I" /> 
- <img src="https://latex.codecogs.com/gif.latex?\frac{dR}{dt}=-{\gamma}I" /> 

where:
- <img src="https://latex.codecogs.com/gif.latex?{\beta}"/> is the transmition rate constant representingthe average number of transmissive contacts per day.
- <img src="https://latex.codecogs.com/gif.latex?\frac{1}{\gamma}"/>  is the mean infection time and <img src="https://latex.codecogs.com/gif.latex?N"/>  is the total population size

- the force of infection is defined by <img src="https://latex.codecogs.com/gif.latex?{{\beta}I}"/> and models the transition rate from S to I compartment.

This model can be a first approximator for estimate how disease spreads, to get the total number of infected or the duration of the epidemic. By playing with <img src="https://latex.codecogs.com/gif.latex?{\beta}"/> and <img src="https://latex.codecogs.com/gif.latex?\gamma"/> you can profile some different situations.


On this model, with little modifications, one can also take into account vital dynamics, such as death rate and birth rate. However we hope the pandemic is limited in time so these factors can be omitted.

# The SEIR model

Unfortunately we know coronavirus spread has an incubation period. So even in the case no infected individuals result from a global epidemic test we have to consider that we have to put on our attention for a while. This bring the need for a further compartment that is the Exposed one.

For SEIR system the mathematical model is:

- <img src="https://latex.codecogs.com/gif.latex?\frac{dS}{dt}=-\frac{{\beta}IS}{N}" /> 
- <img src="https://latex.codecogs.com/gif.latex?\frac{dE}{dt}=\frac{{\beta}IS}{N}-{{\sigma}E}" /> 
- <img src="https://latex.codecogs.com/gif.latex?\frac{dI}{dt}={{\sigma}E}-{\gamma}I" /> 
- <img src="https://latex.codecogs.com/gif.latex?\frac{dR}{dt}={\gamma}I" /> 

## Incubation period
Lauer, Grantz et al [2] made a study on 181 cases, reported between 4 January 2020 and 24 February 2020,  and computed the median incubation period to be 5.1 days (from 4.5 to 5.8 days), and they further discovered that 97.5% of those who develop symptoms will do so within 11.5 days (from 8.2 to 15.6 days) of infection. 

## The reproductive number R0
<img src="https://latex.codecogs.com/gif.latex?{R_{0}}" />  is the reproductive number and you can think at it as the number of new cases generated from a single case - as a mean number - in a non-infected polulation, under hypothesis that all the polulation is supsceptible. It's definition is still not completely shared in mathematical community.

- <img src="https://latex.codecogs.com/gif.latex?{R_{0}=\frac{\beta}{\gamma}}" /> 


## Some strong assumptions:
- No international travels are admitted
- Birth rate is equal to death rate
- Recovered people develop immunity
- All the polulation is supsceptible

## Further consideration
Keep the distance please  :frowning_man: :straight_ruler: :frowning_man:

# Sources:
[1] _Modified SEIR and AI prediction of the epidemics trend of COVID-19 in China under public health interventions._ J Thorac Dis. 2020;12(3):165-174. doi:10.21037/jtd.2020.02.64,  Yang Z, Zeng Z, Wang K, et al.

[2] _The Incubation Period of Coronavirus Disease 2019 (COVID-19) From Publicly Reported Confirmed Cases: Estimation and Application_, Stephen A. Lauer, Kyra H. Grantz, Qifang Bi, Forrest K. Jones, Qulu Zheng, Hannah R. Meredith, Andrew S. Azman, Nicholas G. Reich, Justin Lessler, https://doi.org/10.7326/M20-0504

[3] M.  J.  Keeling  and  P.  Rohani,Modeling  infectious  diseases  in  humansand animals.    Princeton University Press, 2008

[4] https://en.wikipedia.org/

    [4.1] https://en.wikipedia.org/wiki/Compartmental_models_in_epidemiology
    
    [4.2] https://it.wikipedia.org/wiki/Numero_di_riproduzione_di_base

[5] https://idmod.org/docs/general/model-seir.html

[6] A cost-based comparison of quarantine strategies for new emerging diseases, Anuj Mubayi, hristopher Kribs Zaleta, Maia Martcheva, Carlos Castillo-Ch ́avez1,
an others. Mathematical Biosciences and Engineering 

Other useful resources:

 [7] https://it.mathworks.com/matlabcentral/fileexchange/74545-generalized-seir-epidemic-model-fitting-and-computation
    
 [8] Works on coronavirus by this author: https://it.mathworks.com/matlabcentral/profile/authors/3576565
    
 [9] https://it.mathworks.com/matlabcentral/answers/517966-using-lsqcurvefit-with-ode15s-sir-model\#comment_831103
    
 [10] https://github.com/EfDe2020/IP_COVID-19/blob/master/script1.m
    
 [11] https://towardsdatascience.com/estimating-parameters-of-compartmental-models-from-observed-data-62f87966bb2b
    
 [12] https://cs.uwaterloo.ca/~paforsyt/SEIR.html
