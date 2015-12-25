require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe AccidentReportsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # AccidentReport. As you add validations to AccidentReport, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AccidentReportsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all accident_reports as @accident_reports" do
      accident_report = AccidentReport.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:accident_reports)).to eq([accident_report])
    end
  end

  describe "GET #show" do
    it "assigns the requested accident_report as @accident_report" do
      accident_report = AccidentReport.create! valid_attributes
      get :show, {:id => accident_report.to_param}, valid_session
      expect(assigns(:accident_report)).to eq(accident_report)
    end
  end

  describe "GET #new" do
    it "assigns a new accident_report as @accident_report" do
      get :new, {}, valid_session
      expect(assigns(:accident_report)).to be_a_new(AccidentReport)
    end
  end

  describe "GET #edit" do
    it "assigns the requested accident_report as @accident_report" do
      accident_report = AccidentReport.create! valid_attributes
      get :edit, {:id => accident_report.to_param}, valid_session
      expect(assigns(:accident_report)).to eq(accident_report)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new AccidentReport" do
        expect {
          post :create, {:accident_report => valid_attributes}, valid_session
        }.to change(AccidentReport, :count).by(1)
      end

      it "assigns a newly created accident_report as @accident_report" do
        post :create, {:accident_report => valid_attributes}, valid_session
        expect(assigns(:accident_report)).to be_a(AccidentReport)
        expect(assigns(:accident_report)).to be_persisted
      end

      it "redirects to the created accident_report" do
        post :create, {:accident_report => valid_attributes}, valid_session
        expect(response).to redirect_to(AccidentReport.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved accident_report as @accident_report" do
        post :create, {:accident_report => invalid_attributes}, valid_session
        expect(assigns(:accident_report)).to be_a_new(AccidentReport)
      end

      it "re-renders the 'new' template" do
        post :create, {:accident_report => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested accident_report" do
        accident_report = AccidentReport.create! valid_attributes
        put :update, {:id => accident_report.to_param, :accident_report => new_attributes}, valid_session
        accident_report.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested accident_report as @accident_report" do
        accident_report = AccidentReport.create! valid_attributes
        put :update, {:id => accident_report.to_param, :accident_report => valid_attributes}, valid_session
        expect(assigns(:accident_report)).to eq(accident_report)
      end

      it "redirects to the accident_report" do
        accident_report = AccidentReport.create! valid_attributes
        put :update, {:id => accident_report.to_param, :accident_report => valid_attributes}, valid_session
        expect(response).to redirect_to(accident_report)
      end
    end

    context "with invalid params" do
      it "assigns the accident_report as @accident_report" do
        accident_report = AccidentReport.create! valid_attributes
        put :update, {:id => accident_report.to_param, :accident_report => invalid_attributes}, valid_session
        expect(assigns(:accident_report)).to eq(accident_report)
      end

      it "re-renders the 'edit' template" do
        accident_report = AccidentReport.create! valid_attributes
        put :update, {:id => accident_report.to_param, :accident_report => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end


end
