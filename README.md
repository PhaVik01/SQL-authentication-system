
# 🔐 Authentication System – Harrys Bilar

This project is a secure user authentication system designed for the fictional car dealership "Hederlige Harrys Bilar". It includes a SQL Server database schema, ER-diagram, and documentation for handling user login, authentication, logging, and security.

---

## 🧾 Project Overview

The goal of this project was to design and implement a secure, scalable authentication system for a fictional application used by **Hederlige Harrys Bilar**. The database was created to manage user login, password security, account verification, and activity logging.

This system handles:

- **User registration and profile data**
- **Login attempts** (successful and failed) with IP logging
- **Account status** including lockouts and verification
- **Password security** using hashing and salting
- **Stored procedures** for login validation, password reset, and token handling
- **Views** for monitoring login trends and user activity
- **Security measures** against brute-force attacks
- **Performance optimizations** using indexes and execution analysis

The project is built entirely in **SQL Server** and includes:
- Schema definition in SQL
- ER diagram in `.dawio` format
- Full documentation in Markdown and Word

---


## ✅ What I Did

- Designed a **secure SQL Server database** for user authentication and access control  
- Implemented **password hashing with salt** using SHA2-512 to protect user credentials  
- Built stored procedures for:
  - Validating login attempts (`GetTryLogin`)
  - Managing password reset tokens (`GetForgotPassword`)
  - Updating passwords securely (`GetSetForgottenPassword`)
- Created **views** to analyze user login behavior and audit failed attempts
- Developed **account lockout logic** to prevent brute-force attacks
- Indexed key columns to **optimize query performance** and reduce execution time
- Documented the entire system including:
  - ER-model (Draw.io)
  - Functional flow
  - Security strategy
  - Future improvement ideas

## 📁 Project Structure

```
authentication-system/
├── sql/
│   └── authentication-schema.sql
├── diagrams/
│   └── database-model.dawio
├── docs/
│   └── documentation.md
```

---

## 🧩 Database Overview

The database contains two core tables:

### `Users`
Stores user data and access credentials.

- `UserID` (PK)
- `Email`, `FullName`, `Role`, `Address`, etc.
- `PasswordHash` with unique `Salt`
- `IsVerified`, `IsActive`, `IsLocked`, `FailedAttempts`
- `VerificationToken` and `TokenExpiry`

### `Log`
Tracks all login attempts (success & failure).

- `LogID` (PK)
- `UserID` (FK)
- `Email`, `IPAddress`, `Success`, `LogMessage`, `LogTimestamp`

> The schema supports one-to-many relation between Users and Log.

---

## 🔐 Security Features

- Passwords hashed with `SHA2-512` and unique salt using `HASHBYTES()`
- Account lockout after 3 failed attempts within 15 minutes
- Tokens for email verification and password reset (24h expiration)

---

## 🛠 Stored Procedures

### `GetTryLogin`
Handles login attempts, checks lock status, hashes password, logs results.

### `GetForgotPassword`
Generates a token for password reset, checks for existing valid token.

### `GetSetForgottenPassword`
Validates token and updates password with a new hash and salt.

---

## 📊 Views

- `UsersLogInformation`: Shows latest login attempts (success/failure) per user
- `UserLoginDetails`: Analyzes login behavior per IP address using window functions

---

## 🧪 Performance & Optimization

- Added **non-clustered indexes** on:
  - `Email` (Users)
  - `IPAddress` (Log)
- Execution time improved from 106 ms to 92 ms
- Physical reads dropped to 0 on both tables

---

## 📈 Future Improvements

- Add email verification step via stored procedure
- Auto-unlock after 30 minutes instead of requiring admin
- Enhanced audit trail and role-based access logic

---

## 🖼 ER Diagram

Available in `diagrams/database-model.dawio` (Draw.io format)

---

## 📫 Contact

- 👩‍💻 Author: Phatsorn Vik  
- 📧 Email: your.email@example.com  
- 💼 LinkedIn: [linkedin.com/in/yourprofile](https://www.linkedin.com/in/yourprofile)

---

Thank you for checking out this project!
