# External Module Risk: {{FEATURE_TITLE}}

## Status

Status: pending

source_type: public
risk_level: critical
human_approval_required: true
allowed_mode: reference-only
forbidden_modes: vendor,direct-copy

## Sensitive Domains

- auth
- user
- permission
- payment
- crypto
- file-upload
- admin-account

## Assessment

- TBD

## Completion Checklist

- [ ] Public modules are treated as reference-only by default
- [ ] Vendor/direct-copy is forbidden unless a human explicitly approves an exception
- [ ] Sensitive domain impact is documented
- [ ] Remaining risk is explicit
