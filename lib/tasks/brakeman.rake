task :brakeman do
  sh <<end
mkdir -p tmp && (brakeman --quiet --output tmp/brakeman.out --exit-on-warn && echo "no warnings or errors") || (cat tmp/brakeman.out; exit 1)
end
end
