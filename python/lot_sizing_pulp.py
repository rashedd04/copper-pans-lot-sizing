import pulp

T = 10
K = 2
U = 34  

d = [
  [5, 10],
  [15, 5],
  [10, 0],
  [60, 20],
  [10, 5],
  [30, 5],
  [10, 5],
  [45, 0],
  [10, 60],
  [0, 10]
]

alpha = [1.0, 1.5]
c = [7.0, 4.0, 9.0, 5.0, 4.0, 9.0, 9.0, 4.0, 5.0, 7.0]
h = [3.0, 1.0, 2.0, 4.0, 6.0, 6.0, 6.0, 3.0, 2.0, 3.0]
beta = [2.5, 2.0]

# --- Model creation ---
model = pulp.LpProblem("Production_Planning", pulp.LpMinimize)

# Decision variables
x = pulp.LpVariable.dicts("x", (range(T), range(K)), lowBound=0, cat="Integer")
s = pulp.LpVariable.dicts("s", (range(T), range(K)), lowBound=0, cat="Integer")

# --- Objective function ---
model += pulp.lpSum(
    x[t][k] * alpha[k] * c[t] + s[t][k] * beta[k] * h[t]
    for t in range(T) for k in range(K)
)

# --- Constraints ---
# Capacity limit
for t in range(T):
    model += pulp.lpSum(x[t][k] for k in range(K)) <= U, f"Capacity_{t}"

# Demand satisfaction
for t in range(T):
    for k in range(K):
        if t == 0:
            model += x[t][k] >= d[t][k], f"Initial_Demand_{t}_{k}"
        else:
            model += x[t][k] + s[t-1][k] >= d[t][k], f"Demand_{t}_{k}"

# Inventory balance
for t in range(T):
    for k in range(K):
        if t == 0:
            model += s[t][k] == x[t][k] - d[t][k], f"Initial_Stock_{t}_{k}"
        else:
            model += s[t][k] == s[t-1][k] + x[t][k] - d[t][k], f"Stock_{t}_{k}"

# --- Solve model ---
model.solve(pulp.PULP_CBC_CMD(msg=True))

# --- Display results ---
print("\n--- Optimal Solution ---")
if pulp.LpStatus[model.status] == "Optimal":
    print(f"Total Cost: {pulp.value(model.objective):.2f}\n")
    for t in range(T):
        for k in range(K):
            print(f"x[{t+1},{k+1}] = {x[t][k].value():.2f}\t s[{t+1},{k+1}] = {s[t][k].value():.2f}")
else:
    print("No optimal solution found.")
