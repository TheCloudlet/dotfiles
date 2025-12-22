# Cpp Prompt

## High-Level Guidelines

1. SICP Principle: “Compound Procedures” (Abstraction)

   - Rule: If logic is complex (> 5 lines, involves branching, or loops), DO NOT use inline lambdas or IIFEs.
   - Action: Extract into a private member function (mark const if pure) or a static helper with a descriptive name.
   - Why: Improves stack traces, enables unit testing, and keeps GDB stepping sane.

2. SICP Principle: “Environment Model” (State Isolation)

   - Rule: Avoid top-level variable declarations followed by mutation.
   - Action: Declare variables as late as possible; if scoped to a loop or block, enclose in {}.
   - Const-Correctness: Prefer const locals. For trivial one-liners, inline lambda is fine; otherwise, extract per Rule #1.

3. SICP Principle: “Data-Directed Programming”

   - Rule: Use std::variant or std::optional to model state explicitly—avoid error codes or null pointers.
   - Action: Ensure types reflect the truth of the data.

4. The “No-Magic” Policy

   - Rule: Avoid excessive TMP unless solving a generic architectural problem.
   - Rule: Avoid nested lambdas.
   - Rule: Prefer range-based for over complex std::accumulate if the lambda body is messy.
   - Guideline: Clarity > Cleverness.

## Prompt Guidelines

1. Clarification Question
   - Rule: Ask me clarification questions if you are not under 60% confidence about understanding the requirements
