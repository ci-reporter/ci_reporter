require 'rspec'

class Spinach::Features::ExampleSpinachFeature < Spinach::FeatureSteps
  include RSpec::Matchers

  step 'that I am a conscientious developer' do
  end

  step 'I write cucumber features' do
  end

  step 'I should see a green bar' do
  end

  step 'that I am a lazy hacker' do
  end

  step 'I don\'t bother writing cucumber features' do
    false.should be_true
  end

  step 'I should be fired' do
  end

  step 'that I can\'t code for peanuts' do
  end

  step 'I write step definitions that throw exceptions' do
    raise RuntimeError, "User error!"
  end

  step 'I shouldn\'t be allowed out in public' do
  end
end
