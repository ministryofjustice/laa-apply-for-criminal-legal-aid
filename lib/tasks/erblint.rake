task :erblint do
  sh 'bundle exec erb_lint --lint-all'
end
