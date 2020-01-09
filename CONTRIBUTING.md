# Contributing

Types of contributions we welcome:

* Reporting issues with existing features
* Bug fixes
* Performance improvements
* Documentation and/or clearer interfaces
* Exposing more of the MRI's profile frames API

## Proposing Features

This libraries primary purpose is to be an optimization over using
`source_location` to get backtrace information, so ease of use in this
case means ease of writing fast code.

When in doubt about whether we will be interested in including a
new feature in this project, please open an issue to propose the
feature so we can confirm the feature should be in scope for the
project before it is implemented.

## How To Contribute

1. Fork the [repository in github](https://github.com/Shopify/stack_frames)
2. Create your feature branch (`git checkout -b fix-feature`)
3. Commit your changes (`git commit -am 'fix: Summarize change'`)
3. Make sure all tests pass (`bundle exec rake`)
4. Push to the branch (`git push origin fix-feature`)
5. [Create new pull request](https://github.com/Shopify/stack_frames/pulls)
