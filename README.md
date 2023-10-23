# Archived

This repository has been archived. We will continue to develop it at the new location: [govuk-one-login/github-actions][1]

# di-github-actions

This repository contains shared GitHub Actions to be used across Digital Identity projects.

The actions are intended to be lightweight bits of functionality that can be re-used across many workflows.

## Using actions from this repo in other repos

Use the following syntax in your workflow:

`uses: alphagov/di-github-actions/{action-directory}@{ref}`

The `ref` can be a specific branch, git ref or commit SHA.

For instance:

```yaml
jobs:
  job:
    steps:
      - name: Step
        uses: alphagov/di-github-actions/beautify-branch-name@main
```

**Note:** It is preferable to use a specific SHA to prevent workflows from breaking when incompatible changes are
published.

Refer to
the [GitHub Actions docs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsuses)
for more info.

# Adding new actions

- Create a directory at the root of this repository to contain all the action's files
- Follow
  the [documentation to create a composite action](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)
  or copy an existing action and modify as needed
- Add a workflow in the `.github` directory of this repo to test the action's functionality. The test workflow **must**
  have one job called `Test action`. Take a look at the [existing tests](.github/workflows) to see how to test an
  action.

### Guidelines for actions

**Flexibility**

Actions should be flexible enough to be used in different scenarios. Use action inputs to allow its users to customise
behaviour.

**Testing**

Each action should have a workflow associated with it that thoroughly verifies the action's behaviour. To use a specific
action in a test, use the `uses: ./{action-directory}` syntax in the workflow.

Create a workflow in the `.github` directory with a single job named `Test action` - this will ensure the tests will be
required to pass on each pull request before merging is enabled.

Add steps to the job as needed to test the action's behaviour.
