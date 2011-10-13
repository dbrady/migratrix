#!/bin/sh
rm -f migratrix-*.gem
gem uninstall -x migratrix
gem build migratrix.gemspec
