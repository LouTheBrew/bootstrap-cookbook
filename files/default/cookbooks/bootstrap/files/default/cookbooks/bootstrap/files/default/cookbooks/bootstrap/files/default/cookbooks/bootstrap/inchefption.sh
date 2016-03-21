#!/bin/env bash
berks vendor
rm -rf files/default/cookbooks
mv berks-cookbooks files/default/cookbooks
