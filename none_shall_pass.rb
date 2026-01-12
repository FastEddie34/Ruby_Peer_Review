require 'yaml'

USERNAME = "eddiew"
PASSWORD = "goblue"

SERVICE_CREDENTIALS = {

}

VAULT_FILE = "password_vault.yml"

# Load vault from file or initialize empty hash
def load_vault
  if File.exist?(VAULT_FILE)
    YAML.load_file(VAULT_FILE) || {}
  else
    {}
  end
end

def save_vault(vault)
  File.open(VAULT_FILE, 'w') { |file| file.write(vault.to_yaml) }
end

PASSWORD_VAULT = load_vault

def welcome
  puts "Welcome to the program."
end

def exit_program(message = "Exiting the program.")
  puts message
  exit
end

def prompt(message)
  print message
  gets.chomp
end

def authenticate
  username = prompt("Enter your username to continue: ")
  exit_program("Incorrect Username.") unless username == USERNAME

  password = prompt("Enter your password to continue: ")
  exit_program("Incorrect Password.") unless password == PASSWORD
end

def menu_selection
  puts "\nWhat would you like to do?"
  puts "1. Create new credentials"
  puts "2. Access current credentials"
  puts "3. Delete Credentials"
  puts "4. Exit Program"
  prompt("Enter your selection: ")
end

def create_new_credentials
  service = prompt("Enter name of new service: ").strip.downcase.to_sym
  username = prompt("Enter username for new service: ")
  password = prompt("Enter password for new service: ")

  PASSWORD_VAULT[service] = { username: username, password: password }
  save_vault(PASSWORD_VAULT)

  puts "\nNew credentials added:"
  puts "#{service.capitalize}: #{PASSWORD_VAULT[service]}"
end

def access_credentials
  service = prompt("What service do you want to access?: ").strip.downcase.to_sym

  credentials = SERVICE_CREDENTIALS[service] || PASSWORD_VAULT[service]

  if credentials
    puts "\n#{service.capitalize} credentials:"
    puts "Username: #{credentials[:username]}"
    puts "Password: #{credentials[:password]}"
    loop do
    selection = menu_selection
    handle_selection(selection)
    end
  else
    exit_program("Service not found.")
  end
end

def delete_credentials
  delete_service = prompt("Enter name of service to be deleted: ").strip.downcase.to_sym

  delete_credentials = SERVICE_CREDENTIALS[delete_service] || PASSWORD_VAULT[delete_service]
  
  if delete_credentials
    SERVICE_CREDENTIALS.delete(delete_service)

    # Write back to the YAML file
    File.open(VAULT_FILE, 'w') do |f|
      f.write(SERVICE_CREDENTIALS.to_yaml)
    end

    puts "#{delete_service} credentials deleted."
  else
    puts "Service not found: #{delete_service}"
  end
end


def handle_selection(selection)
  case selection
  when "1"
    create_new_credentials
  when "2"
    access_credentials
  when "3"
    delete_credentials
  when "4"
    exit_program
  else
    exit_program("Invalid selection.")
  end
end

# --- Program Execution ---
welcome
authenticate

loop do
  selection = menu_selection
  handle_selection(selection)

  puts "\nWould you like to perform another action? (y/n)"
  continue = gets.chomp.downcase
  break unless continue == "y"
end

exit_program("Thank you for using the program.")


