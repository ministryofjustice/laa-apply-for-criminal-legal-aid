Rails.autoloaders.each do |autoloader|
  autoloader.ignore(Rails.root.join('app/services/evidence/rules/*'))
end
