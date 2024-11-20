
# **Project Name**

1. This is a Ruby on Rails-based application that provides APIs for user management, wallet operations, transfers, withdrawals, and deposits.
2. It includes authentication via JWT, Sidekiq for background processing, and RSpec for testing.
3. Using Event Sourcing thoughts(every change to wallet amount will base on an event)

---

## **Requirements**

### **Ruby Version**
- `>= 3.0`

### **System Dependencies**
1. **MySQL**: Version `>= 8.0` (Recommended)
2. **Redis**: Required for Sidekiq background processing

---

## **Installation**

### **Step 1: Clone the Repository**
```shell
git clone <repository_url>
cd <repository_folder>
```

### **Step 2: Install Required Gems**
Run the following command to install dependencies:
```shell
bundle install
```

### **Step 3: Configure Environment Variables**
Copy the example `.env.development` file to `.env`:
```shell
cp .env.development .env
```
Update the `.env` file with your database and other environment-specific configurations.

---

## **Database Setup**

### **Step 1: Create and Migrate the Database**
Drop, create, and migrate the database:
```shell
rails db:drop
rails db:create
rails db:migrate
```

---

## **Running the Application**

### **Start the Rails Server**
Run the Rails server locally:
```shell
rails server
```
By default, the server runs on `http://localhost:3000`.

### **Start Sidekiq**
Ensure Redis is running, then start Sidekiq:
```shell
bundle exec sidekiq
```

---

## **Testing**

### **Run RSpec Test Suite**
Execute all tests using the following command:
```shell
rspec
```

---

## **Project Features**

1. **Authentication**:
  - JWT-based authentication.
  - Users can register, log in, and fetch their profile.

2. **Wallet Management**:
  - Check wallet balance.
  - Automated updates on transactions.

3. **Transfers**:
  - Transfer funds between users.
  - Includes error handling for insufficient balance or invalid operations.

4. **Withdrawals**:
  - Create and confirm withdrawals.
  - Includes error handling for failed transactions.

5. **Deposits**:
  - Deposit funds to wallets.
  - Supports multiple payment platforms.

6. **Background Processing**:
  - Uses Sidekiq for handling asynchronous tasks.

---

## **API Endpoints**

### **Users**
- `POST /users/register` - Register a new user.
- `POST /users/login` - Log in and get a JWT token.
- `GET /users/me` - Get the logged-in user's profile.

### **Wallets**
- `GET /wallets/user_balance` - Get the wallet balance of the authenticated user.

### **Transfers**
- `GET /transfers` - List all transfers for the authenticated user.
- `POST /transfers` - Create a new transfer.

### **Withdrawals**
- `GET /withdrawals` - List all withdrawals for the authenticated user.
- `POST /withdrawals` - Create a new withdrawal.
- `POST /withdrawals/confirm` - Confirm a withdrawal.

### **Deposits**
- `GET /deposits` - List all deposits for the authenticated user.
- `POST /deposits` - Create a new deposit.

---

## **Contribution Guidelines**

### **Adding Tests**
1. Write tests for your feature using RSpec.
2. Ensure all tests pass before submitting a pull request:
   ```shell
   rspec
   ```

### **Code Coverage**
Add unit tests to improve test coverage. Consider using tools like `simplecov` for tracking coverage.

---

## **License**

This project is licensed under the [MIT License](LICENSE).

---

## **Future Enhancements**
- Add Swagger documentation for APIs.
- Add ut coverage rate check tool(like coverall).
- Add event record automatically(by using some gems)
