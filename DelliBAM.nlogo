; run out of memory

; Bottom-up Adaptive Macroeconomics
extensions [palette array]

breed[firms firm]
breed[workers worker]
breed[banks bank]

globals [
  average-price-list
]

firms-own[
  production-Y
  labor-productivity-alpha
  desired-production-Yd
  expected-demand-De
  desired-labor-force-Ld
  my-employees
  current-numbers-employees-L0
  number-of-vacancies-offered-V
  minimum-wage-W-hat
  wage-offered-Wb
  net-worth-A
  total-payroll-W
  loan-B
  my-potential-banks
  my-bank
  my-interest-rate
  amount-of-Interest-to-pay
  inventory-S
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
  employed?
  my-potential-firms
  my-firm
  contract
  my-wage
  income
  savings
  wealth
  propensity-to-consume-c
  my-stores
  my-large-store
]
banks-own[
  total-amount-of-credit-C
  patrimonial-base-E
  operational-interest-rate
  my-borrowing-firms
  interest-rate-r
  bad-debt-BD
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
    set production-Y fn-truncated-normal 6 2
    set labor-productivity-alpha 1
    set desired-production-Yd 0
    set expected-demand-De 1
    set desired-labor-force-Ld 0
    set my-employees no-turtles
    set current-numbers-employees-L0 0
    set number-of-vacancies-offered-V 0
    set minimum-wage-W-hat 1
    set wage-offered-Wb 0
    set net-worth-A fn-truncated-normal 6 2
    set total-payroll-W 0
    set loan-B 0
    set my-potential-banks no-turtles
    set my-bank no-turtles
    set inventory-S one-of [0 1]
    set individual-price-P fn-truncated-normal 6 2
    set revenue-R 0
    set retained-profits-pi 0
  ]
  ask workers [
    set employed? false
    set my-potential-firms no-turtles
    set my-firm nobody
    set contract 0
    set income 0
    set savings fn-truncated-normal 6 2
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
  ]
  set average-price-list array:from-list n-values 4 [6]
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
  if ticks >= 1000 [stop]
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
  adapt-individual-price
  adapt-expected-demand
  ask firms [
    set desired-production-Yd expected-demand-De; submodel 2
  ]
  array:set average-price-list (ticks mod 4) mean [individual-price-P] of firms
end

to adapt-individual-price; submodel 27 y 28
  ask firms [
    let minimum-price-Pl ifelse-value (production-Y > 0)[( total-payroll-W + amount-of-Interest-to-pay ) / production-Y] [0]
    if (inventory-S = 0 and individual-price-P <  average-market-price)
    [
      set individual-price-P max(list minimum-price-Pl (individual-price-P * (1 + price-shock-eta)))
    ]
    if (inventory-S > 0 and individual-price-P >= average-market-price)
    [
      set individual-price-P max(list minimum-price-Pl (individual-price-P * (1 - price-shock-eta)))
    ]
  ]
end

to adapt-expected-demand; submodel 29 y 30
  ask firms [
    if (inventory-S = 0 and individual-price-P >= average-market-price)
    [
      set expected-demand-De round ( production-Y * (1 + production-shock-rho))
    ]
    if (inventory-S > 0 and individual-price-P < average-market-price)
    [
      set expected-demand-De round (production-Y * (1 - production-shock-rho))
    ]
  ]
