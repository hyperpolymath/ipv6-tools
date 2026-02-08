# Tri-Perimeter Contribution Framework (TPCF)

## Overview

The IPv6-Only Tools project uses the **Tri-Perimeter Contribution Framework (TPCF)**, a graduated trust model that balances openness with security. This framework defines three distinct contribution perimeters, each with different access levels, responsibilities, and trust requirements.

## The Three Perimeters

### Perimeter 3: Community Sandbox (Outer Perimeter)

**Trust Level:** Open to all
**Current Status:** ✅ ACTIVE

**Purpose:**
- Encourage widespread participation
- Lower barriers to entry
- Foster community growth
- Enable experimentation

**What You Can Do:**
- Open issues and feature requests
- Submit documentation fixes
- Contribute examples and tutorials
- Participate in discussions
- Report bugs
- Suggest improvements
- Review pull requests (informally)

**Requirements:**
- GitHub account
- Agreement to Code of Conduct
- No special permissions needed

**Review Process:**
- Community review encouraged
- Maintainer approval required for merge
- Fast turnaround for simple changes (< 48 hours)
- Detailed feedback provided

**Typical Contributions:**
- Documentation improvements
- Example code
- Test cases
- Bug reports
- Feature proposals
- Translations (future)

### Perimeter 2: Verified Contributors (Middle Perimeter)

**Trust Level:** Established contributors
**Current Status:** 🔜 PLANNED (not yet active)

**Purpose:**
- Recognize regular contributors
- Streamline contribution process
- Enable more substantial changes
- Build trusted community

**What You Can Do:**
- All Perimeter 3 privileges
- Direct push to feature branches
- Merge simple pull requests
- Triage issues
- Label and prioritize
- Help onboard new contributors
- Participate in design discussions

**Requirements to Join:**
- 5+ merged contributions in Perimeter 3
- Demonstrated understanding of project goals
- Positive community interactions
- Maintainer nomination
- Background check (for security-sensitive areas)

**Review Process:**
- Peer review by other P2 contributors
- Maintainer spot-check
- More autonomy for routine changes
- Expedited merge for trusted contributors

**Responsibilities:**
- Mentor P3 contributors
- Review pull requests
- Maintain code quality
- Follow security practices
- Uphold Code of Conduct

### Perimeter 1: Core Team (Inner Perimeter)

**Trust Level:** Full trust
**Current Status:** ✅ ACTIVE (Lead Maintainer only)

**Purpose:**
- Project governance
- Security-critical decisions
- Release management
- Strategic direction

**What You Can Do:**
- All Perimeter 2 privileges
- Merge to main branch
- Create releases
- Manage security issues
- Access credentials and secrets
- Make architectural decisions
- Invite P2 contributors
- Handle Code of Conduct violations

**Requirements to Join:**
- Significant long-term contributions
- Deep technical expertise
- Proven judgment and responsibility
- Unanimous approval by existing P1 members
- Enhanced background verification
- Signing authority (GPG keys)

**Responsibilities:**
- Project leadership
- Security incident response
- Release quality assurance
- Community health
- Legal compliance
- Conflict resolution

**Current Members:**
- Hyperpolymath (Lead Maintainer)

## Contribution Workflow by Perimeter

### For Perimeter 3 (Community Sandbox)

1. Fork the repository
2. Create a feature branch
3. Make changes with tests and docs
4. Submit pull request
5. Respond to review feedback
6. Maintainer merges (or P2 for simple changes)

### For Perimeter 2 (Verified Contributors)

1. Create branch in main repo (or fork)
2. Make changes following guidelines
3. Self-review and test
4. Create pull request
5. Peer review by another P2
6. Merge when approved

### For Perimeter 1 (Core Team)

1. Discuss major changes in advance
2. Create branch
3. Implement with full test coverage
4. Security review for sensitive changes
5. Merge after approval
6. Monitor post-merge

## Advancing Through Perimeters

### From P3 to P2

