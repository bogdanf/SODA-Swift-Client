# Build Swift apps with Oracle's Autonomous Database and NoSQL

This repository ilustrate [my article][1] about how to integrate a modern Swift app with a cloud Oracle Autonomous Database storing JSON documents.
To fully understand what's going on in the code and properly setup the database, please [read the full article][1]

![header](https://miro.medium.com/max/600/1*gf4diWCZyxAHhJHQ16AQBQ.png)

## Technology

The client part uses Swift 5.3 / SwiftUI 2.0 and it's tested with XCode 12 (beta 5).
The server part uses an Oracle Autonomous Database hosted on Oracle Cloud (OCI), under the free tier.

## How to install

A working database instance running on cloud is needed, for full instructions on how to do that please read the first part of the [article][1]

For the client part, just clone the code here, replace your specific endpoint URL and admin credentials in SODA.swift.

[1]: https://medium.com/so-much-code/build-swift-apps-with-oracles-autonomous-database-and-nosql-f1dee7e7cec3
