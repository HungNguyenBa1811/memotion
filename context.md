{
  "api_spec": {
    "name": "Get Task Detail",
    "description": "Retrieve detailed information for a specific task. This API provides comprehensive details about a task including instructions, completion status, associated patient information, and any additional notes.",
    "method": "GET",
    "endpoint": "/api/tasks/{task_id}",
    "authorization": "Authenticated user required (task owner or assigned caretaker)."
  },
  "process_flow": [
    "Validates user access to the specified task",
    "Retrieves detailed task information from database"
  ],
  "parameters": [
    {
      "name": "task_id",
      "in": "path",
      "required": true,
      "type": "string",
      "description": "Unique identifier of the task"
    }
  ],
  "responses": {
    "200": {
      "description": "Successful Response: Complete task details with all associated information.",
      "media_type": "application/json",
      "example": {
        "code": "200",
        "message": "",
        "data": {
          "title": "string",
          "description": "string",
          "task_duedate": "2026-01-24T18:01:21.724Z",
          "task_type": "string",
          "status": "string",
          "owner_type": "string",
          "task_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "care_plan_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "medication_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "nutrition_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "exercise_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "linked_task_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "medication_detail": {
            "medication_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "name": "string",
            "description": "string",
            "dosage": "string",
            "frequency_per_day": 0,
            "notes": "string",
            "image_path": "string"
          },
          "nutrition_detail": {
            "nutrition_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "name": "string",
            "calories": 0,
            "description": "string",
            "meal_type": "string",
            "image_path": "string"
          },
          "exercise_detail": {
            "exercise_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "name": "string",
            "target_body_region": "string",
            "description": "string",
            "duration_minutes": 0,
            "difficulty_level": 0,
            "video_path": "string"
          }
        }
      }
    },
    "422": {
      "description": "Validation Error",
      "media_type": "application/json",
      "example": {
        "detail": [
          {
            "loc": [
              "string",
              0
            ],
            "msg": "string",
            "type": "string"
          }
        ]
      }
    }
  }
}