**Automatic Criteria** (any of):
- 10+ merged pull requests
- 3+ months of regular contribution
- Maintained significant feature

**Plus Evidence Of:**
- Technical competence
- Good communication
- Community respect
- Alignment with project values

**Process:**
1. Self-nominate or maintainer nominates
2. Review contribution history
3. Existing P1/P2 members vote
4. Simple majority required
5. Onboarding and access granted

### From P2 to P1

**Criteria:**
- 6+ months as P2 contributor
- Leadership demonstrated
- Security awareness proven
- Deep project knowledge
- Community trust earned

**Process:**
1. Nomination by existing P1
2. Unanimous P1 approval
3. Background verification
4. Formal onboarding
5. Gradual privilege escalation

## Security Implications

### Perimeter-Specific Security

**P3:** Untrusted
- All contributions reviewed
- No direct repository access
- Cannot trigger deployments
- Limited issue permissions

**P2:** Trusted for routine work
- Can review code
- Cannot merge security-sensitive changes
- No access to secrets
- Subject to audit

**P1:** Fully trusted
- Full repository access
- Security issue access
- Deployment permissions
- Signing authority

### Incident Response

If security breach occurs:
1. **P3:** Contributor account compromised → revoke fork access, investigate
2. **P2:** Contributor account compromised → immediate revocation, audit all recent changes
3. **P1:** Maintainer account compromised → emergency response, rotate all secrets, public disclosure

## Technical Implementation

### GitHub Permissions

**P3:**
- Role: External contributor
- Access: Fork only

**P2:**
- Role: Triage + Write (limited)
- Access: Direct branch creation
- Restrictions: No main/release branches

**P1:**
- Role: Admin
- Access: Full
- MFA: Required
- GPG: Required

### Branch Protection

- **main:** P1 only, required reviews
- **release/*:** P1 only
- **feature/*:** P2+ can create
- **docs/*:** P3 can contribute

### CI/CD

- **P3:** Tests run, no deployments
- **P2:** Tests + build artifacts
- **P1:** Full deployment pipeline

## Comparison with Traditional Models

| Aspect | Traditional OSS | TPCF |
|--------|----------------|------|
| Entry barrier | Low | Low (P3) |
| Trust model | All-or-nothing | Graduated |
| Security | Reactive | Proactive |
| Governance | Implicit | Explicit |
| Scaling | Ad-hoc | Structured |

## Benefits

### For Contributors
- Clear advancement path
- Recognized trust levels
- Appropriate permissions
- Reduced friction at each level

### For Maintainers
- Reduced review burden
- Distributed responsibilities
- Better security posture
- Sustainable governance

### For Users
- Stronger security guarantees
- More stable releases
- Faster bug fixes
- Transparent governance

## FAQ

**Q: Why not just use GitHub's built-in roles?**
A: TPCF adds social/trust dimension beyond technical permissions. It's about community norms, not just access control.

**Q: Can I skip straight to P2?**
A: No. Everyone starts at P3 to build trust and familiarity.

**Q: How long does P3→P2 take?**
A: Varies. Quality matters more than quantity. Typically 2-6 months of active contribution.

**Q: What if I disagree with perimeter placement?**
A: Contact maintainers at maintainers@ipv6-only.example.com. Decisions are reviewable.

**Q: Can perimeter level be revoked?**
A: Yes, for Code of Conduct violations, security incidents, or extended inactivity (with warning).

## Related Documents

- **CODE_OF_CONDUCT.md**: Community standards
- **CONTRIBUTING.md**: How to contribute
- **MAINTAINERS.md**: Current maintainers
- **security.md**: Security policies

## References

- [Academic Paper on TPCF](docs/academic-papers.md#tpcf-graduated-trust-model)
- [Rhodium Standard Repository Framework](https://github.com/hyperpolymath/rhodium)

## Updates

This framework evolves with the project. Suggestions welcome via GitHub Discussions.

Last updated: 2024-11-22
