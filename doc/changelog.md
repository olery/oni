# @title Changelog
# Changelog

## 4.0.0 - April 24th, 2015

Oni now depends on V2 of the AWS SDK and no longer sends any benchmarking
details to `Daemon#complete`.

## 3.1.1 - February 20th, 2015

Oni now depends on version 1 of the AWS SDK (`aws-sdk-v1`) due to the `aws-sdk`
now installing version 2 (which is not compatible).

## 3.1.0 - December 17th, 2013

Added the `Oni::WrappedError` class that can be used to wrap existing error
classes within workers.

## 3.0.0 - December 17th, 2013

This release reverts the changes of version 2.0.0 and 2.0.1 as they proved to
be too problematic.

## 2.0.1 - December 17th, 2013

* Fixed a bug where the complete() callback would be executed upon worker
  failures.

## 2.0.0 - December 16th, 2013

* Error callbacks now take an optional argument that contains extra error data
  as returned by a worker.

## 1.0.0 - November 18th, 2013

The first public release of Oni.
