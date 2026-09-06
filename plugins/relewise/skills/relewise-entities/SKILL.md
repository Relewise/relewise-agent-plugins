---
name: relewise-entities
description: Find and inspect Relewise Products, Product Variants, Content, Brands, Product Categories, and Content Categories through the relewise-agent CLI. Use when a user wants to locate entities or review their stored properties and Data Values.
---

# Relewise Entities

When `../../scripts/relewise-agent` exists relative to this file, resolve it to an absolute path and use that executable. Otherwise, use `relewise-agent` from `PATH`.

Use `relewise-agent` for execution. Do not construct Agent Gateway URLs, send HTTP directly, or ask for a PAT in chat. Discover and validate the intended Dataset before making an Entities call. These operations are read-only.

## Find an entity

- When the exact entity ID is known, inspect the relevant get operation with `schema`, then execute it with `call`.
- When an ID is unknown, use the matching search operation with a specific term, then retrieve the selected result with its get operation when complete stored properties are needed.
- A Product Variant requires both its parent Product ID and its Variant ID. Product search does not search Variant Data Values.
- Product Category and Content Category searches return category entities, not the Products or Content assigned to them.

Searches are bounded and default to excluding disabled entities. Use a language only when needed for multilingual matching, and preserve its case. Narrow an ambiguous search instead of presenting an undifferentiated result set.

## Interpret entity data

Preserve entity IDs and the association between a Product and its Variants. Treat Data Key names, language identifiers, currency identifiers, and returned values as case-sensitive stored data. Do not invent missing fields or interpret the absence of a Data Value as proof that the value does not exist in another language, currency, or entity scope.

State the Dataset and entity type with the result. Use display names for readability, but include IDs when they identify the selected entity or disambiguate similar results.
