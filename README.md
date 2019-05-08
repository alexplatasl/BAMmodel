Overview
========

Purpose
-------

Modeling an economy with stable macro signals, that works as a benchmark for studying the effects of the agent activities, e.g. extortion, at the service of the elaboration of public policies..

Entities, state variables, and scales
-------------------------------------

-   Agents: Firms (also know as producers), workers (also know as consumers and households) and banks.

-   Environment: Virtual or geographically characterized markets.

    -   Labor market.

    -   Goods market

    -   Credit market.

-   State variables: Productivity, net worth, wage and loans.

Process overview and scheduling
-------------------------------

1.  Firms calculate production based on expected demand.

2.  A decentralized labor market opens.

3.  A decentralized credit market opens.

4.  Firms produce.

5.  Market for goods open.

6.  Firms will pay loan and dividends.

7.  Firms and banks will survive or die.

8.  Replacing of bankrupt firms/banks.

Design concepts
===============

### Basic Principles

Neo classical economy.

### Emergence

Model as a whole has the objective of generating adaptive behavior of the agents, without the imposition of an equation that governs the actions of the agents.

### Adaptation

Firms can adapt in each period $t$ price or amount to supply (only one of the two strategies). Adaptation of each strategy depends on the condition of the firm (level of excessive supply / demand in the previous period) and/or the market environment (the difference between the individual price and the market price in the previous period).

### Objectives

Just firms has the objetive of maximizing their net worth.

### Learning

Firms do not have learning, they present different responses to an environment that is constantly evolving.

### Prediction

Firms use both their own elements and the environment to make the prediction of the quantity to be produced or the price. As an internal element, it uses the excessive amount of supply / demand in the previous period; while the environment takes the differential of its price and the market.

### Sensing

-   Firms are able to perceive their produced quantity, their price and the market price, offered wages, profits, net value, their labor force and interest rate of randomly chosen banks.

-   Workers/consumers perceive the size of firms visited in the previous period, prices published by the firms in actual period and wages offered by the firms.

-   Banks are able to sense net value of potential borrower (firms) in order to calculate interest rate.

### Interaction

Macroeconomic results come from continuous adaptive dispersed interactions of autonomous, heterogeneous and rationally bounded agents that coincide in an uncertain environment.

### Stochasticity

Elements that have random shocks are:

-   Determination of wages (when vacancies are offered), `wages-shock-xi`.

-   Determination of contractual interest rate offered by banks to
    firms, `interest-shock-phi`.

-   Strategy to set prices, `price-shock-eta`.

-   Strategy to determine the quantity to produce, `production-shock-rho`.

### Collectives

In addition to the sets of agents (consumers, producers and banks), groups of firms and consumers are selected as an emergent property of the simulation (rich and poor).

### Observation

Along simulation are observed:

-   Logarithm of real GDP.

-   Unemployment rate.

-   Annual inflation rate.


At end of simulation are computed:

-   Distribution of the size of firms.


Details
=======

Initialization
--------------

