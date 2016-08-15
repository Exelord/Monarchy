# frozen_string_literal: true
require 'tqdm'

task 'monarchy:reparentize' do
  p 'Monarchy reparentize...'

  Monarchy.resource_classes.with_progress.each do |klass|
    klass.all.each do |model|
      model.send(:assign_parent, true)
    end
  end

  Monarchy::Hierarchy.rebuild!
  p 'Monarchy reparentize ended!'
end

task 'monarchy:hierarchization' do
  p 'Monarchy hierarchization...'
  Monarchy.resource_classes.with_progress.each do |klass|
    klass.all.each do |model|
      model.send(:ensure_hierarchy)
    end
  end
  p 'Monarchy hierarchization ended!'
end

task 'monarchy:rebuild' do
  p 'Rebuilding Monarchy...'

  Monarchy::Hierarchy.all.delete_all
  Rake::Task["monarchy:hierarchization"].invoke
  Rake::Task["monarchy:reparentize"].invoke

  p 'Rebuilding Monarchy ended!'
end
