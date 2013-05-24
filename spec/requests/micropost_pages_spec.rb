require 'spec_helper'

describe "MicropostPages" do
	subject { page }

	let(:user) { FactoryGirl.create(:user) }
	let(:wrong_user) {FactoryGirl.create(:user) }
	before { sign_in user }

	describe "micropost creation" do
		before { visit root_path }

		describe "with invalid information" do

			it "should not create a micropost" do
				expect { click_button "Post"}.not_to change(Micropost, :count)
			end

			describe "error messages" do
				before { click_button "Post" }
				it { should have_content('error') }
			end
		end

		describe "with valid information" do

			before { fill_in 'micropost_content', with: "Lorem Lipsum" }

			it "should create a micropost" do
				expect { click_button "Post" }.to change(Micropost, :count).by(1)
			end
		end
	end

	describe "Micropost desctruction" do
		before do
			FactoryGirl.create(:micropost, user: user)
			FactoryGirl.create(:micropost, user: wrong_user, content: "don't destroy me")
		end

		describe "as correct user" do
			before { visit root_path }

			it "should delete a micropost" do
				expect { click_link "delete" }.to change(Micropost, :count).by(-1)
			end
		end

		describe "as wrong user" do
			before { visit user_path(wrong_user) }

			it { should have_content("don't destroy me") }
			it { should_not have_link("delete") }
		end
	end
end
