desc 'Automated deletions of applications'
task automated_deletion: [:environment] do
  AutomatedDeletion.call
end