<table class="tg">
  <tr>
    <th class="tg-0pky">Parameter</th>
    <th class="tg-0pky">Parameter</th>
    <th class="tg-0pky">Value</th>
  </tr>
  <tr>
    <td class="tg-0pky">I</td>
    <td class="tg-0pky">Consumers</td>
    <td class="tg-0pky">500</td>
  </tr>
  <tr>
    <td class="tg-0pky">J</td>
    <td class="tg-0pky">Producers</td>
    <td class="tg-0pky">100</td>
  </tr>
  <tr>
    <td class="tg-0pky">K</td>
    <td class="tg-0pky">Banks</td>
    <td class="tg-0pky">10</td>
  </tr>
  <tr>
    <td class="tg-0pky">T</td>
    <td class="tg-0pky">Periods</td>
    <td class="tg-0pky">1000</td>
  </tr>
  <tr>
    <td class="tg-0pky">C<sub>P</sub></td>
    <td class="tg-0pky">Propensity to consume of poorest people</td>
    <td class="tg-0pky">1</td>
  </tr>
  <tr>
    <td class="tg-0pky">C<sub>R</sub></td>
    <td class="tg-0pky">Propensity to consume of richest people</td>
    <td class="tg-0pky">0.5</td>
  </tr>
  <tr>
    <td class="tg-0pky">h<sub>&xi</sub></td>
    <td class="tg-0pky">Maximum growth rate of wages</td>
    <td class="tg-0pky">0.05</td>
  </tr>
  <tr>
    <td class="tg-0pky">H<sub>&eta</sub></td>
    <td class="tg-0pky">Maximum growth rate of prices</td>
    <td class="tg-0pky">0.1</td>
  </tr>
  <tr>
    <td class="tg-0pky">H<sub>&rho</sub></td>
    <td class="tg-0pky">Maximum growth rate of quantities</td>
    <td class="tg-0pky">0.1</td>
  </tr>
  <tr>
    <td class="tg-0pky">H<sub>&phi</sub></td>
    <td class="tg-0pky">Maximum amount of banks’ costs</td>
    <td class="tg-0pky">0.1</td>
  </tr>
  <tr>
    <td class="tg-0pky">Z</td>
    <td class="tg-0pky">Number of trials in the goods market</td>
    <td class="tg-0pky">2</td>
  </tr>
  <tr>
    <td class="tg-0pky">M</td>
    <td class="tg-0pky">Number of trials in the labor market</td>
    <td class="tg-0pky">4</td>
  </tr>
  <tr>
    <td class="tg-0pky">H</td>
    <td class="tg-0pky">Number of trials in the credit market</td>
    <td class="tg-0pky">2</td>
  </tr>
  <tr>
    <td class="tg-0pky">w&#770</td>
    <td class="tg-0pky">Minimum wage (set by a mandatory law)</td>
    <td class="tg-0pky">1</td>
  </tr>
  <tr>
    <td class="tg-0pky">P<sub>t<sub></td>
    <td class="tg-0pky">Base price</td>
    <td class="tg-0pky">1</td>
  </tr>
  <tr>
    <td class="tg-0pky">&delta</td>
    <td class="tg-0pky">Fixed fraction to share dividends</td>
    <td class="tg-0pky">0.15</td>
  </tr>
  <tr>
    <td class="tg-0pky">r&#772</td>
    <td class="tg-0pky">Interest rate (set by the central monetary authority)</td>
    <td class="tg-0pky">0.07</td>
  </tr>
</table>

Input data
----------

No input data were needed to represent process.

Submodels
---------

