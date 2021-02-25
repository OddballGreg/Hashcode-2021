#!/bin/sh
cp -R algo.rb outputs/algo.rb &
ruby algo.rb inputs/a.txt &
ruby algo.rb inputs/b.txt &
ruby algo.rb inputs/c.txt &
ruby algo.rb inputs/d.txt &
ruby algo.rb inputs/e.txt &
ruby algo.rb inputs/f.txt &

wait
echo "FINISHED"