end
;;;;;;;;;; to labor-market  ;;;;;;;;;;
to labor-market
  ask firms [
    set desired-labor-force-Ld round (desired-production-Yd / labor-productivity-alpha); submodel 3
    set current-numbers-employees-L0 count my-employees; summodel 4
    set number-of-vacancies-offered-V max(list (desired-labor-force-Ld - current-numbers-employees-L0) 0 ); submodel 5
    if (ticks > 0 and ticks mod 4 = 0 )
    [
      set minimum-wage-W-hat minimum-wage-W-hat; submodel 6
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
        set contract random-poisson 10
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
      set loan-B max (list (total-payroll-W - net-worth-A) 0); submodel 10
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
    let leverage-of-borrower [loan-B] of my-best-borrower / [net-worth-A] of my-best-borrower; submodel 19
    ;submodel 17
    let contractual-interest interest-rate-policy-rbar * (1 + ([operational-interest-rate] of self * leverage-of-borrower))
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
end

;;;;;;;;;; to goods-market  ;;;;;;;;;;
to goods-market
  let average-savings mean [savings] of workers
  ask workers[
    set wealth income + savings
    set propensity-to-consume-c 1 / (1 + (fn-tanh (savings / average-savings)) ^ beta)
    set savings savings + (1 - propensity-to-consume-c) * income
    let money-to-consume propensity-to-consume-c * wealth
    set my-stores (turtle-set my-large-store n-of (goods-market-Z - count (turtle-set my-large-store)) firms)
    set my-large-store max-one-of my-stores [production-Y]
    buying-step goods-market-Z money-to-consume
  ]
end

to buying-step [trials money]; workers procedure
  while [trials > 0 and money > 0][
    let my-cheapest-store min-one-of my-stores [individual-price-P]
    let posible-goods-to-buy min list money [inventory-S] of my-cheapest-store
    set money money - posible-goods-to-buy
    set wealth wealth - posible-goods-to-buy
    ask my-cheapest-store [
      set inventory-S inventory-S - posible-goods-to-buy
    ]
    set trials trials - 1
    set my-cheapest-store max-n-of trials my-stores [individual-price-P]
  ]
end
;;;;;;;;;; to firms-pay  ;;;;;;;;;;
to firms-pay
  ask firms [
    set revenue-R individual-price-P * production-Y
    set gross-profits revenue-R - ( total-payroll-W )
    let principal-and-Interest amount-of-Interest-to-pay
    ifelse (gross-profits > amount-of-Interest-to-pay)[; submodel 42
      if is-bank? my-bank [ ; Check why a dead bank is arriving here!
        ask my-bank [
          set patrimonial-base-E patrimonial-base-E + principal-and-Interest
        ]
      ]
    ][
      let bank-financing ifelse-value (net-worth-A != 0 ) [loan-B / net-worth-A][1]
      let bad-debt-amount bank-financing * net-worth-A
      if is-bank? my-bank [
        ask my-bank [
          set patrimonial-base-E patrimonial-base-E - bad-debt-amount
        ]
      ]
    ]
    set net-profits gross-profits - amount-of-Interest-to-pay
    if (net-profits > 0)[
      set retained-profits-pi (1 - dividends-delta ) * net-profits
    ]
  ]
end

;;;;;;;;;; to firms-banks-survive ;;;;;;;;;;
to firms-banks-survive
  ask firms [
    set net-worth-A net-worth-A + retained-profits-pi
    if (net-worth-A < 0)[
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
      set my-bank no-turtles
    ]
    die
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
      set production-Y mean [production-Y] of incumbent-firms
      set labor-productivity-alpha 1
      set my-employees no-turtles
      set minimum-wage-W-hat minimum-wage-W-hat
      set net-worth-A mean [net-worth-A] of incumbent-firms
      set my-potential-banks no-turtles
      set my-bank no-turtles
      set inventory-S one-of [0 1]
      set individual-price-P mean [individual-price-P] of incumbent-firms
    ]
  ]

  if (count banks < number-of-firms / 10)[
    let needed-banks (number-of-firms / 10) - count banks
    let this-bank one-of banks
    ask this-bank [
      let me nobody
      hatch-banks needed-banks [
        set me self
        rt random 360
        fd (random 10) + 1
        set my-borrowing-firms no-turtles
      ]
    ]
  ]
end

; utilities

to-report average-market-price
  report mean [individual-price-P] of firms
end

to-report fn-tanh [a]
  report (exp (2 * a) - 1) / (exp (2 * a) + 1)
end

to-report fn-minimum-wage-W-hat
  report 1
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
  report ifelse-value (normal-value > (m - sd)) [normal-value][m - sd]
end

; observation
to-report logarithm-of-real-GDP

end

to unemployment-rate
  let unemployed count workers with [not employed?]
  plot unemployed / count workers
end

to plot-quarterly-inflation
  let actual-price array:item average-price-list (ticks mod 4)
  let previous-price array:item average-price-list ((ticks - 1) mod 4)
  plot ((actual-price - previous-price) / actual-price) * 100
end

to-report annualized-inflation
  let i 0
  let quarter-inflation 0
  let yearly-inflation array:from-list n-values 4 [1]
  while [i < 4][
    let actual-price array:item average-price-list (i mod 4)
    let previous-price array:item average-price-list ((i - 1) mod 4)
    set quarter-inflation ((actual-price - previous-price) / actual-price) + 1
    array:set yearly-inflation i quarter-inflation
    set i i + 1
  ]
  report ((reduce * array:to-list yearly-inflation) - 1)
end

to plot-annualized-inflation
  plot annualized-inflation * 100
end

to-report fn-annual-inflation-rate
  let annual-prices array:to-list average-price-list
  report (reduce * annual-prices) - 1
end

to-report average-real-interest-rate

end

to-report number-of-firms-which-go-bankrupt

end

to-report vacancy-rate

end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
642
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
21
10
94
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
101
10
164
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
10
1000
100.0
5
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
0
0.5
0.05
0.05
1
NIL
HORIZONTAL

SLIDER
2
121
195
154
interest-shock-phi
interest-shock-phi
0
0.5
0.1
0.05
1
NIL
HORIZONTAL

SLIDER
2
157
196
190
price-shock-eta
price-shock-eta
0
0.5
0.1
0.05
1
NIL
HORIZONTAL

SLIDER
2
194
196
227
production-shock-rho
production-shock-rho
0
0.5
0.1
0.05
1
NIL
HORIZONTAL

SLIDER
2
231
196
264
v
v
0
1
0.5
1
1
NIL
HORIZONTAL

SLIDER
2
268
197
301
labor-market-M
labor-market-M
1
6
4.0
1
1
trials
HORIZONTAL

PLOT
655
10
858
130
Unemployment rate
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nunemployment-rate"
"pen-1" 1.0 0 -7500403 true "" "plot 0"

SLIDER
2
303
198
336
credit-market-H
credit-market-H
1
5
2.0
1
1
trials
HORIZONTAL

SLIDER
2
338
198
371
goods-market-Z
goods-market-Z
1
6
2.0
1
1
trials
HORIZONTAL

SLIDER
3
374
198
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
3
410
198
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
862
10
1065
130
Net worth distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "set-histogram-num-bars 8\nset-plot-x-range floor min [net-worth-A] of firms ceiling max [net-worth-A] of firms\nhistogram  [net-worth-A] of firms"

PLOT
1068
10
1271
130
log (Net worth) of firms
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nset-plot-y-range 0 ceiling log max [net-worth-A] of firms 10\nplot log mean [net-worth-A] of firms 10"
"pen-1" 1.0 2 -2674135 true "set-plot-pen-mode 2" "plot log min [net-worth-A] of firms 10"
"pen-2" 1.0 2 -13840069 true "set-plot-pen-mode 2" "plot log max [net-worth-A] of firms 10"

PLOT
655
133
858
253
Propensity to consume
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nplot mean [propensity-to-consume-c] of workers"
"pen-1" 1.0 2 -2674135 true "" "plot min [propensity-to-consume-c] of workers"
"pen-2" 1.0 2 -13345367 true "" "plot max [propensity-to-consume-c] of workers"

PLOT
862
133
1066
253
Quarterly inflation
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks + 5)\nplot-quarterly-inflation"
"pen-1" 1.0 2 -5987164 true "" "plot 0"

PLOT
1069
133
1269
253
Annualized inflation
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "set-plot-x-range 0 (ticks / 4) + 1\nif (ticks > 0 and ticks mod 4 = 0 )[\nplot-annualized-inflation]"
"pen-1" 1.0 0 -7500403 true "" "plot 0"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
0
@#$#@#$#@
