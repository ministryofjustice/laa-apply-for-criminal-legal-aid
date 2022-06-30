# Architectural decision records

This folder will hold markdown documents that record Architectural decision records (ARDs) for the LAA Apply for Criminal Legal Aid application.

For information on what ARDs are see [here](https://adr.github.io/).

Please use [this simple template](https://github.com/joelparkerhenderson/architecture-decision-record/blob/main/templates/decision-record-template-by-michael-nygard/index.md) as descibed by Michael Nygard [here](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) a base to record new ADRs. 

Please use the following file name format:

<adr-id>-<hypendated-title-of-adr>.md

the "adr-id" should be in the form 0001 and increment each time a new ARD is added.

an example file name would look like:

`0001-database-choice.md`

An example of ARD content:

-----

# 1. Database choice

Date: 30-07-2022

## Status

Accepted

## Context 

Or application needs a database to store its application data

## Decision

We will use the Postgressql database as it integrates well with the rails web framework and is open source.

## Consequences

It will allow us to store relational data.

