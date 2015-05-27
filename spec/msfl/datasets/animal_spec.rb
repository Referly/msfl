require 'spec_helper'

describe MSFL::Datasets::Animal do

  it "has a foreign: person" do
    expect(described_class.new.foreigns).to include :person
  end

  it "has the name field" do
    expect(described_class.new.fields).to include :name
  end

  it "has the gender field" do
    expect(described_class.new.fields).to include :gender
  end

  it "has the age field" do
    expect(described_class.new.fields).to include :age
  end

  it "has the type field" do
    expect(described_class.new.fields).to include :type
  end
end