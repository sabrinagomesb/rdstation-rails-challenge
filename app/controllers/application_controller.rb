class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from StandardError, with: :render_unprocessable

  private

  def render_not_found
    render_error("Record not found", :not_found)
  end

  def render_unprocessable(exception)
    render_error(exception.message, :unprocessable_entity)
  end

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end
end
