#!/usr/bin/env bash

REGION=${1:?Requires region as first option}
shift   # Any other options on cli get passed to aws command

aws ec2 --region $REGION describe-instances $@ | \
  jq -r '.Reservations[].Instances[] | [ .InstanceId, (.Tags[]? | select(.Key == "Name") | .Value) ]'


# vim:ts=2 sts=2 sw=2 expandtab