1.  Production with constant returns to scale and technological multiplier.

    ![equation-01](https://latex.codecogs.com/gif.latex?Y_{it}&space;=&space;\alpha_&space;{it}&space;L_{it},&space;\alpha_{it}>&space;0).

2. Desired production level ![eqn-02-a](https://latex.codecogs.com/gif.latex?Y_&space;{it}&space;^&space;d) is equal to the expected
   demand ![eqn-02-b](https://latex.codecogs.com/gif.latex?D_{it}^d).

3. Desired labor force (employees) ![eqn-03-a](https://latex.codecogs.com/gif.latex?L_&space;{it}&space;^&space;d) is

   ![eqn-03-b](https://latex.codecogs.com/gif.latex?L_&space;{it}&space;^&space;d&space;=&space;\frac&space;{Y_&space;{it}&space;^&space;d}&space;{\alpha_&space;{it}}).

4. Current number of employees ![eqn-04](https://latex.codecogs.com/gif.latex?L_&space;{it}&space;^&space;0) is the sum of employees with and without a valid contract.

5. Number of vacancies offered by firms ![eqn-05-a](https://latex.codecogs.com/gif.latex?V_&space;{it}) is 

    ![eqn-05-b](https://latex.codecogs.com/gif.latex?V_&space;{it}&space;=&space;max&space;(L_&space;{it}&space;^&space;d&space;-&space;L_&space;{it}&space;^&space;0,&space;0)).

6. ![eqn-06](https://latex.codecogs.com/gif.latex?\hat&space;{w_t}) is the minimum wage determined by law.

7. If there are no vacancies ![eqn-07-a](https://latex.codecogs.com/gif.latex?V_&space;{it}&space;=&space;0), wage offered is:

   ![eqn-07-b](https://latex.codecogs.com/gif.latex?w_&space;{it}&space;^&space;b&space;=&space;max&space;(\hat&space;{w_t},&space;w_&space;{it-1})),

8. If number of vacancies is greater than 0, wage offered is:

   ![eqn-08](https://latex.codecogs.com/gif.latex?w_&space;{it}&space;^&space;b&space;=&space;max&space;(\hat&space;{w_t},&space;w_&space;{it-1}&space;(1&plus;&space;\xi_&space;{it}))),

9. ![eqn-09-a](https://latex.codecogs.com/gif.latex?\xi_&space;{it}) is a random term evenly distributed between
   ![eqn-09-b](https://latex.codecogs.com/gif.latex?(0,&space;h&space;_&space;{\xi})).

10. At the beginning of each period, a firm has a net value ![eqn-10-a](https://latex.codecogs.com/gif.latex?A_&space;{it}).
    If total payroll to be paid ![eqn-10-b](https://latex.codecogs.com/gif.latex?W_&space;{it}) is greater than ![eqn-10-c](https://latex.codecogs.com/gif.latex?A_&space;{it}),
    firm asks for a ![eqn-10-d](https://latex.codecogs.com/gif.latex?B_&space;{it}) loan:
    
    ![eqn-10-e](https://latex.codecogs.com/gif.latex?B_&space;{it}&space;=&space;max&space;(W_&space;{it}&space;-&space;A_&space;{it},&space;0&space;))

11. For the loan search costs, it must be met that ![eqn-11](https://latex.codecogs.com/gif.latex?H&space;<K)

12. In each period the ![eqn-12-a](https://latex.codecogs.com/gif.latex?k) -thmost bank can distribute a total amount
    of credit ![eqn-12-b](https://latex.codecogs.com/gif.latex?C_k) equivalent to a multiple of its patrimonial base:
    
    ![eqn-12-c](https://latex.codecogs.com/gif.latex?C_&space;{kt}&space;=&space;\frac&space;{E_&space;{kt}}{v}),

13. where ![eqn-13-a](https://latex.codecogs.com/gif.latex?0&space;<v&space;<1) can be interpreted as the capital requirement
    coefficient. Therefore, the ![eqn-13-b](https://latex.codecogs.com/gif.latex?v) reciprocal represents the maximum
    allowed leverage by the bank.

14. Bank offers credit ![eqn-14-a](https://latex.codecogs.com/gif.latex?$&space;C_&space;{k}&space;$), with its respective interest rate
    ![eqn-14-b](https://latex.codecogs.com/gif.latex?r_&space;{it}&space;^&space;k) and contract for 1 period.

15. Payment scheme if ![eqn-15-a](https://latex.codecogs.com/gif.latex?A_&space;{it&space;&plus;&space;1}>&space;0): 

    ![eqn-15-b](https://latex.codecogs.com/gif.latex?B_&space;{it}&space;(1&space;&plus;&space;r_&space;{it}&space;^&space;k))

16. If ![eqn-16-a](https://latex.codecogs.com/gif.latex?A_&space;{it&space;&plus;&space;1}&space;\leq&space;0), bank retrieves 

    ![eqn-16-b](https://latex.codecogs.com/gif.latex?R_&space;{it&space;&plus;&space;1}).

17. Contractual interest rate offered by the bank ![eqn-17-a](https://latex.codecogs.com/gif.latex?k) to the firm
    ![eqn-17-b](https://latex.codecogs.com/gif.latex?i) is determined as a margin on a rate policy established by
    Central Monetary Authority ![eqn-17-c](https://latex.codecogs.com/gif.latex?\bar{r}):
    
    ![eqn-17-d](https://latex.codecogs.com/gif.latex?R_{it}^k=\bar{r}(1&plus;\phi_{kt}\mu(\ell_{it}))).

18. Margin is a function of the specificity of the bank as possible
    variations in its operating costs and captured by the uniform random
    variable ![eqn-18-a](https://latex.codecogs.com/gif.latex?\phi_{kt}) in the interval ![eqn-18-b](https://latex.codecogs.com/gif.latex?(0,h_\phi)).

19. Margin is also a function of the borrower’s financial fragility,
    captured by the term ![eqn-19-a](https://latex.codecogs.com/gif.latex?\mu&space;(\ell_&space;{it})), ![eqn-19-b](https://latex.codecogs.com/gif.latex?\mu&space;^&space;{'}>&space;0). Where
    
    ![eqn-19-c](https://latex.codecogs.com/gif.latex?\ell_&space;{it}&space;=&space;\frac&space;{B_&space;{it}}&space;{A_&space;{it}}) 
    
    is the leverage of borrower.

20. Demand for credit is divisible, that is, if a single bank is not
    able to satisfy the requested credit, it can request in the
    remaining ![eqn-20](https://latex.codecogs.com/gif.latex?H-1) randomly selected banks.

21. Each firm has an inventory of unsold goods ![eqn-21-a](https://latex.codecogs.com/gif.latex?S_&space;{it}), where excess
    supply ![eqn-21-b](https://latex.codecogs.com/gif.latex?S_&space;{it}>&space;0) or demand ![eqn-21-c](https://latex.codecogs.com/gif.latex?S_&space;{it}&space;=&space;0) is reflected.

22. Deviation of the individual price from the average market price
    during the previous period is represented as:
    
    ![eqn-22](https://latex.codecogs.com/gif.latex?P_&space;{it-1}&space;-&space;P_&space;{t-1})

23. If deviation is positive ![eqn-23](https://latex.codecogs.com/gif.latex?P_&space;{it-1}>&space;P_&space;{t-1}), firm recognizes
    that its price is high compared to its competitors, and is induced
    to decrease the price or quantity to prevent a migration massive in
    favor of its rivals.

24. Vice versa.

25. In case of adjusting price to downside, this is bounded below
    ![eqn-25-a](https://latex.codecogs.com/gif.latex?P_&space;{it}&space;^l) to not be less than your average costs
    ![eqn-25-b](https://latex.codecogs.com/gif.latex?$$P_&space;{it}&space;^&space;l&space;=&space;\frac&space;{W_&space;{it}&space;&plus;&space;\sum\limits_k&space;r_&space;{kit}&space;B_&space;{kit}}&space;{Y_&space;{it}}$$).

26. Aggregate price ![eqn-26-a](https://latex.codecogs.com/gif.latex?P_t) is common knowledge (global variable), while
    inventory ![eqn-26-b](https://latex.codecogs.com/gif.latex?S_&space;{it}) and individual price ![eqn-26-c](https://latex.codecogs.com/gif.latex?P_&space;{it}) private
    knowledge child (local variables).

27. Only the price or quantity to be produced can be modified. In the
    case of price, we have the following rule:
    $$\begin{aligned} P_{it}^s= ​ \begin{cases} ​ \text{max}[P_{it}^l, P_{it-1}(1+\eta_{it})] & \text{if $S_{it-1}=0$ and $P_{it-1}<P$ }\\ ​ \text{max}[P_{it}^l, P_{it-1}(1-\eta_{it})] & \text{if $S_{it-1}>0$ and $P_{it-1}\geq ​ P$} ​ \end{cases}\end{aligned}$$
    
28. ![eqn-28-a](https://latex.codecogs.com/gif.latex?\eta_&space;{it}) is a randomized term uniformly distributed in the
    range ![eqn-28-b](https://latex.codecogs.com/gif.latex?(0,&space;h_&space;\eta)) and ![eqn-28-c](https://latex.codecogs.com/gif.latex?P_&space;{it}&space;^&space;l) is the minimum price at which firm
    ![eqn-28-d](https://latex.codecogs.com/gif.latex?i) can solve its minimal costs at time ![eqn-28-e](https://latex.codecogs.com/gif.latex?t)
    (previously defined).

29. In the case of quantities, these are adjusted adaptively according
    to the following rule:

    $$\begin{aligned}
    D_{it}^e=
    ​    \begin{cases}
    ​        Y_{it-1}(1+\rho_{it}) & \text{if $S_{it-1}=0$ and $P_{it-1}\geq P$} \\
    ​        Y_{it-1}(1-\rho_{it}) & \text{if $S_{it-1}>0$ and $P_{it-1}< P$}
    ​    \end{cases}\end{aligned}$$

30. ![eqn-30-a](https://latex.codecogs.com/gif.latex?\rho_&space;{it}) is a random term uniform distributed and bounded
    between ![eqn-30-b](https://latex.codecogs.com/gif.latex?(0,&space;h_&space;\rho)).

31. Total income of households (workers/consumers) is the sum of the
    payroll paid to the workers (each household represents a worker) in
    ![eqn-31-a](https://latex.codecogs.com/gif.latex?t) and the dividends distributed to the shareholders in ![eqn-31-b](https://latex.codecogs.com/gif.latex?t-1).

32. Wealth is defined as the sum of labor income plus the sum of all
    savings ![eqn-32](https://latex.codecogs.com/gif.latex?SA) of the past.

33. Marginal propensity to consume ![eqn-33-a](https://latex.codecogs.com/gif.latex?c) is a decreasing function of the
    worker’s total wealth (higher the wealth lower the proportion spent
    on consumption) defined as:

    ![eqn-33-b](https://latex.codecogs.com/gif.latex?$$c_&space;{jt}&space;=&space;\frac&space;{1}&space;{1&plus;&space;\left&space;[\text&space;{tanh}&space;\left&space;(\frac&space;{SA_&space;{jt}}&space;{SAt}&space;\right)\right]&space;^&space;\beta}$$)

34. ![eqn-34-a](https://latex.codecogs.com/gif.latex?SA_t) is the average savings. ![eqn-34-b](https://latex.codecogs.com/gif.latex?SA_&space;{jt}) is the real saving of
    the ![eqn-34-a](https://latex.codecogs.com/gif.latex?j) -th consumer.

35. The revenue ![eqn-35-a](https://latex.codecogs.com/gif.latex?R_&space;{it}) of a firm after the goods market closes is
    equal to:

    ![eqn-35-b](https://latex.codecogs.com/gif.latex?$$R_&space;{it}&space;=&space;P_&space;{it}&space;Y_&space;{it}$$)

36. At the end of ![eqn-36-a](https://latex.codecogs.com/gif.latex?t) period, each firm computes benefits
    ![eqn-36-b](https://latex.codecogs.com/gif.latex?\pi_&space;{it-1}).

37. If the benefits are positive, the shareholders of firms receive
    dividends:

    ![eqn-37-a](https://latex.codecogs.com/gif.latex?Div_&space;{it-1}&space;=&space;\delta&space;\pi_&space;{it-1}).

38. Residual, after discounting dividends, is added to net value
    inherited from previous period, ![eqn-38-a](https://latex.codecogs.com/gif.latex?A_{it-1}). Therefore, net worth of
    a profitable firm in ![eqn-38-a](https://latex.codecogs.com/gif.latex?t) is:

    ![eqn-38-b](https://latex.codecogs.com/gif.latex?A_{it}&space;=&space;A_{it-1}&plus;\pi_{it-1}&space;-Div_{it-1}&space;\equiv&space;A_{it-1}&plus;&space;(1-\delta)\pi_{it-1}).

39. If firm, say ![eqn-39-a](https://latex.codecogs.com/gif.latex?f), accumulates a net value ![eqn-39-b](https://latex.codecogs.com/gif.latex?A_&space;{it}&space;<0)
    goes bankrupt.

40. Firm that goes bankrupt is replaced with another one of smaller size
    than the average of incumbent firms.

41. Non-incumbent firms are those whose size is above and below 5%, is
    used to calculate a more robust estimator of the average.

42. Bank’s capital

    ![eqn-42-a](https://latex.codecogs.com/gif.latex?E_{kt}=E_{kt-1}&space;&plus;&space;\sum&space;\limits_&space;{i&space;\in&space;\Theta}&space;r_&space;{kit-1}&space;B_&space;{kit-1}&space;-BD_{kt-1}).

43. ![eqn-43-a](https://latex.codecogs.com/gif.latex?\Theta) is the bank’s loan portfolio, ![eqn-43-b](https://latex.codecogs.com/gif.latex?BD_{kt-1}) represents
    the portfolio of firms that go bankrupt.

44. If a bank goes bankrupt, it is replaced with a copy of the
    surviving banks.


Reference
========
Delli Gatti, D. et. al, (2011). *Macroeconomics from the Bottom-up*. Springer-Verlag Mailand, Milan.
