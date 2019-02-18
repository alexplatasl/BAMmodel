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

1.  Production with constant returns to scale and
    technological multiplier. $Y_{it} = \alpha_ {it} L_{it}, \alpha_{it}> 0 $.

2. Desired production level $ Y_ {it} ^ d $ is equal to the expected
   demand $ D_ 
   ​    {it} ^ d $.

3. Desired labor force (employees) $ L_ {it} ^ d $ is
   $ L_ {it} ^ d = \frac {Y_ {it} ^ d} {\alpha_ {it}} $

4. Current number of employees $ L_ {it} ^ 0 $ is the sum of employees
   with and without a valid contract.

5. Number of vacancies offered by firms $ V_ {it} $ is
   $ V_ {it} = max (L_ {it} ^ d - L_ {it} ^ 0, 0) $.

6. $ \hat {w_t} $ is the minimum wage determined by law.

7. If there are no vacancies $ V_ {it} = 0 $, wage offered is:
   $ w_ {it} ^ b = max (\hat {w_t}, w_ {it-1}) $,

8. If number of vacancies is greater than 0, wage offered is:
   $ w_ {it} ^ b = max (\hat {w_t}, w_ {it-1} (1+ \xi_ {it})) $,

9. $ \xi_ {it} $ is a random term evenly distributed between
   $ (0, h _ {\xi}) $.

10. At the beginning of each period, a firm has a net value $ A_ {it} $.
    If total payroll to be paid $ W_ {it} $ is greater than $ A_ {it} $,
    firm asks for a $ B_ {it} $ loan:
    $ B_ {it} = max (W_ {it} - A_ {it}, 0 )$

11. For the loan search costs, it must be met that $ H <K $

12. In each period the $ k $ -thmost bank can distribute a total amount
    of credit $ 
    ​    C_k $ equivalent to a multiple of its patrimonial base:
    $ C_ {kt} = \frac {E_ {kt}} 
    ​    {v} $,

13. where $ 0 <v <1 $ can be interpreted as the capital requirement
    coefficient. Therefore, the $ v $ reciprocal represents the maximum
    allowed leverage by the bank.

14. Bank offers credit $ C_ {k} $, with its respective interest rate
    $ r_ 
    ​    {it} ^ k $ and contract for 1 period.

15. Payment scheme if $ A_ {it + 1}> 0 $: $ B_ {it} (1 + r_ {it} ^ k) $

16. If $ A_ {it + 1} \leq 0 $, bank retrieves $ R_ {it + 1} $

17. Contractual interest rate offered by the bank $ k $ to the firm
    $ i $ is determined as a margin on a rate policy established by
    Central Monetary Authority $ \bar {r} $:
    $ R_ {it} ^ k = \bar {r} (1+ \phi_ {kt} \mu (\ell_ {it})) $.

18. Margin is a function of the specificity of the bank as possible
    variations in its operating costs and captured by the uniform random
    variable $ \phi_ {kt} $ in the interval $ (0, h_\phi) $.

