; Bottom-up Adaptive Macroeconomics

extensions [palette array cf] ; arrays are used to enhance performance.

breed[firms firm]          ; the firms in the simulation, 500 by default.
breed[workers worker]      ; the workers or households, 5 * number of firms by default.
breed[banks bank]          ; the banks, max of credit-market-h + 1 and number of firms / 10 by default.

globals [
  quarters-average-price   ; an array storing the average price for the last 4 quarters.
  quarters-inflation       ; an array storing the inflation for the last 4 quarters.
]

firms-own[
  production-Y                         ; labor * labor productiviy
  labor-productivity-alpha             ; labor productivity > 0
  desired-production-Yd
  expected-demand-De
  desired-labor-force-Ld               ; desired production / labor productivity
  my-employees                         ; an agent set of current employees.
  current-numbers-employees-L0         ; number of current employees.
  number-of-vacancies-offered-V        ; max of desired labor force - current labor force and 0.
  minimum-wage-W-hat                   ; mandatory minimum wage set by law
  wage-offered-Wb                      ; contractual wage: if no vacancies the max of previous wage
                                       ; and minimum wage; otherwise previous wage is also pondered
                                       ; by an idiosyncratic shock, e.g., 1 + wage-shock-xi
  net-worth-A                          ; previous net worth + profits - dividends (profits * 1 - profits-delta)
  total-payroll-W                      ; the desired wage bill
  loan-B                               ; max of desired wage bill - net worth and 0
  my-potential-banks                   ; credit-market-H < number of banks (less than firms/10)
  my-bank                              ; the current bank of the firm
  my-interest-rate
  amount-of-Interest-to-pay
  inventory-S                          ; inventory of unsold goods
  individual-price-P
  revenue-R
  gross-profits
  net-profits
  retained-profits-pi
  ; for visual representation
  x-position
  y-position
]

workers-own[
  employed?                   ; a boolean, true iff the agent is employed.
  my-potential-firms
  my-firm                     ; the current firm if employed.
  contract
  my-wage                     ; current wage
  income
  savings
  wealth
  propensity-to-consume-c
  my-stores
  my-large-store
]

banks-own[
  ;  Repayment schedule (eq. 3.6, p. 53) is represented in firms-pay procedure as in p.50:
  ; "If gross profits are high enough, they “validate” debt commitments, i.e. firms pay back both the principal and the interest to the bank"
  ; r-bar (instead r-hat) (eq. 3.7, p. 53) is represented as a reporter (interest-rate-policy-rbar)
  total-amount-of-credit-C    ; a multiple of its equity base in terms of capital req. coeff (buy default v= 0.23).
  patrimonial-base-E
  operational-interest-rate
  my-borrowing-firms
  interest-rate-r
  bad-debt-BD
  bankrupt?
]

; Setup procedures
to setup
  clear-all

  start-firms number-of-firms
  start-workers round (number-of-firms * 5)
  start-banks max (list (credit-market-H + 1) round (number-of-firms / 10))
  initialize-variables

  reset-ticks
end

to initialize-variables
  ask firms [
    set production-Y 1
    set labor-productivity-alpha 1
    set desired-production-Yd 0
    set expected-demand-De 1
    set desired-labor-force-Ld 0
    set my-employees no-turtles
    set current-numbers-employees-L0 0
    set number-of-vacancies-offered-V 0
    set minimum-wage-W-hat 1
    set wage-offered-Wb minimum-wage-W-hat
    set net-worth-A 10
    set total-payroll-W 0
    set loan-B 0
    set my-potential-banks no-turtles
    set my-bank no-turtles
    set inventory-S 0
    set individual-price-P base-price
    set revenue-R 0
    set retained-profits-pi 0
  ]
  ask workers [
    set employed? false
    set my-potential-firms no-turtles
    set my-firm nobody
    set contract 0
    set income 0
    set savings 1 + random-poisson base-savings
    set wealth 0
    set propensity-to-consume-c 1
    set my-stores no-turtles
    set my-large-store no-turtles
  ]
  ask banks [
    set total-amount-of-credit-C 0
    set patrimonial-base-E random-poisson 10000 + 10
    set operational-interest-rate 0
    set interest-rate-r 0
    set my-borrowing-firms no-turtles
    set bankrupt? false
  ]
  set quarters-average-price array:from-list n-values 4 [base-price]
  set quarters-inflation array:from-list n-values 4 [0]
end

to start-firms [#firms]
  create-firms #firms [
    set x-position random-pxcor * 0.9
    set y-position random-pycor * 0.9
    setxy x-position y-position
    set color blue
    set size 1.2
    set shape "factory"
  ]
end

to start-workers [#workers]
  create-workers #workers [
    setxy random-pxcor random-pycor
    set color yellow
    set size 1 / log number-of-firms 10
    set shape "person"
  ]
end

to start-banks [#banks]
  create-banks #banks[
    setxy random-pxcor * 0.9 random-pycor * 0.9
    set color red
    set size 1.5
    set shape "house"
  ]
end

