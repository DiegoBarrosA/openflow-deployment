# Commit Message Template

## Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

## Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `config`: Configuration changes
- `chore`: Maintenance tasks
- `deploy`: Deployment changes

## Scope (optional)

- `kube`: Kubernetes/Podman configuration
- `ci`: CI/CD changes
- `docs`: Documentation

## Subject

- Use imperative mood ("add" not "added")
- First letter lowercase
- No period at end
- Maximum 50 characters

## Body (optional)

- Explain what and why
- Reference issues if applicable

## Footer (optional)

- Reference issues: `Closes #123`
- Breaking changes: `BREAKING CHANGE: description`

## AI Assistance Tag

Add at the end of commit message:
```
[AI-Assisted: Composer]
```

## Examples

```
feat(kube): add resource limits to containers

Adds memory and CPU limits to backend and frontend containers
to prevent resource exhaustion.

[AI-Assisted: Composer]
```

```
docs(integration): add backend-frontend integration guide

Documents how backend and frontend repositories integrate
through this deployment repository.

[AI-Assisted: Composer]
```

