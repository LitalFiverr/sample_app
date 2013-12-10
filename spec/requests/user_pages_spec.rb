require 'spec_helper'

describe "User Pages" do

  	subject {page}

    describe "index" do
      let(:user) {FactoryGirl.create(:user)}

      before(:each) do
        sign_in user
        visit users_path
      end

      it {should have_title(full_title('All users'))}
      it {should have_content('All users')}

      describe "pagination" do
        before(:all) {30.times {FactoryGirl.create(:user)}}
        after(:all) {User.delete_all}

        it {should have_selector('div.pagination')} 
        it "should list each user" do
          User.paginate(page: 1).each do |user|
            expect(page).to have_selector('li', user.name)
          end
        end
      end

      describe "delete links" do
        it {should_not have_link("delete")}

        describe "as an admin user" do
          let(:admin) { FactoryGirl.create(:admin) }
          before do
            sign_in admin
            visit users_path
          end

          it {should have_link('delete', href: user_path(User.first))}

          it "should be able to delete another user" do
            expect do
              click_link('delete', match: :first)
            end.to change(User, :count).by(-1)
          end
          it {should_not have_link('delete', href: user_path(admin))}
        end
      end

      describe "destroy admin user by itself" do
        let(:admin) {FactoryGirl.create(:admin)}
        before do 
          sign_in admin, no_capybara: true
        end
        
        it "should not be destroyed" do
          expect {delete user_path(admin)}.not_to change(User,:count)
        end
      end
    end

  	describe "signup page" do
  		before {visit signup_path}

  		it {should have_content('Sign up')}
  		it {should have_title(full_title('Sign up'))}

      describe "after sign in" do
        let(:user) {FactoryGirl.create(:user)}
        before do 
          sign_in(user)
          visit(signup_path)
        end

        it {should_not have_title("Sign up")}
      end
  	end

    describe "signup" do
      
      before { visit signup_path }
      
      let(:submit) {"Create my account"}
      
      describe "with invalid information" do
        it "should not create a user" do
          expect {click_button submit}.not_to change(User,:count)
        end

        describe "after submission" do
          before {click_button submit}

          it {should have_title('Sign up')}
          it {should have_content('error')}
          it {should have_content('Name can\'t be blank')}
          it {should have_content('Email can\'t be blank')}
          it {should have_content('Email is invalid')}
          it {should have_content('Password can\'t be blank')}
          it {should have_content('minimum is 6 characters')}
        end
      end

      describe "with valid information" do
        before {valid_signup}

        it "should create a user" do
          expect { click_button submit }.to change(User, :count).by(1)
        end

        describe "after saving the user" do
          before {click_button submit}
          let(:user) {User.find_by(email: "user@example.com")}

          it {should have_link('Sign out')}
          it {should have_title(user.name)}
          it {should have_success_message('Welcome')}
          it {should have_selector('img', minimum: 1)}
          it {should have_selector('h1', text: user.name)}
        end
      end
    end

  	describe "profile page" do
			let(:user_to_show) { FactoryGirl.create(:user) }
      let!(:m1) {FactoryGirl.create(:micropost, user:user_to_show, content:"m1")}
      let!(:m2) {FactoryGirl.create(:micropost, user:user_to_show, content:"m2")}

			before {visit user_path(user_to_show)}

			it {should have_content (user_to_show.name)}
			it {should have_title (user_to_show.name)}

      describe "microposts" do
        it {should have_content(m1.content)}
        it {should have_content(m2.content)}
        it {should have_content(user_to_show.microposts.count)}
      end
		end

    describe "edit" do
      let(:user) {FactoryGirl.create(:user)}
      before do
        sign_in(user)
        visit edit_user_path(user)
      end

      describe "page" do
        it {should have_content("Update your profile")}
        it {should have_title("Edit user")}
        it {should have_link('change', href:'http://gravatar.com/emails')}
      end

      describe "with invalid information" do
        before {click_button "Save changes"}

        it {should have_error_message('error')}
      end

      describe "with valid information" do
        let(:new_name)  { "New Name" }
        let(:new_email) { "new@example.com" }
        before do
          fill_in "Name",             with: new_name
          fill_in "Email",            with: new_email
          fill_in "Password",         with: user.password
          fill_in "Confirm Password", with: user.password
          click_button "Save changes"
        end

        it { should have_title(new_name) }
        it { should have_selector('div.alert.alert-success') }
        it { should have_link('Sign out', href: signout_path) }
        specify { expect(user.reload.name).to  eq new_name }
        specify { expect(user.reload.email).to eq new_email }
      end

      describe "set admin property when not admin" do
        let(:non_admin) {FactoryGirl.create(:user)}
        before do 
          sign_in non_admin, no_capybara: true
          patch user_path(non_admin), user: {admin: true, password:"Example", password_confirmation:"Example"}
        end
        specify {expect(non_admin.reload.admin).to eq false }
      end  
    end
end