to go
  if (ticks >= 1000
    ;or (ticks > 600 and fn-unemployment-rate > 0.5)
    ;or (ticks > 600 and abs annualized-inflation > 0.25)
  ) [stop]
  ; Process overview and scheduling
  firms-calculate-production
  labor-market
  credit-market
  firms-produce
  goods-market
  firms-pay
  firms-banks-survive
  replace-bankrupt

  tick
end

;;;;;;;;;; to firms-calculate production ;;;;;;;;;;
to firms-calculate-production
  adapt-expected-demand-or-price
  ask firms [
    set desired-production-Yd expected-demand-De; submodel 2
  ]
  array:set quarters-average-price (ticks mod 4) mean [individual-price-P] of firms
  let actual-price array:item quarters-average-price (ticks mod 4)
  let previous-price array:item quarters-average-price ((ticks - 1) mod 4)
  let quarter-inflation ((actual-price - previous-price) / previous-price) * 100
  array:set quarters-inflation (ticks mod 4) quarter-inflation
end

to adapt-expected-demand-or-price
  let avg-market-price average-market-price
  ask firms [
    let minimum-price-Pl ifelse-value (production-Y > 0)[( total-payroll-W + amount-of-Interest-to-pay ) / production-Y] [avg-market-price]
    (cf:ifelse
      (inventory-S = 0 and individual-price-P >= avg-market-price and production-Y > 0)
        [ set expected-demand-De max (list 1 ceiling (production-Y * (1 + production-shock-rho)))]
      (inventory-S > 0 and individual-price-P < avg-market-price)
        [ set expected-demand-De max (list 1 ceiling (production-Y * (1 - production-shock-rho)))]
      (inventory-S = 0 and individual-price-P <  avg-market-price)
        [ set individual-price-P max(list minimum-price-Pl (individual-price-P * (1 + price-shock-eta)))]
      (inventory-S > 0 and individual-price-P >= avg-market-price)
        [ set individual-price-P max(list minimum-price-Pl (individual-price-P * (1 - price-shock-eta)))]
        [ show (word "No selected strategies ")]
    )
  ]
end

;;;;;;;;;; to labor-market  ;;;;;;;;;;
to labor-market
  let law-minimum-wage ifelse-value (ticks > 0 and ticks mod 4 = 0 )[fn-minimum-wage-W-hat][[minimum-wage-W-hat] of firms]
  ask firms [
    set desired-labor-force-Ld ceiling (desired-production-Yd / labor-productivity-alpha); submodel 3
    set current-numbers-employees-L0 count my-employees; summodel 4
    set number-of-vacancies-offered-V max(list (desired-labor-force-Ld - current-numbers-employees-L0) 0 ); submodel 5
    if (ticks > 0 and ticks mod 4 = 0 )
    [
      set minimum-wage-W-hat law-minimum-wage; submodel 6
    ]
    ifelse (number-of-vacancies-offered-V = 0)
    [
      set wage-offered-Wb max(list minimum-wage-W-hat wage-offered-Wb); submodel 7
    ]
    [
      set wage-offered-Wb max(list minimum-wage-W-hat (wage-offered-Wb * (1 + wages-shock-xi))); submodels 8 and 9
    ]
  ]
  labor-market-opens
end

to labor-market-opens
  if (sum [number-of-vacancies-offered-V] of firms > 0) [
    let potential-firms firms with [number-of-vacancies-offered-V > 0]
    ask workers with [not employed?][
      ifelse (not empty? [my-firm] of my-potential-firms)
      [set my-potential-firms (turtle-set my-firm n-of (labor-market-M - 1 ) potential-firms)]
      [set my-potential-firms n-of (min (list labor-market-M count potential-firms)) potential-firms]
    ]
  ]

  hiring-step labor-market-M
  ask workers with [not employed?][
    set my-wage 0
    set income 0
    rt random 360
    fd (random 4) + 1
  ]
  ask firms [
    set label count my-employees
    set color palette:scale-gradient [[68 1 84] [33 144 140] [253 231 37]] net-worth-A 0 max [net-worth-A] of firms
  ]
end

to hiring-step [trials]
  while [trials > 0]
  [
    ask workers with [not employed? and any? my-potential-firms][
      move-to max-one-of my-potential-firms [wage-offered-Wb]
    ]
    ask firms with [number-of-vacancies-offered-V > 0 ][
      let potential-workers workers-here with [not employed?]
      let quantity count potential-workers
      let workers-hired n-of (min list quantity number-of-vacancies-offered-V) potential-workers
      let wage-employees wage-offered-Wb
      set my-employees (turtle-set my-employees workers-hired)
      set number-of-vacancies-offered-V number-of-vacancies-offered-V - count workers-hired
      set total-payroll-W total-payroll-W + (count workers-hired * wage-offered-Wb)
      ask my-employees with [not employed?] [
        set color green
        set employed? true
        set my-wage wage-employees
        set contract 8 + random-poisson 10
        set my-firm firms-here
        set my-potential-firms no-turtles
      ]
    ]
    set trials trials - 1
    ask workers with [not employed? and any? my-potential-firms][
      set my-potential-firms min-n-of min (list trials count my-potential-firms) my-potential-firms [wage-offered-Wb]
    ]
  ]
