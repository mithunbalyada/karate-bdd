
Feature: Test API hosted at http://dummy.restapiexample.com for various operation on employee data.

  Background:
    *  url 'http://dummy.restapiexample.com'


  Scenario: Retrieve all the employees and validate the resultant schema

    # Define schema of employee objcect, using regular expression define the structure of the output.. Employee_salary can have digits 0-9 and an optional decimal '.'
    * def EmployeeSchema =  {id: '#regex[0-9]+', employee_name: '#string', employee_salary: '#regex[0-9.]+', employee_age: '#regex[0-9]+', profile_image: '#string'}

    Given path '/api/v1/employees'

    #select method as HTTP.GET
    When method get

    #Expect the status  HTTP.OK
    Then status 200

    #response should be an array
    And match response == '#[]'

    #response should be an array and consists of one or more 'EmployeeSchema' type objects
    And match response == '#[] EmployeeSchema'





  Scenario: Save the details of new employee and validate the output, query employee details using id and then updated the details, finally deleted the employee details

    #-----------------------------------------------------------------------------------------#
    # Add an Employee
    #-----------------------------------------------------------------------------------------#

    Given path '/api/v1/create'

    #set the header content-type as application/json
    And header Accept = 'application/json'

    #Construct JSON request data
    And request {name:"my-api-test-emp",salary:"1234534",age:"30"}

    #select method as HTTP.POST
    When method post

    #Expect the status  HTTP.OK
    Then status 200

    #Response should match the given regular expressions. Consult API spec for more details
    And match response == {id: '#regex[0-9]+', name: '#string', salary: '#regex[0-9.]+', age: '#regex[0-9]+' }

    #Save the response for next steps
    * def id = response.id
    * def employee_name = response.name
    * def employee_salary = response.salary
    * def employee_age = response.age

    * print id


    #-----------------------------------------------------------------------------------------#
    # Get Employee details by id
    #-----------------------------------------------------------------------------------------#

    Given path '/api/v1/employee/', id

    #select method as HTTP.GET
    When method get

    #Expect the status  HTTP.OK
    Then status 200


    #Compare the response to previously stored employee details. This step behaves similar to Junit Assertions
    * def employee = response
    * print employee
    And match employee.id == id
    And match employee.employee_name == employee_name
    And match employee.employee_salary == employee_salary
    And match employee.employee_age == employee_age

    #-----------------------------------------------------------------------------------------#
    # Update employee salary
    #-----------------------------------------------------------------------------------------#

    Given path '/api/v1/update/', id

    #set the header content-type as application/json
    And header Accept = 'application/json'

    #prepare the request, change only the salary and retain the rest
    And request {name:employee_name ,salary:"678910.00",age:employee_age}

    #select method as HTTP.PUT
    When method put

    #Expect the status  HTTP.OK
    Then status 200

    #And match employee ==  {id: '#regex[0-9]+', employee_name: '#string', employee_salary: '#regex[0-9.]+', employee_age: '#regex[0-9]+', profile_image: '#string'}
    * def employeeUpdate = response
    * print employeeUpdate
    And match employeeUpdate.salary == "678910.00"



    #-----------------------------------------------------------------------------------------#
    # Delete the employee
    #-----------------------------------------------------------------------------------------#

    Given path '/api/v1/delete/', id

    #select method as HTTP.DELETE
    When method delete

    #Expect the status  HTTP.OK
    Then status 200

    #Validate the response for the delete
    And match response contains {"success":{"text":"successfully! deleted Records"}}


