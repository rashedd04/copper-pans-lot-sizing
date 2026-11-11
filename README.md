# Copper pans: multi-product lot sizing with LP and MIP

Production planning for a workshop that makes several types of copper pans under a daily capacity limit, modelled as a linear program and then as four mixed-integer formulations of increasing strength. Written in OPL for IBM CPLEX, with a small PuLP version in Python.

Team case study for the course "Operations Research for Logistics" at Grenoble INP – Génie Industriel (November–December 2025).

## The problem

A workshop produces K types of pans over T days.

- Daily production is limited to U units, all types together.
- Making one unit of type k takes α_k hours, paid c_t per hour on day t.
- Unsold units are stored; each stored unit of type k costs β_k minutes of inspection every evening, paid h_t per minute.
- Second part: if anything is in stock at the end of day t, a night guard is paid a fixed fee f_t.

Goal: meet all demand at minimum total cost.

## Models

| File | Model | Idea |
| --- | --- | --- |
| `opl/modele_P.mod` | (P), linear program | Production and stock variables, flow balance per type and day, shared capacity. Prints the primal plan and the dual values of the capacity constraints. |
| `opl/modele_IP1.mod` | (IP1) | Adds a binary "guard needed" variable per day, linked to total stock with a big-M (remaining future demand). |
| `opl/modele_IP2.mod` | (IP2) | Same, with one big-M constraint per pan type, so each bound is tighter. |
| `opl/modele_IP3.mod` | (IP3), extended formulation | New variables w[k][t][p]: units of type k made on day t to serve the demand of day p. The guard constraint is bounded by a single day's demand, so no big-M is needed. |
| `opl/modele_IP4.mod` | (IP4) | IP3 restricted to a 14-day storage window, which removes most w variables. |
| `python/lot_sizing_pulp.py` | (P) in PuLP | The example instance with integer variables and U = 34, solved with CBC. |

The team also proved that (P) is an ideal formulation (totally unimodular constraint matrix), wrote its dual, and used the dual values to explain the slope of the cost curve below.

## Results

All figures are from the team's CPLEX runs (`results/results.xlsx`), except the PuLP line.

### Linear program (P)

| Instance | Types × days | Variables | Constraints | Optimal cost | Time (s) |
| --- | --- | --- | --- | --- | --- |
| exemple | 2 × 10 | 40 | 30 | 2,657.5 | 0.1 |
| inst_25_200 | 25 × 200 | 10,000 | 5,200 | 2,251,877.75 | 3.0 |
| inst_100_500 | 100 × 500 | 100,000 | 50,500 | 5,434,510 | 3.5 |
| inst_50_1000 | 50 × 1000 | 100,000 | 51,000 | 11,265,051 | 3.3 |

Solutions are integer on every instance without integrality constraints, as the ideal-formulation proof predicts.

### Cost as a function of capacity

On the example, the optimal cost z*(U) was computed for every U from 35 to 85. It is decreasing, convex and piecewise linear:

| Capacity U | 35 | 40 | 50 | 60 | 70 | 80 to 85 |
| --- | --- | --- | --- | --- | --- | --- |
| Optimal cost | 4,062.5 | 3,352.5 | 2,657.5 | 2,230 | 2,140 | 2,095 |

One more unit of capacity saves 252 at U = 35, 55 around U = 50 and nothing from U = 80. With U = 30 the problem is infeasible: demand over the first four days is 125 units against 120 of capacity.

The PuLP script solves U = 34 with integer variables and finds a cost of 4,318.5 (`results/pulp_output_U34.txt`). Run with U = 50 it returns 2,657.5, the same as the OPL model.

### Comparing the four MIP formulations

Branch-and-bound with CPLEX presolve, cuts and heuristics switched off (see `opl/main_IP.mod`), 60-second limit.

| Instance (types × days) | Measure | IP1 | IP2 | IP3 | IP4 |
| --- | --- | --- | --- | --- | --- |
| inst_A (6 × 60), optimum 467,060.75 | Root LP bound | 392,198 | 400,813 | 444,112 | 444,329 |
| | Nodes | 312,529 | 206,497 | 713 | 945 |
| | Time (s) | 23.9 | 14.6 | 3.0 | 2.7 |
| inst_B (10 × 60), optimum 427,879.75 | Root LP bound | 367,880 | 379,830 | 421,699 | 421,699 |
| | Nodes | 1,031,593 | 483,182 | 124 | 95 |
| | Time (s) | 60 (gap 0.8%) | 39.6 | 1.5 | 0.7 |
| inst_C (6 × 100), optimum 672,488.25 | Root LP bound | 522,111 | 535,999 | 630,089 | 630,089 |
| | Nodes | 1,135,569 | 832,322 | 70 | 72 |
| | Time (s) | 60 (gap 2.3%) | 60 (gap 0.8%) | 4.2 | 0.9 |
| inst_D (6 × 100), optimum 620,822 | Root LP bound | 447,161 | 470,569 | 615,056 | 615,056 |
| | Nodes | 1,269,961 | 981,072 | 30 | 28 |
| | Time (s) | 60 (gap 10.9%) | 60 (gap 8.1%) | 2.7 | 0.5 |

The extended formulation has about 25 times more variables than the compact ones on the 100-day instances (31,600 against 1,300), but its LP bound is so much tighter that branch-and-bound needs tens of nodes where the big-M models need around a million. The 14-day window then cuts the variables by about two thirds (9,670) and the time by a factor of about 5 on those instances.

## Run it

OPL models need IBM ILOG CPLEX Optimization Studio (free academic edition available):

```bash
oplrun opl/modele_P.mod   instances/P/exemple.dat
oplrun opl/modele_IP3.mod instances/IP/inst_A.dat
```

To reproduce the capacity curve, uncomment the `include "main_P_test_U.mod";` line at the top of `modele_P.mod`.

Python version:

```bash
pip install -r requirements.txt
python python/lot_sizing_pulp.py
```

## Credits

- **Team:** built by a team of three students; Ahmed Rashed is the member publishing this repository.
- **Case study and data:** "Production de casseroles en cuivre" by O. Briant, N. Catusse, M. Chaikovskaia, Q. Christ and B. Penz (Grenoble INP – Génie Industriel, 2025–2026). The harness files `main_IP.mod` and `main_P_test_U.mod`, the model file skeletons and all files in `instances/` were provided by the course staff and are not covered by the licence of this repository.

## Licence

MIT for the team's models and scripts (see `LICENSE`).
