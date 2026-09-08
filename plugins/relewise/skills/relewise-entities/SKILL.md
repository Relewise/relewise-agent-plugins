---
name: relewise-entities
metadata:
  relewise-execution-skill: relewise-agent-gateway
description: Find and inspect Relewise Products, Product Variants, Content, Brands, Product Categories, and Content Categories. Use when a user wants to locate entities or review their stored properties and Data Values.
---

# Relewise Entities

Before any Agent Gateway call, activate and follow the installed `relewise-agent-gateway` skill from this plugin. Pass it the selected REST operation ID and/or MCP tool plus validated parameters; do not resolve the CLI, choose a transport, or handle authentication in this domain skill. Discover and validate the intended Dataset before making an Entities call. These operations are read-only.

## Find an entity

- When the exact entity ID is known, inspect the selected transport's get schema, then execute that operation or related MCP tool.
- When an ID is unknown, use the matching search capability with a specific term, then retrieve the selected result with its get capability when complete stored properties are needed.
- A Product Variant requires both its parent Product ID and its Variant ID. Product search does not search Variant Data Values.
- Product Category and Content Category searches return category entities, not the Products or Content assigned to them.

Searches are bounded and default to excluding disabled entities. Use a language only when needed for multilingual matching, and preserve its case. Narrow an ambiguous search instead of presenting an undifferentiated result set.

## Interpret entity data

Preserve entity IDs and the association between a Product and its Variants. Treat Data Key names, language identifiers, currency identifiers, and returned values as case-sensitive stored data. Do not invent missing fields or interpret the absence of a Data Value as proof that the value does not exist in another language, currency, or entity scope.

State the Dataset and entity type with the result. Use display names for readability, but include IDs when they identify the selected entity or disambiguate similar results.
