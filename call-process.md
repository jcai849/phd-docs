---
title: Description of distObj Client-Server Call Process
date: 2020-10-07
---

N.B. There were originally some TiKz figures that have since been lost; the document may make less sense without them.

# Introduction

This document aims to describe the current process enabling the evaluation of a function over some chunks through `do.call`{.R}, as initiated by a `do.call.distObjRef`{.R} call with a distributed object reference in the arguments.
The process typically involves multiple nodes, with least the initial call taking place on a node that will then act as client, and the terminal evaluation using a node acting as a server, with nodes free to take on any roles as appropriate.

# Overview

The process is initialised on a node which will act as a client, with `do.call.distObjRef`{.R} call, using at least one distributed object reference in the arguments.
Of the distributed object references, one is picked as a target, for which the nodes hosting the chunks making up the referent distributed object will serve as the points of evaluation, with all other distributed object chunks eventually transported to these nodes.

One message for each chunk reference within the distributed object reference is sent to the corresponding nodes hosting the chunks.
The message contains information including the requested function, the arguments to the function in the form of a list of distributed object references as well as other non-distributed arguments, and the name with which to assign the results to, which the client also keeps as an address to send messages to for any future work on the results.
The client may continue with the remainder of its process, including producing a future reference for the expected final results of evaluation.

Concurrent to the initialisers further work after sending a message, the node hosting a target chunk receives the message, unpacks it and feeds the relevant information to `do.call.msg`{.R}.

All distributed reference arguments are replaced in the list of arguments by their actual referents.
`do.call`{.R} is then used to perform the terminal evaluation of the given function over the argument list.
The server then assigns the value of the `do.call`{.R} to the given chunk name within an internal chunk store environment, sending relevant details such as size and error information back to the initial requesting node.
The object server is also supplied with a reference to the chunk, used to send the chunk point-to-point upon request.

# Argument Replacement

The process of argument replacement on the server merits further explanation.
This procedure takes a chunk reference as the target with which to compare and deliver the corresponding chunk of a distributed object reference.

The alignment of the argument to the target is first determined, including recycling if necessary to fit the argument chunks appropriately to the target chunk.
The referent chunks are then emerged either from the local object store, or if the chunks are not local, through a request to the object server of the chunks host.
The emerged chunks are then cut and fit to the right size as per alignment specifications, and returned, ready to replace their references in the argument list.

\end{document}