19. Margin is also a function of the borrower’s financial fragility,
    captured by the term $ \mu (\ell_ {it}) $, $ \mu ^ {'}> 0 $. Where
    $ \ell_ {it} = \frac 
    ​    {B_ {it}} {A_ {it}} $ is the leverage of borrower.

20. Demand for credit is divisible, that is, if a single bank is not
    able to satisfy the requested credit, it can request in the
    remaining $ H-1 $ randomly selected banks.

21. Each firm has an inventory of unsold goods $ S_ {it} $, where excess
    supply $ S_ {it}> 0 $ or demand $ S_ {it} = 0 $ is reflected.

22. Deviation of the individual price from the average market price
    during the previous period is represented as:
    $ P_ {it-1} - P_ {t-1} $

23. If deviation is positive $ P_ {it-1}> P_ {t-1} $, firm recognizes
    that its price is high compared to its competitors, and is induced
    to decrease the price or quantity to prevent a migration massive in
    favor of its rivals.

24. Vice versa.

25. In case of adjusting price to downside, this is bounded below
    $ P_ {it} ^l $ to not be less than your average costs
    $$P_ {it} ^ l = \frac {W_ {it} + \sum\limits_k r_ {kit} B_ {kit}} {Y_ {it}}$$.

26. Aggregate price $ P_t $ is common knowledge (global variable), while
    inventory $ S_ {it} $ and individual price $ P_ {it} $ private
    knowledge child (local variables).

27. Only the price or quantity to be produced can be modified. In the
    case of price, we have the following rule:

    $$\begin{aligned}
    P_{it}^s=
    ​    \begin{cases}
    ​    \text{max}[P_{it}^l, P_{it-1}(1+\eta_{it})] & \text{if $S_{it-1}=0$ and $P_{it-1}<P$ 
    ​    }\\
    ​    \text{max}[P_{it}^l, P_{it-1}(1-\eta_{it})] & \text{if $S_{it-1}>0$ and $P_{it-1}\geq 
    ​    P$}
    ​    \end{cases}\end{aligned}$$

28. $\eta_ {it} $ is a randomized term uniformly distributed in the
    range $ (0, h_ 
    ​    \eta) $ and $ P_ {it} ^ l $ is the minimum price at which firm
    $ i $ can solve its minimal costs at time $ t $
    (previously defined).

29. In the case of quantities, these are adjusted adaptively according
    to the following rule:

    $$\begin{aligned}
    D_{it}^e=
    ​    \begin{cases}
    ​        Y_{it-1}(1+\rho_{it}) & \text{if $S_{it-1}=0$ and $P_{it-1}\geq P$} \\
    ​        Y_{it-1}(1-\rho_{it}) & \text{if $S_{it-1}>0$ and $P_{it-1}< P$}
    ​    \end{cases}\end{aligned}$$

30. $\rho_ {it} $ is a random term uniform distributed and bounded
    between $ (0, h_ 
    ​    \rho) $.

31. Total income of households (workers/consumers) is the sum of the
    payroll paid to the workers (each household represents a worker) in
    $ t $ and the dividends distributed to the shareholders in $ t-1 $.

32. Wealth is defined as the sum of labor income plus the sum of all
    savings $SA$ of the past.

33. Marginal propensity to consume $c$ is a decreasing function of the
    worker’s total wealth (higher the wealth lower the proportion spent
    on consumption) defined as:

    $$c_ {jt} = \frac {1} {1+ \left [\text {tanh} \left (\frac {SA_ {jt}} {SAt} \right) 
    ​    \right] ^ \beta}$$

34. $ SA_t $ is the average savings. $ SA_ {jt} $ is the real saving of
    the $ j $ -th consumer.

35. The revenue $ R_ {it} $ of a firm after the goods market closes is
    equal to:

    $$R_ {it} = P_ {it} Y_ {it}$$

36. At the end of $ t $ period, each firm computes benefits
    $ \pi_ {it-1} $ .

37. If the benefits are positive, the shareholders of firms receive
    dividends:

    $Div_ {it-1} = \delta \pi_ {it-1} $

38. Residual, after discounting dividends, is added to net value
    inherited from previous period, $A_{it-1}$. Therefore, net worth of
    a profitable firm in $t$ is:

    $A_{it} = A_{it-1}+\pi_{it-1} -Div_{it-1} \equiv A_{it-1}+ (1-\delta)\pi_{it-1} $

39. If firm, say $f$, accumulates a net value $ A_ {it} <0 $
    goes bankrupt.

40. Firm that goes bankrupt is replaced with another one of smaller size
    than the average of incumbent firms.

41. Non-incumbent firms are those whose size is above and below 5%, is
    used to calculate a more robust estimator of the average.

42. Bank’s capital

    $E_{kt}=E_{kt-1} + \sum \limits_ {i \in \Theta} r_ {kit-1} B_ {kit-1} -BD_{kt-1}$

43. $ \Theta $ is the bank’s loan portfolio, $ BD_{kt-1} $ represents
    the portfolio of firms that go bankrupt.

44. If a bank goes bankrupt, it is replaced with a copy of the
    surviving banks.


Reference
========
Delli Gatti, D. et. al, (2011). *Macroeconomics from the Bottom-up*. Springer-Verlag Mailand, Milan.
