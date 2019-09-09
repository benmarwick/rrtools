# Contributing

We love pull requests from everyone. By participating in this project, you
agree to abide by our [code of conduct](CONDUCT.md).

## Getting Started

* Make sure you have a [{{{gitRemoteService}}} account](https://{{{gitRemoteService}}}.com/signup/free). If you are not familar with git and {{{gitRemoteService}}}, take a look at <http://happygitwithr.com/> to get started.
* [Submit a post for your issue](https://{{{gitRemoteService}}}.com/{{{username}}}/{{{repo}}}/issues/), assuming one does not already exist.
  * Clearly describe your issue, including steps to reproduce when it is a bug, or some justification for a proposed improvement.
* [Fork](https://{{{gitRemoteService}}}.com/{{{username}}}/{{{repo}}}/#fork-destination-box) the repository on {{{gitRemoteService}}} to make a copy of the repository on your account. Or use this line in your shell terminal:

    `git clone git@{{{gitRemoteService}}}.com:{{{username}}}/{{{repo}}}.git`
    
## Making changes

* Edit the files, save often, and make commits of logical units, where each commit indicates one concept
* Follow our [style guide](http://adv-r.had.co.nz/Style.html).
* Make sure you write [good commit messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).
* Make sure you have added the necessary tests for your code changes.
* Run _all_ the tests using `devtools::check()` to assure nothing else was accidentally broken.
* If you need help or unsure about anything, post an update to [your issue](https://{{{gitRemoteService}}}.com/{{{username}}}/{{{repo}}}/issues/).

## Submitting your changes

Push to your fork and [submit a pull request](https://{{{gitRemoteService}}}.com/{{{username}}}/{{{repo}}}/compare/).

At this point you're waiting on us. We like to at least comment on pull requests
within a few days (and, typically, one business day). We may suggest
some changes or improvements or alternatives.

Some things you can do that will increase the chance that your pull request is accepted:

* Engage in discussion on [your issue](https://{{{gitRemoteService}}}.com/{{{username}}}/{{{repo}}}/issues/).
* Be familiar with the backround literature cited in the [README](README.Rmd)
* Write tests that pass.
* Follow our [code style guide](http://adv-r.had.co.nz/Style.html).
* Write a [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).



