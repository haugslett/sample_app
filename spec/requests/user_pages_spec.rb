require 'spec_helper'

describe "User pages" do

	subject { page }

	describe "profile page" do
		let(:user) { FactoryGirl.create(:user) }
		let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "foo") }
		let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "bar") }
		
		before { visit user_path(user) }

		it { should have_headline(user.name) }
		it { should have_title(user.name) }

		describe "microposts" do
			it { should have_content(m1.content) }
			it { should have_content(m2.content) }
			it { should have_content(user.microposts.count) }
		end
	end

	describe "sidebar" do
		let(:user) { FactoryGirl.create(:user) }
		before { sign_in user }
		describe "should have correct pluralization of micropost number" do

			describe "with 0 microposts" do
				before { visit root_path }
				it { should have_content("0 microposts")}
			end

			describe "with 1 micropost" do
				let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "foo") }
				before { visit root_path }

				it { should have_content("1 micropost") }
			end

			describe "with 2 microposts" do
				let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "foo") }
				let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "bar") }
				before { visit root_path }

				it { should have_content("2 microposts")}
			end
		end
	end


	describe "signup" do

		before { visit signup_path }

		describe "signup page" do

			it { should have_headline('Sign up') }
			it { should have_title(full_title('Sign up')) }
		end

		let(:submit) { "Create my account" }

		describe "with invalid information" do
			it "should not create a user" do
				expect { click_button submit }.not_to change(User, :count)
			end
		end

		describe "with valid information" do
			before { valid_signup }

			it "should create a user" do
				expect { click_button submit }.to change(User, :count).by(1)
			end

			describe "after saving the user" do
	        	before { click_button submit }
	        	let(:user) { User.find_by_email('user@example.com') }

	        	it { should have_title(user.name) }
	        	it { should have_success_message('Welcome') }
	        	it { should have_link('Sign out') }
     		end
		end
	end

	describe "edit" do
		let(:user) { FactoryGirl.create(:user) }
		before do
			sign_in user
			visit edit_user_path(user)
		end

		describe "page" do
			it { should have_headline('Update your profile') }
			it { should have_title('Edit user') }
			it { should have_link('change', href: 'http://gravatar.com/emails') }
		end

		describe "with invalid information" do
			before { click_button "Save changes" }

			it { should have_content('error') }
		end

		describe "with valid information" do
			let(:new_name) { "New name" }
			let(:new_email) { "new@example.com" }
			before do
				fill_in "Name",				with: new_name
				fill_in "Email", 			with: new_email
				fill_in "Password", 		with: user.password
				fill_in "Confirm Password",	with: user.password
				click_button "Save changes"
			end

			it { should have_title(new_name) }
			it { should have_success_message }
			it { should have_link('Sign out', href: signout_path)}
			specify { user.reload.name.should == new_name }
			specify { user.reload.email.should == new_email }
		end
	end

	describe "index" do
			let(:user) { FactoryGirl.create(:user)}

			before(:each) do
				sign_in user
				visit users_path
			end

		it { should have_title('All users')}
		it { should have_headline('All users')}

		describe "pagination" do

			before(:all) { 30.times { FactoryGirl.create(:user) } }
			after(:all) { User.delete_all }

			it { should have_selector('div.pagination') }

			it "should list each user" do
				User.paginate(page: 1).each do |user|
					page.should have_selector('li', text: user.name)
				end
			end
		end

		describe "delete links" do
			it { should_not have_link("delete") }

			describe "as an admin user" do
				let(:admin) { FactoryGirl.create(:admin) }
				before do
					sign_in admin
					visit users_path
				end

				it { should have_link('delete', href: user_path(User.first)) }
				it "should be able to delete another user" do
					expect { click_link('delete').to change(User, :count).by(-1) }
				end
				it { should_not have_link('delete', href: user_path(admin)) }

				it "should not be able to issue DELETE to himself" do
					expect { delete user_path(admin) }.not_to change(User, :count).by(-1)
				end
			end
		end
	end
end