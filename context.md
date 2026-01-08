Act as a Senior Flutter Developer. 

I need you to implement the **Authentication Data Layer** using **Dio** for networking and **json_serializable/freezed** for data models.

Please implement the following:
1.  **Data Transfer Objects (DTOs)**: Request and Response models.
2.  **AuthRepository**: A class containing methods for Login and Register.
3.  **Error Handling**: Handle generic server responses and standard HTTP errors.

### General Response Structure
The API wraps all successful data in a generic structure:
```json
{
  "code": "string", // e.g., "200"
  "message": "string",
  "data": <Generic_Object>
}
API Specifications
1. Login
Endpoint: POST /api/auth/login

Request Body:

JSON

{
  "username": "long.dh@teko.vn",
  "password": "secret123"
}
Success Response (200 OK):

JSON

{
  "code": "200",
  "message": "",
  "data": {
    "access_token": "string",
    "token_type": "bearer"
  }
}
2. Register
Endpoint: POST /api/auth/register

Request Body:

JSON

{
  "full_name": "string",
  "email": "user@example.com",
  "password": "string",
  "phone": "string",
  "role": "PATIENT",
  "patient_full_name": "string",
  "patient_email": "user@example.com",
  "patient_phone": "string"
}
Success Response (200 OK):

JSON

{
  "code": "200",
  "message": "",
  "data": {
    "full_name": "string",
    "email": "user@example.com",
    "is_active": true,
    "user_id": "uuid-string",
    "phone": "string",
    "role": "string",
    "patient": {
      "user_id": "uuid-string",
      "full_name": "string",
      "email": "user@example.com",
      "phone": "string"
    }
  }
}
3. Error Response (Example for 422 Validation Error)
Structure:

JSON

{
  "detail": [
    {
      "loc": ["string", 0],
      "msg": "string",
      "type": "string"
    }
  ]
}
Requirements:
Use dio for API calls.

Use json_annotation for parsing.

Create a BaseResponse<T> class to handle the wrapper.

Ensure types are nullable where appropriate.