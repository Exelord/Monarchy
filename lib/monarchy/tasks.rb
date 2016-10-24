# frozen_string_literal: true
require 'tqdm'

module Monarchy
  class << self
    def rebuild!
      p 'Rebuilding Monarchy...'
      hierarhization
      reparentize
      p 'Rebuilding Monarchy ended!'
    end

    private

    def hierarhization
      p 'Monarchy hierarchization...'
      Monarchy.resource_classes.with_progress.each do |klass|
        klass.all.each do |model|
          model.send(:ensure_hierarchy, true)
        end
      end
      p 'Monarchy hierarchization ended!'
    end

    def reparentize
      p 'Monarchy reparentize...'

      Monarchy.resource_classes.with_progress.each do |klass|
        klass.all.each do |model|
          model.send(:assign_parent, true)
        end
      end

      Monarchy.hierarchy_class.rebuild!
      p 'Monarchy reparentize ended!'
    end
  end
end
