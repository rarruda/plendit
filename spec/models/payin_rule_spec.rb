require 'rails_helper'

RSpec.describe PayinRule, type: :model do

  # All tests are failing guid uniqueness validation!
  it "should work on a valid model" do
    payin_rule = FactoryGirl.build_stubbed(:payin_rule_ad)
    expect(payin_rule).to be_valid
  end

  it "should not accept effective_from_unit gt 23 for hours" do
    payin_rule = FactoryGirl.build_stubbed(:payin_rule_ad, unit: 'hour', effective_from: 25)
    expect(payin_rule).not_to be_valid
  end

  it "should not accept very low day prices" do
    payin_rule = FactoryGirl.build_stubbed(:payin_rule_ad, unit: 'day', payin_amount: 1_00)
    expect(payin_rule).not_to be_valid
  end

  it "should not accept very high prices" do
    payin_rule = FactoryGirl.build_stubbed(:payin_rule_ad, payin_amount: 10_000_000_00)
    expect(payin_rule).not_to be_valid
  end

  it "should accept 99 NOK as minimum price" do
    payin_rule = FactoryGirl.build_stubbed(:payin_rule_ad, payin_amount: 99_00)
    expect(payin_rule).to be_valid
  end

  context "for a small boat" do
    it "should not accept 99 NOK as minimum price for a small boat" do
      payin_rule = FactoryGirl.build_stubbed(:payin_rule_ad, payin_amount: 99_00, ad: FactoryGirl.build_stubbed(:ad_small_boat))
      expect(payin_rule).not_to be_valid
    end

    it "should accept 149 NOK as minimum price for a small boat" do
      payin_rule = FactoryGirl.build_stubbed(:payin_rule_ad, payin_amount: 149_00, ad: FactoryGirl.build_stubbed(:ad_small_boat))
      expect(payin_rule).to be_valid
    end
  end

  context "for a medium boat with estimated value at 150.001" do
    it "should not accept 149 NOK as minimum price" do
      payin_rule = FactoryGirl.build_stubbed(:payin_rule_ad, payin_amount: 149_00, ad: FactoryGirl.build_stubbed(:ad_medium_boat, estimated_value: 150_001_00))
      expect(payin_rule).not_to be_valid
    end

    it "should accept 451 NOK as minimum price" do
      payin_rule = FactoryGirl.build_stubbed(:payin_rule_ad, payin_amount: 451_00, ad: FactoryGirl.build_stubbed(:ad_medium_boat, estimated_value: 150_001_00))
      expect(payin_rule).to be_valid
    end
  end

  context "when payin_rule has a simple day price rule" do
    let(:payin_rule) { FactoryGirl.build_stubbed(:payin_rule, unit: 'day', payin_amount: 200_00,
        ad: FactoryGirl.build_stubbed(:ad_motor) )
      }
    let(:duration) { 4.days.to_i }

    it "should generate correctly prices for one unit" do
      expect(payin_rule.payin_amount_for_duration).to  eq(200_00)
    end

    it "should generate correctly prices for multiple units" do
      expect(payin_rule.payin_amount_for_duration  duration).to eq(800_00)
    end
  end


  context "ads have with multiple day payin_rules for medium boats" do
    # This needs to be created in the database, as the other payin rules need to reference this ad model,
    #  and its payin amounts directly from the database.
    let(:ad_medium_boat) { FactoryGirl.create(:ad_medium_boat,
        estimated_value: 150_001_00,
        user: FactoryGirl.build(:user_a),
        ad_images: [ FactoryGirl.build(:ad_image) ] ) do |a|
          a.main_payin_rule.update_columns(payin_amount: 451_00)
          # example of a has_many:
          # a.payin_rules << FactoryGirl.build(:payin_rule, unit: 'day', payin_amount: 600_00, effective_from: 2, ad: a)
      end
    }

    it "should be valid on single valid payin_amount" do
      expect(ad_medium_boat.main_payin_rule).to be_valid
    end

    it "should be valid with valid discounts" do
      valid_payin_rule = FactoryGirl.build(:payin_rule, unit: 'day', payin_amount: 316_00, effective_from: 2, guid: SecureRandom.uuid, ad: ad_medium_boat)

      expect(valid_payin_rule).to be_valid
    end

    it "should be invalid with invalid discounts" do
      invalid_payin_rule = FactoryGirl.build(:payin_rule, unit: 'day', payin_amount: 315_00, effective_from: 2, guid: SecureRandom.uuid, ad: ad_medium_boat)

      expect(invalid_payin_rule).not_to be_valid
    end

    it "should be invalid on single invalid payin_amount" do
      ad_medium_boat.main_payin_rule.payin_amount = 449_00
      expect(ad_medium_boat.main_payin_rule).not_to be_valid
    end
  end

  context "ads have with multiple day payin_rules for small boats" do
    # This needs to be created in the database, as the other payin rules need to reference this ad model,
    #  and its payin amounts directly from the database.
    let(:ad_small_boat) { FactoryGirl.create(:ad_small_boat,
        estimated_value: 149_900_00,
        user: FactoryGirl.build(:user_a),
        ad_images: [ FactoryGirl.build(:ad_image) ] ) do |a|
          a.main_payin_rule.update_columns(payin_amount: 149_00)
          # example of a has_many:
          # a.payin_rules << FactoryGirl.build(:payin_rule, unit: 'day', payin_amount: 600_00, effective_from: 2, ad: a)
      end
    }

    it "should be valid on single valid payin_amount" do
      expect(ad_small_boat.main_payin_rule).to be_valid
    end

    it "should be valid with valid discounts" do
      valid_payin_rule = FactoryGirl.build(:payin_rule, unit: 'day', payin_amount: 105_00, effective_from: 2, guid: SecureRandom.uuid, ad: ad_small_boat)

      expect(valid_payin_rule).to be_valid
    end

    it "should be invalid with invalid discounts" do
      invalid_payin_rule = FactoryGirl.build(:payin_rule, unit: 'day', payin_amount: 104_00, effective_from: 2, guid: SecureRandom.uuid, ad: ad_small_boat)

      expect(invalid_payin_rule).not_to be_valid
    end

    it "should be invalid on single invalid payin_amount" do
      ad_small_boat.main_payin_rule.payin_amount = 148_00
      expect(ad_small_boat.main_payin_rule).not_to be_valid
    end
  end



  context "when payin_rule has a simple hour price rule" do
    let(:payin_rule) { FactoryGirl.build_stubbed(:payin_rule_ad_hour, unit: 'hour', payin_amount: 100_00,
        ad: FactoryGirl.build_stubbed(:ad_motor) )
      }
    let(:duration) { 4.hours.to_i }

    it { expect(payin_rule.payin_amount_for_duration).to  eq(100_00) }
    it { expect(payin_rule.payin_amount_for_duration duration).to eq(400_00) }
  end


  context "when payin_rule payin_amount comes as a float" do
    let(:payin_rule) { FactoryGirl.build_stubbed(:payin_rule_ad_hour, unit: 'hour', payin_amount_in_h: 250.0,
        ad: FactoryGirl.build_stubbed(:ad_motor) )
      }

    it { expect(payin_rule.payin_amount).to      eq ( 250_00) }
    it { expect(payin_rule.payin_amount_in_h).to eq ( 250.00) }
  end
end
