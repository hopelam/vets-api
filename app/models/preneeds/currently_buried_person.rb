# frozen_string_literal: true
require 'common/models/base'

module Preneeds
  class CurrentlyBuriedPerson < Preneeds::Base
    attribute :cemetery_number, String
    attribute :name, Preneeds::FullName

    def message
      { cemetery_number: cemetery_number, name: name.message }
    end

    def self.permitted_params
      [:cemetery_number, name: Preneeds::FullName.permitted_params]
    end
  end
end