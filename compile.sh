#!/bin/sh

mix clean
mix deps.get
mix deps.compile
mix compile
