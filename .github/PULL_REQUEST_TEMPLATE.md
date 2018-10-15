## Contributor Comments
[Please place any comments here.  A description of the problem/enhancement, how to reproduce the issue, your testing methodology, etc.]


## Pull Request Checklist

Thank you for submitting a contribution to Apache Metron's kafka log writing plugin for Bro.

In order to streamline the review of the contribution we ask you follow these guidelines and ask you to double check the following:

### For all changes:
- [ ] Is there a JIRA ticket associated with this PR? If not one needs to be created at [Metron Jira](https://issues.apache.org/jira/browse/METRON/?selectedTab=com.atlassian.jira.jira-projects-plugin:summary-panel).
- [ ] Does your PR title start with METRON-XXXX where XXXX is the JIRA number you are trying to resolve? Pay particular attention to the hyphen "-" character.
- [ ] Has your PR been rebased against the latest commit within the target branch (typically master)?

### For code changes:
- [ ] Have you included steps to reproduce the behavior or problem that is being changed or addressed?
- [ ] Have you included steps or a guide to how the change may be verified and tested manually?
- [ ] Have you ensured that the full suite of tests and checks have been executed via:
  ```
  bro-pkg install $GITHUB_USERNAME/metron-bro-plugin-kafka --version $BRANCH
  ```
- [ ] Have you written or updated unit tests and or integration tests to verify your changes?
- [ ] If adding new dependencies to the code, are these dependencies licensed in a way that is compatible for inclusion under [ASF 2.0](http://www.apache.org/legal/resolved.html#category-a)?
- [ ] Have you verified the basic functionality of the build by building and running locally with Apache Metron's [Vagrant full-dev environment](https://github.com/apache/metron/tree/master/metron-deployment/development/centos6) or the equivalent?

