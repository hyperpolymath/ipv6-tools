# SPDX-License-Identifier: PMPL-1.0-or-later
# Justfile - IPv6 site enforcer deployment automation

default:
    @just --list

# Deploy IPv6 site enforcer to Kubernetes cluster
deploy:
    @echo "Deploying IPv6 site enforcer..."
    kubectl apply -f manifests/namespace.yaml
    kubectl apply -f manifests/configmap.yaml
    kubectl apply -f manifests/deployment.yaml
    kubectl apply -f manifests/service.yaml
    kubectl apply -f manifests/networkpolicy.yaml
    @echo "IPv6 site enforcer deployed"
    @just status

# Remove IPv6 site enforcer from cluster
undeploy:
    @echo "Removing IPv6 site enforcer..."
    kubectl delete -f manifests/ --ignore-not-found=true
    @echo "Cleanup complete"

# Show deployment status
status:
    @echo "=== IPv6 Site Enforcer Status ==="
    @kubectl -n ipv6-enforcer get all 2>/dev/null || echo "Not deployed yet"

# Watch pod logs
logs:
    kubectl -n ipv6-enforcer logs -f deployment/ipv6-site-enforcer --all-containers=true

# Validate manifests
validate:
    @echo "Validating Kubernetes manifests..."
    @for file in manifests/*.yaml; do \
        echo "Checking $$file..."; \
        kubectl apply --dry-run=client -f $$file > /dev/null; \
    done
    @echo "All manifests valid"

# Test DNS64 resolution
test-dns64 DOMAIN="example.com":
    @echo "Testing DNS64 resolution for {{DOMAIN}}..."
    kubectl -n ipv6-enforcer exec deployment/ipv6-site-enforcer -c unbound-dns64 -- \
        dig AAAA {{DOMAIN}} @127.0.0.1

# Run lint checks
lint:
    @echo "Linting..."

# Run tests
test:
    @echo "Testing..."

# Clean build artifacts
clean:
    @just undeploy

# Format code
fmt:
    @echo "Formatting..."

# Run all checks
check: lint test

# Prepare a release
release VERSION:
    @echo "Releasing {{VERSION}}..."
