class EmployeesController < ApplicationController
  before_action :authenticate_employee!
  def dashboard    
    #    abort(current_employee.inspect)
  end
  
  def sign_in
    
  end
end
