#!/bin/bash

set -e

exec supervisord

exec "$@"
