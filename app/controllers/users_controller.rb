require 'base64'

class UsersController < ApplicationController

  API_KEY = 'c017489c03b2c42da75fc7dd84afd85c6b720a0d79295144319d1623306fc9e691b1673ee6a714b3'

  def index
    @users = User.all.order("created_at DESC")
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    begin
      issue_id = create_issue(create_bitex_user)
      @user.issue_id = issue_id
      @user.issue_status = 'new'
      if @user.save
        create_natural_docket_seed(issue_id)
        create_attachment(create_identification_seed(issue_id), "identification_seeds", "id_card_image")
        create_attachment(create_domicile_seed(issue_id), "domicile_seeds", "proof_of_address")
        submit_for_review(issue_id)
        redirect_to '/'
      else
        flash[:alert] = "Could not save User"
        render 'new'
      end
    rescue FaradayException => e
        render 'new', :alert => "Error: #{e.message} [Exception Type: #{e.exception_type}]"
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def test_connection
    response = faraday_get('https://sandbox.bitex.la/api/users/me')
    render json: JSON.parse(response.body)
  end

  def check_issue_status
    response = faraday_get("https://sandbox.bitex.la/api/issues/#{params[:issue_id]}")
    state = JSON.parse(response.body)['data']['attributes']['state']
    @user = User.find(params[:user_id])
    @user.issue_status = state
    if @user.save
      @user
    else
      render '/', :alert => "Could not save issue status"
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :birth_date, :gender,
                                 :nationality, :id_number, :id_card_image,
                                 :city, :country, :floor, :postal_code, :street_address,
                                 :street_number, :proof_of_address, :issue_id, :issue_status)
  end

  def faraday_get(url)
    Faraday.get(url) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Accept'] = 'application/json'
      req.headers['Authorization'] = API_KEY
    end
  end

  def faraday_post(url, request_params = nil)
    Faraday.post(url, request_params) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Accept'] = 'application/json'
      req.headers['Authorization'] = API_KEY
    end
  end

  def create_bitex_user
    request_params = {
      data: { type: "users" }
    }.to_json
    response = faraday_post('https://sandbox.bitex.la/api/users', request_params)
    if response.status != '200'
      JSON.parse(response.body)['data']['id']
    else
      raise FaradayException.new "Error while creating a new User", "Not Created"
    end
  end

  def create_issue(user_id)
    request_params = {
      data: {
        type: "issues",
        attributes: {
          reason_code: "new_client"
        },
        relationships: {
          issue: {
            data: {
              type: "users",
              id: user_id
            }
          }
        }
      }
    }.to_json
    response = faraday_post('https://sandbox.bitex.la/api/issues', request_params)
    if response.status != '201'
      JSON.parse(response.body)['data']['id']
    else
      raise FaradayException.new "Error while creating a new Issue", "Not Created"
    end
  end

  def create_natural_docket_seed(issue_id)
    request_params = {
      data: {
        type: "natural_docket_seeds",
        attributes: {
          first_name: @user.first_name,
          last_name: @user.last_name,
          nationality: @user.nationality,
          gender_code: @user.gender,
          marital_status_code: "single",
          politically_exposed: "false",
          birth_date: @user.birth_date
        },
        relationships: {
          issue: { data: { type: "issues", id: issue_id } }
        }
      }
    }.to_json
    response = faraday_post('https://sandbox.bitex.la/api/natural_docket_seeds', request_params)
    raise FaradayException.new "Error while creating a new Natural Docket Seed", "Not Created" unless response.status != '201'
  end

  def create_identification_seed(issue_id)
    request_params = {
      data: {
        type: "identification_seeds",
        attributes: {
          identification_kind_code: "national_id",
          issuer: @user.nationality,
          number: @user.id_number
        },
        relationships: {
          issue: { data: { type: "issues", id: issue_id } }
        }
      }
    }.to_json
    response = faraday_post('https://sandbox.bitex.la/api/identification_seeds', request_params)
    if response.status != '201'
      JSON.parse(response.body)['data']['id']
    else
      raise FaradayException.new "Error while creating a new Identification Seed", "Not Created"
    end
  end

  def create_domicile_seed(issue_id)
    request_params = {
      data: {
    		type: "domicile_seeds",
    		attributes: {
    			city: @user.city,
    			country: @user.country,
    			floor: @user.floor,
    			postal_code: @user.postal_code,
    			street_address: @user.street_address,
    			street_number: @user.street_number
    		}
    	},
      relationships: {
        issue: { data: { type: "issues", id: issue_id } }
      }
    }.to_json
    response = faraday_post('https://sandbox.bitex.la/api/domicile_seeds', request_params)
    if response.status != '201'
      JSON.parse(response.body)['data']['id']
    else
      raise FaradayException.new "Error while creating a new Domicile Seed", "Not Created"
    end
  end

  def create_attachment(seed_id, seed_type, user_file)
    data = File.open(@user.send(user_file.to_sym).file.file).read
    encoded = Base64.strict_encode64(data)

    request_params = {
      data: {
        type: "attachments",
        attributes: {
          document: "data:#{@user.id_card_image.content_type};base64,#{encoded}",
          document_file_name: @user.id_card_image.filename,
          document_content_type: @user.id_card_image.content_type,
          document_size: data.size
        },
        relationships: {
          attached_to_seed: {
            data: { id: seed_id, type: seed_type }
          }
        }
      }
    }.to_json
    response = faraday_post('https://sandbox.bitex.la/api/attachments', request_params)
    raise FaradayException.new "Error while creating a new Attachment", "Not Created" unless response.status != '201'
  end

  def submit_for_review(issue_id)
    faraday_post("https://sandbox.bitex.la/api/issues/#{issue_id}/complete")
  end

end
