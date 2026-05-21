# Superpowers Adapter

This adapter maps role prompts to Superpowers-style methods:

- planning: writing-plans
- implementation: subagent-driven-development
- testing: test-driven-development
- review: requesting-code-review
- fixes: systematic-debugging
- completion: finishing-a-development-branch

The minimum integration encodes these methods in role contracts. A later
adapter can import installed Superpowers skills directly.
