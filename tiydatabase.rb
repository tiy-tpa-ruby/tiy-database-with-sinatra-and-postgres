require 'sinatra'
require 'pg'
require 'sinatra/reloader' if development?

class Employee
  attr_reader "id", "name", "phone", "address", "position" , "salary", "slack", "github"

  def initialize(employee)
    @id = employee["id"]
    @name = employee["name"]
    @phone = employee["phone"]
    @address = employee["address"]
    @position = employee["position"]
    @salary = employee["salary"]
    @slack = employee["slack"]
    @github = employee["github"]
  end

  def self.create(params)
    database = PG.connect(dbname: "tiy-database")
    name     = params["name"]
    phone    = params["phone"]
    address  = params["address"]
    position = params["position"]
    salary   = params["salary"]
    github   = params["github"]
    slack    = params["slack"]

    database.exec("insert into employees (name, phone, address, position, salary, github, slack) values($1, $2, $3, $4, $5, $6, $7)", [name, phone, address, position, salary, github, slack])
  end

  def self.all
    database = PG.connect(dbname: "tiy-database")

    return database.exec("select * from employees").map { |employee| Employee.new(employee) }
  end

  def self.find(id)
    database = PG.connect(dbname: "tiy-database")

    employees = database.exec("select * from employees where id =$1", [id]).map { |employee| Employee.new(employee) }

    return employees.first
  end

  def self.search(text)
    database = PG.connect(dbname: "tiy-database")

    return database.exec("select * from employees where name like $1 or github=$2 or slack=$2", ["%#{text}%", text]).map { |employee| Employee.new(employee) }
  end
end

get '/' do
  erb :home
end

get '/employees' do
  @employees = Employee.all

  erb :employees
end

get '/employee_show' do
  @employee = Employee.find(params["id"])
  if @employee
    erb :employee_show
  else
    erb :no_employee_found
  end
end

get '/new' do
  erb :employees_new
end

get '/employees_new' do
  Employee.create(params)

  redirect('/')
end

get '/searched' do
  search = params["search"]
  @employees = Employee.search(search)
  erb :searched
end

get '/edit' do
  database = PG.connect(dbname: "tiy-database")

  id = params["id"]

  employees = database.exec("select * from employees where id =$1", [id])

  @employee = employees.first

  erb :edit
end

get '/update' do
  database = PG.connect(dbname: "tiy-database")

  id       = params["id"]
  name     = params["name"]
  phone    = params["phone"]
  address  = params["address"]
  position = params["position"]
  salary   = params["salary"]
  github   = params["github"]
  slack    = params["slack"]

  database.exec("UPDATE employees SET name = $1, phone = $2, address = $3, position = $4, salary = $5, github = $6, slack =$7 WHERE id = $8;", [name, phone, address, position, salary, github, slack, id])

  employees = database.exec("select * from employees where id = $1", [id])

  @employee = employees.first

  erb :employee_show
end

get '/delete' do
  database = PG.connect(dbname: "tiy-database")

  id = params["id"]

  database.exec("DELETE FROM  employees where id = $1", [id])

  redirect('/employees')
end
