# 2. LAA Portal for auth

Date: 2022-07-14

## Status

Accepted

## Context

Crime Apply will only be available to authenticated users. In this context, users are solicitors who are contracted with the LAA to provide work in criminal courts ('providers'). Currently there are around 15000 provider users.

##### Our needs
- To authenticate users as criminal legal aid providers
- To authorise users based on certain user attributes. Users are granted access to legal aid applications based on the offices they work in (each law firm has one or more offices, and each office has one or more users).
- To temporarily limit access to a subset of users during private beta.

##### Current auth process
- a) Providers log into LAA portal.
- b) Providers get a link to eForms (the current service for applying for criminal legal aid).
- c) Provider users are onboarded and managed via CWA. User data is pushed to portal via Oracle Directory Integration Platform, and pushed to eForms via the Hub.

##### Future context
LAA Digital plans to replace the LAA Portal with a modern identity service in the future, but in the meantime it remains the goto for LAA auth (note, a few other LAA systems have rolled their own auth and identity management, eg CCCD, MAAT).

##### Key considerations:
- Users: we want to minimise disruption and provide a seamless login experience for users
- Simplicity: we want the implementation to be as simple as possible, ideally reusing an existing approach. However we will need it to scale to the full user base within a relatively short period.
- User management: we don't want to manage the JML process (Joiners, Movers, Leavers) for users but rather utilise existing processes and systems
- User data: we need access to certain attributes about users, namely: email, office, firm. However we want the application to persist the minimum amount of user data possible.


## Decision

A) Use LAA Portal for authentication

- This minimises disruption to users and enables a single-sign-on experience during the transition from old to new services (since eForms uses Portal too).
- We can largely reuse the Portal implementation of Civil Apply.
- The user data we need is available as Portal attributes (ie email, office, firm)
- We can utilise the existing JML (Joiners, Movers, Leavers) process in CWA rather than managing these processes ourselves
- Alternatives we considered:
  - Implementing our own auth and user management: this might be quicker to implement in the short-term but would result in much more overhead in the long-term - we would need to gradually onboard users and then manage JML ourselves, or sync with CWA.
  - Use a cloud auth service (eg AWS Cognito) and federate with Portal: this would add complexity to the initial implementation (we would be the first service to federate an identify provider with LAA Portal) with limited initial benefit (CWA/Portal would still be the source of truth for user data).

B) Use an existing role in Portal

- For MVP we plan to use a single role for providers. Users will need the relevant role attached to their identity (in CWA) in order to access the service.
- There are a number of existing eForms roles in Portal - https://github.com/ministryofjustice/laa-portal/blob/master/documentation/Technical_Documentation/CWA_OID_MAPPING.md. EFORMS_eFormsAuthor maps to the role of provider users for Crime Apply. We plan to reuse this role rather than creating a new one.
- The payoff here is that all EFORMS_eFormsAuthor users will immediately see Crime Apply in their list of services in Portal, even if they have not been onboarded to the private beta yet (see section c) below). We believe this can be handled with appropriate content design.
- Alternative considered:
  - We could create a new role for the service (as Civil Apply have done), but this would require attaching the role to each user onboarded to the service (we expect to gradually onboard users during private beta).
  - Due to limitations in CWA, the process of attaching a role is largely manual and depends on another team. Given the number of users (0000s) and the planned speed of rollout during private beta, this would quickly become unworkable.   

C) Private beta: whitelist users by firm

- We plan to initially limit the service to a subset of users.
- We plan to limit by firm. Once a firm is added, providers attached to that firm will be able to access the service (provided they also have the relevant role - see b)).
- We will maintain a list of onboarded firms and check against it using the firm attribute returned from Portal.


## Consequences

- For users, a relatively seamless experience in migrating from existing to new services.
- For us, the implementation is relatively simple and well known.
- Longer term, we may need to migrate away from Portal to a new auth provider (subject to wider LAA Digital direction). Once we've fully rolled out the service to criminal providers, we may also want to consider renaming the EFORMS_eFormsAuthor role to something more meaningful.
