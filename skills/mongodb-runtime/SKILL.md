---
name: mongodb-runtime
description: "Runtime guidance for common MongoDB work. Use for document modeling, repository code, aggregation, and index design. Prefer this over the full MongoDB reference for routine tasks."
applyTo: "**/*mongo*.py,**/*mongo*.ts,**/*repository*.py,**/*repository*.ts,**/*model*.py,**/*model*.ts,**/*schema*.py,**/*schema*.ts"
---

# MongoDB Runtime

Use this skill for routine MongoDB work. Load the full `mongodb-patterns` reference only when this card is insufficient.

## Use For

* Document modeling
* Repository and query code
* Aggregation pipelines
* Basic indexing decisions

## Core Rules

* Embed when data is read together and bounded
* Reference when data grows without bound or changes independently
* Keep documents query-shaped for the main access path
* Index the filter and sort path, not every field
* Keep aggregations readable and stage-focused

## Minimal Checklist

* Model matches the dominant read pattern
* Document size stays bounded
* Query path has supporting indexes
* Repository methods return predictable shapes

## Escalate to Full Reference When

* You need complex embedding vs reference trade-offs
* You are building large aggregation pipelines
* You need ODM-specific patterns
* You are tuning performance under scale