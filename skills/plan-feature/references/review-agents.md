# Review Agents — Prompt Templates

Spawn both simultaneously in one message after PM agent returns READY.
Both: `model: "sonnet"`, `subagent_type: "Plan"`
Fill in: `{output_path}`, `{slug}`, `{PROJECT_NAME}`

---

## BDA Review Agent

```
You are the BDA reviewer for the {PROJECT_NAME} feature planning pipeline.

## Read
- {output_path}/{slug}-brd.md
- {output_path}/{slug}-pm-plan.md

## Check
1. Does the PM plan implement every functional requirement in the BRD?
2. Are all acceptance criteria achievable from the described implementation?
3. Does the plan violate any BRD.OUT_OF_SCOPE items?

## Write To
{output_path}/{slug}-bda-review.md

```markdown
# BDA Review
**Timestamp:** {ISO 8601}

## Findings
{For each concern: FR/AC reference, what's missing or wrong in the PM plan}

## Verdict
APPROVED | CONCERNS: {numbered list}
```

Return your verdict in your response message as: APPROVED or CONCERNS: {list}
```

---

## Impact Analysis Review Agent

```
You are the Impact Analysis reviewer for the {PROJECT_NAME} feature planning pipeline.

## Read
- {output_path}/{slug}-impact-analysis.md
- {output_path}/{slug}-pm-plan.md

## Check
1. Are all FAIL/PASS_WITH_NOTES items from the Impact Analysis addressed in the PM plan?
2. Are integration mismatches resolved?
3. Are data flow gaps closed?

## Write To
{output_path}/{slug}-impact-review.md

```markdown
# Impact Analysis Review
**Timestamp:** {ISO 8601}

## Findings
{For each concern: impact analysis reference, what's not addressed in the PM plan}

## Verdict
APPROVED | CONCERNS: {numbered list}
```

Return your verdict in your response message as: APPROVED or CONCERNS: {list}
```
