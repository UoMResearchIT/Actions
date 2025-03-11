# Security of the Actions of UoMResearchIT

We take the securing of these actions _very_ seriously. If there's a problem, we want to know as soon as possible; we'd rather an issue be reported to us multiple times than not at all!

We aim to fix security problems as rapidly as possible. _In extremis,_ if faults in these actions are being used to attack systems (especially those of the University, but not only) then we will disable their use entirely. It is our strong desire to avoid that, but we reserve the right to do so.

## Reporting Security Problems

There are nuances of security issue reporting depending on the reporter's status with respect to the University of Manchester; the actual reporting routes are the same, but the details of how to use them vary.

### Reports by University of Manchester Members

Members of the University of Manchester should use Connect to report problems with this repository if confidentiality is required; see our [Application Support](https://research-it.manchester.ac.uk/services/application-support/) page for details, including a direct link to the reporting form. Alternatively, the [standard Connect entry point](https://www.itservices.manchester.ac.uk/help/connect/) may also be used.

Members of Research IT (only!) may contact the Automation Working Group directly on Teams to report problems.

Non-confidential security problems may be raised as an [issue](https://github.com/UoMResearchIT/actions/issues/), bearing in mind that that is a public channel.

### Reports by People and Organisations External to the University

You may either:
* [Submit an Issue](https://github.com/UoMResearchIT/actions/issues/), or
* [Report via Connect](https://www.itservices.manchester.ac.uk/help/connect/) (see that page for details of how to report issues to the Research IT Application Support channel without a University account).

The latter is preferred for any report that needs confidentiality.

## Update Policy

We endeavour to ensure that our dependencies are kept reasonably up to date.
Security problems in our dependencies should be reported directly to the dependency concerned (_unless the action `README` states otherwise_).
Bear in mind that with some dependencies, the version in use will actually depend on the distribution (e.g., of Ubuntu) from which the dependency is drawn; if that updates, so too will these actions.
