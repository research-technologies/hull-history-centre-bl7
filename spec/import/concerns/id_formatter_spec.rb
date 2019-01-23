require 'spec_helper'
require_relative '../../../lib/import/concerns/id_formatter'

class IdTester
  extend IdFormatter
end


describe IdFormatter do

  describe '.sortable_id' do
    it "will return the prefix of reference number based upon its casing" do
      expect(IdTester.sortable_id('U DMU/1/154')).to eq 'U DMU/000001/000154'
    end
  end 

end

