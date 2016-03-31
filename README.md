Buildkite Metadata Finder
===

Have so many projects that it's hard to keep track which projects use which agent metadata tags?
What happens if you upgrade an agent's metadata tag and your old projects hang forever?
e.g. you upgrade a node with the tag `xcode=7.1` to `xcode=7.3`?

This will help you identify the projects that need updating.

Setup
===
1. Run `bundle install`
2. Make sure `GITHUB_TOKEN`, `BUILDKITE_ORG` and `BUILDKITE_API_TOKEN` are set.
  - You'll need `read_pipelines` permissions to work.

Usage
===

Find by one tag:

`./metadata_finder xcode=7.1`

Find by "true" tags:

`./metadata_finder ios` (will match `ios=true` or `ios=1`)

Find by many tags:

`./metadata_finder xcode=7.1 ios`

Example output
===
`./metadata_finder xcode=7.1 ios`

```
Finding all projects with metadata xcode=7.1,ios
================================================
Couldn't find .buildkite/pipeline.yml in git@github.com:Example/example.git

Name: iOS project that uses Xcode 7.1
Repo: git@github.com:Example/ios-xcode-71.git
Url: https://buildkite.com/example/ios-xcode-71
```

Advanced usage
===
Include `metadata_finder` and call `MetadataFinder.find(array_of_metadata)`. It will return a hash from the Buildkite API.
