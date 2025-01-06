require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe 'associations' do
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:products).through(:cart_items) }
  end

  describe 'enum status' do
    it { should define_enum_for(:status).with_values(open: 'open', abandoned: 'abandoned').backed_by_column_of_type(:string) }

    it 'has default status as open' do
      cart = create(:cart)
      expect(cart.status).to eq('open')
    end
  end

  describe 'callbacks' do
    it 'sets default total_price to 0 if not provided' do
      cart = create(:cart, total_price: nil)
      expect(cart.total_price).to eq(0)
    end
  end

  describe 'mark_as_abandoned' do
    let(:cart) { create(:cart) }

    it 'marks the cart as abandoned if inactive for a certain time' do
      cart.update(last_interaction_at: 3.hours.ago)
      expect { cart.mark_as_abandoned }.to change { cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:cart) { create(:cart, last_interaction_at: 7.days.ago) }

    it 'removes the cart if abandoned for a certain time' do
      cart.mark_as_abandoned
      expect { cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end
end