end
;;;;;;;;;; to credit-market  ;;;;;;;;;;
to credit-market; observer-procedure
  ask banks [
    set total-amount-of-credit-C patrimonial-base-E / v; submodel 12
    set operational-interest-rate random-float interest-shock-phi; part of submodel 14
  ]

  ask firms with [production-Y > 0][
    if (total-payroll-W > net-worth-A)[
      let leverage desired-production-Yd * wage-offered-Wb
      set loan-B max (list (leverage - net-worth-A) 0); submodel 10
      if (loan-B > 0)[
        set shape "person business"
      ]
    ]
  ]
  credit-market-opens
  firing-step
end

to credit-market-opens; observer procedure
  ask firms with [loan-B > 0][
    set my-potential-banks n-of credit-market-H banks
  ]
  borrowing-step credit-market-H
end

to borrowing-step [trials]; observer procedure
  while [trials > 0][ ; submodel 20
    ask firms with [loan-B > 0][
      move-to min-one-of my-potential-banks [operational-interest-rate]
    ]
    ask banks [
      set my-borrowing-firms firms-here
      if any? my-borrowing-firms
      [
        lending-step my-borrowing-firms
      ]
    ]
    set trials trials - 1
  ]
end

to lending-step [#borrowing-firms]; banks procedure
  while [any? #borrowing-firms and total-amount-of-credit-C > 0][
    let my-best-borrower max-one-of #borrowing-firms [net-worth-A]
    let networth max (list [net-worth-A] of my-best-borrower 1)
    let leverage-of-borrower [loan-B] of my-best-borrower / networth; submodel 19
    ;submodel 17
    let contractual-interest interest-rate-policy-rbar * (1 + ([operational-interest-rate] of self * leverage-of-borrower));
    let the-lender-bank self
    let loan min (list [loan-B] of my-best-borrower total-amount-of-credit-C); part of submodel 14

    ask my-best-borrower [
      set my-bank the-lender-bank
      set my-interest-rate contractual-interest
      set amount-of-Interest-to-pay loan * ( 1 + contractual-interest )
      set net-worth-A net-worth-A + loan
      set loan-B loan-B - loan
      setxy [x-position] of my-best-borrower [y-position] of my-best-borrower
      set shape "factory"
    ]

    let count-borrowers count #borrowing-firms
    set #borrowing-firms min-n-of (count-borrowers - 1) #borrowing-firms [net-worth-A]
  ]
end

to firing-step
  ask firms with [loan-B > 0][
    while [total-payroll-W  > net-worth-A and count my-employees > 1][
      let expensive-worker max-one-of my-employees [my-wage]
      set my-employees min-n-of (count my-employees - 1) my-employees [my-wage]
      set total-payroll-W total-payroll-W - [my-wage] of expensive-worker
      ask expensive-worker[
        set color yellow
        set employed? false
        set my-wage 0
        set income 0
        set contract 0
        set my-firm no-turtles
        rt random 360
        fd (random 4) + 1
      ]
    ]
  ]
end

;;;;;;;;;; to firms-produce  ;;;;;;;;;;
to firms-produce
  ask firms [
    set production-Y labor-productivity-alpha * count my-employees; submodel 1
    set inventory-S production-Y * individual-price-P
    set net-worth-A net-worth-A - total-payroll-W
  ]

  ask workers with [employed?][
    set income my-wage
    set contract contract - 1
    if (contract = 0)[
      set employed? false
      set color yellow
      set my-wage 0
      rt random 360
      fd (random 4) + 1
    ]
  ]

  ; firing employees with expired contract
  ask firms [
    set my-employees my-employees with [contract > 0]
  ]
end

;;;;;;;;;; to goods-market  ;;;;;;;;;;
to goods-market ;; an observer procedure
  let average-savings mean [savings] of workers
  ask workers[
    set wealth income + savings
    set propensity-to-consume-c 1 / (1 + (fn-tanh (savings / average-savings)) ^ beta)
    let money-to-consume propensity-to-consume-c * wealth
    set savings ((1 - propensity-to-consume-c) * wealth)
    ifelse (any? turtle-set my-large-store)
      [
        let id-store [who] of my-large-store
        set my-stores (turtle-set my-large-store n-of (goods-market-Z - 1) firms with [who != id-store])
      ]
      [
        set my-stores n-of goods-market-Z firms
      ]
    set my-large-store max-one-of my-stores [production-Y]
    if (count my-stores != goods-market-Z) [show (word "Number of my stores " count my-stores " who " who)]
    buying-step goods-market-Z money-to-consume
  ]
end

to buying-step [trials money]; workers procedure
  while [trials > 0 and money > 0][
    let my-cheapest-store min-one-of my-stores [individual-price-P]
    let possible-goods-to-buy min list money [inventory-S] of my-cheapest-store
    set money money - possible-goods-to-buy
    ask my-cheapest-store [
      ; goods are fractional e.g. liters or pounds, so its possible to buy a fraction
      set inventory-S inventory-S - possible-goods-to-buy
    ]
    ask [patch-here] of my-cheapest-store [
      set pcolor green
    ]
    set trials trials - 1
    set my-stores max-n-of trials my-stores [individual-price-P]; eliminate cheap-store of my-stores with sets
  ]
  if (money > 0)[
    set savings savings + money
  ]
end
;;;;;;;;;; to firms-pay  ;;;;;;;;;;
to firms-pay
  ask firms [
    set revenue-R individual-price-P * production-Y
    set gross-profits revenue-R - total-payroll-W
    let principal-and-Interest amount-of-Interest-to-pay
    if (amount-of-Interest-to-pay > 0)[
      ifelse (gross-profits > amount-of-Interest-to-pay)[; submodel 42
        ask my-bank [
          set patrimonial-base-E patrimonial-base-E + principal-and-Interest
        ]
      ][
        let bank-financing ifelse-value (net-worth-A != 0 ) [loan-B / net-worth-A][1]
        let bad-debt-amount bank-financing * net-worth-A
        ask my-bank [
          set patrimonial-base-E patrimonial-base-E - bad-debt-amount
        ]
      ]
    ]
    set net-profits gross-profits - amount-of-Interest-to-pay
    set amount-of-Interest-to-pay 0
    if (net-profits > 0)[
      set retained-profits-pi (1 - dividends-delta ) * net-profits
    ]
  ]
end

;;;;;;;;;; to firms-banks-survive ;;;;;;;;;;
to firms-banks-survive
  ask firms [
    set net-worth-A net-worth-A + retained-profits-pi
    if (net-worth-A <= 0
        or production-Y <= 0
      )[
      ask my-bank [
        set bad-debt-BD bad-debt-BD + 1
      ]
      ask my-employees [
        set color yellow
        set employed? false
        set my-wage 0
        set contract 0
        set my-firm no-turtles
        rt random 360
        fd (random 4) + 1
      ]
      die
    ]
  ]
  ask banks with [patrimonial-base-E < 0][
    ask my-borrowing-firms [
      set my-potential-banks no-turtles
      set my-bank no-turtles
    ]
    set bankrupt? true
  ]
end

to replace-bankrupt
  if (count firms < number-of-firms)[
    let incumbent-firms fn-incumbent-firms
    create-firms (number-of-firms - count firms) [
      set x-position random-pxcor * 0.9
      set y-position random-pycor * 0.9
      setxy x-position y-position
      set color blue
      set size 1.2
      set shape "factory"
      ;-----------------
      set production-Y ceiling mean [production-Y] of incumbent-firms
      set labor-productivity-alpha 1
      set my-employees no-turtles
      set minimum-wage-W-hat min [minimum-wage-W-hat] of incumbent-firms
      set wage-offered-Wb (1 - size-replacing-firms) * mean [wage-offered-Wb] of incumbent-firms
      set net-worth-A (1 - size-replacing-firms) * mean [net-worth-A] of incumbent-firms
      set my-potential-banks no-turtles
      set my-bank no-turtles
      set inventory-S 0
      set individual-price-P  1.26 * average-market-price
    ]
  ]

  ask banks with [bankrupt?][
    set total-amount-of-credit-C 0
    set patrimonial-base-E random-poisson 10000 + 10
    set operational-interest-rate 0
    set interest-rate-r 0
    set my-borrowing-firms no-turtles
    set bankrupt? false
  ]
  ; re-paint patches
  ask patches [
    set pcolor black
  ]
end

; utilities

to-report average-market-price
  report mean [individual-price-P] of firms
end

to-report fn-tanh [a]
  report ifelse-value (a < 354.391)[(exp (2 * a) - 1) / (exp (2 * a) + 1)][0.135335283]
end

to-report fn-minimum-wage-W-hat
  let currently-minimum-w min [minimum-wage-W-hat] of firms
  report annualized-inflation * currently-minimum-w
end

to-report interest-rate-policy-rbar
  report 0.07
end

to-report fn-incumbent-firms
  let lower count firms * 0.05
  let upper count firms * 0.95
  let ordered-firms sort-on [net-worth-A] firms
  let list-incumbent-firms sublist ordered-firms lower upper
  report (turtle-set list-incumbent-firms)
end

to-report fn-truncated-normal [ m sd ]
  let normal-value random-normal m sd
  report ifelse-value (normal-value > (m - sd)) [normal-value][max list 1 (m - sd)]
end

; observation
to-report nominal-GDP
  let output sum [production-Y * individual-price-P] of firms
  report output
end

to plot-nominal-GDP
  plot ln-hopital nominal-GDP
end

to-report CPI
  let base base-price
  let current array:item quarters-average-price (ticks mod 4)
  report (current / base) * 100
end

to-report real-GDP
  report nominal-GDP / CPI
end

to plot-real-GDP
  plot ln-hopital real-GDP
end

to-report logarithm-of-households-consumption
  let output sum [production-Y * individual-price-P] of firms
  let consumption output - sum [inventory-S] of firms
  report ln-hopital consumption
end

to-report fn-unemployment-rate
  report count workers with [not employed?] / count workers
end

to unemployment-rate
  let unemployed count workers with [not employed?]
  plot unemployed / count workers
end

to-report quarterly-inflation
  let q-inflation array:item quarters-inflation (ticks mod 4)
  report q-inflation
end

to-report annualized-inflation
  report reduce * map [i -> (i / 100) + 1] array:to-list quarters-inflation
end

to plot-annualized-inflation
  plot (annualized-inflation - 1) * 100
end

to-report ln-hopital [number]
  report ifelse-value (number > 0)[ln number][0]
end

to plot-size-of-firms
  histogram map ln-hopital [production-Y] of fn-incumbent-firms
end

to-report base-price
  report 1.5
end

to-report base-savings
  report 2
end

to-report average-real-interest-rate

end

to-report number-of-firms-which-go-bankrupt

end

to-report vacancy-rate

end
@#$#@#$#@
GRAPHICS-WINDOW
269
10
701
443
-1
-1
8.0
1
8
1
1
1
0
0
0
1
-26
26
-26
26
0
0
1
ticks
120.0

BUTTON
26
10
99
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
106
10
169
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
2
48
194
81
number-of-firms
number-of-firms
2
1000
100.0
2
1
NIL
HORIZONTAL

SLIDER
2
84
194
117
wages-shock-xi
wages-shock-xi
0.01
0.5
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
2
121
194
154
interest-shock-phi
interest-shock-phi
0
0.5
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
2
157
194
190
price-shock-eta
price-shock-eta
0
0.5
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
2
194
194
227
production-shock-rho
production-shock-rho
0
0.5
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
2
231
194
264
v
v
0
1
0.23
0.01
1
NIL
HORIZONTAL

SLIDER
2
268
194
301
labor-market-M
labor-market-M
1
10
4.0
1
1
trials
HORIZONTAL

PLOT
708
10
974
130
Unemployment rate
Quarter
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "set-plot-x-range 0  (ticks + 5)\nset-plot-y-range 0  0.3\nunemployment-rate"
"pen-1" 1.0 2 -7500403 true "" "plot 0"
"pen-2" 1.0 0 -2674135 true "" "plot 0.10"

SLIDER
2
303
194
336
credit-market-H
credit-market-H
1
10
2.0
1
1
trials
HORIZONTAL

SLIDER
2
338
194
371
goods-market-Z
goods-market-Z
1
15
2.0
1
1
trials
HORIZONTAL

SLIDER
2
374
194
407
beta
beta
0.01
1
0.87
0.01
1
NIL
HORIZONTAL

SLIDER
2
410
194
443
dividends-delta
dividends-delta
0
0.5
0.15
0.01
1
NIL
HORIZONTAL

PLOT
977
10
1243
130
Net worth distribution
log money
freq
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "set-histogram-num-bars sqrt count firms\nset-plot-y-range 0 ceiling sqrt count firms\nset-plot-x-range floor ln-hopital min [net-worth-A] of fn-incumbent-firms ceiling ln-hopital max [net-worth-A] of fn-incumbent-firms\nhistogram map ln-hopital [net-worth-A] of fn-incumbent-firms"

PLOT
1246
10
1512
130
log (Net worth) of firms
Quarter
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nset-plot-y-range 0 max (list 1 ceiling ln-hopital max [net-worth-A] of firms)\nplot ln-hopital mean [net-worth-A] of firms"
"min" 1.0 0 -2674135 true "" "plot ln-hopital min [net-worth-A] of firms"
"max" 1.0 2 -13840069 true "set-plot-pen-mode 2" "plot ln-hopital max [net-worth-A] of firms"

PLOT
708
133
974
253
Propensity to consume
Quarter
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nplot mean [propensity-to-consume-c] of workers"
"min" 1.0 2 -2674135 true "" "plot min [propensity-to-consume-c] of workers"
"max" 1.0 2 -13345367 true "" "plot max [propensity-to-consume-c] of workers"

PLOT
977
133
1243
253
Quarterly inflation
Quarter
%
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nset-plot-y-range -5 10\nplot quarterly-inflation"
"pen-1" 1.0 2 -5987164 true "" "plot 0"

PLOT
1246
133
1512
253
Annualized inflation
Year
%
0.0
10.0
-1.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "set-plot-x-range max list 0 (ceiling (ticks / 4) - 125) ceiling (ticks / 4) + 1\nset-plot-y-range -2 6\nif (ticks > 0 and ticks mod 4 = 0 )[\nplot-annualized-inflation]"
"pen-1" 1.0 0 -7500403 true "" "set-plot-x-range max list 0 (ceiling (ticks / 4) - 125) ceiling (ticks / 4) + 1\nif (ticks > 0 and ticks mod 4 = 0 )[plot 0]"

TEXTBOX
7
451
192
481
Random scaling parameter
12
0.0
1

SLIDER
2
470
194
503
size-replacing-firms
size-replacing-firms
0.05
0.5
0.2
0.01
1
NIL
HORIZONTAL

PLOT
708
256
974
376
Ln nominal - real GDP
Quater
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Nom." 1.0 2 -12030287 true "" "set-plot-x-range 0 (ticks + 5)\nplot-nominal-GDP"
"Real" 1.0 0 -8053223 true "" "plot-real-GDP"

PLOT
977
256
1243
376
Ln of consumption
Quarter
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nplot logarithm-of-households-consumption"

PLOT
1246
256
1512
376
Ln Price of firms
Quarter
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nplot ln average-market-price"
"min" 1.0 2 -2674135 true "" "set-plot-x-range 0 (ticks + 5)\nplot ln min [individual-price-P] of firms"
"max" 1.0 0 -13345367 true "" "set-plot-x-range 0 (ticks + 5)\nplot ln max [individual-price-P] of firms"

PLOT
708
379
974
499
wage-offered-Wb
Quarter
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nplot ln mean [wage-offered-Wb] of firms"
"min" 1.0 0 -2674135 true "" "plot ln min [wage-offered-Wb] of firms"
"max" 1.0 0 -13345367 true "" "plot ln max [wage-offered-Wb] of firms"

TEXTBOX
216
61
260
79
100
12
5.0
1

TEXTBOX
199
16
273
34
Init values
12
5.0
1

TEXTBOX
216
99
290
117
0.05
12
5.0
1

TEXTBOX
217
138
268
156
0.10
12
5.0
1

TEXTBOX
217
173
282
191
0.10
12
5.0
1

TEXTBOX
217
211
290
229
0.10
12
5.0
1

TEXTBOX
221
287
282
305
4
12
5.0
1

TEXTBOX
222
320
277
338
2
12
5.0
1

TEXTBOX
221
353
271
371
2
12
5.0
1

TEXTBOX
220
391
292
409
0.87
12
5.0
1

TEXTBOX
219
428
293
446
0.15
12
5.0
1

PLOT
977
380
1243
500
Wealth distribution
log wealth
freq
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "set-histogram-num-bars sqrt count workers\nset-plot-y-range 0 ceiling sqrt count workers\nset-plot-x-range floor ln-hopital min [wealth] of workers ceiling ln-hopital max [wealth] of workers\nhistogram map ln-hopital [wealth] of workers with [wealth > 0]"

PLOT
1246
381
1513
501
Size of firms
log Production
freq
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "set-histogram-num-bars sqrt count firms\nset-plot-y-range 0 ceiling sqrt count firms\nset-plot-x-range floor ln-hopital min [production-Y] of fn-incumbent-firms ceiling ln-hopital max [production-Y] of fn-incumbent-firms\nplot-size-of-firms"

PLOT
1516
10
1776
130
Production of firms
Quarter
Quantity
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nset-plot-y-range 0 ceiling (max (list 1 [production-Y] of firms))\nplot mean [production-Y] of fn-incumbent-firms"
"max" 1.0 0 -13840069 true "" "plot max [production-Y] of fn-incumbent-firms"
"min" 1.0 0 -2674135 true "" "plot min [production-Y] of fn-incumbent-firms"

PLOT
1516
133
1776
253
Desired production
Quarter
Quantity
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nset-plot-y-range 0 ceiling (max (list 1 [desired-production-Yd] of firms))\nplot mean [desired-production-Yd] of firms"
"max" 1.0 0 -13840069 true "" "plot max [desired-production-Yd] of firms"
"min" 1.0 0 -2674135 true "" "plot min [desired-production-Yd] of firms"
"median" 1.0 0 -11053225 true "" "plot median [desired-production-Yd] of firms"

PLOT
1516
257
1776
377
Contractual interest rate
Quaters
%
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nplot 100 * mean [my-interest-rate] of firms"
"max" 1.0 0 -2674135 true "" "plot 100 * max [my-interest-rate] of firms"
"min" 1.0 0 -13345367 true "" "plot 100 * min [my-interest-rate] of firms"

PLOT
1516
381
1776
501
Wealth of workers
Quarter
Ln
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nset-plot-y-range 0 max (list 1 ceiling ln-hopital max [wealth] of workers)\nplot ln-hopital mean [wealth] of workers"
"max" 1.0 0 -13840069 true "" "plot ln-hopital max [wealth] of workers"
"min" 1.0 0 -2674135 true "" "plot ln-hopital round min [wealth] of workers"

PLOT
710
505
975
625
Inventory-S
Quarter
Ln
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nplot ln-hopital mean [inventory-S] of firms"
"max" 1.0 0 -2674135 true "" "plot ln-hopital max [inventory-S] of firms"
"min" 1.0 0 -13345367 true "" "plot ln-hopital min [inventory-S] of firms"

PLOT
975
505
1240
625
Banks patrimonial base
Quarter
Ln
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nset-plot-y-range max (list 0 ceiling ln-hopital min [patrimonial-base-E] of banks) max (list 1 (1 + ceiling ln-hopital max [patrimonial-base-E] of banks))\nplot ln-hopital mean [patrimonial-base-E] of banks"
"max" 1.0 0 -2674135 true "" "plot ln-hopital max [patrimonial-base-E] of banks"
"min" 1.0 0 -13345367 true "" "plot ln-hopital min [patrimonial-base-E] of banks"

@#$#@#$#@
Overview
========

Purpose
-------

Modeling an economy with stable macro signals, that works as a benchmark for studying the effects of the agent activities, e.g. extortion, at the service of the elaboration of public policies.

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

Firms can adapt in each period t price or amount to supply (only one of the two strategies). Adaptation of each strategy depends on the condition of the firm (level of excessive supply / demand in the previous period) and/or the market environment (the difference between the individual price and the market price in the previous period).

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
	Y<sub>it</sub> = &alpha;<sub>it</sub> L<sub>it</sub>, &alpha;<sub>it</sub> > 0.

2.  Desired production level Y<sub>it</sub><sup>d</sup> is equal to the expected demand 	D<sub>it</sub><sup>d</sup>.

3.  Desired labor force (employees) L<sub>it</sub><sup>d</sup> is L<sub>it</sub><sup>d</sup> = Y<sub>it</sub><sup>d</sup> &frasl; &alpha;<sub>it</sub>

4.  Current number of employees L<sub>it</sub><sup>0</sup> is the sum of employees     with and without a valid contract.

5.  Number of vacancies offered by firms V<sub>it</sub> is V<sub>it</sub> = max (L<sub>it</sub><sup>d</sup> - L<sub>it</sub><sup>0</sup>, 0).

6.  w&#770;<sub>t</sub> is the minimum wage determined by law.

7.  If there are no vacancies V<sub>it</sub> = 0, wage offered is:
    w<sub>it</sub><sup>b</sup> = max (w&#770;<sub>t</sub>, w<sub>it-1</sub>),

8.  If number of vacancies is greater than 0, wage offered is:
    w<sub>it</sub><sup>b</sup> = max (w&#770;<sub>t</sub>, w<sub>it-1</sub> (1+ &xi;<sub>it</sub>)),

9.  &xi;<sub>it</sub> is a random term evenly distributed between (0, h<sub>&xi;</sub>).

10. At the beginning of each period, a firm has a net value A<sub>it</sub>. If total payroll to be paid W<sub>it</sub> is greater than A<sub>it</sub>, firm asks for a B<sub>it</sub> loan:
    B<sub>it</sub> = max (W<sub>it</sub> - A<sub>it</sub>, 0 )

11. For the loan search costs, it must be met that H < K.

12. In each period the <i>k</i>-th most bank can distribute a total amount of credit C<sub>k</sub> equivalent to a multiple of its patrimonial base:
    C<sub>kt</sub> = E<sub>kt</sub> &frasl; v,

13. where 0 < <i>v</i> < 1 can be interpreted as the capital requirement coefficient. Therefore, the <i>v</i> reciprocal represents the maximum allowed leverage by the bank.

14. Bank offers credit C<sub>k</sub>, with its respective interest rate r<sub>it</sub><sup>k</sup> and contract for 1 period.

15. Payment scheme if A<sub>it + 1</sub> > 0: B<sub>it</sub> (1 + r<sub>it</sub><sup>k</sup>).

16. If A<sub>it + 1</sub> &#8804; 0 , bank retrieves R<sub>it + 1</sub>.

17. Contractual interest rate offered by the bank k to the firm i is determined as a margin on a rate policy established by Central Monetary Authority r&#772;:
    R<sub>it</sub><sup>k</sup> = r&#772; (1 + &phi;<sub>kt</sub> &mu;(&ell;<sub>it</sub>)).

18. Margin is a function of the specificity of the bank as possible variations in its operating costs and captured by the uniform random variable &phi;<sub>kt</sub> in the interval (0, h<sub>&phi;</sub>).

19. Margin is also a function of the borrower’s financial fragility, captured by the term
	&mu; (&ell;<sub>it</sub>), &mu;<sup>'</sup>} > 0. Where &ell;<sub>it</sub> = B<sub>it</sub> &frasl;A<sub>it</sub> is the leverage of borrower.

20. Demand for credit is divisible, that is, if a single bank is not able to satisfy the requested credit, it can request in the remaining H-1 randomly selected banks.

21. Each firm has an inventory of unsold goods S<sub>it</sub>, where excess supply  S<sub>it</sub> > 0 or demand S<sub>it</sub> = 0 is reflected.

22. Deviation of the individual price from the average market price during the previous period is represented as:
    P<sub>it-1</sub> - P<sub>t-1</sub>

23. If deviation is positive, P<sub>it-1</sub> > P<sub>t-1</sub>, firm recognizes that its price is high compared to its competitors, and is induced to decrease the price or quantity to prevent a migration massive in favor of its rivals.

24. Vice versa.

25. In case of adjusting price to downside, this is bounded below P<sub>it</sub><sup>l</sup> to not be less than your average costs
    P<sub>it</sub><sup>l</sup> = &#91; W<sub>it</sub> + &Sigma;<sub>k</sub> r<sub>kit</sub> B<sub>kit</sub> &#93; &frasl; Y<sub>it</sub>.

26. Aggregate price P<sub>t</sub> is common knowledge (global variable), while inventory S<sub>it</sub> and individual price P<sub>it</sub> private knowledge child (local variables).

27. Only the price or quantity to be produced can be modified. In the case of price, we have the following rule for P<sub>it</sub><sup>s</sup>:
max[P<sub>it</sub><sup>l</sup>, P<sub>it-1</sub>(1+&eta;<sub>it</sub>)]  &nbsp;&nbsp;&nbsp;    if &nbsp;&nbsp;&nbsp; S<sub>it-1</sub>=0 and P<sub>it-1</sub><P
max[P<sub>it</sub><sup>l</sup>, P<sub>it-1</sub>(1-&eta;<sub>it</sub>)] &nbsp;&nbsp;&nbsp;    if &nbsp;&nbsp;&nbsp; S<sub>it-1</sub>>0 and P<sub>it-1</sub>&#8805; P

28. &eta;<sub>it</sub> is a randomized term uniformly distributed in the range (0, h<sub> &eta;</sub>) and P<sub>it</sub><sup>l</sup> is the minimum price at which firm i can solve its minimal costs at time t (previously defined).

29. In the case of quantities, these are adjusted adaptively according to the following rule for D<sub>it</sub><sup>e</sup> :
Y<sub>it-1</sub>(1+&rho;<sub>it</sub>) &nbsp;&nbsp;&nbsp; if &nbsp;&nbsp;&nbsp; S<sub>it-1</sub>=0 and P<sub>it-1</sub>&#8805; P
Y<sub>it-1</sub>(1-&rho;<sub>it</sub>) &nbsp;&nbsp;&nbsp; if &nbsp;&nbsp;&nbsp; S<sub>it-1</sub>>0 and P<sub>it-1</sub>< P

30. &rho;<sub>it</sub> is a random term uniform distributed and bounded between (0, h<sub>&rho;</sub>).

31. Total income of households (workers/consumers) is the sum of the payroll paid to the workers (each household represents a worker) in t and the dividends distributed to the shareholders in t-1.

32. Wealth is defined as the sum of labor income plus the sum of all savings SA of the past.

33. Marginal propensity to consume c is a decreasing function of the worker’s total wealth (higher the wealth lower the proportion spent on consumption) defined as:

    c<sub>jt</sub> = 1 &frasl; [ 1 + tanh (SA<sub>jt</sub> &frasl;SA<sub>t</sub>)]<sup>&beta;</sup>

34. SA<sub>t</sub> is the average savings. SA<sub>jt</sub> is the real saving of the j -th consumer.

35. The revenue R<sub>it</sub> of a firm after the goods market closes is equal to:

    R<sub>it</sub> = P<sub>it</sub> Y<sub>it</sub>

36. At the end of t period, each firm computes benefits &pi;<sub>it-1</sub>.

37. If the benefits are positive, the shareholders of firms receive dividends:

    Div<sub>it-1</sub> = &delta; &pi;<sub>it-1</sub>

38. Residual, after discounting dividends, is added to net value inherited from previous period, A<sub>it-1</sub>. Therefore, net worth of a profitable firm in t is:

    A<sub>it</sub> = A<sub>it-1</sub>+&pi;<sub>it-1</sub> -Div<sub>it-1</sub> &equiv; A<sub>it-1</sub>+ (1-&delta;)&pi;<sub>it-1</sub>

39. If firm, say f, accumulates a net value A<sub>it</sub> < 0 goes bankrupt.

40. Firm that goes bankrupt is replaced with another one of smaller size than the average of incumbent firms.

41. Non-incumbent firms are those whose size is above and below 5%, is used to calculate a more robust estimator of the average.

42. Bank’s capital

    E<sub>kt</sub>=E<sub>kt-1</sub> + &Sigma;<sub>i &isin; &Theta;</sub> r<sub>kit-1</sub> B<sub>kit-1</sub> - BD<sub>kt-1</sub>

43. &Theta; is the bank’s loan portfolio, BD<sub>kt-1</sub> represents the portfolio of firms that go bankrupt.

44. If a bank goes bankrupt, it is replaced with a copy of the surviving banks.


Reference
========
Delli Gatti, D. et. al, (2011). *Macroeconomics from the Bottom-up*. Springer-Verlag Mailand, Milan.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -1184463 true false 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

factory
false
0
Rectangle -7500403 true true 76 194 285 270
Rectangle -7500403 true true 36 95 59 231
Rectangle -16777216 true false 90 210 270 240
Line -7500403 true 90 195 90 255
Line -7500403 true 120 195 120 255
Line -7500403 true 150 195 150 240
Line -7500403 true 180 195 180 255
Line -7500403 true 210 210 210 240
Line -7500403 true 240 210 240 240
Line -7500403 true 90 225 270 225
Circle -1 true false 37 73 32
Circle -1 true false 55 38 54
Circle -1 true false 96 21 42
Circle -1 true false 105 40 32
Circle -1 true false 129 19 42
Rectangle -7500403 true true 14 228 78 270

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
10
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true true 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -13345367 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -1184463 true false 110 5 80
Rectangle -1184463 true false 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true true 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true true 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="stylized-facts" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>[net-worth-A] of fn-incumbent-firms</metric>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
